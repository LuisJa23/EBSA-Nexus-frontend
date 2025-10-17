// crew_repository_impl.dart
//
// Implementación del repositorio de cuadrillas
//
// PROPÓSITO:
// - Implementar operaciones de cuadrillas
// - Coordinar entre fuente de datos remota y local
// - Manejo de errores y transformación de excepciones
//
// CAPA: DATA LAYER

import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/crew.dart';
import '../../domain/entities/crew_with_members.dart';
import '../../domain/entities/available_user.dart';
import '../../domain/repositories/crew_repository.dart';
import '../datasources/crew_remote_datasource.dart';

/// Implementación del repositorio de cuadrillas
class CrewRepositoryImpl implements CrewRepository {
  final CrewRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  CrewRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Crew>>> getAllCrews() async {
    if (await networkInfo.isConnected) {
      try {
        final crews = await remoteDataSource.getAllCrews();
        return Right(crews.map((model) => model.toEntity()).toList());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(
          ServerFailure(message: 'Error inesperado: ${e.toString()}'),
        );
      }
    } else {
      return Left(NetworkFailure(message: 'No hay conexión a internet'));
    }
  }

  @override
  Future<Either<Failure, CrewWithMembers>> getCrewWithMembers(
    int crewId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final crewWithMembers = await remoteDataSource.getCrewWithMembers(
          crewId,
        );
        return Right(crewWithMembers.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(
          ServerFailure(message: 'Error inesperado: ${e.toString()}'),
        );
      }
    } else {
      return Left(NetworkFailure(message: 'No hay conexión a internet'));
    }
  }

  @override
  Future<Either<Failure, List<AvailableUser>>> getAvailableUsers() async {
    if (await networkInfo.isConnected) {
      try {
        final users = await remoteDataSource.getAvailableUsers();
        return Right(users.map((model) => model.toEntity()).toList());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(
          ServerFailure(message: 'Error inesperado: ${e.toString()}'),
        );
      }
    } else {
      return Left(NetworkFailure(message: 'No hay conexión a internet'));
    }
  }

  @override
  Future<Either<Failure, void>> createCrew({
    required String name,
    required String description,
    required int createdBy,
    required List<Map<String, dynamic>> members,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.createCrew(
          name: name,
          description: description,
          createdBy: createdBy,
          members: members,
        );
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(
          ServerFailure(message: 'Error inesperado: ${e.toString()}'),
        );
      }
    } else {
      return Left(NetworkFailure(message: 'No hay conexión a internet'));
    }
  }

  @override
  Future<Either<Failure, void>> addMemberToCrew({
    required int crewId,
    required int userId,
    required bool isLeader,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.addMemberToCrew(
          crewId: crewId,
          userId: userId,
          isLeader: isLeader,
        );
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(
          ServerFailure(message: 'Error inesperado: ${e.toString()}'),
        );
      }
    } else {
      return Left(NetworkFailure(message: 'No hay conexión a internet'));
    }
  }

  @override
  Future<Either<Failure, void>> removeMemberFromCrew({
    required int crewId,
    required int memberId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.removeMemberFromCrew(
          crewId: crewId,
          memberId: memberId,
        );
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(
          ServerFailure(message: 'Error inesperado: ${e.toString()}'),
        );
      }
    } else {
      return Left(NetworkFailure(message: 'No hay conexión a internet'));
    }
  }

  @override
  Future<Either<Failure, void>> promoteMemberToLeader({
    required int crewId,
    required int memberId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.promoteMemberToLeader(
          crewId: crewId,
          memberId: memberId,
        );
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(
          ServerFailure(message: 'Error inesperado: ${e.toString()}'),
        );
      }
    } else {
      return Left(NetworkFailure(message: 'No hay conexión a internet'));
    }
  }
}
