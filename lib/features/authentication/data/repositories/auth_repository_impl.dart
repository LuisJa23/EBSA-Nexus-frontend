// auth_repository_impl.dart
//
// Implementación del repositorio de autenticación
//
// PROPÓSITO:
// - Implementar AuthRepository del dominio
// - Coordinar entre remote y local data sources
// - Manejo de errores y conversión a Failures
// - Lógica offline-first para autenticación
//
// CAPA: DATA LAYER
// IMPLEMENTA: AuthRepository (domain interface)

import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/credentials.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/credentials_model.dart';
import '../models/user_model.dart';

/// Implementación concreta del repositorio de autenticación
///
/// Coordina entre fuentes de datos remotas y locales siguiendo
/// una estrategia offline-first. Convierte exceptions técnicas
/// en failures de dominio y maneja el cache inteligente.
///
/// **Estrategia Offline-First**:
/// - Intentar operación remota primero
/// - En caso de error de red, usar datos locales
/// - Cachear datos exitosos automáticamente
/// - Sincronizar en segundo plano cuando sea posible
class AuthRepositoryImpl implements AuthRepository {
  /// Fuente de datos remota (API)
  final AuthRemoteDataSource _remoteDataSource;

  /// Fuente de datos local (Cache/Storage)
  final AuthLocalDataSource _localDataSource;

  /// Detector de conectividad de red
  final NetworkInfo _networkInfo;

  /// Stream controller para estado de autenticación
  final StreamController<User?> _authStateController =
      StreamController<User?>.broadcast();

  /// Stream controller para estado de conectividad
  final StreamController<bool> _connectivityController =
      StreamController<bool>.broadcast();

  /// Constructor que recibe las dependencias inyectadas
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _networkInfo = networkInfo {
    // Inicializar monitoreo de conectividad
    _initConnectivityMonitoring();
  }

  // ============================================================================
  // OPERACIONES DE AUTENTICACIÓN PRINCIPAL
  // ============================================================================

  @override
  Future<Either<Failure, User>> login(Credentials credentials) async {
    try {
      // Convertir entidad del dominio a modelo de datos
      final credentialsModel = CredentialsModel.fromEntity(credentials);

      // Verificar conectividad de red
      final isConnected = await _networkInfo.isConnected;

      if (!isConnected) {
        // Sin conexión - intentar login offline si es posible
        return _attemptOfflineLogin(credentialsModel);
      }

      // Con conexión - intentar login remoto
      final remoteResult = await _attemptRemoteLogin(credentialsModel);

      return remoteResult.fold(
        (failure) async {
          // Login remoto falló - intentar offline como fallback
          final offlineResult = await _attemptOfflineLogin(credentialsModel);

          return offlineResult.fold(
            (offlineFailure) => Left(failure), // Retornar error remoto original
            (user) => Right(user), // Login offline exitoso
          );
        },
        (user) async {
          // Login remoto exitoso - cachear y emitir estado
          final userModel = UserModel.fromEntity(user);
          await _cacheSuccessfulLogin(userModel, credentialsModel);
          _authStateController.add(user);
          return Right(user);
        },
      );
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Obtener usuario actual para logging (opcional)
      final userResult = await getCurrentUser();
      userResult.fold(
        (failure) => null, // Error obteniendo usuario - continuar logout
        (user) => print('Logging out user: ${user.email}'), // Log opcional
      );

      // Intentar logout remoto si hay conexión
      final isConnected = await _networkInfo.isConnected;

      if (isConnected) {
        final token = await _localDataSource.getAccessToken();
        if (token != null) {
          try {
            await _remoteDataSource.logout(token);
          } catch (e) {
            // Error remoto no es crítico para logout
            print('Error en logout remoto: $e');
          }
        }
      }

      // Limpiar datos locales (siempre)
      await _localDataSource.clearAuthData();

      // Emitir cambio de estado
      _authStateController.add(null);

      return const Right(null);
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  // ============================================================================
  // GESTIÓN DE ESTADO DE AUTENTICACIÓN
  // ============================================================================

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      // Primero intentar obtener desde cache local
      final cachedUser = await _localDataSource.getCachedUser();

      if (cachedUser != null) {
        // Verificar si necesitamos actualizar datos
        final shouldRefresh = await _shouldRefreshUserData();

        if (!shouldRefresh) {
          return Right(cachedUser.toEntity());
        }
      }

      // Intentar obtener datos actualizados si hay conexión
      final isConnected = await _networkInfo.isConnected;

      if (isConnected) {
        final token = await _localDataSource.getAccessToken();

        if (token != null) {
          try {
            final remoteUser = await _remoteDataSource.getCurrentUser(token);

            // Actualizar cache con datos frescos
            await _localDataSource.saveUser(remoteUser);

            return Right(remoteUser.toEntity());
          } on AuthenticationException {
            // Token inválido - intentar refresh
            final refreshResult = await refreshToken();
            return refreshResult.fold((failure) {
              // Refresh falló - usar cache si está disponible
              if (cachedUser != null) {
                return Right(cachedUser.toEntity());
              }
              return Left(failure);
            }, (user) => Right(user));
          }
        }
      }

      // Fallback a cache local si está disponible
      if (cachedUser != null) {
        return Right(cachedUser.toEntity());
      }

      // No hay usuario disponible
      return const Left(
        AuthFailure(
          message: 'No hay usuario autenticado',
          code: 'USER_NOT_AUTHENTICATED',
        ),
      );
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, bool>> isUserLoggedIn() async {
    try {
      // Verificar token local primero (rápido)
      final hasValidToken = await _localDataSource.hasValidToken();

      if (!hasValidToken) {
        return const Right(false);
      }

      // Verificar que hay datos de usuario
      final cachedUser = await _localDataSource.getCachedUser();

      return Right(cachedUser != null);
    } catch (e) {
      return const Right(false); // En caso de error, asumir no autenticado
    }
  }

  // ============================================================================
  // GESTIÓN DE TOKENS
  // ============================================================================

  @override
  Future<Either<Failure, User>> refreshToken() async {
    try {
      final isConnected = await _networkInfo.isConnected;

      if (!isConnected) {
        return const Left(
          NetworkFailure(
            message: 'Sin conexión para renovar token',
            code: 'NO_CONNECTION_REFRESH',
          ),
        );
      }

      final refreshToken = await _localDataSource.getRefreshToken();

      if (refreshToken == null) {
        return const Left(
          AuthFailure(
            message: 'No hay refresh token disponible',
            code: 'NO_REFRESH_TOKEN',
          ),
        );
      }

      final refreshedUser = await _remoteDataSource.refreshToken(refreshToken);

      // Actualizar cache con usuario renovado
      await _localDataSource.saveUser(refreshedUser);

      // Emitir cambio de estado
      _authStateController.add(refreshedUser.toEntity());

      return Right(refreshedUser.toEntity());
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, bool>> isTokenValid() async {
    try {
      // SOLO validación local del JWT - NO llamar al servidor
      // El token se valida únicamente por su expiración
      final hasValidToken = await _localDataSource.hasValidToken();
      return Right(hasValidToken);
    } catch (e) {
      return const Right(false);
    }
  }

  // ============================================================================
  // STREAMS REACTIVOS
  // ============================================================================

  @override
  Stream<User?> get authStateStream => _authStateController.stream;

  @override
  Stream<bool> get connectivityStream => _connectivityController.stream;

  // ============================================================================
  // OPERACIONES DE PERFIL
  // ============================================================================

  @override
  Future<Either<Failure, User>> getUserProfile() async {
    try {
      // Verificar conectividad
      final isConnected = await _networkInfo.isConnected;
      if (!isConnected) {
        // Sin conexión - retornar usuario desde cache
        print('⚠️ Sin conexión, obteniendo perfil desde cache...');
        final cachedUser = await _localDataSource.getCachedUser();
        if (cachedUser == null) {
          return const Left(
            CacheFailure(message: 'No hay datos de perfil en cache'),
          );
        }
        return Right(cachedUser);
      }

      // Obtener token actual
      final token = await _localDataSource.getAccessToken();
      if (token == null || token.isEmpty) {
        return const Left(
          TokenExpiredFailure(
            message: 'Sesión expirada, inicie sesión nuevamente',
          ),
        );
      }

      print('🔄 Obteniendo perfil completo desde servidor...');

      // Obtener perfil completo desde el servidor
      final userProfile = await _remoteDataSource.getUserProfile(token);

      // Guardar en cache local
      await _localDataSource.saveUser(userProfile);

      // Actualizar stream de autenticación
      _authStateController.add(userProfile);

      print('✅ Perfil cargado exitosamente desde servidor');
      print('📋 Datos: ${userProfile.firstName} ${userProfile.lastName}');
      print('📞 Teléfono: ${userProfile.phoneNumber}');
      print('🆔 Documento: ${userProfile.documentNumber}');

      return Right(userProfile);
    } on AuthenticationException catch (e) {
      print('❌ Error de autenticación: ${e.message}');
      return Left(AuthFailure(message: e.message, code: e.code));
    } on ServerException catch (e) {
      print('❌ Error de servidor: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      print('❌ Error de red: ${e.message}');
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      print('❌ Error inesperado en getUserProfile: $e');
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, User>> updateUserProfile({
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    try {
      // Verificar conectividad
      final isConnected = await _networkInfo.isConnected;
      if (!isConnected) {
        return const Left(
          NetworkFailure(
            message: 'No se puede actualizar el perfil sin conexión a internet',
          ),
        );
      }

      // Obtener token actual
      final token = await _localDataSource.getAccessToken();
      if (token == null || token.isEmpty) {
        return const Left(
          TokenExpiredFailure(
            message: 'Sesión expirada, inicie sesión nuevamente',
          ),
        );
      }

      // Actualizar en el servidor
      final updatedUser = await _remoteDataSource.updateUserProfile(
        token: token,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
      );

      // Guardar en cache local
      await _localDataSource.saveUser(updatedUser);

      // Actualizar stream de autenticación
      _authStateController.add(updatedUser);

      print('✅ Perfil actualizado exitosamente en repositorio');

      return Right(updatedUser);
    } on AuthenticationException catch (e) {
      print('❌ Error de autenticación: ${e.message}');
      return Left(AuthFailure(message: e.message, code: e.code));
    } on ValidationException catch (e) {
      print('❌ Error de validación: ${e.message}');
      return Left(ValidationFailure(message: e.message, field: e.field));
    } on ServerException catch (e) {
      print('❌ Error de servidor: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      print('❌ Error de red: ${e.message}');
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      print('❌ Error inesperado en repositorio: $e');
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      // TODO: Implementar cambio de contraseña
      return const Left(
        ServerFailure(
          message: 'Cambio de contraseña no implementado aún',
          code: 'NOT_IMPLEMENTED',
        ),
      );
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  // ============================================================================
  // MÉTODOS PRIVADOS DE IMPLEMENTACIÓN
  // ============================================================================

  /// Intenta login remoto con la API
  Future<Either<Failure, User>> _attemptRemoteLogin(
    CredentialsModel credentials,
  ) async {
    try {
      print('🔍 Repository: Intentando login remoto para ${credentials.email}');
      final userModel = await _remoteDataSource.login(credentials);
      print('✅ Repository: Login remoto exitoso para ${credentials.email}');

      // IMPORTANTE: Extraer y guardar el token del usuario
      // El token viene dentro del UserModel o debe ser obtenido del response
      // Por ahora, verificamos si hay token en el storage después del login

      return Right(userModel.toEntity());
    } catch (e) {
      print('❌ Repository: Error en login remoto: $e');
      final failure = _mapExceptionToFailure(e);
      print(
        '❌ Repository: Failure mapeado: ${failure.message} (${failure.code})',
      );
      return Left(failure);
    }
  }

  /// Intenta login offline con datos locales
  Future<Either<Failure, User>> _attemptOfflineLogin(
    CredentialsModel credentials,
  ) async {
    try {
      // Verificar si hay usuario recordado para este email
      final rememberedEmail = await _localDataSource.getRememberedEmail();

      if (rememberedEmail == null || rememberedEmail != credentials.email) {
        return const Left(
          AuthFailure(
            message: 'Sin datos de login offline para este usuario',
            code: 'NO_OFFLINE_LOGIN_DATA',
          ),
        );
      }

      // Verificar si debe recordar sesión
      final rememberMe = await _localDataSource.getRememberMe();

      if (!rememberMe) {
        return const Left(
          AuthFailure(
            message: 'Login offline no permitido - sesión no recordada',
            code: 'OFFLINE_LOGIN_NOT_ALLOWED',
          ),
        );
      }

      // Obtener usuario desde cache
      final cachedUser = await _localDataSource.getCachedUser();

      if (cachedUser == null) {
        return const Left(
          AuthFailure(
            message: 'No hay datos de usuario en cache',
            code: 'NO_CACHED_USER_DATA',
          ),
        );
      }

      return Right(cachedUser.toEntity());
    } catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  /// Cachea datos de login exitoso
  Future<void> _cacheSuccessfulLogin(
    UserModel user,
    CredentialsModel credentials,
  ) async {
    // Guardar usuario en cache
    await _localDataSource.saveUser(user);

    // Guardar preferencias si el usuario eligió recordar
    if (credentials.rememberMe) {
      await _localDataSource.saveRememberedEmail(credentials.email);
      await _localDataSource.saveRememberMe(true);
    }

    // Actualizar timestamp de último login
    await _localDataSource.updateLastLogin();
  }

  /// Verifica si se deben actualizar los datos del usuario
  Future<bool> _shouldRefreshUserData() async {
    // TODO: Implementar lógica más sofisticada
    // Por ahora, siempre intentar refresh si hay conexión
    return _networkInfo.isConnected;
  }

  /// Convierte exceptions técnicas en failures de dominio
  Failure _mapExceptionToFailure(dynamic exception) {
    if (exception is AuthenticationException) {
      return AuthFailure(message: exception.message, code: exception.code);
    }

    if (exception is NetworkException) {
      return NetworkFailure(message: exception.message, code: exception.code);
    }

    if (exception is ServerException) {
      return ServerFailure(message: exception.message, code: exception.code);
    }

    if (exception is CacheException) {
      return CacheFailure(message: exception.message, code: exception.code);
    }

    // Exception genérica
    return ServerFailure(
      message: 'Error inesperado: $exception',
      code: 'UNKNOWN_ERROR',
    );
  }

  /// Inicializa el monitoreo de conectividad
  void _initConnectivityMonitoring() {
    // TODO: Implementar monitoreo de conectividad en tiempo real
    // Por ahora, emitir estado inicial
    _networkInfo.isConnected.then((isConnected) {
      _connectivityController.add(isConnected);
    });
  }

  /// Libera recursos del repositorio
  void dispose() {
    _authStateController.close();
    _connectivityController.close();
  }
}
