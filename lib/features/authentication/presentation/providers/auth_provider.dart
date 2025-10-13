// auth_provider.dart
//
// Provider de estado para autenticación
//
// PROPÓSITO:
// - Manejar estado global de autenticación
// - Coordinar entre UI y use cases
// - Notificar cambios de estado a widgets
// - Centralizar lógica de navegación auth
//
// CAPA: PRESENTATION LAYER
// DEPENDENCIAS: Riverpod/Provider, use cases del dominio

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';

import '../../../../config/dependency_injection/injection_container.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../domain/entities/credentials.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

/// Estados posibles de la autenticación
enum AuthStatus {
  /// Estado inicial - no se ha verificado la autenticación
  initial,

  /// Verificando estado de autenticación
  loading,

  /// Usuario autenticado correctamente
  authenticated,

  /// Usuario no autenticado
  unauthenticated,

  /// Error en proceso de autenticación
  error,
}

/// Estado de la autenticación
class AuthState extends Equatable {
  /// Estado actual de autenticación
  final AuthStatus status;

  /// Usuario actualmente autenticado (null si no hay sesión)
  final User? user;

  /// Mensaje de error si el estado es error
  final String? errorMessage;

  /// Código de error para manejo específico
  final String? errorCode;

  /// Indica si se debe recordar la sesión
  final bool rememberMe;

  /// Email recordado para próximo login
  final String? rememberedEmail;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.errorCode,
    this.rememberMe = false,
    this.rememberedEmail,
  });

  /// Crea una copia del estado con campos actualizados
  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
    String? errorCode,
    bool? rememberMe,
    String? rememberedEmail,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      errorCode: errorCode,
      rememberMe: rememberMe ?? this.rememberMe,
      rememberedEmail: rememberedEmail ?? this.rememberedEmail,
    );
  }

  /// Estado inicial
  factory AuthState.initial() => const AuthState();

  /// Estado de carga
  factory AuthState.loading() => const AuthState(status: AuthStatus.loading);

  /// Estado autenticado
  factory AuthState.authenticated(User user) =>
      AuthState(status: AuthStatus.authenticated, user: user);

  /// Estado no autenticado
  factory AuthState.unauthenticated({
    String? rememberedEmail,
    bool rememberMe = false,
  }) => AuthState(
    status: AuthStatus.unauthenticated,
    rememberedEmail: rememberedEmail,
    rememberMe: rememberMe,
  );

  /// Estado de error
  factory AuthState.error({
    required String message,
    String? code,
    String? rememberedEmail,
    bool rememberMe = false,
  }) => AuthState(
    status: AuthStatus.error,
    errorMessage: message,
    errorCode: code,
    rememberedEmail: rememberedEmail,
    rememberMe: rememberMe,
  );

  /// Getters de conveniencia
  bool get isInitial => status == AuthStatus.initial;
  bool get isLoading => status == AuthStatus.loading;
  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;
  bool get hasError => status == AuthStatus.error;

  @override
  List<Object?> get props => [
    status,
    user,
    errorMessage,
    errorCode,
    rememberMe,
    rememberedEmail,
  ];

  @override
  String toString() {
    return 'AuthState(status: $status, user: ${user?.email}, error: $errorMessage)';
  }
}

/// Notificador de estado de autenticación
class AuthNotifier extends StateNotifier<AuthState> {
  /// Use case para login
  final LoginUseCase _loginUseCase;

  /// Use case para logout
  final LogoutUseCase _logoutUseCase;

  /// Use case para obtener usuario actual
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  /// Constructor con inyección de dependencias
  AuthNotifier({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
  }) : _loginUseCase = loginUseCase,
       _logoutUseCase = logoutUseCase,
       _getCurrentUserUseCase = getCurrentUserUseCase,
       super(AuthState.initial()) {
    // Verificar estado de autenticación al inicializar
    _checkInitialAuthStatus();
  }

  // ============================================================================
  // MÉTODOS PÚBLICOS DE AUTENTICACIÓN
  // ============================================================================

  /// Realiza login con email y contraseña
  Future<void> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      print('🔍 AuthProvider: Iniciando login para $email');
      // Cambiar a estado de carga
      state = AuthState.loading();

      // Crear credenciales
      final credentials = Credentials.create(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );

      print('🔍 AuthProvider: Ejecutando use case de login');
      // Ejecutar login use case
      final result = await _loginUseCase.call(credentials);

      result.fold(
        (failure) {
          // Login falló
          print(
            '❌ AuthProvider: Login falló con failure: ${failure.message} (código: ${failure.code})',
          );
          state = AuthState.error(
            message: failure.message,
            code: failure.code,
            rememberedEmail: rememberMe ? email : null,
            rememberMe: rememberMe,
          );
          print(
            '❌ AuthProvider: Estado actualizado a error: ${state.errorMessage}',
          );
          // Limpiar el error automáticamente después de 5 segundos
          _clearErrorAfterDelay();
        },
        (user) async {
          // Login exitoso
          print('✅ AuthProvider: Login exitoso para: ${user.email}');

          // Guardar preferencias de "recordar sesión"
          try {
            final localDataSource = sl<AuthLocalDataSource>();
            await localDataSource.saveRememberMe(rememberMe);
            if (rememberMe) {
              await localDataSource.saveRememberedEmail(email);
            }
          } catch (e) {
            print('Error guardando preferencias: $e');
          }

          state = AuthState.authenticated(user).copyWith(
            rememberedEmail: rememberMe ? email : null,
            rememberMe: rememberMe,
          );
        },
      );
    } catch (e) {
      // Error inesperado
      print('❌ AuthProvider: Error inesperado: $e');
      state = AuthState.error(
        message: 'Error inesperado durante el login: $e',
        code: 'UNEXPECTED_ERROR',
      );
    }
  }

  /// Cierra sesión del usuario
  Future<void> logout() async {
    try {
      // Cambiar a estado de carga
      state = AuthState.loading();

      // Obtener datos para recordar (antes del logout)
      final currentRememberedEmail = state.rememberedEmail;
      final currentRememberMe = state.rememberMe;

      // Ejecutar logout use case
      final result = await _logoutUseCase.call();

      result.fold(
        (failure) {
          // Logout falló - pero continuar con limpieza local
          print('Error en logout: ${failure.message}');

          // Limpiar estado de autenticación de todos modos
          state = AuthState.unauthenticated(
            rememberedEmail: currentRememberedEmail,
            rememberMe: currentRememberMe,
          );
        },
        (_) {
          // Logout exitoso
          state = AuthState.unauthenticated(
            rememberedEmail: currentRememberedEmail,
            rememberMe: currentRememberMe,
          );
        },
      );
    } catch (e) {
      // Error inesperado - forzar limpieza
      print('Error inesperado en logout: $e');
      state = AuthState.unauthenticated();
    }
  }

  /// Verifica el estado de autenticación actual
  Future<void> checkAuthStatus() async {
    try {
      // Cambiar a estado de carga solo si no estamos ya autenticados
      if (!state.isAuthenticated) {
        state = AuthState.loading();
      }

      // Cargar preferencias de rememberMe y email recordado primero
      String? rememberedEmail;
      bool rememberMe = false;

      try {
        // Cargar desde local storage a través del data source
        // Estos datos se usan incluso si no hay sesión activa
        final localDataSource = sl<AuthLocalDataSource>();
        rememberedEmail = await localDataSource.getRememberedEmail();
        rememberMe = await localDataSource.getRememberMe();

        // Verificar rápidamente si hay un token válido
        final hasValidToken = await localDataSource.hasValidToken();

        if (!hasValidToken) {
          print('❌ No hay token válido - usuario no autenticado');
          state = AuthState.unauthenticated(
            rememberedEmail: rememberedEmail,
            rememberMe: rememberMe,
          );
          return;
        }

        print('✅ Token válido encontrado - verificando usuario');
      } catch (e) {
        print('Error cargando preferencias de rememberMe: $e');
      }

      // Verificar si hay usuario autenticado
      final result = await _getCurrentUserUseCase.call();

      result.fold(
        (failure) {
          // No hay usuario autenticado o hay error
          print('❌ Error obteniendo usuario actual: ${failure.message}');
          if (failure.code == 'USER_NOT_AUTHENTICATED' ||
              failure.code == 'SESSION_EXPIRED') {
            state = AuthState.unauthenticated(
              rememberedEmail: rememberedEmail,
              rememberMe: rememberMe,
            );
          } else {
            state = AuthState.error(
              message: failure.message,
              code: failure.code,
              rememberedEmail: rememberedEmail,
              rememberMe: rememberMe,
            );
          }
        },
        (user) {
          // Usuario autenticado
          print('✅ Usuario autenticado encontrado: ${user.email}');
          state = AuthState.authenticated(
            user,
          ).copyWith(rememberedEmail: rememberedEmail, rememberMe: rememberMe);
        },
      );
    } catch (e) {
      print('Error verificando estado de autenticación: $e');
      state = AuthState.error(
        message: 'Error verificando estado de autenticación: $e',
        code: 'CHECK_AUTH_ERROR',
      );
    }
  }

  /// Limpia el estado de error
  void clearError() {
    if (state.hasError) {
      print('🔍 AuthProvider: Limpiando error manualmente');
      state = AuthState.unauthenticated(
        rememberedEmail: state.rememberedEmail,
        rememberMe: state.rememberMe,
      );
    }
  }

  /// Limpia el error automáticamente después de un tiempo
  void _clearErrorAfterDelay() {
    Timer(const Duration(seconds: 15), () {
      if (state.hasError) {
        print(
          '🔍 AuthProvider: Limpiando error automáticamente después de 15 segundos',
        );
        clearError();
      }
    });
  }

  /// Actualiza las preferencias de recordar usuario
  void updateRememberPreferences({required bool rememberMe, String? email}) {
    state = state.copyWith(
      rememberMe: rememberMe,
      rememberedEmail: rememberMe ? (email ?? state.rememberedEmail) : null,
    );
  }

  // ============================================================================
  // MÉTODOS PRIVADOS
  // ============================================================================

  /// Verifica estado inicial de autenticación al cargar la app
  Future<void> _checkInitialAuthStatus() async {
    // Pequeña demora para evitar flickering de UI
    await Future.delayed(const Duration(milliseconds: 100));

    // Primero verificar si hay token almacenado localmente
    try {
      final localDataSource = sl<AuthLocalDataSource>();
      final hasValidToken = await localDataSource.hasValidToken();

      if (hasValidToken) {
        print('✅ Token válido encontrado en almacenamiento local');
        await checkAuthStatus();
      } else {
        print('❌ No hay token válido almacenado');
        // Cargar preferencias de usuario aunque no esté autenticado
        String? rememberedEmail;
        bool rememberMe = false;

        try {
          rememberedEmail = await localDataSource.getRememberedEmail();
          rememberMe = await localDataSource.getRememberMe();
        } catch (e) {
          print('Error cargando preferencias: $e');
        }

        state = AuthState.unauthenticated(
          rememberedEmail: rememberedEmail,
          rememberMe: rememberMe,
        );
      }
    } catch (e) {
      print('Error verificando estado inicial: $e');
      await checkAuthStatus();
    }
  }

  /// Refresca los datos del usuario actual
  Future<void> refreshUser() async {
    if (!state.isAuthenticated) return;

    try {
      final result = await _getCurrentUserUseCase.call(forceRefresh: true);

      result.fold(
        (failure) {
          // Error refrescando - mantener usuario actual pero mostrar error
          print('Error refrescando usuario: ${failure.message}');
        },
        (user) {
          // Usuario actualizado
          if (state.isAuthenticated) {
            state = AuthState.authenticated(user);
          }
        },
      );
    } catch (e) {
      print('Error inesperado refrescando usuario: $e');
    }
  }
}

// ============================================================================
// PROVIDERS GLOBALES
// ============================================================================

/// Provider para el notificador de autenticación
/// Provider del notificador de autenticación
///
/// Configurado con dependencias del service locator (get_it)
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  return AuthNotifier(
    loginUseCase: sl<LoginUseCase>(),
    logoutUseCase: sl<LogoutUseCase>(),
    getCurrentUserUseCase: sl<GetCurrentUserUseCase>(),
  );
});

/// Provider para acceso directo al estado de autenticación
final authStateProvider = Provider<AuthState>((ref) {
  return ref.watch(authNotifierProvider);
});

/// Provider para verificar si el usuario está autenticado
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.isAuthenticated;
});

/// Provider para obtener el usuario actual
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.user;
});

/// Provider para verificar si hay un error de autenticación
final authErrorProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.hasError ? authState.errorMessage : null;
});
