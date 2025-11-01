// report_repository_impl.dart
//
// Implementación del repositorio de reportes
//
// PROPÓSITO:
// - Implementar ReportRepository del dominio
// - Coordinar entre remote y local data sources
// - Estrategia offline-first para reportes
// - Manejo inteligente de sincronización
//
// CAPA: DATA LAYER
// IMPLEMENTA: ReportRepository (domain interface)

import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_local_datasource.dart';
import '../datasources/report_remote_datasource.dart';
import '../models/report_model.dart';
import '../models/evidence_model.dart';

/// Implementación del repositorio de reportes
///
/// Coordina operaciones offline-first con sincronización al servidor
class ReportRepositoryImpl implements ReportRepository {
  final ReportLocalDataSource localDataSource;
  final ReportRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  const ReportRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  // ===========================================================================
  // OPERACIONES PRINCIPALES
  // ===========================================================================

  @override
  Future<Either<Failure, List<ReportModel>>> getReports({
    bool onlyPending = false,
  }) async {
    try {
      AppLogger.debug('📦 Obteniendo reportes (pending: $onlyPending)');

      // Siempre devolver reportes locales (offline-first)
      final reports = await localDataSource.getReports(
        onlyPending: onlyPending,
      );

      AppLogger.success('Reportes obtenidos: ${reports.length}');
      return Right(reports);
    } on CacheException catch (e) {
      AppLogger.cacheError('getReports', e);
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      AppLogger.error('Error inesperado obteniendo reportes', error: e);
      return Left(CacheFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, ReportModel?>> getReportById(String id) async {
    try {
      AppLogger.debug('📦 Obteniendo reporte: $id');

      final report = await localDataSource.getReportById(id);

      if (report == null) {
        AppLogger.debug('Reporte no encontrado: $id');
        return const Right(null);
      }

      return Right(report);
    } on CacheException catch (e) {
      AppLogger.cacheError('getReportById', e);
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      AppLogger.error('Error inesperado obteniendo reporte', error: e);
      return Left(CacheFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, ReportModel>> createReportOffline(
    ReportModel report,
  ) async {
    try {
      AppLogger.debug('💾 Creando reporte offline: ${report.id}');

      // Guardar reporte localmente
      await localDataSource.saveReport(report);

      AppLogger.success('Reporte creado offline: ${report.id}');
      return Right(report);
    } on CacheException catch (e) {
      AppLogger.cacheError('createReportOffline', e);
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      AppLogger.error('Error creando reporte offline', error: e);
      return Left(CacheFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateReport(ReportModel report) async {
    try {
      AppLogger.debug('🔄 Actualizando reporte: ${report.id}');

      await localDataSource.updateReport(report);

      AppLogger.success('Reporte actualizado: ${report.id}');
      return const Right(null);
    } on CacheException catch (e) {
      AppLogger.cacheError('updateReport', e);
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      AppLogger.error('Error actualizando reporte', error: e);
      return Left(CacheFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteReport(String id) async {
    try {
      AppLogger.debug('🗑️ Eliminando reporte: $id');

      await localDataSource.deleteReport(id);

      AppLogger.success('Reporte eliminado: $id');
      return const Right(null);
    } on CacheException catch (e) {
      AppLogger.cacheError('deleteReport', e);
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      AppLogger.error('Error eliminando reporte', error: e);
      return Left(CacheFailure(message: 'Error inesperado: $e'));
    }
  }

  // ===========================================================================
  // SINCRONIZACIÓN
  // ===========================================================================

  @override
  Future<Either<Failure, SyncResult>> syncPendingReports() async {
    try {
      AppLogger.syncStarted('reports');

      // Verificar conectividad
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        AppLogger.connectivityChanged(false);
        return Left(NetworkFailure(message: 'Sin conexión a Internet'));
      }

      // Obtener reportes pendientes
      final pendingReports = await localDataSource.getPendingSyncReports();

      if (pendingReports.isEmpty) {
        AppLogger.info('✅ No hay reportes pendientes de sincronizar');
        return const Right(
          SyncResult(successCount: 0, failureCount: 0, failures: []),
        );
      }

      AppLogger.info(
        '📤 Sincronizando ${pendingReports.length} reportes pendientes',
      );

      int successCount = 0;
      int failureCount = 0;
      final failures = <SyncFailureItem>[];

      // Sincronizar cada reporte
      for (final report in pendingReports) {
        try {
          // 1. Subir evidencias primero
          final evidencesWithUrls = await _uploadEvidences(report);

          // 2. Crear reporte actualizado con URLs de evidencias
          final reportWithUrls = report.copyWith(evidences: evidencesWithUrls);

          // 3. Enviar reporte al servidor
          final serverReport = await remoteDataSource.createReport(
            reportWithUrls.toServerPayload(),
          );

          // 4. Marcar como sincronizado
          await localDataSource.markReportAsSynced(
            report.id,
            serverReport['id'] as int,
          );

          successCount++;
          AppLogger.success('✅ Reporte sincronizado: ${report.id}');
        } catch (e) {
          failureCount++;
          final errorMessage = _getErrorMessage(e);

          AppLogger.error(
            '❌ Error sincronizando reporte ${report.id}',
            error: e,
          );

          // Marcar error
          await localDataSource.markReportSyncError(report.id, errorMessage);

          failures.add(
            SyncFailureItem(reportId: report.id, error: errorMessage),
          );
        }
      }

      AppLogger.syncSuccess('reports', successCount);

      if (failureCount > 0) {
        AppLogger.syncFailure(
          'reports',
          '$failureCount de ${pendingReports.length} fallaron',
        );
      }

      return Right(
        SyncResult(
          successCount: successCount,
          failureCount: failureCount,
          failures: failures,
        ),
      );
    } on NetworkException catch (e) {
      AppLogger.networkError('syncReports', e);
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      AppLogger.error('Error del servidor sincronizando', error: e);
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      AppLogger.error('Error inesperado sincronizando', error: e);
      return Left(UnknownFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getPendingReportsCount() async {
    try {
      final pending = await localDataSource.getPendingSyncReports();
      return Right(pending.length);
    } catch (e) {
      AppLogger.error(
        'Error obteniendo cantidad de reportes pendientes',
        error: e,
      );
      return const Right(0);
    }
  }

  // ===========================================================================
  // CACHE DE DEPENDENCIAS
  // ===========================================================================

  @override
  Future<Either<Failure, void>> cacheNovelties() async {
    try {
      AppLogger.debug('💾 Cacheando novedades...');

      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        AppLogger.warning('Sin conexión, usando cache existente');
        return const Right(null);
      }

      // Obtener novedades del servidor
      final novelties = await remoteDataSource.fetchNovelties();

      // Guardar en cache
      await localDataSource.cacheNovelties(novelties);

      AppLogger.cacheSaved('novelties');
      return const Right(null);
    } on NetworkException catch (e) {
      AppLogger.networkError('cacheNovelties', e);
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      AppLogger.error('Error del servidor cacheando novedades', error: e);
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      AppLogger.error('Error inesperado cacheando novedades', error: e);
      return Left(UnknownFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> cacheCrews() async {
    try {
      AppLogger.debug('💾 Cacheando cuadrillas...');

      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        AppLogger.warning('Sin conexión, usando cache existente');
        return const Right(null);
      }

      // Obtener cuadrillas del servidor
      final crews = await remoteDataSource.fetchCrews();

      // Guardar en cache
      await localDataSource.cacheCrews(crews);

      AppLogger.cacheSaved('crews');
      return const Right(null);
    } on NetworkException catch (e) {
      AppLogger.networkError('cacheCrews', e);
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      AppLogger.error('Error del servidor cacheando cuadrillas', error: e);
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      AppLogger.error('Error inesperado cacheando cuadrillas', error: e);
      return Left(UnknownFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>>
  getCachedNovelties() async {
    try {
      final novelties = await localDataSource.getCachedNovelties();
      AppLogger.cacheRead('novelties', novelties.isNotEmpty);
      return Right(novelties);
    } on CacheException catch (e) {
      AppLogger.cacheError('getCachedNovelties', e);
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      AppLogger.error('Error obteniendo novedades del cache', error: e);
      return Left(CacheFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getCachedCrews() async {
    try {
      final crews = await localDataSource.getCachedCrews();
      AppLogger.cacheRead('crews', crews.isNotEmpty);
      return Right(crews);
    } on CacheException catch (e) {
      AppLogger.cacheError('getCachedCrews', e);
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      AppLogger.error('Error obteniendo cuadrillas del cache', error: e);
      return Left(CacheFailure(message: 'Error inesperado: $e'));
    }
  }

  // ===========================================================================
  // HELPERS PRIVADOS
  // ===========================================================================

  /// Sube las evidencias de un reporte y retorna la lista actualizada
  Future<List<EvidenceModel>> _uploadEvidences(ReportModel report) async {
    final evidencesWithUrls = <EvidenceModel>[];

    for (final evidence in report.evidences) {
      if (evidence.isLocal && !evidence.isUploaded) {
        try {
          // Subir archivo al servidor
          final serverUrl = await remoteDataSource.uploadEvidence(
            evidence.getLocalFile()!,
            evidence.type.toString().split('.').last,
          );

          // Actualizar evidencia con URL del servidor
          final updatedEvidence = evidence.copyWith(
            url: serverUrl,
            uploadedAt: DateTime.now(),
          );

          evidencesWithUrls.add(updatedEvidence);
        } catch (e) {
          AppLogger.warning(
            'Error subiendo evidencia, usando ruta local',
            error: e,
          );
          evidencesWithUrls.add(evidence);
        }
      } else {
        evidencesWithUrls.add(evidence);
      }
    }

    return evidencesWithUrls;
  }

  /// Extrae mensaje de error de una excepción
  String _getErrorMessage(dynamic error) {
    if (error is NetworkException) return error.message;
    if (error is ServerException) return error.message;
    if (error is CacheException) return error.message;
    return error.toString();
  }
}

/// Resultado de la sincronización
class SyncResult {
  final int successCount;
  final int failureCount;
  final List<SyncFailureItem> failures;

  const SyncResult({
    required this.successCount,
    required this.failureCount,
    required this.failures,
  });

  bool get hasFailures => failureCount > 0;
  bool get allSuccess => failureCount == 0;
  int get totalCount => successCount + failureCount;
}

/// Item de fallo en sincronización
class SyncFailureItem {
  final String reportId;
  final String error;

  const SyncFailureItem({required this.reportId, required this.error});
}
