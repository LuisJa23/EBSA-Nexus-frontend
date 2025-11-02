// analytics_repository.dart
// Repositorio para obtener estadísticas y analytics

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/analytics_stats.dart';

abstract class AnalyticsRepository {
  /// Obtener estadísticas generales de novedades
  Future<Either<Failure, NoveltyOverview>> getNoveltyOverview({
    DateTime? startDate,
    DateTime? endDate,
    int? areaId,
  });

  /// Obtener tendencias temporales
  Future<Either<Failure, List<NoveltyTrend>>> getNoveltyTrends({
    required String period, // 'daily', 'weekly', 'monthly'
    DateTime? startDate,
    DateTime? endDate,
    int? areaId,
  });

  /// Obtener rendimiento de cuadrillas
  Future<Either<Failure, List<CrewPerformance>>> getCrewPerformance({
    DateTime? startDate,
    DateTime? endDate,
    int? crewId,
  });

  /// Obtener rendimiento de usuarios
  Future<Either<Failure, List<UserPerformance>>> getUserPerformance({
    DateTime? startDate,
    DateTime? endDate,
    int? userId,
    int? workRoleId,
  });

  /// Obtener distribución geográfica
  Future<Either<Failure, List<MunicipalityStats>>> getNoveltyByMunicipality({
    DateTime? startDate,
    DateTime? endDate,
    String? status,
  });

  /// Obtener dashboard completo (consolidado)
  Future<Either<Failure, AnalyticsDashboard>> getDashboard({
    DateTime? startDate,
    DateTime? endDate,
  });
}
