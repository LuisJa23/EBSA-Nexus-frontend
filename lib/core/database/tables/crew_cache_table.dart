// crew_cache_table.dart
//
// Tabla para almacenar cache de cuadrillas
//
// PROPÓSITO:
// - Cache offline de cuadrillas para consulta sin conexión
// - Permitir operaciones offline-first
// - Reducir llamadas a API
//
// CAPA: CORE - DATABASE

import 'package:drift/drift.dart';

/// Tabla de cache de cuadrillas
///
/// Almacena cuadrillas descargadas para acceso offline
@DataClassName('CrewCacheTableData')
class CrewCacheTable extends Table {
  // ===========================================================================
  // IDENTIFICACIÓN
  // ===========================================================================

  /// ID de la cuadrilla (clave primaria, del servidor)
  IntColumn get crewId => integer().named('crew_id')();

  // ===========================================================================
  // INFORMACIÓN BÁSICA
  // ===========================================================================

  /// Nombre de la cuadrilla
  TextColumn get name => text()();

  /// Descripción
  TextColumn get description => text()();

  /// Estado (ACTIVA, INACTIVA, etc.)
  TextColumn get status => text()();

  /// ID del usuario que creó la cuadrilla
  IntColumn get createdBy => integer().named('created_by')();

  // ===========================================================================
  // INFORMACIÓN ADICIONAL
  // ===========================================================================

  /// Cantidad de miembros activos
  IntColumn get activeMemberCount =>
      integer().named('active_member_count').nullable()();

  /// Tiene asignaciones activas
  BoolColumn get hasActiveAssignments =>
      boolean().named('has_active_assignments').nullable()();

  // ===========================================================================
  // FECHAS
  // ===========================================================================

  /// Fecha de creación en el servidor
  DateTimeColumn get createdAt => dateTime().named('created_at')();

  /// Fecha de última actualización en el servidor
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  /// Fecha de eliminación (opcional)
  DateTimeColumn get deletedAt => dateTime().named('deleted_at').nullable()();

  // ===========================================================================
  // CACHE METADATA
  // ===========================================================================

  /// Fecha de almacenamiento en cache
  DateTimeColumn get cachedAt => dateTime().named('cached_at')();

  /// Datos JSON completos para información adicional (miembros, etc.)
  TextColumn get rawJson => text().named('raw_json')();

  // ===========================================================================
  // CONFIGURACIÓN DE TABLA
  // ===========================================================================

  @override
  Set<Column> get primaryKey => {crewId};

  @override
  String get tableName => 'crew_cache';
}
