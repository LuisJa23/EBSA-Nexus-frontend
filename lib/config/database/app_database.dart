// app_database.dart
//
// Configuración de base de datos local con Drift
//
// PROPÓSITO:
// - Definir esquema de base de datos offline
// - Gestionar tablas de novedades offline
// - Soporte para sincronización
//
// CAPA: DATA LAYER

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// Tabla de novedades offline
@DataClassName('OfflineIncidentData')
class OfflineIncidents extends Table {
  /// ID local (UUID)
  TextColumn get id => text()();

  /// ID del servidor (null hasta sincronizar)
  IntColumn get serverId => integer().nullable()();

  /// ID numérico del área
  IntColumn get areaId => integer()();

  /// Número de cuenta
  TextColumn get accountNumber => text()();

  /// Número de medidor
  TextColumn get meterNumber => text()();

  /// Área de la novedad (nombre)
  TextColumn get area => text()();

  /// Motivo de la novedad (reason)
  TextColumn get reason => text()();

  /// Motivo de la novedad (nombre legible - motivo)
  TextColumn get motivo => text()();

  /// Municipio
  TextColumn get municipio => text()();

  /// Municipio (municipality para API)
  TextColumn get municipality => text()();

  /// Dirección (address para API)
  TextColumn get address => text()();

  /// Descripción
  TextColumn get description => text()();

  /// Lectura activa
  TextColumn get activeReading => text()();

  /// Lectura reactiva
  TextColumn get reactiveReading => text()();

  /// Observaciones
  TextColumn get observations => text()();

  /// Estado de sincronización: pending, synced, error
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();

  /// Mensaje de error (si falla sincronización)
  TextColumn get errorMessage => text().nullable()();

  /// Fecha de creación
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// Fecha de última actualización
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  /// Usuario que creó la novedad
  IntColumn get createdBy => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tabla de imágenes de novedades offline
@DataClassName('OfflineIncidentImageData')
class OfflineIncidentImages extends Table {
  /// ID de la imagen
  IntColumn get id => integer().autoIncrement()();

  /// ID de la novedad (FK)
  TextColumn get incidentId =>
      text().references(OfflineIncidents, #id, onDelete: KeyAction.cascade)();

  /// Ruta local del archivo
  TextColumn get localPath => text()();

  /// URL del servidor (null hasta sincronizar)
  TextColumn get serverUrl => text().nullable()();

  /// Estado de sincronización: pending, synced, error
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();

  /// Fecha de creación
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Base de datos de la aplicación
@DriftDatabase(tables: [OfflineIncidents, OfflineIncidentImages])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: (migrator, from, to) async {
        if (from < 2) {
          // Agregar nuevas columnas en versión 2
          await migrator.addColumn(offlineIncidents, offlineIncidents.areaId);
          await migrator.addColumn(offlineIncidents, offlineIncidents.reason);
          await migrator.addColumn(
            offlineIncidents,
            offlineIncidents.municipality,
          );
          await migrator.addColumn(offlineIncidents, offlineIncidents.address);
          await migrator.addColumn(
            offlineIncidents,
            offlineIncidents.description,
          );
        }
      },
    );
  }

  // ============================================================================
  // MÉTODOS DE CONSULTA - NOVEDADES
  // ============================================================================

  /// Obtener todas las novedades offline
  Future<List<OfflineIncidentData>> getAllOfflineIncidents() async {
    return select(offlineIncidents).get();
  }

  /// Obtener novedades pendientes de sincronizar
  Future<List<OfflineIncidentData>> getPendingIncidents() async {
    return (select(
      offlineIncidents,
    )..where((tbl) => tbl.syncStatus.equals('pending'))).get();
  }

  /// Obtener una novedad por ID
  Future<OfflineIncidentData?> getIncidentById(String id) async {
    return (select(
      offlineIncidents,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  /// Insertar una nueva novedad offline
  Future<int> insertOfflineIncident(OfflineIncidentsCompanion incident) async {
    return into(offlineIncidents).insert(incident);
  }

  /// Actualizar estado de sincronización de una novedad
  Future<int> updateIncidentSyncStatus({
    required String id,
    required String status,
    int? serverId,
    String? errorMessage,
  }) async {
    return (update(offlineIncidents)..where((tbl) => tbl.id.equals(id))).write(
      OfflineIncidentsCompanion(
        syncStatus: Value(status),
        serverId: serverId != null ? Value(serverId) : const Value.absent(),
        errorMessage: errorMessage != null
            ? Value(errorMessage)
            : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Eliminar una novedad offline
  Future<int> deleteOfflineIncident(String id) async {
    return (delete(offlineIncidents)..where((tbl) => tbl.id.equals(id))).go();
  }

  // ============================================================================
  // MÉTODOS DE CONSULTA - IMÁGENES
  // ============================================================================

  /// Obtener imágenes de una novedad
  Future<List<OfflineIncidentImageData>> getIncidentImages(
    String incidentId,
  ) async {
    return (select(
      offlineIncidentImages,
    )..where((tbl) => tbl.incidentId.equals(incidentId))).get();
  }

  /// Insertar una imagen
  Future<int> insertIncidentImage(OfflineIncidentImagesCompanion image) async {
    return into(offlineIncidentImages).insert(image);
  }

  /// Actualizar estado de sincronización de una imagen
  Future<int> updateImageSyncStatus({
    required int id,
    required String status,
    String? serverUrl,
  }) async {
    return (update(
      offlineIncidentImages,
    )..where((tbl) => tbl.id.equals(id))).write(
      OfflineIncidentImagesCompanion(
        syncStatus: Value(status),
        serverUrl: serverUrl != null ? Value(serverUrl) : const Value.absent(),
      ),
    );
  }

  /// Eliminar imágenes de una novedad
  Future<int> deleteIncidentImages(String incidentId) async {
    return (delete(
      offlineIncidentImages,
    )..where((tbl) => tbl.incidentId.equals(incidentId))).go();
  }

  // ============================================================================
  // MÉTODOS DE ESTADÍSTICAS
  // ============================================================================

  /// Contar novedades pendientes
  Future<int> countPendingIncidents() async {
    final query = selectOnly(offlineIncidents)
      ..addColumns([offlineIncidents.id.count()])
      ..where(offlineIncidents.syncStatus.equals('pending'));

    final result = await query.getSingleOrNull();
    return result?.read(offlineIncidents.id.count()) ?? 0;
  }

  /// Contar novedades con error
  Future<int> countErrorIncidents() async {
    final query = selectOnly(offlineIncidents)
      ..addColumns([offlineIncidents.id.count()])
      ..where(offlineIncidents.syncStatus.equals('error'));

    final result = await query.getSingleOrNull();
    return result?.read(offlineIncidents.id.count()) ?? 0;
  }

  /// Contar novedades sincronizadas
  Future<int> countSyncedIncidents() async {
    final query = selectOnly(offlineIncidents)
      ..addColumns([offlineIncidents.id.count()])
      ..where(offlineIncidents.syncStatus.equals('synced'));

    final result = await query.getSingleOrNull();
    return result?.read(offlineIncidents.id.count()) ?? 0;
  }
}

/// Abre la conexión a la base de datos
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'ebsa_nexus.db'));
    return NativeDatabase(file);
  });
}
