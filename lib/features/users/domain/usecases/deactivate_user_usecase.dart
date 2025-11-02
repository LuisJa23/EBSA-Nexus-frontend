// deactivate_user_usecase.dart
//
// Caso de uso para desactivar usuario
//
// PROPÓSITO:
// - Desactivar un usuario del sistema
// - Validaciones de negocio
// - Manejo de errores
//
// CAPA: DOMAIN LAYER

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/user_repository.dart';

/// Caso de uso para desactivar un usuario del sistema
///
/// Solo usuarios con rol ADMIN pueden desactivar usuarios.
class DeactivateUserUseCase {
  final UserRepository repository;

  DeactivateUserUseCase({required this.repository});

  /// Desactiva un usuario por su ID
  ///
  /// **Parámetros:**
  /// - [userId]: ID del usuario a desactivar
  ///
  /// **Retorna:**
  /// - [Right(void)]: Usuario desactivado exitosamente
  /// - [Left(Failure)]: Error en la desactivación
  Future<Either<Failure, void>> call(int userId) async {
    return await repository.deactivateUser(userId);
  }
}
