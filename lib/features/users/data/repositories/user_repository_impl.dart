// user_repository_impl.dart
//
// Implementación del repositorio de usuarios
//
// PROPÓSITO:
// - Implementar el contrato del repositorio
// - Coordinar data sources (remoto y local)
// - Convertir excepciones en failures
// - Manejar lógica de offline/online
//
// CAPA: DATA LAYER

import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../authentication/domain/entities/user.dart';
import '../../domain/entities/user_creation_dto.dart';
import '../../domain/entities/worker.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_datasource.dart';
import '../models/user_creation_model.dart';

/// Implementación del repositorio de usuarios
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, User>> createUser(UserCreationDto dto) async {
    try {
      // Convertir DTO a modelo
      final model = UserCreationModel.fromDto(dto);

      // Llamar al data source remoto
      final user = await remoteDataSource.createUser(model);

      return Right(user);
    } on ValidationException catch (e) {
      return Left(
        ValidationFailure(
          message: e.message,
          field: e.field,
          fieldErrors: e.fieldErrors, // Propagar errores de campos
        ),
      );
    } on AuthenticationException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.code));
    } on AuthorizationException catch (e) {
      return Left(AuthorizationFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(message: e.message, code: e.code));
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.message,
          statusCode: e.statusCode,
          code: e.code,
        ),
      );
    } catch (e) {
      return Left(UnknownFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, List<User>>> getUsers() async {
    try {
      final users = await remoteDataSource.getUsers();
      return Right(users);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: 'Error al obtener usuarios: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> getUserById(int userId) async {
    try {
      final user = await remoteDataSource.getUserById(userId);
      return Right(user);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: 'Error al obtener usuario: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> updateUser(
    int userId,
    UserCreationDto dto,
  ) async {
    // TODO: Implementar cuando sea necesario
    return Left(
      UnsupportedFailure(message: 'Actualización no implementada aún'),
    );
  }

  @override
  Future<Either<Failure, void>> deleteUser(int userId) async {
    // TODO: Implementar cuando sea necesario
    return Left(UnsupportedFailure(message: 'Eliminación no implementada aún'));
  }

  @override
  Future<Either<Failure, List<Worker>>> getWorkers() async {
    try {
      final workers = await remoteDataSource.getWorkers();
      return Right(workers);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: 'Error al obtener trabajadores: $e'));
    }
  }
}
