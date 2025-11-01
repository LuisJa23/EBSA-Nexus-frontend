// analytics_models.dart
// Modelos de datos para analytics (extienden las entidades)

import '../../domain/entities/analytics_stats.dart';

class NoveltyOverviewModel extends NoveltyOverview {
  const NoveltyOverviewModel({
    required super.totalNovelties,
    required super.byStatus,
    required super.byArea,
    required super.byReason,
    required super.averageResolutionTimeHours,
    required super.resolvedNovelties,
    required super.pendingNovelties,
  });

  factory NoveltyOverviewModel.fromJson(Map<String, dynamic> json) {
    return NoveltyOverviewModel(
      totalNovelties: json['totalNovelties'] ?? 0,
      byStatus: Map<String, int>.from(json['byStatus'] ?? {}),
      byArea: Map<String, int>.from(json['byArea'] ?? {}),
      byReason: Map<String, int>.from(json['byReason'] ?? {}),
      averageResolutionTimeHours: (json['averageResolutionTimeHours'] ?? 0.0)
          .toDouble(),
      resolvedNovelties: json['resolvedNovelties'] ?? 0,
      pendingNovelties: json['pendingNovelties'] ?? 0,
    );
  }
}

class NoveltyTrendModel extends NoveltyTrend {
  const NoveltyTrendModel({
    required super.period,
    required super.created,
    required super.completed,
    required super.cancelled,
  });

  factory NoveltyTrendModel.fromJson(Map<String, dynamic> json) {
    return NoveltyTrendModel(
      period: json['period'] ?? '',
      created: json['created'] ?? 0,
      completed: json['completed'] ?? 0,
      cancelled: json['cancelled'] ?? 0,
    );
  }
}

class CrewPerformanceModel extends CrewPerformance {
  const CrewPerformanceModel({
    required super.crewId,
    required super.crewName,
    required super.assignedNovelties,
    required super.completedNovelties,
    required super.pendingNovelties,
    required super.averageResolutionTimeHours,
    required super.completionRate,
    required super.memberCount,
  });

  factory CrewPerformanceModel.fromJson(Map<String, dynamic> json) {
    return CrewPerformanceModel(
      crewId: json['crewId'] ?? 0,
      crewName: json['crewName'] ?? '',
      assignedNovelties: json['assignedNovelties'] ?? 0,
      completedNovelties: json['completedNovelties'] ?? 0,
      pendingNovelties: json['pendingNovelties'] ?? 0,
      averageResolutionTimeHours: (json['averageResolutionTimeHours'] ?? 0.0)
          .toDouble(),
      completionRate: (json['completionRate'] ?? 0.0).toDouble(),
      memberCount: json['memberCount'] ?? 0,
    );
  }
}

class UserPerformanceModel extends UserPerformance {
  const UserPerformanceModel({
    required super.userId,
    required super.fullName,
    required super.workRole,
    required super.noveltiesCreated,
    required super.noveltiesCompleted,
    required super.reportsGenerated,
    required super.participationsInReports,
    required super.averageResolutionTimeHours,
  });

  factory UserPerformanceModel.fromJson(Map<String, dynamic> json) {
    return UserPerformanceModel(
      userId: json['userId'] ?? 0,
      fullName: json['fullName'] ?? '',
      workRole: json['workRole'] ?? '',
      noveltiesCreated: json['noveltiesCreated'] ?? 0,
      noveltiesCompleted: json['noveltiesCompleted'] ?? 0,
      reportsGenerated: json['reportsGenerated'] ?? 0,
      participationsInReports: json['participationsInReports'] ?? 0,
      averageResolutionTimeHours: (json['averageResolutionTimeHours'] ?? 0.0)
          .toDouble(),
    );
  }
}

class MunicipalityStatsModel extends MunicipalityStats {
  const MunicipalityStatsModel({
    required super.municipality,
    required super.totalNovelties,
    required super.completed,
    required super.pending,
  });

  factory MunicipalityStatsModel.fromJson(Map<String, dynamic> json) {
    return MunicipalityStatsModel(
      municipality: json['municipality'] ?? '',
      totalNovelties: json['totalNovelties'] ?? 0,
      completed: json['completed'] ?? 0,
      pending: json['pending'] ?? 0,
    );
  }
}

class AnalyticsDashboardModel extends AnalyticsDashboard {
  const AnalyticsDashboardModel({
    required super.overview,
    required super.trends,
    required super.topCrews,
    required super.topUsers,
    required super.byMunicipality,
  });

  factory AnalyticsDashboardModel.fromJson(Map<String, dynamic> json) {
    try {
      print('🔍 [DASHBOARD_MODEL] Parsing dashboard...');
      print('🔍 [DASHBOARD_MODEL] JSON keys: ${json.keys}');

      // Parse overview
      final overviewData = json['overview'];
      print('🔍 [DASHBOARD_MODEL] overview type: ${overviewData.runtimeType}');
      final overview = NoveltyOverviewModel.fromJson(
        overviewData is Map<String, dynamic> ? overviewData : {},
      );

      // Parse trends
      final trendsData = json['trends'];
      print('🔍 [DASHBOARD_MODEL] trends type: ${trendsData.runtimeType}');
      List<NoveltyTrendModel> trends = [];
      if (trendsData is List) {
        trends = trendsData
            .map((e) => NoveltyTrendModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      // Parse topCrews
      final topCrewsData = json['topCrews'];
      print('🔍 [DASHBOARD_MODEL] topCrews type: ${topCrewsData.runtimeType}');
      List<CrewPerformanceModel> topCrews = [];
      if (topCrewsData is List) {
        topCrews = topCrewsData
            .map(
              (e) => CrewPerformanceModel.fromJson(e as Map<String, dynamic>),
            )
            .toList();
      }

      // Parse topUsers
      final topUsersData = json['topUsers'];
      print('🔍 [DASHBOARD_MODEL] topUsers type: ${topUsersData.runtimeType}');
      List<UserPerformanceModel> topUsers = [];
      if (topUsersData is List) {
        topUsers = topUsersData
            .map(
              (e) => UserPerformanceModel.fromJson(e as Map<String, dynamic>),
            )
            .toList();
      }

      // Parse byMunicipality
      final byMunicipalityData = json['byMunicipality'];
      print(
        '🔍 [DASHBOARD_MODEL] byMunicipality type: ${byMunicipalityData.runtimeType}',
      );
      List<MunicipalityStatsModel> byMunicipality = [];
      if (byMunicipalityData is List) {
        byMunicipality = byMunicipalityData
            .map(
              (e) => MunicipalityStatsModel.fromJson(e as Map<String, dynamic>),
            )
            .toList();
      }

      print('✅ [DASHBOARD_MODEL] Dashboard parsed successfully');

      return AnalyticsDashboardModel(
        overview: overview,
        trends: trends,
        topCrews: topCrews,
        topUsers: topUsers,
        byMunicipality: byMunicipality,
      );
    } catch (e, stackTrace) {
      print('❌ [DASHBOARD_MODEL] Error parsing dashboard: $e');
      print('❌ [DASHBOARD_MODEL] JSON received: $json');
      print('❌ [DASHBOARD_MODEL] Stack: $stackTrace');
      rethrow;
    }
  }
}
