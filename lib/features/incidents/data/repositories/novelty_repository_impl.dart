// novelty_repository_impl.dart
//
// Implementación del repositorio de novedades
//
// PROPÓSITO:
// - Implementar operaciones de consulta de novedades
// - Manejo de errores y conversión de modelos
//
// CAPA: DATA LAYER - REPOSITORIES

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/novelty.dart';
import '../../domain/repositories/novelty_repository.dart';
import '../models/novelty_page_response.dart';
import '../novelty_service.dart';

/// Implementación del repositorio de novedades
class NoveltyRepositoryImpl implements NoveltyRepository {
  final NoveltyService _noveltyService;

  NoveltyRepositoryImpl(this._noveltyService);

  @override
  Future<Either<Failure, NoveltyPage>> getNovelties(
    NoveltyFilters filters,
  ) async {
    try {
      final response = await _noveltyService.getNovelties(
        page: filters.page,
        size: filters.size,
        sort: filters.sort,
        direction: filters.direction,
        status: filters.status?.value,
        priority: filters.priority?.value,
        areaId: filters.areaId,
        crewId: filters.crewId,
        creatorId: filters.creatorId,
        startDate: filters.startDate?.toIso8601String(),
        endDate: filters.endDate?.toIso8601String(),
      );

      final pageResponse = NoveltyPageResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      final noveltyPage = NoveltyPage(
        novelties: pageResponse.content
            .map((model) => model.toEntity())
            .toList(),
        totalElements: pageResponse.totalElements,
        totalPages: pageResponse.totalPages,
        currentPage: pageResponse.number,
        pageSize: pageResponse.size,
        isFirst: pageResponse.first,
        isLast: pageResponse.last,
        isEmpty: pageResponse.empty,
      );

      return Right(noveltyPage);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Novelty>> getNoveltyById(int id) async {
    try {
      final response = await _noveltyService.getNoveltyById(id.toString());

      final noveltyResponse = response.data as Map<String, dynamic>;
      final novelty = noveltyResponse.toEntity();

      return Right(novelty);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: ${e.toString()}'));
    }
  }

  /// Maneja errores de Dio y los convierte en Failures
  Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure(message: 'Tiempo de espera agotado');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] as String?;

        if (statusCode == 401) {
          return AuthFailure(message: message ?? 'No autorizado');
        } else if (statusCode == 403) {
          return AuthFailure(message: message ?? 'Acceso denegado');
        } else if (statusCode == 404) {
          return ServerFailure(message: message ?? 'Recurso no encontrado');
        } else {
          return ServerFailure(
            message: message ?? 'Error del servidor (código: $statusCode)',
          );
        }

      case DioExceptionType.cancel:
        return const NetworkFailure(message: 'Petición cancelada');

      case DioExceptionType.connectionError:
        return const NetworkFailure(
          message: 'Error de conexión. Verifica tu internet.',
        );

      default:
        return NetworkFailure(message: 'Error de red: ${error.message}');
    }
  }
}

/// Extensión para convertir el Map response a entidad
extension _NoveltyResponseExtension on Map<String, dynamic> {
  Novelty toEntity() {
    return Novelty(
      id: this['id'] as int,
      description: this['description'] as String,
      status: NoveltyStatus.fromString(this['status'] as String),
      priority: NoveltyPriority.fromString(this['priority'] as String),
      reason: this['reason'] as String,
      accountNumber: this['accountNumber'] as String,
      meterNumber: this['meterNumber'] as String,
      activeReading: this['activeReading'] as String,
      reactiveReading: this['reactiveReading'] as String,
      municipality: this['municipality'] as String,
      address: this['address'] as String,
      observations: this['observations'] as String?,
      crewId: this['crewId'] as int?,
      crewName: this['crewName'] as String?,
      areaId: this['areaId'] as int,
      areaName: this['areaName'] as String,
      creatorId: this['creatorId'] as int,
      creatorName: this['creatorName'] as String,
      imageCount: this['imageCount'] as int,
      createdAt: DateTime.parse(this['createdAt'] as String),
      updatedAt: DateTime.parse(this['updatedAt'] as String),
    );
  }
}
