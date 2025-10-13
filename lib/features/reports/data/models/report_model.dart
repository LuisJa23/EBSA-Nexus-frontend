// report_model.dart
//
// Modelo de datos para Reporte (Data Layer)
//
// PROPÓSITO:
// - Representar datos de reporte de la API y DB local
// - Transformación JSON ↔ Objeto ↔ Database
// - Extensión de Report entity del dominio
// - Manejo de estados de sincronización
//
// CAPA: DATA LAYER
// HERENCIA: extends Report (domain entity)
//
// CONTENIDO ESPERADO:
// - class ReportModel extends Report
// - Constructor que llame super() con parámetros de Report entity
// - factory ReportModel.fromJson(Map<String, dynamic> json)
// - Map<String, dynamic> toJson()
// - factory ReportModel.fromEntity(Report report)
// - Report toEntity()
// - factory ReportModel.fromDrift(ReportData driftData) // para Drift
// - ReportData toDrift() // para Drift
// - Campos adicionales de data layer:
//   - bool isSynced, DateTime lastSyncAttempt
//   - String? serverErrorMessage
// - Manejo de listas de evidencias y GPS
// - Validación de integridad de datos
