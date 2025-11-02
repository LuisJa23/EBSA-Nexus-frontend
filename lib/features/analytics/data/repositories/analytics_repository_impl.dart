// analytics_repository_impl.dart
// Implementación del repositorio de analytics

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/analytics_stats.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../datasources/analytics_remote_datasource.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsRemoteDataSource remoteDataSource;

  AnalyticsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, NoveltyOverview>> getNoveltyOverview({
    DateTime? startDate,
    DateTime? endDate,
    int? areaId,
  }) async {
    try {
      final result = await remoteDataSource.getNoveltyOverview(
        startDate: startDate,
        endDate: endDate,
        areaId: areaId,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Error de conexión'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<NoveltyTrend>>> getNoveltyTrends({
    required String period,
    DateTime? startDate,
    DateTime? endDate,
    int? areaId,
  }) async {
    try {
      final result = await remoteDataSource.getNoveltyTrends(
        period: period,
        startDate: startDate,
        endDate: endDate,
        areaId: areaId,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Error de conexión'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CrewPerformance>>> getCrewPerformance({
    DateTime? startDate,
    DateTime? endDate,
    int? crewId,
  }) async {
    try {
      final result = await remoteDataSource.getCrewPerformance(
        startDate: startDate,
        endDate: endDate,
        crewId: crewId,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Error de conexión'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserPerformance>>> getUserPerformance({
    DateTime? startDate,
    DateTime? endDate,
    int? userId,
    int? workRoleId,
  }) async {
    try {
      final result = await remoteDataSource.getUserPerformance(
        startDate: startDate,
        endDate: endDate,
        userId: userId,
        workRoleId: workRoleId,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Error de conexión'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MunicipalityStats>>> getNoveltyByMunicipality({
    DateTime? startDate,
    DateTime? endDate,
    String? status,
  }) async {
    try {
      final result = await remoteDataSource.getNoveltyByMunicipality(
        startDate: startDate,
        endDate: endDate,
        status: status,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Error de conexión'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AnalyticsDashboard>> getDashboard({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final result = await remoteDataSource.getDashboard(
        startDate: startDate,
        endDate: endDate,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on DioException catch (e) {
      return Left(ServerFailure(message: e.message ?? 'Error de conexión'));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
