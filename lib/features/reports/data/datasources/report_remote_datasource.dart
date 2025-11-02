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

import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/app_logger.dart';

/// Contrato para la fuente de datos remota de reportes
///
/// Define las operaciones de comunicación con el backend
abstract class ReportRemoteDataSource {
  /// Crea un reporte en el servidor
  Future<Map<String, dynamic>> createReport(Map<String, dynamic> reportData);

  /// Sube una evidencia al servidor
  Future<String> uploadEvidence(File file, String type);

  /// Obtiene novedades del servidor
  Future<List<Map<String, dynamic>>> fetchNovelties();

  /// Obtiene cuadrillas del servidor
  Future<List<Map<String, dynamic>>> fetchCrews();
}

/// Implementación de la fuente de datos remota de reportes
///
/// Utiliza ApiClient para comunicación con el backend
class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  final ApiClient _apiClient;

  const ReportRemoteDataSourceImpl(this._apiClient);

  @override
  Future<Map<String, dynamic>> createReport(
    Map<String, dynamic> reportData,
  ) async {
    try {
      AppLogger.networkRequest('POST', '/api/v1/novelty-reports');

      final response = await _apiClient.post(
        '/api/v1/novelty-reports',
        data: reportData,
      );

      if (response.statusCode == 201) {
        AppLogger.networkSuccess('/api/v1/novelty-reports', 201);
        return response.data as Map<String, dynamic>;
      } else {
        throw ServerException(
          message: 'Error creando reporte: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      AppLogger.networkError('/api/v1/novelty-reports', e);

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const NetworkException(message: 'Timeout en la conexión');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw const NetworkException(message: 'Error de conexión');
      }

      throw ServerException(
        message: e.response?.data?['message'] ?? 'Error del servidor',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      AppLogger.error('Error inesperado creando reporte', error: e);
      throw ServerException(message: 'Error inesperado: $e');
    }
  }

  @override
  Future<String> uploadEvidence(File file, String type) async {
    try {
      AppLogger.networkRequest('POST', '/api/v1/evidence/upload');

      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
        'type': type,
      });

      final response = await _apiClient.post(
        '/api/v1/evidence/upload',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final url = response.data['url'] as String;
        AppLogger.networkSuccess(
          '/api/v1/evidence/upload',
          response.statusCode!,
        );
        return url;
      } else {
        throw ServerException(
          message: 'Error subiendo evidencia: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      AppLogger.networkError('/api/v1/evidence/upload', e);

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const NetworkException(message: 'Timeout subiendo evidencia');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw const NetworkException(
          message: 'Error de conexión subiendo evidencia',
        );
      }

      throw ServerException(
        message: e.response?.data?['message'] ?? 'Error del servidor',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      AppLogger.error('Error inesperado subiendo evidencia', error: e);
      throw ServerException(message: 'Error inesperado: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchNovelties() async {
    try {
      AppLogger.networkRequest('GET', '/api/v1/novelties');

      final response = await _apiClient.get('/api/v1/novelties');

      if (response.statusCode == 200) {
        AppLogger.networkSuccess('/api/v1/novelties', 200);

        final data = response.data;
        if (data is Map && data.containsKey('content')) {
          final content = data['content'] as List<dynamic>;
          return content.cast<Map<String, dynamic>>();
        } else if (data is List) {
          return data.cast<Map<String, dynamic>>();
        }

        throw ServerException(message: 'Formato de respuesta inesperado');
      } else {
        throw ServerException(
          message: 'Error obteniendo novedades: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      AppLogger.networkError('/api/v1/novelties', e);
      throw _handleDioException(e);
    } catch (e) {
      AppLogger.error('Error inesperado obteniendo novedades', error: e);
      throw ServerException(message: 'Error inesperado: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchCrews() async {
    try {
      AppLogger.networkRequest('GET', '/api/v1/crews');

      final response = await _apiClient.get('/api/v1/crews');

      if (response.statusCode == 200) {
        AppLogger.networkSuccess('/api/v1/crews', 200);

        final data = response.data as List<dynamic>;
        return data.cast<Map<String, dynamic>>();
      } else {
        throw ServerException(
          message: 'Error obteniendo cuadrillas: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      AppLogger.networkError('/api/v1/crews', e);
      throw _handleDioException(e);
    } catch (e) {
      AppLogger.error('Error inesperado obteniendo cuadrillas', error: e);
      throw ServerException(message: 'Error inesperado: $e');
    }
  }

  /// Maneja excepciones de Dio y las convierte en excepciones del dominio
  Exception _handleDioException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return const NetworkException(message: 'Timeout en la conexión');
    }

    if (e.type == DioExceptionType.connectionError) {
      return const NetworkException(message: 'Sin conexión a Internet');
    }

    return ServerException(
      message: e.response?.data?['message'] ?? 'Error del servidor',
      statusCode: e.response?.statusCode,
    );
  }
}
