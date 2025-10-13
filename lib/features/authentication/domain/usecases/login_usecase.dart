// login_usecase.dart
//
// Caso de uso para iniciar sesión
//
// PROPÓSITO:
// - Encapsular lógica de negocio del login
// - Validar credenciales antes del repository
// - Manejar reglas específicas de autenticación
// - Un solo punto de entrada para login desde la UI
//
// CAPA: DOMAIN LAYER (NO dependencias externas)
// PATRÓN: Single Responsibility - solo login

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/credentials.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso para realizar login de usuario
///
/// Encapsula toda la lógica de negocio relacionada con el inicio de sesión,
/// incluyendo validaciones previas, límites de intentos y logging seguro.
///
/// **Responsabilidades**:
/// - Validar credenciales según reglas de negocio
/// - Controlar límites de intentos de login
/// - Invocar repositorio para autenticación
/// - Registrar intentos de login (sin contraseñas)
/// - Manejar casos especiales (cuentas bloqueadas, etc.)
class LoginUseCase {
  /// Repositorio de autenticación (inyectado por DI)
  final AuthRepository _repository;

  /// Constructor que recibe el repositorio por inyección de dependencias
  const LoginUseCase(this._repository);

  /// Ejecuta el caso de uso de login
  ///
  /// **Flujo de ejecución**:
  /// 1. Validar credenciales de dominio
  /// 2. Verificar límites de intentos previos
  /// 3. Ejecutar login a través del repositorio
  /// 4. Registrar resultado del intento
  /// 5. Retornar usuario autenticado o falla específica
  ///
  /// **Parámetros**:
  /// - [credentials]: Credenciales validadas del usuario
  ///
  /// **Retorna**:
  /// - [Right<User>]: Usuario autenticado exitosamente
  /// - [Left<Failure>]: Falla específica del login
  Future<Either<Failure, User>> call(Credentials credentials) async {
    // =========================================================================
    // VALIDACIONES PREVIAS DE DOMINIO
    // =========================================================================

    // Validar que las credenciales cumplan reglas de negocio
    if (!credentials.isValid) {
      return const Left(
        ValidationFailure(
          message: 'Las credenciales proporcionadas no son válidas',
          code: 'INVALID_CREDENTIALS_FORMAT',
        ),
      );
    }

    // Verificar si es un email corporativo para validaciones adicionales
    if (credentials.isEBSAEmail) {
      // Para emails corporativos, aplicar validaciones adicionales
      final domainValidation = _validateEBSADomain(credentials);
      if (domainValidation != null) {
        return Left(domainValidation);
      }
    }

    // Validar fortaleza de contraseña para nuevos usuarios
    if (credentials.passwordStrength == PasswordStrength.weak) {
      return const Left(
        ValidationFailure(
          message:
              'La contraseña es demasiado débil. Use al menos 8 caracteres con mayúsculas, minúsculas y números',
          code: 'WEAK_PASSWORD',
        ),
      );
    }

    // =========================================================================
    // VERIFICAR LÍMITES DE INTENTOS
    // =========================================================================

    // TODO: Implementar verificación de límites de intentos fallidos
    // En una implementación completa, aquí verificaríamos:
    // - Número de intentos fallidos recientes para esta cuenta
    // - Bloqueos temporales por seguridad
    // - Rate limiting por IP o dispositivo

    // =========================================================================
    // EJECUTAR LOGIN ATRAVÉS DEL REPOSITORIO
    // =========================================================================

    // Registrar intento de login (sin contraseña por seguridad)
    _logLoginAttempt(credentials);

    // Ejecutar login a través del repositorio
    final result = await _repository.login(credentials);

    // =========================================================================
    // PROCESAR RESULTADO
    // =========================================================================

    return result.fold(
      (failure) {
        // Registrar falla de login
        _logLoginFailure(credentials, failure);

        // Transformar failure técnica a mensaje de usuario
        return Left(_transformFailureToUserFriendly(failure));
      },
      (user) {
        // Registrar login exitoso
        _logLoginSuccess(user);

        // Verificar reglas post-login
        final postLoginValidation = _validatePostLogin(user);
        if (postLoginValidation != null) {
          return Left(postLoginValidation);
        }

        return Right(user);
      },
    );
  }

  // ===========================================================================
  // VALIDACIONES DE NEGOCIO
  // ===========================================================================

  /// Valida reglas específicas para emails corporativos EBSA
  ValidationFailure? _validateEBSADomain(Credentials credentials) {
    // Reglas específicas para empleados de EBSA
    if (credentials.emailDomain == 'ebsa.com.co') {
      // Validación de contraseña básica (solo longitud mínima)
      // La validación de fortaleza se desactivó para permitir flexibilidad
      if (credentials.password.length < 6) {
        return const ValidationFailure(
          message: 'La contraseña debe tener al menos 6 caracteres',
          code: 'PASSWORD_TOO_SHORT',
        );
      }
    }

    return null; // Validación exitosa
  }

  /// Validaciones que se aplican después de un login exitoso
  ValidationFailure? _validatePostLogin(User user) {
    // Verificar si la cuenta requiere configuración inicial
    if (user.isFirstLogin) {
      return const ValidationFailure(
        message: 'Debe completar la configuración inicial de su cuenta',
        code: 'FIRST_LOGIN_SETUP_REQUIRED',
      );
    }

    // Verificar si el usuario tiene roles válidos
    if (user.role == UserRole.fieldWorker && !user.hasActiveAssignment) {
      return const ValidationFailure(
        message:
            'Su cuenta no tiene asignaciones activas. Contacte al administrador',
        code: 'NO_ACTIVE_ASSIGNMENT',
      );
    }

    return null; // Usuario listo para usar la app
  }

  // ===========================================================================
  // TRANSFORMACIÓN DE ERRORES
  // ===========================================================================

  /// Convierte failures técnicas en mensajes amigables para el usuario
  Failure _transformFailureToUserFriendly(Failure failure) {
    if (failure is AuthFailure) {
      switch (failure.code) {
        case 'INVALID_CREDENTIALS':
          return const AuthFailure(
            message:
                'Email o contraseña incorrectos. Verifique sus datos e intente nuevamente',
            code: 'LOGIN_INVALID_CREDENTIALS',
          );
        case 'ACCOUNT_LOCKED':
          return const AuthFailure(
            message:
                'Su cuenta ha sido bloqueada temporalmente por seguridad. Intente en 15 minutos',
            code: 'LOGIN_ACCOUNT_LOCKED',
          );
        case 'TOKEN_EXPIRED':
          return const AuthFailure(
            message:
                'Su sesión ha expirado. Por favor inicie sesión nuevamente',
            code: 'LOGIN_SESSION_EXPIRED',
          );
        default:
          return const AuthFailure(
            message: 'Error de autenticación. Intente nuevamente',
            code: 'LOGIN_AUTH_ERROR',
          );
      }
    }

    if (failure is NetworkFailure) {
      return const NetworkFailure(
        message:
            'Sin conexión a internet. Verifique su conexión e intente nuevamente',
        code: 'LOGIN_NO_CONNECTION',
      );
    }

    if (failure is ServerFailure) {
      return const ServerFailure(
        message: 'El servidor no está disponible. Intente en unos momentos',
        code: 'LOGIN_SERVER_ERROR',
      );
    }

    // Para otros tipos de failure, retornar mensaje genérico
    return const ServerFailure(
      message: 'Ha ocurrido un error inesperado. Intente nuevamente',
      code: 'LOGIN_UNKNOWN_ERROR',
    );
  }

  // ===========================================================================
  // LOGGING SEGURO
  // ===========================================================================

  /// Registra intento de login (sin contraseña por seguridad)
  void _logLoginAttempt(Credentials credentials) {
    // TODO: Implementar logging con servicio de logging
    // En producción, esto debería usar un logger configurado
    print('Login attempt for: ${credentials.email}');
  }

  /// Registra login exitoso
  void _logLoginSuccess(User user) {
    print('Login successful for user: ${user.email} (${user.role.name})');
  }

  /// Registra falla de login
  void _logLoginFailure(Credentials credentials, Failure failure) {
    print('Login failed for: ${credentials.email}, reason: ${failure.code}');
  }
}
