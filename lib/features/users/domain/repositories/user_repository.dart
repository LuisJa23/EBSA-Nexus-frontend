// user_repository.dart
//
// Repositorio abstracto de usuarios
//
// PROPÓSITO:
// - Definir contrato para operaciones de usuarios
// - Independiente de implementación (HTTP, local, etc.)
// - Retorna Either para manejo funcional de errores
//
// CAPA: DOMAIN LAYER

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../authentication/domain/entities/user.dart';
import '../entities/user_creation_dto.dart';
import '../entities/worker.dart';

/// Repositorio abstracto para gestión de usuarios
///
/// Define las operaciones disponibles para trabajar con usuarios
/// en el sistema, independientemente de la fuente de datos.
abstract class UserRepository {
  /// Crea un nuevo usuario en el sistema
  ///
  /// **Parámetros:**
  /// - [dto]: DTO con los datos del usuario a crear
  ///
  /// **Retorna:**
  /// - [Right(User)]: Usuario creado exitosamente
  /// - [Left(Failure)]: Error en la creación (validación, duplicado, red, etc.)
  Future<Either<Failure, User>> createUser(UserCreationDto dto);

  /// Obtiene lista de todos los usuarios
  ///
  /// **Retorna:**
  /// - [Right(List<User>)]: Lista de usuarios
  /// - [Left(Failure)]: Error al obtener usuarios
  Future<Either<Failure, List<User>>> getUsers();

  /// Obtiene un usuario por su ID
  ///
  /// **Parámetros:**
  /// - [userId]: ID del usuario a buscar
  ///
  /// **Retorna:**
  /// - [Right(User)]: Usuario encontrado
  /// - [Left(Failure)]: Error al buscar usuario (no encontrado, red, etc.)
  Future<Either<Failure, User>> getUserById(int userId);

  /// Actualiza un usuario existente
  ///
  /// **Parámetros:**
  /// - [userId]: ID del usuario a actualizar
  /// - [dto]: Nuevos datos del usuario
  ///
  /// **Retorna:**
  /// - [Right(User)]: Usuario actualizado
  /// - [Left(Failure)]: Error en la actualización
  Future<Either<Failure, User>> updateUser(int userId, UserCreationDto dto);

  /// Elimina un usuario del sistema
  ///
  /// **Parámetros:**
  /// - [userId]: ID del usuario a eliminar
  ///
  /// **Retorna:**
  /// - [Right(void)]: Usuario eliminado exitosamente
  /// - [Left(Failure)]: Error en la eliminación
  Future<Either<Failure, void>> deleteUser(int userId);

  /// Desactiva un usuario del sistema
  ///
  /// **Parámetros:**
  /// - [userId]: ID del usuario a desactivar
  ///
  /// **Retorna:**
  /// - [Right(void)]: Usuario desactivado exitosamente
  /// - [Left(Failure)]: Error en la desactivación
  Future<Either<Failure, void>> deactivateUser(int userId);

  /// Activa un usuario del sistema
  ///
  /// **Parámetros:**
  /// - [userId]: ID del usuario a activar
  ///
  /// **Retorna:**
  /// - [Right(void)]: Usuario activado exitosamente
  /// - [Left(Failure)]: Error en la activación
  Future<Either<Failure, void>> activateUser(int userId);

  /// Obtiene lista de trabajadores desde el endpoint público
  ///
  /// **Retorna:**
  /// - [Right(List<Worker>)]: Lista de trabajadores
  /// - [Left(Failure)]: Error al obtener trabajadores
  Future<Either<Failure, List<Worker>>> getWorkers();
}
