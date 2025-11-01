// report_repository.dart - INTERFAZ DOMINIO (NO DEPENDENCIAS EXTERNAS)
//
// Repositorio de reportes con soporte offline
//
// PROPÓSITO:
// - Definir contrato para operaciones de reportes
// - Soporte para operaciones offline-first
// - Sincronización manual de reportes
// - Cache de dependencias (novedades y cuadrillas)

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../data/models/report_model.dart';
import '../../data/repositories/report_repository_impl.dart';

/// Repositorio de reportes con funcionalidad offline
abstract class ReportRepository {
  /// Obtiene todos los reportes locales
  Future<Either<Failure, List<ReportModel>>> getReports({
    bool onlyPending = false,
  });

  /// Obtiene un reporte por ID
  Future<Either<Failure, ReportModel?>> getReportById(String id);

  /// Crea un reporte localmente (offline)
  Future<Either<Failure, ReportModel>> createReportOffline(ReportModel report);

  /// Actualiza un reporte local
  Future<Either<Failure, void>> updateReport(ReportModel report);

  /// Elimina un reporte
  Future<Either<Failure, void>> deleteReport(String id);

  /// Sincroniza reportes pendientes con el servidor
  Future<Either<Failure, SyncResult>> syncPendingReports();

  /// Obtiene cantidad de reportes pendientes de sincronizar
  Future<Either<Failure, int>> getPendingReportsCount();

  /// Cachea novedades para uso offline
  Future<Either<Failure, void>> cacheNovelties();

  /// Cachea cuadrillas para uso offline
  Future<Either<Failure, void>> cacheCrews();

  /// Obtiene novedades del cache
  Future<Either<Failure, List<Map<String, dynamic>>>> getCachedNovelties();

  /// Obtiene cuadrillas del cache
  Future<Either<Failure, List<Map<String, dynamic>>>> getCachedCrews();
}
