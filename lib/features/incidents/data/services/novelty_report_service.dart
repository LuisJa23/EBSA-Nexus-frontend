// novelty_report_service.dart
//
// Servicio para resolución de novedades
//
// PROPÓSITO:
// - Comunicación con API para resolver novedades
// - Marca novedades como completadas con notas de resolución
//
// CAPA: DATA LAYER - SERVICES

import 'package:dio/dio.dart';
import '../models/novelty_report_model.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/app_logger.dart';

class NoveltyReportService {
  final ApiClient apiClient;

  NoveltyReportService({required this.apiClient});

  /// Crear reporte de resolución de novedad
  /// Usa el endpoint correcto del backend: POST /api/v1/novelty-reports
  /// Verifica si ya existe un reporte antes de crear uno nuevo
  Future<NoveltyReportModel> createReport(
    CreateNoveltyReportRequest request,
  ) async {
    try {
      AppLogger.info('📝 Creando reporte de resolución de novedad');
      AppLogger.debug('  - Novedad ID: ${request.noveltyId}');
      AppLogger.debug('  - Estado resolución: ${request.resolutionStatus}');
      AppLogger.debug('  - Participantes: ${request.participants.length}');
      AppLogger.debug('  - Fecha inicio: ${request.workStartDate}');
      AppLogger.debug('  - Fecha fin: ${request.workEndDate}');

      // Verificar si ya existe un reporte para esta novedad
      // Solo si la verificación es exitosa y realmente existe un reporte
      try {
        AppLogger.debug(
          '🔍 Verificando si ya existe reporte para novedad ${request.noveltyId}',
        );
        final existingReport = await getReportByNoveltyId(request.noveltyId);

        if (existingReport != null) {
          AppLogger.error(
            '⚠️ Ya existe un reporte para la novedad ${request.noveltyId}',
          );
          throw Exception(
            'Ya existe un reporte de resolución para esta novedad. '
            'No se pueden crear reportes duplicados.',
          );
        }
        AppLogger.debug(
          '✓ No existe reporte previo, continuando con creación...',
        );
      } catch (e) {
        // Si el error es que ya existe reporte, re-lanzar
        if (e.toString().contains('Ya existe un reporte')) {
          rethrow;
        }
        // Si es cualquier otro error (404, red, etc.), continuar con la creación
        // El backend hará la validación final
        AppLogger.debug(
          '⚠️ Error al verificar reporte existente, continuando: $e',
        );
      }

      final startTime = DateTime.now();

      // Usar el endpoint correcto del backend
      final response = await apiClient.post(
        '/api/v1/novelty-reports',
        data: request.toJson(),
      );

      final duration = DateTime.now().difference(startTime);

      if (response.statusCode == 201) {
        AppLogger.info(
          '✅ Reporte creado exitosamente en ${duration.inMilliseconds}ms',
        );
        AppLogger.debug('  - Reporte ID: ${response.data['id']}');

        return NoveltyReportModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }

      AppLogger.error(
        '❌ Respuesta inesperada del servidor: ${response.statusCode}',
      );
      throw Exception(_parseErrorResponse(response));
    } on DioException catch (e) {
      AppLogger.error('❌ Error al crear reporte de novedad');
      AppLogger.error('  - Tipo: ${e.type}');
      AppLogger.error('  - Status Code: ${e.response?.statusCode}');
      AppLogger.error('  - Response: ${e.response?.data}');
      AppLogger.error('  - Message: ${e.message}');

      throw Exception(_parseDioError(e));
    } catch (e) {
      AppLogger.error('❌ Error inesperado al crear reporte', error: e);
      rethrow;
    }
  }

  /// Parsear errores de la respuesta
  String _parseErrorResponse(Response response) {
    final data = response.data;

    // Intentar extraer mensaje del backend
    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['error'];
      if (message != null) return message.toString();
    }

    // Mensajes por código de estado
    switch (response.statusCode) {
      case 400:
        return 'Datos del reporte inválidos. Verifica que todos los campos sean correctos.';
      case 403:
        return 'No tienes permisos para crear reportes en esta novedad.';
      case 404:
        return 'Novedad no encontrada o usuario participante no existe.';
      case 409:
        return 'Ya existe un reporte de resolución para esta novedad. No se pueden crear múltiples reportes.';
      case 500:
        return 'Error al procesar el reporte. Verifica que la novedad esté EN_CURSO y tenga cuadrilla asignada.';
      default:
        return 'Error al crear reporte (${response.statusCode})';
    }
  }

  /// Parsear errores de Dio
  String _parseDioError(DioException e) {
    // Intentar extraer mensaje del backend
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'] ?? data['error'];
        if (message != null) return message.toString();
      }

      // Si no hay mensaje, usar el parser de errores por código
      return _parseErrorResponse(e.response!);
    }

    // Errores de conexión
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Tiempo de espera agotado. Verifica tu conexión a internet.';
      case DioExceptionType.connectionError:
        return 'Error de conexión. Verifica que el servidor esté disponible.';
      case DioExceptionType.badResponse:
        return 'Respuesta inválida del servidor.';
      case DioExceptionType.cancel:
        return 'Operación cancelada.';
      default:
        return 'Error de red: ${e.message}';
    }
  }

  /// Obtener reporte por ID de novedad
  Future<NoveltyReportModel?> getReportByNoveltyId(int noveltyId) async {
    try {
      AppLogger.debug('Obteniendo reporte de novedad $noveltyId');

      final response = await apiClient.get(
        '/api/v1/novelty-reports/by-novelty/$noveltyId',
      );

      if (response.statusCode == 200) {
        final report = NoveltyReportModel.fromJson(
          response.data as Map<String, dynamic>,
        );
        AppLogger.info('✅ Reporte encontrado: ID ${report.id}');
        return report;
      } else if (response.statusCode == 404) {
        AppLogger.debug('No existe reporte para la novedad $noveltyId');
        return null; // No existe reporte
      } else {
        throw Exception('Error al obtener reporte: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        AppLogger.debug('No existe reporte para la novedad $noveltyId (404)');
        return null;
      }
      AppLogger.error('❌ Error al obtener reporte de novedad', error: e);
      throw Exception(_parseDioError(e));
    }
  }

  /// Obtener reporte por ID
  Future<NoveltyReportModel> getReportById(int reportId) async {
    try {
      AppLogger.debug('Obteniendo reporte $reportId');

      final response = await apiClient.get('/api/v1/novelty-reports/$reportId');

      if (response.statusCode == 200) {
        final report = NoveltyReportModel.fromJson(
          response.data as Map<String, dynamic>,
        );
        AppLogger.info('✅ Reporte obtenido: ID ${report.id}');
        return report;
      } else if (response.statusCode == 404) {
        throw Exception('Reporte no encontrado');
      } else {
        throw Exception('Error al obtener reporte: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Reporte no encontrado');
      }
      AppLogger.error('❌ Error al obtener reporte', error: e);
      throw Exception(_parseDioError(e));
    }
  }

  /// Obtener mis reportes
  Future<List<NoveltyReportModel>> getMyReports() async {
    try {
      AppLogger.debug('Obteniendo mis reportes');

      final response = await apiClient.get(
        '/api/v1/novelty-reports/my-reports',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        final reports = data
            .map((e) => NoveltyReportModel.fromJson(e as Map<String, dynamic>))
            .toList();

        AppLogger.info('✅ Mis reportes obtenidos: ${reports.length}');
        return reports;
      } else {
        throw Exception('Error al obtener reportes: ${response.statusCode}');
      }
    } on DioException catch (e) {
      AppLogger.error('❌ Error al obtener mis reportes', error: e);
      throw Exception(_parseDioError(e));
    }
  }

  /// Obtener reportes por usuario
  Future<List<NoveltyReportModel>> getReportsByUser(int userId) async {
    try {
      AppLogger.debug('Obteniendo reportes del usuario $userId');

      final response = await apiClient.get(
        '/api/v1/novelty-reports/by-user/$userId',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        final reports = data
            .map((e) => NoveltyReportModel.fromJson(e as Map<String, dynamic>))
            .toList();

        AppLogger.info('✅ Reportes obtenidos: ${reports.length}');
        return reports;
      } else {
        throw Exception('Error al obtener reportes: ${response.statusCode}');
      }
    } on DioException catch (e) {
      AppLogger.error('❌ Error al obtener reportes del usuario', error: e);
      throw Exception(_parseDioError(e));
    }
  }
}
