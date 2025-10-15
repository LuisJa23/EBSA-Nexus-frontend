// update_user_profile_usecase.dart
//
// Caso de uso para actualizar perfil de usuario
//
// PROPÓSITO:
// - Actualizar información editable del perfil del usuario
// - Validar datos antes de enviar al repositorio
// - Implementar reglas de negocio de actualización de perfil
//
// CAPA: DOMAIN LAYER (Lógica de negocio pura)

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso para actualizar el perfil del usuario actual
///
/// **Responsabilidades**:
/// - Validar datos de entrada (nombres, apellidos, teléfono)
/// - Aplicar reglas de negocio de actualización
/// - Coordinar con el repositorio para persistir cambios
/// - Retornar usuario actualizado o falla específica
///
/// **Datos editables**:
/// - firstName (Nombres)
/// - lastName (Apellidos)
/// - phone (Teléfono)
///
/// **Validaciones**:
/// - Campos no vacíos
/// - Longitud mínima/máxima
/// - Formato de teléfono válido
class UpdateUserProfileUseCase {
  final AuthRepository _repository;

  const UpdateUserProfileUseCase(this._repository);

  /// Ejecuta el caso de uso de actualización de perfil
  ///
  /// **Entrada**: [UpdateProfileParams] con datos a actualizar
  /// **Salida**: [User] actualizado o [Failure]
  ///
  /// **Flujo**:
  /// 1. Validar parámetros de entrada
  /// 2. Verificar reglas de negocio
  /// 3. Llamar al repositorio para actualizar
  /// 4. Retornar resultado
  Future<Either<Failure, User>> call(UpdateProfileParams params) async {
    // Validar parámetros
    final validationFailure = _validateParams(params);
    if (validationFailure != null) {
      return Left(validationFailure);
    }

    // Delegar actualización al repositorio
    return await _repository.updateUserProfile(
      firstName: params.firstName,
      lastName: params.lastName,
      phone: params.phone,
    );
  }

  /// Valida los parámetros de actualización
  ///
  /// Retorna [ValidationFailure] si hay errores, null si todo es válido
  ValidationFailure? _validateParams(UpdateProfileParams params) {
    // Validar firstName
    if (params.firstName.trim().isEmpty) {
      return ValidationFailure(
        message: 'El nombre no puede estar vacío',
        field: 'firstName',
      );
    }

    if (params.firstName.trim().length < 2) {
      return ValidationFailure(
        message: 'El nombre debe tener al menos 2 caracteres',
        field: 'firstName',
      );
    }

    if (params.firstName.trim().length > 50) {
      return ValidationFailure(
        message: 'El nombre no puede exceder 50 caracteres',
        field: 'firstName',
      );
    }

    // Validar lastName
    if (params.lastName.trim().isEmpty) {
      return ValidationFailure(
        message: 'El apellido no puede estar vacío',
        field: 'lastName',
      );
    }

    if (params.lastName.trim().length < 2) {
      return ValidationFailure(
        message: 'El apellido debe tener al menos 2 caracteres',
        field: 'lastName',
      );
    }

    if (params.lastName.trim().length > 50) {
      return ValidationFailure(
        message: 'El apellido no puede exceder 50 caracteres',
        field: 'lastName',
      );
    }

    // Validar phone
    if (params.phone.trim().isEmpty) {
      return ValidationFailure(
        message: 'El teléfono no puede estar vacío',
        field: 'phone',
      );
    }

    // Validar formato de teléfono colombiano
    final phoneRegex = RegExp(r'^(\+57|57)?[3][0-9]{9}$|^[3][0-9]{9}$');
    final cleanPhone = params.phone.replaceAll(RegExp(r'[\s\-()]'), '');

    if (!phoneRegex.hasMatch(cleanPhone)) {
      return ValidationFailure(
        message:
            'El teléfono debe ser un número válido colombiano (10 dígitos, inicia con 3)',
        field: 'phone',
      );
    }

    // Todo válido
    return null;
  }
}

/// Parámetros para actualizar perfil de usuario
///
/// Contiene solo los campos editables del perfil
class UpdateProfileParams extends Equatable {
  /// Nombres del usuario
  final String firstName;

  /// Apellidos del usuario
  final String lastName;

  /// Número de teléfono
  final String phone;

  const UpdateProfileParams({
    required this.firstName,
    required this.lastName,
    required this.phone,
  });

  @override
  List<Object?> get props => [firstName, lastName, phone];

  @override
  String toString() {
    return 'UpdateProfileParams(firstName: $firstName, lastName: $lastName, phone: $phone)';
  }
}
