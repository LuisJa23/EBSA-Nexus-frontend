// novelty_cache_table.dart
//
// Tabla para almacenar cache de novedades
//
// PROPÓSITO:
// - Cache offline de novedades para consulta sin conexión
// - Permitir operaciones offline-first
// - Reducir llamadas a API
//
// CAPA: CORE - DATABASE

import 'package:drift/drift.dart';

/// Tabla de cache de novedades
///
/// Almacena novedades descargadas para acceso offline
@DataClassName('NoveltyCacheTableData')
class NoveltyCacheTable extends Table {
  // ===========================================================================
  // IDENTIFICACIÓN
  // ===========================================================================

  /// ID de la novedad (clave primaria, del servidor)
  IntColumn get noveltyId => integer().named('novelty_id')();

  // ===========================================================================
  // INFORMACIÓN BÁSICA
  // ===========================================================================

  /// ID del área
  IntColumn get areaId => integer().named('area_id')();

  /// Razón/motivo de la novedad
  TextColumn get reason => text()();

  /// Número de cuenta
  TextColumn get accountNumber => text().named('account_number')();

  /// Número de medidor
  TextColumn get meterNumber => text().named('meter_number')();

  /// Lectura activa
  RealColumn get activeReading => real().named('active_reading')();

  /// Lectura reactiva
  RealColumn get reactiveReading => real().named('reactive_reading')();

  /// Municipio
  TextColumn get municipality => text()();

  /// Dirección
  TextColumn get address => text()();

  /// Descripción
  TextColumn get description => text()();

  /// Observaciones (opcional)
  TextColumn get observations => text().nullable()();

  // ===========================================================================
  // ESTADO Y ASIGNACIÓN
  // ===========================================================================

  /// Estado de la novedad
  TextColumn get status => text()();

  /// ID del usuario que creó la novedad
  IntColumn get createdBy => integer().named('created_by')();

  /// ID de la cuadrilla asignada (opcional)
  IntColumn get crewId => integer().named('crew_id').nullable()();

  // ===========================================================================
  // FECHAS
  // ===========================================================================

  /// Fecha de creación en el servidor
  DateTimeColumn get createdAt => dateTime().named('created_at')();

  /// Fecha de última actualización en el servidor
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  /// Fecha de completado (opcional)
  DateTimeColumn get completedAt =>
      dateTime().named('completed_at').nullable()();

  /// Fecha de cierre (opcional)
  DateTimeColumn get closedAt => dateTime().named('closed_at').nullable()();

  /// Fecha de cancelación (opcional)
  DateTimeColumn get cancelledAt =>
      dateTime().named('cancelled_at').nullable()();

  // ===========================================================================
  // CACHE METADATA
  // ===========================================================================

  /// Fecha de almacenamiento en cache
  DateTimeColumn get cachedAt => dateTime().named('cached_at')();

  /// Datos JSON completos para información adicional
  TextColumn get rawJson => text().named('raw_json')();

  // ===========================================================================
  // CONFIGURACIÓN DE TABLA
  // ===========================================================================

  @override
  Set<Column> get primaryKey => {noveltyId};

  @override
  String get tableName => 'novelty_cache';
}
