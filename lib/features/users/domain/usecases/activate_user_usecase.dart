// activate_user_usecase.dart
//
// Caso de uso para activar usuario
//
// PROPÓSITO:
// - Activar un usuario del sistema
// - Validaciones de negocio
// - Manejo de errores
//
// CAPA: DOMAIN LAYER

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/user_repository.dart';

/// Caso de uso para activar un usuario del sistema
///
/// Solo usuarios con rol ADMIN pueden activar usuarios.
class ActivateUserUseCase {
  final UserRepository repository;

  ActivateUserUseCase({required this.repository});

  /// Activa un usuario por su ID
  ///
  /// **Parámetros:**
  /// - [userId]: ID del usuario a activar
  ///
  /// **Retorna:**
  /// - [Right(void)]: Usuario activado exitosamente
  /// - [Left(Failure)]: Error en la activación
  Future<Either<Failure, void>> call(int userId) async {
    return await repository.activateUser(userId);
  }
}
