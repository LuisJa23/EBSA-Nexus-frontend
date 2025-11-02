// report_evidence_table.dart
//
// Tabla para almacenar evidencias de reportes
//
// PROPÓSITO:
// - Almacenar referencias a fotos, videos, audios
// - Asociar evidencias con reportes
// - Gestionar archivos locales
//
// CAPA: CORE - DATABASE

import 'package:drift/drift.dart';

/// Tabla de evidencias de reportes
///
/// Almacena referencias a archivos de evidencia (fotos, videos, audio)
@DataClassName('ReportEvidenceTableData')
class ReportEvidenceTable extends Table {
  // ===========================================================================
  // IDENTIFICACIÓN
  // ===========================================================================

  /// ID de la evidencia
  IntColumn get id => integer().autoIncrement()();

  /// ID del reporte asociado
  TextColumn get reportId => text().named('report_id')();

  // ===========================================================================
  // INFORMACIÓN DEL ARCHIVO
  // ===========================================================================

  /// Tipo de evidencia (FOTO, VIDEO, AUDIO)
  TextColumn get type => text()();

  /// Ruta local del archivo
  TextColumn get localPath => text().named('local_path')();

  /// Nombre del archivo
  TextColumn get fileName => text().named('file_name')();

  /// Tamaño del archivo en bytes
  IntColumn get fileSize => integer().named('file_size')();

  /// MIME type del archivo
  TextColumn get mimeType => text().named('mime_type')();

  // ===========================================================================
  // SINCRONIZACIÓN
  // ===========================================================================

  /// URL del servidor (null hasta sincronizar)
  TextColumn get serverUrl => text().named('server_url').nullable()();

  /// Está subido al servidor
  BoolColumn get isUploaded =>
      boolean().named('is_uploaded').withDefault(const Constant(false))();

  /// Fecha de subida al servidor
  DateTimeColumn get uploadedAt => dateTime().named('uploaded_at').nullable()();

  // ===========================================================================
  // METADATA
  // ===========================================================================

  /// Fecha de creación
  DateTimeColumn get createdAt => dateTime().named('created_at')();

  // ===========================================================================
  // CONFIGURACIÓN DE TABLA
  // ===========================================================================

  @override
  String get tableName => 'report_evidence';
}
