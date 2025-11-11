// create_user_usecase.dart
//
// Caso de uso para crear usuarios
//
// PROPÓSITO:
// - Encapsular lógica de negocio de creación de usuarios
// - Validar datos antes de enviar al repositorio
// - Manejar errores de forma consistente
//
// CAPA: DOMAIN LAYER

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../authentication/domain/entities/user.dart';
import '../entities/user_creation_dto.dart';
import '../repositories/user_repository.dart';

/// Caso de uso para crear un nuevo usuario
///
/// Valida los datos del usuario y coordina con el repositorio
/// para persistir la información.
class CreateUserUseCase {
  final UserRepository repository;

  CreateUserUseCase(this.repository);

  /// Ejecuta la creación de usuario
  ///
  /// **Parámetros:**
  /// - [dto]: DTO con los datos del usuario a crear
  ///
  /// **Retorna:**
  /// - [Right(User)]: Usuario creado exitosamente
  /// - [Left(ValidationFailure)]: Errores de validación local
  /// - [Left(ServerFailure)]: Errores del servidor (duplicados, etc.)
  /// - [Left(NetworkFailure)]: Errores de conexión
  Future<Either<Failure, User>> call(UserCreationDto dto) async {
    print('🟢 [CreateUserUseCase] Validando DTO...');
    print('   DTO: $dto');
    
    // Validaciones básicas antes de enviar
    final validationErrors = _validateDto(dto);
    if (validationErrors.isNotEmpty) {
      print('❌ [CreateUserUseCase] Errores de validación local: $validationErrors');
      return Left(
        ValidationFailure(
          message: 'Errores de validación en el formulario',
          field: validationErrors.keys.first,
        ),
      );
    }

    print('✅ [CreateUserUseCase] Validación local exitosa, delegando al repositorio...');
    // Delegar al repositorio
    final result = await repository.createUser(dto);
    
    result.fold(
      (failure) => print('❌ [CreateUserUseCase] Repositorio retornó error: ${failure.message}'),
      (user) => print('✅ [CreateUserUseCase] Repositorio retornó usuario: ${user.email}'),
    );
    
    return result;
  }

  /// Valida el DTO localmente
  Map<String, String> _validateDto(UserCreationDto dto) {
    final errors = <String, String>{};

    // Validar nombre
    if (dto.firstName.trim().isEmpty) {
      errors['firstName'] = 'El nombre es requerido';
    } else if (dto.firstName.length < 2) {
      errors['firstName'] = 'El nombre debe tener al menos 2 caracteres';
    }

    // Validar apellido
    if (dto.lastName.trim().isEmpty) {
      errors['lastName'] = 'El apellido es requerido';
    } else if (dto.lastName.length < 2) {
      errors['lastName'] = 'El apellido debe tener al menos 2 caracteres';
    }

    // Validar email
    if (dto.email.trim().isEmpty) {
      errors['email'] = 'El email es requerido';
    } else if (!_isValidEmail(dto.email)) {
      errors['email'] = 'El email no es válido';
    }

    // Validar documento
    if (dto.documentNumber.trim().isEmpty) {
      errors['documentNumber'] = 'El número de documento es requerido';
    } else if (dto.documentNumber.length < 6 ||
        dto.documentNumber.length > 12) {
      errors['documentNumber'] = 'El documento debe tener entre 6 y 12 dígitos';
    } else if (!_isNumeric(dto.documentNumber)) {
      errors['documentNumber'] = 'El documento solo debe contener números';
    }

    // Validar teléfono
    if (dto.phone.trim().isEmpty) {
      errors['phone'] = 'El teléfono es requerido';
    } else if (dto.phone.length != 10) {
      errors['phone'] = 'El teléfono debe tener 10 dígitos';
    } else if (!_isNumeric(dto.phone)) {
      errors['phone'] = 'El teléfono solo debe contener números';
    } else if (!dto.phone.startsWith('3')) {
      errors['phone'] = 'El teléfono debe iniciar con 3 (celular)';
    }

    // Validar rol y tipo de trabajador
    if (dto.roleName == 'TRABAJADOR' || dto.roleName == 'JEFE_AREA') {
      // Rol Trabajador y Jefe de Área requieren workType y workRoleName
      if (dto.workType == null || dto.workType!.isEmpty) {
        errors['workType'] = 'El tipo de trabajador es requerido';
      }
      if (dto.workRoleName == null) {
        errors['workRoleName'] = 'El rol de trabajo es requerido';
      }
    }

    return errors;
  }

  /// Valida formato de email
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Valida si una cadena es numérica
  bool _isNumeric(String str) {
    return int.tryParse(str) != null;
  }
}
