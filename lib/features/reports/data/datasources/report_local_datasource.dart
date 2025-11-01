// report_local_datasource.dart
//
// Fuente de datos local para reportes
//
// PROPÓSITO:
// - Almacenamiento offline de reportes con Drift (SQLite)
// - Cache local para funcionalidad offline-first
// - Cola de sincronización para reportes pendientes
// - Almacenamiento de evidencias locales
//
// CAPA: DATA LAYER
// DEPENDENCIAS: Puede importar Drift, SharedPreferences, File I/O

import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/report_model.dart';
import '../models/evidence_model.dart';

/// Contrato para la fuente de datos local de reportes
///
/// Define las operaciones de almacenamiento local para reportes,
/// evidencias y sincronización offline.
abstract class ReportLocalDataSource {
  // ===========================================================================
  // OPERACIONES DE REPORTES
  // ===========================================================================

  /// Obtiene todos los reportes locales
  Future<List<ReportModel>> getReports({
    bool onlyPending = false,
    String? status,
  });

  /// Obtiene un reporte por ID local
  Future<ReportModel?> getReportById(String id);

  /// Guarda un nuevo reporte localmente
  Future<void> saveReport(ReportModel report);

  /// Actualiza un reporte existente
  Future<void> updateReport(ReportModel report);

  /// Elimina un reporte
  Future<void> deleteReport(String id);

  // ===========================================================================
  // SINCRONIZACIÓN
  // ===========================================================================

  /// Obtiene reportes pendientes de sincronización
  Future<List<ReportModel>> getPendingSyncReports();

  /// Marca un reporte como sincronizado
  Future<void> markReportAsSynced(String localId, int serverId);

  /// Marca error de sincronización
  Future<void> markReportSyncError(String localId, String error);

  // ===========================================================================
  // EVIDENCIAS
  // ===========================================================================

  /// Guarda evidencias locales
  Future<void> saveLocalEvidence(
    String reportId,
    List<EvidenceModel> evidences,
  );

  /// Obtiene evidencias de un reporte
  Future<List<EvidenceModel>> getReportEvidences(String reportId);

  /// Copia un archivo a almacenamiento permanente
  Future<String> copyToLocalStorage(String sourcePath, String reportId);

  // ===========================================================================
  // CACHE DE DEPENDENCIAS
  // ===========================================================================

  /// Guarda novedades en cache
  Future<void> cacheNovelties(List<Map<String, dynamic>> novelties);

  /// Obtiene novedades del cache
  Future<List<Map<String, dynamic>>> getCachedNovelties();

  /// Guarda cuadrillas en cache
  Future<void> cacheCrews(List<Map<String, dynamic>> crews);

  /// Obtiene cuadrillas del cache
  Future<List<Map<String, dynamic>>> getCachedCrews();

  // ===========================================================================
  // UTILIDADES
  // ===========================================================================

  /// Limpia reportes sincronizados antiguos
  Future<void> cleanupOldReports({int daysToKeep = 30});

  /// Limpia cache antiguo
  Future<void> cleanupOldCache({int daysToKeep = 7});
}

/// Implementación de la fuente de datos local de reportes
///
/// Utiliza Drift (SQLite) para persistencia y gestión de archivos locales
class ReportLocalDataSourceImpl implements ReportLocalDataSource {
  final AppDatabase _database;

  const ReportLocalDataSourceImpl(this._database);

  // ===========================================================================
  // OPERACIONES DE REPORTES
  // ===========================================================================

  @override
  Future<List<ReportModel>> getReports({
    bool onlyPending = false,
    String? status,
  }) async {
    try {
      AppLogger.debug('📦 Obteniendo reportes locales (pending: $onlyPending)');

      final reports = onlyPending
          ? await _database.getPendingSyncReports()
          : await _database.getAllReports();

      AppLogger.debug('✅ Encontrados ${reports.length} reportes locales');

      // Convertir a modelos
      final models = <ReportModel>[];
      for (final report in reports) {
        // Obtener evidencias
        final evidences = await getReportEvidences(report.id);

        models.add(ReportModel.fromDrift(report, evidences));
      }

      return models;
    } catch (e) {
      AppLogger.cacheError('getReports', e);
      throw CacheException(
        message: 'Error obteniendo reportes locales: $e',
        code: 'GET_REPORTS_ERROR',
      );
    }
  }

  @override
  Future<ReportModel?> getReportById(String id) async {
    try {
      AppLogger.debug('📦 Obteniendo reporte local: $id');

      final report = await _database.getReportById(id);
      if (report == null) {
        AppLogger.debug('⚠️ Reporte no encontrado localmente: $id');
        return null;
      }

      final evidences = await getReportEvidences(id);

      return ReportModel.fromDrift(report, evidences);
    } catch (e) {
      AppLogger.cacheError('getReportById', e);
      throw CacheException(
        message: 'Error obteniendo reporte: $e',
        code: 'GET_REPORT_ERROR',
      );
    }
  }

  @override
  Future<void> saveReport(ReportModel report) async {
    try {
      AppLogger.debug('💾 Guardando reporte localmente: ${report.id}');

      final companion = ReportTableCompanion(
        id: drift.Value(report.id),
        serverId: drift.Value(report.serverId),
        noveltyId: drift.Value(report.noveltyId),
        workDescription: drift.Value(report.workDescription),
        observations: drift.Value(report.observations),
        workTime: drift.Value(report.workTime),
        participantIds: drift.Value(jsonEncode(report.participantIds)),
        latitude: drift.Value(report.latitude),
        longitude: drift.Value(report.longitude),
        accuracy: drift.Value(report.accuracy),
        createdAt: drift.Value(report.createdAt),
        updatedAt: drift.Value(report.updatedAt),
        isSynced: drift.Value(report.isSynced),
        syncedAt: drift.Value(report.syncedAt),
        lastSyncAttempt: drift.Value(report.lastSyncAttempt),
        syncAttempts: drift.Value(report.syncAttempts),
        syncError: drift.Value(report.syncError),
      );

      await _database.insertReport(companion);

      // Guardar evidencias
      if (report.evidences.isNotEmpty) {
        await saveLocalEvidence(report.id, report.evidences);
      }

      AppLogger.success('Reporte guardado localmente: ${report.id}');
    } catch (e) {
      AppLogger.cacheError('saveReport', e);
      throw CacheException(
        message: 'Error guardando reporte: $e',
        code: 'SAVE_REPORT_ERROR',
      );
    }
  }

  @override
  Future<void> updateReport(ReportModel report) async {
    try {
      AppLogger.debug('🔄 Actualizando reporte local: ${report.id}');

      final companion = ReportTableCompanion(
        id: drift.Value(report.id),
        serverId: drift.Value(report.serverId),
        noveltyId: drift.Value(report.noveltyId),
        workDescription: drift.Value(report.workDescription),
        observations: drift.Value(report.observations),
        workTime: drift.Value(report.workTime),
        participantIds: drift.Value(jsonEncode(report.participantIds)),
        latitude: drift.Value(report.latitude),
        longitude: drift.Value(report.longitude),
        accuracy: drift.Value(report.accuracy),
        createdAt: drift.Value(report.createdAt),
        updatedAt: drift.Value(DateTime.now()),
        isSynced: drift.Value(report.isSynced),
        syncedAt: drift.Value(report.syncedAt),
        lastSyncAttempt: drift.Value(report.lastSyncAttempt),
        syncAttempts: drift.Value(report.syncAttempts),
        syncError: drift.Value(report.syncError),
      );

      await _database.updateReport(companion);

      AppLogger.success('Reporte actualizado localmente: ${report.id}');
    } catch (e) {
      AppLogger.cacheError('updateReport', e);
      throw CacheException(
        message: 'Error actualizando reporte: $e',
        code: 'UPDATE_REPORT_ERROR',
      );
    }
  }

  @override
  Future<void> deleteReport(String id) async {
    try {
      AppLogger.debug('🗑️ Eliminando reporte local: $id');

      // Eliminar evidencias primero
      await _database.deleteReportEvidences(id);

      // Eliminar reporte
      await _database.deleteReport(id);

      AppLogger.success('Reporte eliminado localmente: $id');
    } catch (e) {
      AppLogger.cacheError('deleteReport', e);
      throw CacheException(
        message: 'Error eliminando reporte: $e',
        code: 'DELETE_REPORT_ERROR',
      );
    }
  }

  // ===========================================================================
  // SINCRONIZACIÓN
  // ===========================================================================

  @override
  Future<List<ReportModel>> getPendingSyncReports() async {
    return getReports(onlyPending: true);
  }

  @override
  Future<void> markReportAsSynced(String localId, int serverId) async {
    try {
      AppLogger.debug('✅ Marcando reporte como sincronizado: $localId');

      await _database.markReportAsSynced(localId, serverId);

      AppLogger.success('Reporte sincronizado: $localId -> server: $serverId');
    } catch (e) {
      AppLogger.cacheError('markReportAsSynced', e);
      throw CacheException(
        message: 'Error marcando reporte como sincronizado: $e',
        code: 'MARK_SYNCED_ERROR',
      );
    }
  }

  @override
  Future<void> markReportSyncError(String localId, String error) async {
    try {
      AppLogger.debug('❌ Marcando error de sincronización: $localId');

      await _database.markReportSyncError(localId, error);

      AppLogger.warning('Error de sincronización registrado: $localId');
    } catch (e) {
      AppLogger.cacheError('markReportSyncError', e);
      throw CacheException(
        message: 'Error marcando error de sincronización: $e',
        code: 'MARK_SYNC_ERROR_ERROR',
      );
    }
  }

  // ===========================================================================
  // EVIDENCIAS
  // ===========================================================================

  @override
  Future<void> saveLocalEvidence(
    String reportId,
    List<EvidenceModel> evidences,
  ) async {
    try {
      AppLogger.debug(
        '💾 Guardando ${evidences.length} evidencias para reporte: $reportId',
      );

      for (final evidence in evidences) {
        // Copiar archivo a almacenamiento permanente si es necesario
        String localPath = evidence.localPath ?? '';
        if (localPath.isEmpty && evidence.url != null) {
          localPath = evidence.url!;
        }

        final companion = ReportEvidenceTableCompanion(
          reportId: drift.Value(reportId),
          type: drift.Value(evidence.type.toString().split('.').last),
          localPath: drift.Value(localPath),
          fileName: drift.Value(evidence.fileName ?? 'unknown'),
          fileSize: drift.Value(evidence.fileSize ?? 0),
          mimeType: drift.Value(
            evidence.mimeType ?? 'application/octet-stream',
          ),
          serverUrl: drift.Value(evidence.url),
          isUploaded: drift.Value(evidence.url != null),
          uploadedAt: drift.Value(evidence.uploadedAt),
          createdAt: drift.Value(DateTime.now()),
        );

        await _database.insertEvidence(companion);
      }

      AppLogger.success('Evidencias guardadas para reporte: $reportId');
    } catch (e) {
      AppLogger.cacheError('saveLocalEvidence', e);
      throw CacheException(
        message: 'Error guardando evidencias: $e',
        code: 'SAVE_EVIDENCE_ERROR',
      );
    }
  }

  @override
  Future<List<EvidenceModel>> getReportEvidences(String reportId) async {
    try {
      final evidences = await _database.getReportEvidences(reportId);

      return evidences.map((e) {
        // Determinar tipo de evidencia
        EvidenceType type = EvidenceType.photo;
        if (e.type == 'VIDEO') type = EvidenceType.video;
        if (e.type == 'AUDIO') type = EvidenceType.audio;

        return EvidenceModel(
          type: type,
          localPath: e.localPath,
          url: e.serverUrl,
          fileName: e.fileName,
          fileSize: e.fileSize,
          mimeType: e.mimeType,
          uploadedAt: e.uploadedAt,
        );
      }).toList();
    } catch (e) {
      AppLogger.cacheError('getReportEvidences', e);
      return [];
    }
  }

  @override
  Future<String> copyToLocalStorage(String sourcePath, String reportId) async {
    try {
      AppLogger.debug('📁 Copiando archivo a almacenamiento local');

      final appDir = await getApplicationDocumentsDirectory();
      final reportsDir = Directory(p.join(appDir.path, 'reports', reportId));

      if (!await reportsDir.exists()) {
        await reportsDir.create(recursive: true);
      }

      final sourceFile = File(sourcePath);
      final fileName = p.basename(sourcePath);
      final destPath = p.join(reportsDir.path, fileName);

      await sourceFile.copy(destPath);

      AppLogger.success('Archivo copiado: $destPath');
      return destPath;
    } catch (e) {
      AppLogger.error('Error copiando archivo', error: e);
      throw CacheException(
        message: 'Error copiando archivo: $e',
        code: 'COPY_FILE_ERROR',
      );
    }
  }

  // ===========================================================================
  // CACHE DE DEPENDENCIAS
  // ===========================================================================

  @override
  Future<void> cacheNovelties(List<Map<String, dynamic>> novelties) async {
    try {
      AppLogger.debug('💾 Guardando ${novelties.length} novedades en cache');

      final companions = novelties.map((json) {
        return NoveltyCacheTableCompanion(
          noveltyId: drift.Value(json['id'] as int),
          areaId: drift.Value(json['areaId'] as int),
          reason: drift.Value(json['reason'] as String),
          accountNumber: drift.Value(json['accountNumber'] as String),
          meterNumber: drift.Value(json['meterNumber'] as String),
          activeReading: drift.Value((json['activeReading'] as num).toDouble()),
          reactiveReading: drift.Value(
            (json['reactiveReading'] as num).toDouble(),
          ),
          municipality: drift.Value(json['municipality'] as String),
          address: drift.Value(json['address'] as String),
          description: drift.Value(json['description'] as String),
          observations: drift.Value(json['observations'] as String?),
          status: drift.Value(json['status'] as String),
          createdBy: drift.Value(json['createdBy'] as int),
          crewId: drift.Value(json['crewId'] as int?),
          createdAt: drift.Value(DateTime.parse(json['createdAt'] as String)),
          updatedAt: drift.Value(DateTime.parse(json['updatedAt'] as String)),
          completedAt: drift.Value(
            json['completedAt'] != null
                ? DateTime.parse(json['completedAt'] as String)
                : null,
          ),
          closedAt: drift.Value(
            json['closedAt'] != null
                ? DateTime.parse(json['closedAt'] as String)
                : null,
          ),
          cancelledAt: drift.Value(
            json['cancelledAt'] != null
                ? DateTime.parse(json['cancelledAt'] as String)
                : null,
          ),
          cachedAt: drift.Value(DateTime.now()),
          rawJson: drift.Value(jsonEncode(json)),
        );
      }).toList();

      await _database.upsertNoveltiesCache(companions);

      AppLogger.success('Novedades guardadas en cache');
    } catch (e) {
      AppLogger.cacheError('cacheNovelties', e);
      throw CacheException(
        message: 'Error guardando novedades en cache: $e',
        code: 'CACHE_NOVELTIES_ERROR',
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCachedNovelties() async {
    try {
      AppLogger.debug('📦 Obteniendo novedades del cache');

      final novelties = await _database.getAllCachedNovelties();

      final result = novelties.map((n) {
        return jsonDecode(n.rawJson) as Map<String, dynamic>;
      }).toList();

      AppLogger.debug('✅ Encontradas ${result.length} novedades en cache');

      return result;
    } catch (e) {
      AppLogger.cacheError('getCachedNovelties', e);
      return [];
    }
  }

  @override
  Future<void> cacheCrews(List<Map<String, dynamic>> crews) async {
    try {
      AppLogger.debug('💾 Guardando ${crews.length} cuadrillas en cache');

      final companions = crews.map((json) {
        return CrewCacheTableCompanion(
          crewId: drift.Value(json['id'] as int),
          name: drift.Value(json['name'] as String),
          description: drift.Value(json['description'] as String),
          status: drift.Value(json['status'] as String),
          createdBy: drift.Value(json['createdBy'] as int),
          activeMemberCount: drift.Value(json['activeMemberCount'] as int?),
          hasActiveAssignments: drift.Value(
            json['hasActiveAssignments'] as bool?,
          ),
          createdAt: drift.Value(DateTime.parse(json['createdAt'] as String)),
          updatedAt: drift.Value(DateTime.parse(json['updatedAt'] as String)),
          deletedAt: drift.Value(
            json['deletedAt'] != null
                ? DateTime.parse(json['deletedAt'] as String)
                : null,
          ),
          cachedAt: drift.Value(DateTime.now()),
          rawJson: drift.Value(jsonEncode(json)),
        );
      }).toList();

      await _database.upsertCrewsCache(companions);

      AppLogger.success('Cuadrillas guardadas en cache');
    } catch (e) {
      AppLogger.cacheError('cacheCrews', e);
      throw CacheException(
        message: 'Error guardando cuadrillas en cache: $e',
        code: 'CACHE_CREWS_ERROR',
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCachedCrews() async {
    try {
      AppLogger.debug('📦 Obteniendo cuadrillas del cache');

      final crews = await _database.getAllCachedCrews();

      final result = crews.map((c) {
        return jsonDecode(c.rawJson) as Map<String, dynamic>;
      }).toList();

      AppLogger.debug('✅ Encontradas ${result.length} cuadrillas en cache');

      return result;
    } catch (e) {
      AppLogger.cacheError('getCachedCrews', e);
      return [];
    }
  }

  // ===========================================================================
  // UTILIDADES
  // ===========================================================================

  @override
  Future<void> cleanupOldReports({int daysToKeep = 30}) async {
    try {
      AppLogger.debug('🧹 Limpiando reportes sincronizados antiguos');

      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));

      // Aquí se podría implementar lógica adicional para eliminar
      // reportes sincronizados antiguos
      // Por ahora solo dejamos el log

      AppLogger.success('Limpieza de reportes completada');
    } catch (e) {
      AppLogger.warning('Error limpiando reportes antiguos', error: e);
    }
  }

  @override
  Future<void> cleanupOldCache({int daysToKeep = 7}) async {
    try {
      AppLogger.debug('🧹 Limpiando cache antiguo');

      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));

      await _database.clearOldNoveltyCache(cutoffDate);
      await _database.clearOldCrewCache(cutoffDate);

      AppLogger.success('Limpieza de cache completada');
    } catch (e) {
      AppLogger.warning('Error limpiando cache antiguo', error: e);
    }
  }
}
