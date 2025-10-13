// get_current_user_usecase.dart
//
// Caso de uso para obtener usuario actual
//
// PROPÓSITO:
// - Obtener datos del usuario autenticado
// - Verificar validez de la sesión actual
// - Manejar refresh automático de tokens
// - Determinar si el usuario está logueado
//
// CAPA: DOMAIN LAYER (NO dependencias externas)
// PATRÓN: Single Responsibility - solo obtener usuario actual

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso para obtener el usuario actualmente autenticado
///
/// Encapsula la lógica de negocio para recuperar y validar
/// el estado del usuario actual, incluyendo manejo de tokens
/// y refresh automático cuando sea necesario.
///
/// **Responsabilidades**:
/// - Verificar existencia de sesión activa
/// - Validar vigencia de tokens
/// - Ejecutar refresh automático si es necesario
/// - Retornar usuario actualizado o falla específica
/// - Optimizar accesos repetitivos con cache inteligente
class GetCurrentUserUseCase {
  /// Repositorio de autenticación (inyectado por DI)
  final AuthRepository _repository;

  /// Constructor que recibe el repositorio por inyección de dependencias
  const GetCurrentUserUseCase(this._repository);

  /// Ejecuta el caso de uso para obtener usuario actual
  ///
  /// **Parámetros opcionales**:
  /// - [forceRefresh]: Fuerza obtener datos frescos del servidor
  /// - [includePermissions]: Incluye permisos detallados del usuario
  ///
  /// **Flujo de ejecución**:
  /// 1. Verificar si hay sesión activa localmente
  /// 2. Validar vigencia del token actual
  /// 3. Ejecutar refresh automático si es necesario
  /// 4. Obtener datos de usuario actualizados
  /// 5. Validar permisos y estado del usuario
  /// 6. Retornar usuario o falla específica
  ///
  /// **Retorna**:
  /// - [Right<User>]: Usuario autenticado válido
  /// - [Left<Failure>]: No hay usuario o sesión inválida
  Future<Either<Failure, User>> call({
    bool forceRefresh = false,
    bool includePermissions = true,
  }) async {
    // =========================================================================
    // VERIFICACIÓN PREVIA DE AUTENTICACIÓN
    // =========================================================================

    // Verificar rápidamente si hay usuario autenticado
    if (!forceRefresh) {
      final isLoggedResult = await _repository.isUserLoggedIn();

      final isUserLoggedIn = isLoggedResult.fold(
        (failure) => false, // Error al verificar = no autenticado
        (isLogged) => isLogged,
      );

      if (!isUserLoggedIn) {
        _logUserAccess(null, success: false, reason: 'NO_SESSION');
        return const Left(
          AuthFailure(
            message: 'No hay usuario autenticado',
            code: 'USER_NOT_AUTHENTICATED',
          ),
        );
      }
    }

    // =========================================================================
    // VERIFICACIÓN DE VALIDEZ DEL TOKEN
    // =========================================================================

    // Verificar si el token actual es válido
    final tokenValidResult = await _repository.isTokenValid();

    bool needsRefresh = false;

    tokenValidResult.fold(
      (failure) {
        // Error al validar token - necesitamos refresh
        needsRefresh = true;
      },
      (isValid) {
        // Token inválido o por expirar - necesitamos refresh
        if (!isValid) {
          needsRefresh = true;
        }
      },
    );

    // =========================================================================
    // REFRESH AUTOMÁTICO SI ES NECESARIO
    // =========================================================================

    if (needsRefresh || forceRefresh) {
      _logTokenRefresh();

      final refreshResult = await _repository.refreshToken();

      // Si el refresh falla, la sesión está realmente expirada
      final refreshSuccess = refreshResult.fold(
        (failure) {
          _logUserAccess(null, success: false, reason: 'REFRESH_FAILED');
          return false;
        },
        (refreshedUser) {
          _logTokenRefreshSuccess(refreshedUser.email);
          return true;
        },
      );

      if (!refreshSuccess) {
        return const Left(
          AuthFailure(
            message: 'Sesión expirada. Por favor inicie sesión nuevamente',
            code: 'SESSION_EXPIRED',
          ),
        );
      }
    }

    // =========================================================================
    // OBTENER DATOS DE USUARIO ACTUAL
    // =========================================================================

    final currentUserResult = await _repository.getCurrentUser();

    return currentUserResult.fold(
      (failure) {
        _logUserAccess(null, success: false, reason: failure.code);
        return Left(_transformGetUserFailure(failure));
      },
      (user) {
        // =====================================================================
        // VALIDACIONES POST-OBTENCIÓN
        // =====================================================================

        // Verificar que el usuario esté activo
        if (!user.isActive) {
          _logUserAccess(user.email, success: false, reason: 'USER_INACTIVE');
          return const Left(
            AuthFailure(
              message:
                  'Su cuenta ha sido desactivada. Contacte al administrador',
              code: 'USER_ACCOUNT_INACTIVE',
            ),
          );
        }

        // Verificar permisos si se solicita
        if (includePermissions) {
          final permissionsValid = _validateUserPermissions(user);
          if (!permissionsValid) {
            _logUserAccess(
              user.email,
              success: false,
              reason: 'INVALID_PERMISSIONS',
            );
            return const Left(
              AuthFailure(
                message: 'Su cuenta no tiene los permisos necesarios',
                code: 'INSUFFICIENT_PERMISSIONS',
              ),
            );
          }
        }

        // Usuario válido y listo para usar
        _logUserAccess(user.email, success: true);
        return Right(user);
      },
    );
  }

  /// Obtiene usuario de forma rápida sin validaciones adicionales
  ///
  /// Útil para verificaciones rápidas de UI sin impacto en performance
  Future<Either<Failure, User>> quickCheck() async {
    return _repository.getCurrentUser();
  }

  /// Verifica si hay un usuario autenticado (sin obtener datos completos)
  ///
  /// Método optimizado para navegación inicial y checks de autenticación
  Future<bool> isAuthenticated() async {
    final result = await _repository.isUserLoggedIn();
    return result.fold((failure) => false, (isLogged) => isLogged);
  }

  // ===========================================================================
  // VALIDACIONES DE NEGOCIO
  // ===========================================================================

  /// Valida que el usuario tiene permisos válidos para usar la app
  bool _validateUserPermissions(User user) {
    // Verificar que el usuario tiene al menos un rol válido
    if (user.role == UserRole.fieldWorker ||
        user.role == UserRole.contractor ||
        user.role == UserRole.areaManager ||
        user.role == UserRole.admin) {
      return true;
    }

    // Rol no reconocido o inválido
    return false;
  }

  // ===========================================================================
  // TRANSFORMACIÓN DE ERRORES
  // ===========================================================================

  /// Convierte failures de obtención de usuario en mensajes apropiados
  Failure _transformGetUserFailure(Failure failure) {
    if (failure is AuthFailure) {
      switch (failure.code) {
        case 'TOKEN_EXPIRED':
          return const AuthFailure(
            message: 'Su sesión ha expirado. Inicie sesión nuevamente',
            code: 'GET_USER_SESSION_EXPIRED',
          );
        case 'USER_NOT_FOUND':
          return const AuthFailure(
            message: 'Usuario no encontrado. Inicie sesión nuevamente',
            code: 'GET_USER_NOT_FOUND',
          );
        default:
          return const AuthFailure(
            message: 'Error de autenticación. Inicie sesión nuevamente',
            code: 'GET_USER_AUTH_ERROR',
          );
      }
    }

    if (failure is NetworkFailure) {
      return const NetworkFailure(
        message: 'Sin conexión. Usando datos locales disponibles',
        code: 'GET_USER_OFFLINE',
      );
    }

    if (failure is CacheFailure) {
      return const CacheFailure(
        message: 'Error al acceder a datos locales. Inicie sesión nuevamente',
        code: 'GET_USER_CACHE_ERROR',
      );
    }

    // Error genérico
    return const ServerFailure(
      message: 'Error al obtener información de usuario',
      code: 'GET_USER_UNKNOWN_ERROR',
    );
  }

  // ===========================================================================
  // LOGGING Y MONITOREO
  // ===========================================================================

  /// Registra acceso a datos de usuario
  void _logUserAccess(
    String? userEmail, {
    required bool success,
    String? reason,
  }) {
    final user = userEmail ?? 'UNKNOWN';
    final status = success ? 'SUCCESS' : 'FAILED';
    final logReason = reason != null ? ' - $reason' : '';

    print('Get current user: $status for $user$logReason');
  }

  /// Registra intento de refresh de token
  void _logTokenRefresh() {
    print('Token refresh attempt initiated');
  }

  /// Registra refresh exitoso de token
  void _logTokenRefreshSuccess(String userEmail) {
    print('Token refresh successful for user: $userEmail');
  }
}
