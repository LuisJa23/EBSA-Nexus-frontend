// change_password_usecase.dart
//
// Caso de uso para cambiar contraseña del usuario
//
// PROPÓSITO:
// - Cambiar la contraseña del usuario autenticado
// - Validar contraseña actual y nueva
// - Mantener sesión activa después del cambio
//
// CAPA: DOMAIN LAYER

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso para cambiar la contraseña del usuario actual
///
/// **Reglas de negocio**:
/// - El usuario debe estar autenticado
/// - La contraseña actual debe ser correcta
/// - La nueva contraseña debe cumplir requisitos de seguridad
/// - La nueva contraseña debe ser diferente a la actual
/// - La sesión permanece activa después del cambio
class ChangePasswordUseCase {
  final AuthRepository _repository;

  ChangePasswordUseCase(this._repository);

  /// Ejecuta el cambio de contraseña
  ///
  /// **Parámetros**:
  /// - [currentPassword]: Contraseña actual del usuario
  /// - [newPassword]: Nueva contraseña deseada
  /// - [confirmPassword]: Confirmación de la nueva contraseña
  ///
  /// **Retorna**:
  /// - [Right(void)]: Contraseña cambiada exitosamente
  /// - [Left(ValidationFailure)]: Validación falló
  /// - [Left(AuthFailure)]: Contraseña actual incorrecta o no autenticado
  /// - [Left(NetworkFailure)]: Sin conexión a internet
  /// - [Left(ServerFailure)]: Error del servidor
  Future<Either<Failure, void>> execute({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    // Validar contraseñas antes de enviar al repositorio
    final validationResult = _validatePasswords(
      currentPassword,
      newPassword,
      confirmPassword,
    );

    if (validationResult != null) {
      return Left(validationResult);
    }

    // Delegar al repositorio
    return await _repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  /// Valida las contraseñas según reglas de negocio
  ValidationFailure? _validatePasswords(
    String currentPassword,
    String newPassword,
    String confirmPassword,
  ) {
    // Validar que ningún campo esté vacío
    if (currentPassword.trim().isEmpty) {
      return const ValidationFailure(
        message: 'La contraseña actual es requerida',
        code: 'password/current-required',
      );
    }

    if (newPassword.trim().isEmpty) {
      return const ValidationFailure(
        message: 'La nueva contraseña es requerida',
        code: 'password/new-required',
      );
    }

    if (confirmPassword.trim().isEmpty) {
      return const ValidationFailure(
        message: 'Debe confirmar la nueva contraseña',
        code: 'password/confirm-required',
      );
    }

    // Validar que las nuevas contraseñas coincidan
    if (newPassword != confirmPassword) {
      return const ValidationFailure(
        message: 'Las contraseñas no coinciden',
        code: 'password/mismatch',
      );
    }

    // Validar que la nueva contraseña sea diferente a la actual
    if (currentPassword == newPassword) {
      return const ValidationFailure(
        message: 'La nueva contraseña debe ser diferente a la actual',
        code: 'password/same-as-current',
      );
    }

    // Validar longitud mínima de la nueva contraseña
    if (newPassword.length < 6) {
      return const ValidationFailure(
        message: 'La contraseña debe tener al menos 6 caracteres',
        code: 'password/too-short',
      );
    }

    // Validar longitud máxima
    if (newPassword.length > 50) {
      return const ValidationFailure(
        message: 'La contraseña no puede exceder 50 caracteres',
        code: 'password/too-long',
      );
    }

    // Todas las validaciones pasaron
    return null;
  }
}
