// sync_queue_table.dart
//
// Tabla para cola de sincronización
//
// PROPÓSITO:
// - Gestionar cola de operaciones pendientes de sincronización
// - Rastrear estado de sincronización
// - Retry logic para operaciones fallidas
//
// CAPA: CORE - DATABASE

import 'package:drift/drift.dart';

/// Tabla de cola de sincronización
///
/// Gestiona operaciones pendientes de sincronización con el servidor
@DataClassName('SyncQueueTableData')
class SyncQueueTable extends Table {
  // ===========================================================================
  // IDENTIFICACIÓN
  // ===========================================================================

  /// ID de la operación
  IntColumn get id => integer().autoIncrement()();

  // ===========================================================================
  // INFORMACIÓN DE LA OPERACIÓN
  // ===========================================================================

  /// Tipo de operación (REPORT_CREATE, REPORT_UPDATE, etc.)
  TextColumn get operationType => text().named('operation_type')();

  /// ID del recurso asociado (report ID, evidence ID, etc.)
  TextColumn get resourceId => text().named('resource_id')();

  /// Datos de la operación (JSON)
  TextColumn get payload => text()();

  // ===========================================================================
  // ESTADO
  // ===========================================================================

  /// Estado (PENDING, COMPLETED, FAILED)
  TextColumn get status => text()();

  /// Cantidad de reintentos
  IntColumn get retryCount =>
      integer().named('retry_count').withDefault(const Constant(0))();

  /// Último error
  TextColumn get lastError => text().named('last_error').nullable()();

  // ===========================================================================
  // FECHAS
  // ===========================================================================

  /// Fecha de creación de la operación
  DateTimeColumn get createdAt => dateTime().named('created_at')();

  /// Fecha de último intento
  DateTimeColumn get lastAttemptAt =>
      dateTime().named('last_attempt_at').nullable()();

  /// Fecha de completado
  DateTimeColumn get completedAt =>
      dateTime().named('completed_at').nullable()();

  // ===========================================================================
  // CONFIGURACIÓN DE TABLA
  // ===========================================================================

  @override
  String get tableName => 'sync_queue';
}
