// novelty_report_service.dart
//
// Servicio para gestión de reportes de novedades
//
// PROPÓSITO:
// - Comunicación con API de reportes
// - Operaciones CRUD de reportes
//
// CAPA: DATA LAYER - SERVICES

import 'package:dio/dio.dart';
import '../models/novelty_report_model.dart';
import '../../../../core/network/api_client.dart';

class NoveltyReportService {
  final ApiClient apiClient;

  NoveltyReportService({required this.apiClient});

  /// Crear reporte de novedad
  Future<NoveltyReportModel> createReport(
    CreateNoveltyReportRequest request,
  ) async {
    try {
      final response = await apiClient.post(
        '/api/v1/novelty-reports',
        data: request.toJson(),
      );

      if (response.statusCode == 201) {
        return NoveltyReportModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else if (response.statusCode == 400) {
        throw Exception('Datos de reporte inválidos');
      } else if (response.statusCode == 403) {
        throw Exception('No tienes permisos para crear reportes');
      } else if (response.statusCode == 404) {
        throw Exception('Novedad no encontrada');
      } else if (response.statusCode == 409) {
        throw Exception('Ya existe un reporte para esta novedad');
      } else {
        throw Exception('Error al crear reporte: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Datos de reporte inválidos');
      } else if (e.response?.statusCode == 403) {
        throw Exception('No tienes permisos para crear reportes');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Novedad no encontrada');
      } else if (e.response?.statusCode == 409) {
        throw Exception('Ya existe un reporte para esta novedad');
      } else {
        throw Exception('Error al crear reporte');
      }
    }
  }

  /// Obtener reporte por novedad
  Future<NoveltyReportModel?> getReportByNovelty(int noveltyId) async {
    try {
      final response = await apiClient.get(
        '/api/v1/novelty-reports/by-novelty/$noveltyId',
      );

      if (response.statusCode == 200) {
        return NoveltyReportModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else if (response.statusCode == 404) {
        return null; // No existe reporte
      } else {
        throw Exception('Error al obtener reporte: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw Exception('Error al obtener reporte');
    }
  }

  /// Obtener reporte por ID
  Future<NoveltyReportModel> getReportById(int reportId) async {
    try {
      final response = await apiClient.get('/api/v1/novelty-reports/$reportId');

      if (response.statusCode == 200) {
        return NoveltyReportModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else if (response.statusCode == 404) {
        throw Exception('Reporte no encontrado');
      } else {
        throw Exception('Error al obtener reporte: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Reporte no encontrado');
      }
      throw Exception('Error al obtener reporte');
    }
  }

  /// Obtener mis reportes
  Future<List<NoveltyReportModel>> getMyReports() async {
    try {
      final response = await apiClient.get(
        '/api/v1/novelty-reports/my-reports',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((e) => NoveltyReportModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Error al obtener reportes: ${response.statusCode}');
      }
    } on DioException {
      throw Exception('Error al obtener reportes');
    }
  }

  /// Obtener reportes por usuario
  Future<List<NoveltyReportModel>> getReportsByUser(int userId) async {
    try {
      final response = await apiClient.get(
        '/api/v1/novelty-reports/by-user/$userId',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((e) => NoveltyReportModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Error al obtener reportes: ${response.statusCode}');
      }
    } on DioException {
      throw Exception('Error al obtener reportes');
    }
  }
}
