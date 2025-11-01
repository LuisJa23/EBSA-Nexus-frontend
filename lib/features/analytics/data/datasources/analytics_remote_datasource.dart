// analytics_remote_datasource.dart
// Fuente de datos remota para analytics

import 'package:dio/dio.dart';
import '../models/analytics_models.dart';

abstract class AnalyticsRemoteDataSource {
  Future<NoveltyOverviewModel> getNoveltyOverview({
    DateTime? startDate,
    DateTime? endDate,
    int? areaId,
  });

  Future<List<NoveltyTrendModel>> getNoveltyTrends({
    required String period,
    DateTime? startDate,
    DateTime? endDate,
    int? areaId,
  });

  Future<List<CrewPerformanceModel>> getCrewPerformance({
    DateTime? startDate,
    DateTime? endDate,
    int? crewId,
  });

  Future<List<UserPerformanceModel>> getUserPerformance({
    DateTime? startDate,
    DateTime? endDate,
    int? userId,
    int? workRoleId,
  });

  Future<List<MunicipalityStatsModel>> getNoveltyByMunicipality({
    DateTime? startDate,
    DateTime? endDate,
    String? status,
  });

  Future<AnalyticsDashboardModel> getDashboard({
    DateTime? startDate,
    DateTime? endDate,
  });
}

class AnalyticsRemoteDataSourceImpl implements AnalyticsRemoteDataSource {
  final Dio dio;
  final String baseUrl;

  AnalyticsRemoteDataSourceImpl({
    required this.dio,
    this.baseUrl = '/api/v1/analytics',
  });

  Map<String, dynamic> _buildQueryParams({
    DateTime? startDate,
    DateTime? endDate,
    int? areaId,
    int? crewId,
    int? userId,
    int? workRoleId,
    String? status,
    String? period,
  }) {
    final params = <String, dynamic>{};
    if (startDate != null) params['startDate'] = startDate.toIso8601String();
    if (endDate != null) params['endDate'] = endDate.toIso8601String();
    if (areaId != null) params['areaId'] = areaId;
    if (crewId != null) params['crewId'] = crewId;
    if (userId != null) params['userId'] = userId;
    if (workRoleId != null) params['workRoleId'] = workRoleId;
    if (status != null) params['status'] = status;
    if (period != null) params['period'] = period;
    return params;
  }

  @override
  Future<NoveltyOverviewModel> getNoveltyOverview({
    DateTime? startDate,
    DateTime? endDate,
    int? areaId,
  }) async {
    final response = await dio.get(
      '$baseUrl/novelties/overview',
      queryParameters: _buildQueryParams(
        startDate: startDate,
        endDate: endDate,
        areaId: areaId,
      ),
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      return NoveltyOverviewModel.fromJson(response.data['data']);
    }
    throw Exception('Error al obtener estadísticas generales');
  }

  @override
  Future<List<NoveltyTrendModel>> getNoveltyTrends({
    required String period,
    DateTime? startDate,
    DateTime? endDate,
    int? areaId,
  }) async {
    final response = await dio.get(
      '$baseUrl/novelties/trends',
      queryParameters: _buildQueryParams(
        period: period,
        startDate: startDate,
        endDate: endDate,
        areaId: areaId,
      ),
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      final trends = response.data['data']['trends'] as List;
      return trends.map((e) => NoveltyTrendModel.fromJson(e)).toList();
    }
    throw Exception('Error al obtener tendencias');
  }

  @override
  Future<List<CrewPerformanceModel>> getCrewPerformance({
    DateTime? startDate,
    DateTime? endDate,
    int? crewId,
  }) async {
    final response = await dio.get(
      '$baseUrl/crews/performance',
      queryParameters: _buildQueryParams(
        startDate: startDate,
        endDate: endDate,
        crewId: crewId,
      ),
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      final data = response.data['data'] as List;
      return data.map((e) => CrewPerformanceModel.fromJson(e)).toList();
    }
    throw Exception('Error al obtener rendimiento de cuadrillas');
  }

  @override
  Future<List<UserPerformanceModel>> getUserPerformance({
    DateTime? startDate,
    DateTime? endDate,
    int? userId,
    int? workRoleId,
  }) async {
    final response = await dio.get(
      '$baseUrl/users/performance',
      queryParameters: _buildQueryParams(
        startDate: startDate,
        endDate: endDate,
        userId: userId,
        workRoleId: workRoleId,
      ),
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      final data = response.data['data'] as List;
      return data.map((e) => UserPerformanceModel.fromJson(e)).toList();
    }
    throw Exception('Error al obtener rendimiento de usuarios');
  }

  @override
  Future<List<MunicipalityStatsModel>> getNoveltyByMunicipality({
    DateTime? startDate,
    DateTime? endDate,
    String? status,
  }) async {
    final response = await dio.get(
      '$baseUrl/novelties/by-municipality',
      queryParameters: _buildQueryParams(
        startDate: startDate,
        endDate: endDate,
        status: status,
      ),
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      final data = response.data['data'] as List;
      return data.map((e) => MunicipalityStatsModel.fromJson(e)).toList();
    }
    throw Exception('Error al obtener distribución geográfica');
  }

  @override
  Future<AnalyticsDashboardModel> getDashboard({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await dio.get(
        '$baseUrl/dashboard',
        queryParameters: _buildQueryParams(
          startDate: startDate,
          endDate: endDate,
        ),
      );

      print('📊 [ANALYTICS] Status Code: ${response.statusCode}');
      print('📊 [ANALYTICS] Response Data Type: ${response.data.runtimeType}');
      print(
        '📊 [ANALYTICS] Response Keys: ${response.data is Map ? (response.data as Map).keys : 'Not a Map'}',
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // Verificar si la respuesta tiene la estructura esperada {success: true, data: {...}}
        if (data is Map<String, dynamic> && data['success'] == true) {
          print('📊 [ANALYTICS] Estructura con success=true detectada');
          print('📊 [ANALYTICS] Data keys: ${(data['data'] as Map?)?.keys}');
          return AnalyticsDashboardModel.fromJson(data['data']);
        }

        // Si no tiene success, asumir que data ES el dashboard directamente
        print('📊 [ANALYTICS] Usando data directamente como dashboard');
        return AnalyticsDashboardModel.fromJson(data);
      }

      throw Exception(
        'Error al obtener dashboard: Status ${response.statusCode}',
      );
    } catch (e, stackTrace) {
      print('❌ [ANALYTICS] Error en getDashboard: $e');
      print('❌ [ANALYTICS] Stack: $stackTrace');
      rethrow;
    }
  }
}
