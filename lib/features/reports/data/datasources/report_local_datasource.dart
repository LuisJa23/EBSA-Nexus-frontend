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
//
// CONTENIDO ESPERADO:
// - abstract class ReportLocalDataSource
// - Future<List<ReportModel>> getReports({filters, sortBy});
// - Future<ReportModel?> getReportById(String id);
// - Future<void> saveReport(ReportModel report);
// - Future<void> updateReport(ReportModel report);
// - Future<void> deleteReport(String id);
// - Future<List<ReportModel>> getPendingSyncReports();
// - Future<void> markReportAsSynced(String id);
// - Future<void> saveLocalEvidence(String reportId, List<String> paths);
// - class ReportLocalDataSourceImpl implements ReportLocalDataSource
// - Uso de Drift database para persistencia
// - Manejo de archivos locales (fotos, videos, audio)
// - Queue de operaciones pendientes de sync
// - Manejo de CacheException
