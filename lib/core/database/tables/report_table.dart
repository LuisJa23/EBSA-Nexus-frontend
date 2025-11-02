// report_table.dart
//
// Tabla para almacenar reportes offline
//
// PROPÓSITO:
// - Almacenamiento de reportes creados offline
// - Gestión de sincronización
// - Cola de reportes pendientes de envío
//
// CAPA: CORE - DATABASE

import 'package:drift/drift.dart';

/// Tabla de reportes offline
///
/// Almacena reportes creados localmente que serán sincronizados
@DataClassName('ReportTableData')
class ReportTable extends Table {
  // ===========================================================================
  // IDENTIFICACIÓN
  // ===========================================================================

  /// ID local del reporte (UUID generado localmente)
  TextColumn get id => text()();

  /// ID del servidor (null hasta sincronizar)
  IntColumn get serverId => integer().named('server_id').nullable()();

  // ===========================================================================
  // DATOS DEL REPORTE
  // ===========================================================================

  /// ID de la novedad asociada
  IntColumn get noveltyId => integer().named('novelty_id')();

  /// Descripción del trabajo realizado
  TextColumn get workDescription => text().named('work_description')();

  /// Observaciones adicionales (opcional)
  TextColumn get observations => text().nullable()();

  /// Tiempo de trabajo en minutos
  IntColumn get workTime => integer().named('work_time')();

  /// Fecha de inicio del trabajo
  DateTimeColumn get workStartDate => dateTime().named('work_start_date')();

  /// Fecha de fin del trabajo
  DateTimeColumn get workEndDate => dateTime().named('work_end_date')();

  /// IDs de participantes (JSON array)
  TextColumn get participantIds => text().named('participant_ids')();

  /// Estado de resolución (COMPLETADO, NO_COMPLETADO)
  TextColumn get resolutionStatus => text()
      .named('resolution_status')
      .withDefault(const Constant('COMPLETADO'))();

  // ===========================================================================
  // UBICACIÓN GPS
  // ===========================================================================

  /// Latitud
  RealColumn get latitude => real()();

  /// Longitud
  RealColumn get longitude => real()();

  /// Precisión del GPS (metros)
  RealColumn get accuracy => real().nullable()();

  // ===========================================================================
  // FECHAS
  // ===========================================================================

  /// Fecha de creación local
  DateTimeColumn get createdAt => dateTime().named('created_at')();

  /// Fecha de última modificación local
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  // ===========================================================================
  // SINCRONIZACIÓN
  // ===========================================================================

  /// Está sincronizado con el servidor
  BoolColumn get isSynced =>
      boolean().named('is_synced').withDefault(const Constant(false))();

  /// Fecha de sincronización exitosa
  DateTimeColumn get syncedAt => dateTime().named('synced_at').nullable()();

  /// Último intento de sincronización
  DateTimeColumn get lastSyncAttempt =>
      dateTime().named('last_sync_attempt').nullable()();

  /// Cantidad de intentos de sincronización
  IntColumn get syncAttempts =>
      integer().named('sync_attempts').withDefault(const Constant(0))();

  /// Error de sincronización (si existe)
  TextColumn get syncError => text().named('sync_error').nullable()();

  // ===========================================================================
  // CONFIGURACIÓN DE TABLA
  // ===========================================================================

  @override
  Set<Column> get primaryKey => {id};

  @override
  String get tableName => 'reports';
}
