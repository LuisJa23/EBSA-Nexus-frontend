// report_remote_datasource.dart
//
// Fuente de datos remota para reportes
//
// PROPÓSITO:
// - Comunicación con API de reportes EBSA
// - Operaciones CRUD remotas para reportes
// - Upload de evidencias multimedia
// - Sincronización con servidor
//
// CAPA: DATA LAYER
// DEPENDENCIAS: Puede importar Dio, ApiClient, multipart
//
// CONTENIDO ESPERADO:
// - abstract class ReportRemoteDataSource
// - Future<List<ReportModel>> getReports({page, limit, filters});
// - Future<ReportModel> getReportById(String id);
// - Future<ReportModel> createReport(ReportModel report);
// - Future<ReportModel> updateReport(String id, ReportModel report);
// - Future<void> deleteReport(String id);
// - Future<List<String>> uploadEvidence(List<File> files);
// - Future<void> syncReports(List<ReportModel> localReports);
// - class ReportRemoteDataSourceImpl implements ReportRemoteDataSource
// - Uso de ApiClient para requests
// - Manejo de multipart/form-data para archivos
// - Paginación y filtros de búsqueda
// - Manejo de ServerException y NetworkException
