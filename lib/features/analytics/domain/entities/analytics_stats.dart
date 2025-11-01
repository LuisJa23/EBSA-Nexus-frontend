// analytics_stats.dart
// Entidades para estadísticas y analytics

import 'package:equatable/equatable.dart';

/// Estadísticas generales de novedades
class NoveltyOverview extends Equatable {
  final int totalNovelties;
  final Map<String, int> byStatus;
  final Map<String, int> byArea;
  final Map<String, int> byReason;
  final double averageResolutionTimeHours;
  final int resolvedNovelties;
  final int pendingNovelties;

  const NoveltyOverview({
    required this.totalNovelties,
    required this.byStatus,
    required this.byArea,
    required this.byReason,
    required this.averageResolutionTimeHours,
    required this.resolvedNovelties,
    required this.pendingNovelties,
  });

  factory NoveltyOverview.fromJson(Map<String, dynamic> json) {
    return NoveltyOverview(
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

  @override
  List<Object?> get props => [
    totalNovelties,
    byStatus,
    byArea,
    byReason,
    averageResolutionTimeHours,
    resolvedNovelties,
    pendingNovelties,
  ];
}

/// Tendencia temporal
class NoveltyTrend extends Equatable {
  final String period;
  final int created;
  final int completed;
  final int cancelled;

  const NoveltyTrend({
    required this.period,
    required this.created,
    required this.completed,
    required this.cancelled,
  });

  factory NoveltyTrend.fromJson(Map<String, dynamic> json) {
    return NoveltyTrend(
      period: json['period'] ?? '',
      created: json['created'] ?? 0,
      completed: json['completed'] ?? 0,
      cancelled: json['cancelled'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [period, created, completed, cancelled];
}

/// Rendimiento de cuadrilla
class CrewPerformance extends Equatable {
  final int crewId;
  final String crewName;
  final int assignedNovelties;
  final int completedNovelties;
  final int pendingNovelties;
  final double averageResolutionTimeHours;
  final double completionRate;
  final int memberCount;

  const CrewPerformance({
    required this.crewId,
    required this.crewName,
    required this.assignedNovelties,
    required this.completedNovelties,
    required this.pendingNovelties,
    required this.averageResolutionTimeHours,
    required this.completionRate,
    required this.memberCount,
  });

  factory CrewPerformance.fromJson(Map<String, dynamic> json) {
    return CrewPerformance(
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

  @override
  List<Object?> get props => [
    crewId,
    crewName,
    assignedNovelties,
    completedNovelties,
    pendingNovelties,
    averageResolutionTimeHours,
    completionRate,
    memberCount,
  ];
}

/// Rendimiento individual
class UserPerformance extends Equatable {
  final int userId;
  final String fullName;
  final String workRole;
  final int noveltiesCreated;
  final int noveltiesCompleted;
  final int reportsGenerated;
  final int participationsInReports;
  final double averageResolutionTimeHours;

  const UserPerformance({
    required this.userId,
    required this.fullName,
    required this.workRole,
    required this.noveltiesCreated,
    required this.noveltiesCompleted,
    required this.reportsGenerated,
    required this.participationsInReports,
    required this.averageResolutionTimeHours,
  });

  factory UserPerformance.fromJson(Map<String, dynamic> json) {
    return UserPerformance(
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

  @override
  List<Object?> get props => [
    userId,
    fullName,
    workRole,
    noveltiesCreated,
    noveltiesCompleted,
    reportsGenerated,
    participationsInReports,
    averageResolutionTimeHours,
  ];
}

/// Distribución por municipio
class MunicipalityStats extends Equatable {
  final String municipality;
  final int totalNovelties;
  final int completed;
  final int pending;

  const MunicipalityStats({
    required this.municipality,
    required this.totalNovelties,
    required this.completed,
    required this.pending,
  });

  factory MunicipalityStats.fromJson(Map<String, dynamic> json) {
    return MunicipalityStats(
      municipality: json['municipality'] ?? '',
      totalNovelties: json['totalNovelties'] ?? 0,
      completed: json['completed'] ?? 0,
      pending: json['pending'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [municipality, totalNovelties, completed, pending];
}

/// Dashboard completo
class AnalyticsDashboard extends Equatable {
  final NoveltyOverview overview;
  final List<NoveltyTrend> trends;
  final List<CrewPerformance> topCrews;
  final List<UserPerformance> topUsers;
  final List<MunicipalityStats> byMunicipality;

  const AnalyticsDashboard({
    required this.overview,
    required this.trends,
    required this.topCrews,
    required this.topUsers,
    required this.byMunicipality,
  });

  factory AnalyticsDashboard.fromJson(Map<String, dynamic> json) {
    return AnalyticsDashboard(
      overview: NoveltyOverview.fromJson(json['overview'] ?? {}),
      trends:
          (json['trends'] as List?)
              ?.map((e) => NoveltyTrend.fromJson(e))
              .toList() ??
          [],
      topCrews:
          (json['topCrews'] as List?)
              ?.map((e) => CrewPerformance.fromJson(e))
              .toList() ??
          [],
      topUsers:
          (json['topUsers'] as List?)
              ?.map((e) => UserPerformance.fromJson(e))
              .toList() ??
          [],
      byMunicipality:
          (json['byMunicipality'] as List?)
              ?.map((e) => MunicipalityStats.fromJson(e))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [
    overview,
    trends,
    topCrews,
    topUsers,
    byMunicipality,
  ];
}
