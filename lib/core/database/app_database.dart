// app_database.dart
//
// Base de datos local de la aplicación usando Drift (SQLite)
//
// PROPÓSITO:
// - Almacenamiento offline de datos críticos
// - Cache de novedades, cuadrillas y reportes
// - Cola de sincronización
// - Soporte para operaciones offline-first
//
// CAPA: CORE - DATABASE

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/novelty_cache_table.dart';
import 'tables/crew_cache_table.dart';
import 'tables/report_table.dart';
import 'tables/report_evidence_table.dart';
import 'tables/sync_queue_table.dart';

part 'app_database.g.dart';

/// Base de datos principal de la aplicación
///
/// Gestiona todas las operaciones de persistencia local usando Drift (SQLite)
/// Incluye tablas para cache, reportes offline y sincronización
@DriftDatabase(
  tables: [
    NoveltyCacheTable,
    CrewCacheTable,
    ReportTable,
    ReportEvidenceTable,
    SyncQueueTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3; // Incrementado para agregar campo resolutionStatus

  // ===========================================================================
  // MIGRACIONES DE BASE DE DATOS
  // ===========================================================================

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // Migración de v1 a v2 o superior
          // Recrear toda la base de datos para la versión 2
          // Esto es necesario porque hubo cambios estructurales significativos

          // Eliminar todas las tablas antiguas si existen
          try {
            await m.deleteTable('reports');
          } catch (_) {}
          try {
            await m.deleteTable('report_evidences');
          } catch (_) {}
          try {
            await m.deleteTable('novelty_cache');
          } catch (_) {}
          try {
            await m.deleteTable('crew_cache');
          } catch (_) {}
          try {
            await m.deleteTable('sync_queue');
          } catch (_) {}

          // Crear todas las tablas nuevas
          await m.createAll();
        } else if (from == 2 && to >= 3) {
          // Migración de v2 a v3: Agregar campo resolutionStatus
          // Solo intentar si la columna no existe
          try {
            await m.addColumn(
              reportTable,
              reportTable.resolutionStatus as GeneratedColumn,
            );
            print('✅ Columna resolutionStatus agregada exitosamente');
          } catch (e) {
            // Si falla, probablemente la columna ya existe
            print(
              '⚠️ Columna resolutionStatus ya existe o error al agregar: $e',
            );
            // Continuar sin error, la columna ya está presente
          }
        }
      },
    );
  }

  // ===========================================================================
  // OPERACIONES DE CACHE DE NOVEDADES
  // ===========================================================================

  /// Guarda o actualiza una novedad en cache
  Future<int> upsertNoveltyCache(NoveltyCacheTableCompanion novelty) async {
    return await into(noveltyCacheTable).insertOnConflictUpdate(novelty);
  }

  /// Guarda múltiples novedades en cache
  Future<void> upsertNoveltiesCache(
    List<NoveltyCacheTableCompanion> novelties,
  ) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(noveltyCacheTable, novelties);
    });
  }

  /// Obtiene todas las novedades en cache
  Future<List<NoveltyCacheTableData>> getAllCachedNovelties() async {
    return await select(noveltyCacheTable).get();
  }

  /// Obtiene una novedad específica del cache
  Future<NoveltyCacheTableData?> getCachedNoveltyById(int noveltyId) async {
    return await (select(
      noveltyCacheTable,
    )..where((tbl) => tbl.noveltyId.equals(noveltyId))).getSingleOrNull();
  }

  /// Obtiene novedades por estado
  Future<List<NoveltyCacheTableData>> getCachedNoveltiesByStatus(
    String status,
  ) async {
    return await (select(
      noveltyCacheTable,
    )..where((tbl) => tbl.status.equals(status))).get();
  }

  /// Limpia cache de novedades antiguas
  Future<int> clearOldNoveltyCache(DateTime olderThan) async {
    return await (delete(
      noveltyCacheTable,
    )..where((tbl) => tbl.cachedAt.isSmallerThanValue(olderThan))).go();
  }

  /// Limpia todo el cache de novedades
  Future<int> clearAllNoveltyCache() async {
    return await delete(noveltyCacheTable).go();
  }

  // ===========================================================================
  // OPERACIONES DE CACHE DE CUADRILLAS
  // ===========================================================================

  /// Guarda o actualiza una cuadrilla en cache
  Future<int> upsertCrewCache(CrewCacheTableCompanion crew) async {
    return await into(crewCacheTable).insertOnConflictUpdate(crew);
  }

  /// Guarda múltiples cuadrillas en cache
  Future<void> upsertCrewsCache(List<CrewCacheTableCompanion> crews) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(crewCacheTable, crews);
    });
  }

  /// Obtiene todas las cuadrillas en cache
  Future<List<CrewCacheTableData>> getAllCachedCrews() async {
    return await select(crewCacheTable).get();
  }

  /// Obtiene una cuadrilla específica del cache
  Future<CrewCacheTableData?> getCachedCrewById(int crewId) async {
    return await (select(
      crewCacheTable,
    )..where((tbl) => tbl.crewId.equals(crewId))).getSingleOrNull();
  }

  /// Obtiene cuadrillas activas del cache
  Future<List<CrewCacheTableData>> getActiveCachedCrews() async {
    return await (select(
      crewCacheTable,
    )..where((tbl) => tbl.status.equals('ACTIVA'))).get();
  }

  /// Limpia cache de cuadrillas antiguas
  Future<int> clearOldCrewCache(DateTime olderThan) async {
    return await (delete(
      crewCacheTable,
    )..where((tbl) => tbl.cachedAt.isSmallerThanValue(olderThan))).go();
  }

  /// Limpia todo el cache de cuadrillas
  Future<int> clearAllCrewCache() async {
    return await delete(crewCacheTable).go();
  }

  // ===========================================================================
  // OPERACIONES DE REPORTES OFFLINE
  // ===========================================================================

  /// Crea un nuevo reporte offline
  Future<int> insertReport(ReportTableCompanion report) async {
    return await into(reportTable).insert(report);
  }

  /// Obtiene todos los reportes locales
  Future<List<ReportTableData>> getAllReports() async {
    return await select(reportTable).get();
  }

  /// Obtiene un reporte por ID
  Future<ReportTableData?> getReportById(String reportId) async {
    return await (select(
      reportTable,
    )..where((tbl) => tbl.id.equals(reportId))).getSingleOrNull();
  }

  /// Obtiene reportes no sincronizados
  Future<List<ReportTableData>> getPendingSyncReports() async {
    return await (select(
      reportTable,
    )..where((tbl) => tbl.isSynced.equals(false))).get();
  }

  /// Actualiza un reporte
  Future<bool> updateReport(ReportTableCompanion report) async {
    return await update(reportTable).replace(report);
  }

  /// Marca un reporte como sincronizado
  Future<int> markReportAsSynced(String reportId, int? serverId) async {
    return await (update(
      reportTable,
    )..where((tbl) => tbl.id.equals(reportId))).write(
      ReportTableCompanion(
        isSynced: const Value(true),
        syncedAt: Value(DateTime.now()),
        serverId: Value(serverId),
        lastSyncAttempt: Value(DateTime.now()),
        syncError: const Value(null),
      ),
    );
  }

  /// Marca un error de sincronización
  Future<int> markReportSyncError(String reportId, String error) async {
    // Primero obtener el reporte actual
    final currentReport = await getReportById(reportId);
    if (currentReport == null) return 0;

    return await (update(
      reportTable,
    )..where((tbl) => tbl.id.equals(reportId))).write(
      ReportTableCompanion(
        lastSyncAttempt: Value(DateTime.now()),
        syncError: Value(error),
        syncAttempts: Value(currentReport.syncAttempts + 1),
      ),
    );
  }

  /// Actualiza el intento de sincronización de un reporte
  Future<int> updateReportSyncAttempt(String reportId, String error) async {
    return await markReportSyncError(reportId, error);
  }

  /// Elimina un reporte
  Future<int> deleteReport(String reportId) async {
    return await (delete(
      reportTable,
    )..where((tbl) => tbl.id.equals(reportId))).go();
  }

  // ===========================================================================
  // OPERACIONES DE EVIDENCIAS
  // ===========================================================================

  /// Inserta evidencia de un reporte
  Future<int> insertEvidence(ReportEvidenceTableCompanion evidence) async {
    return await into(reportEvidenceTable).insert(evidence);
  }

  /// Obtiene todas las evidencias de un reporte
  Future<List<ReportEvidenceTableData>> getReportEvidences(
    String reportId,
  ) async {
    return await (select(
      reportEvidenceTable,
    )..where((tbl) => tbl.reportId.equals(reportId))).get();
  }

  /// Elimina evidencias de un reporte
  Future<int> deleteReportEvidences(String reportId) async {
    return await (delete(
      reportEvidenceTable,
    )..where((tbl) => tbl.reportId.equals(reportId))).go();
  }

  // ===========================================================================
  // OPERACIONES DE COLA DE SINCRONIZACIÓN
  // ===========================================================================

  /// Agrega una operación a la cola de sincronización
  Future<int> enqueueSyncOperation(SyncQueueTableCompanion operation) async {
    return await into(syncQueueTable).insert(operation);
  }

  /// Obtiene operaciones pendientes de sincronización
  Future<List<SyncQueueTableData>> getPendingSyncOperations() async {
    return await (select(syncQueueTable)
          ..where((tbl) => tbl.status.equals('PENDING'))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  /// Marca una operación como completada
  Future<int> markSyncOperationCompleted(int operationId) async {
    return await (update(
      syncQueueTable,
    )..where((tbl) => tbl.id.equals(operationId))).write(
      SyncQueueTableCompanion(
        status: const Value('COMPLETED'),
        completedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Marca una operación como fallida
  Future<int> markSyncOperationFailed(int operationId, String error) async {
    // Obtener operación actual
    final currentOp = await (select(
      syncQueueTable,
    )..where((tbl) => tbl.id.equals(operationId))).getSingleOrNull();
    if (currentOp == null) return 0;

    return await (update(
      syncQueueTable,
    )..where((tbl) => tbl.id.equals(operationId))).write(
      SyncQueueTableCompanion(
        status: const Value('FAILED'),
        lastError: Value(error),
        retryCount: Value(currentOp.retryCount + 1),
      ),
    );
  }

  /// Elimina operaciones completadas
  Future<int> clearCompletedSyncOperations() async {
    return await (delete(
      syncQueueTable,
    )..where((tbl) => tbl.status.equals('COMPLETED'))).go();
  }

  // ===========================================================================
  // UTILIDADES
  // ===========================================================================

  /// Limpia toda la base de datos
  Future<void> clearAllData() async {
    await transaction(() async {
      await delete(noveltyCacheTable).go();
      await delete(crewCacheTable).go();
      await delete(reportTable).go();
      await delete(reportEvidenceTable).go();
      await delete(syncQueueTable).go();
    });
  }
}

/// Abre la conexión a la base de datos
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'ebsa_nexus.db'));

    print('💾 Ruta de base de datos: ${file.path}');

    return NativeDatabase.createInBackground(file);
  });
}
