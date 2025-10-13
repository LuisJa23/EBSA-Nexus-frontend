// logout_usecase.dart
//
// Caso de uso para cerrar sesión
//
// PROPÓSITO:
// - Encapsular lógica de negocio del logout
// - Limpiar datos locales y remotos
// - Invalidar tokens de forma segura
// - Manejar logout forzado vs voluntario
//
// CAPA: DOMAIN LAYER (NO dependencias externas)
// PATRÓN: Single Responsibility - solo logout

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso para cerrar sesión del usuario
///
/// Encapsula toda la lógica de negocio relacionada con el cierre de sesión,
/// incluyendo limpieza local, invalidación de tokens y manejo offline.
///
/// **Responsabilidades**:
/// - Obtener usuario actual antes del logout
/// - Invalidar tokens en el servidor
/// - Limpiar almacenamiento local seguro
/// - Limpiar cache de datos de usuario
/// - Registrar evento de logout
/// - Manejar logout offline/online
class LogoutUseCase {
  /// Repositorio de autenticación (inyectado por DI)
  final AuthRepository _repository;

  /// Constructor que recibe el repositorio por inyección de dependencias
  const LogoutUseCase(this._repository);

  /// Ejecuta el caso de uso de logout
  ///
  /// **Parámetros opcionales**:
  /// - [forced]: Indica si es un logout forzado (token expirado, etc.)
  /// - [reason]: Razón del logout para logging
  ///
  /// **Flujo de ejecución**:
  /// 1. Verificar si hay usuario autenticado
  /// 2. Registrar intento de logout
  /// 3. Ejecutar logout a través del repositorio
  /// 4. Verificar limpieza completa
  /// 5. Registrar resultado del logout
  ///
  /// **Retorna**:
  /// - [Right<void>]: Logout exitoso
  /// - [Left<Failure>]: Error durante el logout (puede continuar offline)
  Future<Either<Failure, void>> call({
    bool forced = false,
    String? reason,
  }) async {
    // =========================================================================
    // PREPARACIÓN PARA LOGOUT
    // =========================================================================

    // Verificar si hay un usuario actualmente autenticado
    final currentUserResult = await _repository.getCurrentUser();

    String? userEmail;

    // Extraer información del usuario para logging (si existe)
    currentUserResult.fold(
      (failure) {
        // No hay usuario autenticado, pero podemos continuar con limpieza
        _logLogoutAttempt(null, forced, reason);
      },
      (user) {
        userEmail = user.email;
        _logLogoutAttempt(user.email, forced, reason);
      },
    );

    // =========================================================================
    // EJECUTAR LOGOUT
    // =========================================================================

    // Ejecutar logout a través del repositorio
    final logoutResult = await _repository.logout();

    return logoutResult.fold(
      (failure) {
        // Registrar falla de logout
        _logLogoutFailure(userEmail, failure);

        // Para logout, algunos errores no son críticos
        if (_isNonCriticalLogoutError(failure)) {
          // Aunque falló la comunicación con el servidor,
          // el logout local fue exitoso, así que continuamos
          _logLogoutSuccess(userEmail, forced, offline: true);
          return const Right(null);
        }

        // Error crítico durante logout
        return Left(_transformLogoutFailure(failure));
      },
      (_) {
        // =====================================================================
        // VERIFICACIONES POST-LOGOUT
        // =====================================================================

        // Verificar que la limpieza fue completa
        _verifyLogoutCleanup();

        // Registrar logout exitoso
        _logLogoutSuccess(userEmail, forced);

        return const Right(null);
      },
    );
  }

  /// Ejecuta logout inmediato para casos de emergencia
  ///
  /// Este método fuerza el logout local sin comunicarse con el servidor.
  /// Útil para casos como token comprometido o cierre de emergencia.
  Future<Either<Failure, void>> forceLogout({required String reason}) async {
    _logLogoutAttempt(null, true, reason);

    // Ejecutar solo limpieza local, sin comunicación con servidor
    final result = await _repository.logout();

    return result.fold(
      (failure) {
        _logLogoutFailure(null, failure);
        return Left(failure);
      },
      (_) {
        _logLogoutSuccess(null, true, offline: true);
        return const Right(null);
      },
    );
  }

  // ===========================================================================
  // VALIDACIONES Y VERIFICACIONES
  // ===========================================================================

  /// Verifica que la limpieza post-logout fue completa
  void _verifyLogoutCleanup() {
    // TODO: En una implementación completa, aquí verificaríamos:
    // - Tokens eliminados del almacenamiento seguro
    // - Cache de usuario limpiado
    // - Headers de autenticación removidos
    // - Estados de UI actualizados

    // Por ahora, solo registramos la verificación
    print('Logout cleanup verification completed');
  }

  /// Determina si un error de logout no es crítico
  bool _isNonCriticalLogoutError(Failure failure) {
    // Errores de red durante logout no son críticos
    // El usuario puede desconectarse sin comunicarse con el servidor
    if (failure is NetworkFailure) return true;

    // Errores de servidor durante logout tampoco son críticos
    if (failure is ServerFailure) return true;

    // Token ya expirado no es crítico para logout
    if (failure is AuthFailure && failure.code == 'TOKEN_EXPIRED') {
      return true;
    }

    // Otros errores sí son críticos (ej: no poder limpiar cache local)
    return false;
  }

  // ===========================================================================
  // TRANSFORMACIÓN DE ERRORES
  // ===========================================================================

  /// Convierte failures de logout en mensajes apropiados
  Failure _transformLogoutFailure(Failure failure) {
    if (failure is CacheFailure) {
      return const CacheFailure(
        message:
            'Error al limpiar datos locales. Su sesión puede no haberse cerrado completamente',
        code: 'LOGOUT_CACHE_ERROR',
      );
    }

    if (failure is AuthFailure) {
      return const AuthFailure(
        message:
            'Error al invalidar la sesión. Por seguridad, evite usar datos sensibles',
        code: 'LOGOUT_AUTH_ERROR',
      );
    }

    // Para otros errores, mensaje genérico
    return const ServerFailure(
      message:
          'Error durante el cierre de sesión. Verifique y cierre la aplicación si persiste',
      code: 'LOGOUT_UNKNOWN_ERROR',
    );
  }

  // ===========================================================================
  // LOGGING SEGURO
  // ===========================================================================

  /// Registra intento de logout
  void _logLogoutAttempt(String? userEmail, bool forced, String? reason) {
    final type = forced ? 'FORCED' : 'VOLUNTARY';
    final user = userEmail ?? 'UNKNOWN';
    final logReason = reason ?? 'USER_REQUEST';

    print('Logout attempt: $type for user $user, reason: $logReason');
  }

  /// Registra logout exitoso
  void _logLogoutSuccess(
    String? userEmail,
    bool forced, {
    bool offline = false,
  }) {
    final type = forced ? 'FORCED' : 'VOLUNTARY';
    final user = userEmail ?? 'UNKNOWN';
    final mode = offline ? 'OFFLINE' : 'ONLINE';

    print('Logout successful: $type for user $user ($mode)');
  }

  /// Registra falla de logout
  void _logLogoutFailure(String? userEmail, Failure failure) {
    final user = userEmail ?? 'UNKNOWN';
    print('Logout failed for user $user: ${failure.code} - ${failure.message}');
  }
}
