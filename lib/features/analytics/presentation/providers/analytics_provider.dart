// analytics_provider.dart
// Provider para el módulo de analytics

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../../../config/dependency_injection/injection_container.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../authentication/data/datasources/auth_local_datasource.dart';
import '../../data/datasources/analytics_remote_datasource.dart';
import '../../data/repositories/analytics_repository_impl.dart';
import '../../domain/entities/analytics_stats.dart';
import '../../domain/repositories/analytics_repository.dart';

// Provider del repositorio
final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.currentBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  // Agregar interceptor de autenticación
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          print('🔍 [ANALYTICS] Interceptor ejecutándose...');
          print('🌐 [ANALYTICS] URL: ${options.uri}');
          print('🌐 [ANALYTICS] Method: ${options.method}');

          // ✅ USAR EL SERVICIO LOCATOR SINGLETON en lugar de crear nueva instancia
          final localStorage = sl<AuthLocalDataSource>();

          print(
            '🔐 [ANALYTICS] Intentando leer token desde AuthLocalDataSource singleton...',
          );
          final token = await localStorage.getAccessToken();

          if (token != null && token.isNotEmpty) {
            print(
              '✅ [ANALYTICS] Token encontrado: ${token.substring(0, 20)}...',
            );
            options.headers['Authorization'] = 'Bearer $token';
            print(
              '✅ [ANALYTICS] Header Authorization agregado: Bearer ${token.substring(0, 20)}...',
            );
            print('🔐 [ANALYTICS] Headers actuales: ${options.headers.keys}');
          } else {
            print('❌ [ANALYTICS] TOKEN NO ENCONTRADO O VACÍO');
            print('❌ [ANALYTICS] La petición se enviará SIN autenticación');
            print('❌ [ANALYTICS] Valor del token: $token');
          }
        } catch (e, stackTrace) {
          print('❌ [ANALYTICS] EXCEPCIÓN al obtener token: $e');
          print('❌ [ANALYTICS] Stack: $stackTrace');
        }
        handler.next(options);
      },
      onError: (error, handler) {
        print('❌ [ANALYTICS] Error en petición: ${error.message}');
        print('❌ [ANALYTICS] Status: ${error.response?.statusCode}');
        print('❌ [ANALYTICS] Response: ${error.response?.data}');
        handler.next(error);
      },
      onResponse: (response, handler) {
        print('✅ [ANALYTICS] Respuesta exitosa: ${response.statusCode}');
        handler.next(response);
      },
    ),
  );

  final dataSource = AnalyticsRemoteDataSourceImpl(dio: dio);
  return AnalyticsRepositoryImpl(remoteDataSource: dataSource);
});

// Provider del dashboard completo
final analyticsDashboardProvider = FutureProvider.autoDispose
    .family<AnalyticsDashboard, DateRangeFilter?>((ref, dateRange) async {
      final repository = ref.watch(analyticsRepositoryProvider);

      final result = await repository.getDashboard(
        startDate: dateRange?.startDate,
        endDate: dateRange?.endDate,
      );

      return result.fold(
        (failure) => throw Exception(failure.message),
        (dashboard) => dashboard,
      );
    });

// Provider de estadísticas generales
final noveltyOverviewProvider = FutureProvider.autoDispose
    .family<NoveltyOverview, DateRangeFilter?>((ref, dateRange) async {
      final repository = ref.watch(analyticsRepositoryProvider);

      final result = await repository.getNoveltyOverview(
        startDate: dateRange?.startDate,
        endDate: dateRange?.endDate,
        areaId: dateRange?.areaId,
      );

      return result.fold(
        (failure) => throw Exception(failure.message),
        (overview) => overview,
      );
    });

// Provider de rendimiento de cuadrillas
final crewPerformanceProvider = FutureProvider.autoDispose
    .family<List<CrewPerformance>, DateRangeFilter?>((ref, dateRange) async {
      final repository = ref.watch(analyticsRepositoryProvider);

      final result = await repository.getCrewPerformance(
        startDate: dateRange?.startDate,
        endDate: dateRange?.endDate,
        crewId: dateRange?.crewId,
      );

      return result.fold(
        (failure) => throw Exception(failure.message),
        (performance) => performance,
      );
    });

// Provider de rendimiento de usuarios
final userPerformanceProvider = FutureProvider.autoDispose
    .family<List<UserPerformance>, DateRangeFilter?>((ref, dateRange) async {
      final repository = ref.watch(analyticsRepositoryProvider);

      final result = await repository.getUserPerformance(
        startDate: dateRange?.startDate,
        endDate: dateRange?.endDate,
        userId: dateRange?.userId,
      );

      return result.fold(
        (failure) => throw Exception(failure.message),
        (performance) => performance,
      );
    });

// Provider de tendencias
final noveltyTrendsProvider = FutureProvider.autoDispose
    .family<List<NoveltyTrend>, TrendFilter>((ref, filter) async {
      final repository = ref.watch(analyticsRepositoryProvider);

      final result = await repository.getNoveltyTrends(
        period: filter.period,
        startDate: filter.startDate,
        endDate: filter.endDate,
        areaId: filter.areaId,
      );

      return result.fold(
        (failure) => throw Exception(failure.message),
        (trends) => trends,
      );
    });

// Clases auxiliares para filtros
class DateRangeFilter {
  final DateTime? startDate;
  final DateTime? endDate;
  final int? areaId;
  final int? crewId;
  final int? userId;

  DateRangeFilter({
    this.startDate,
    this.endDate,
    this.areaId,
    this.crewId,
    this.userId,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DateRangeFilter &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.areaId == areaId &&
        other.crewId == crewId &&
        other.userId == userId;
  }

  @override
  int get hashCode => Object.hash(startDate, endDate, areaId, crewId, userId);
}

class TrendFilter {
  final String period; // 'daily', 'weekly', 'monthly'
  final DateTime? startDate;
  final DateTime? endDate;
  final int? areaId;

  TrendFilter({
    required this.period,
    this.startDate,
    this.endDate,
    this.areaId,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TrendFilter &&
        other.period == period &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.areaId == areaId;
  }

  @override
  int get hashCode => Object.hash(period, startDate, endDate, areaId);
}
