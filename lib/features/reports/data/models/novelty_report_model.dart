// novelty_report_model.dart
//
// Modelo de reporte de novedad
//
// PROPÓSITO:
// - Representar un reporte de resolución de novedad
// - Serialización/deserialización JSON
//
// CAPA: DATA LAYER - MODELS

class NoveltyReportModel {
  final int id;
  final int noveltyId;
  final GeneratedByModel generatedBy;
  final String reportContent;
  final String? observations;
  final DateTime workStartDate;
  final DateTime workEndDate;
  final String resolutionStatus;
  final List<ReportParticipantModel> participants;
  final DateTime createdAt;

  NoveltyReportModel({
    required this.id,
    required this.noveltyId,
    required this.generatedBy,
    required this.reportContent,
    this.observations,
    required this.workStartDate,
    required this.workEndDate,
    required this.resolutionStatus,
    required this.participants,
    required this.createdAt,
  });

  factory NoveltyReportModel.fromJson(Map<String, dynamic> json) {
    return NoveltyReportModel(
      id: json['id'] as int,
      noveltyId: json['noveltyId'] as int,
      generatedBy: GeneratedByModel.fromJson(
        json['generatedBy'] as Map<String, dynamic>,
      ),
      reportContent: json['reportContent'] as String,
      observations: json['observations'] as String?,
      workStartDate: DateTime.parse(json['workStartDate'] as String),
      workEndDate: DateTime.parse(json['workEndDate'] as String),
      resolutionStatus: json['resolutionStatus'] as String,
      participants: (json['participants'] as List<dynamic>)
          .map(
            (e) => ReportParticipantModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'noveltyId': noveltyId,
      'generatedBy': generatedBy.toJson(),
      'reportContent': reportContent,
      'observations': observations,
      'workStartDate': workStartDate.toIso8601String(),
      'workEndDate': workEndDate.toIso8601String(),
      'resolutionStatus': resolutionStatus,
      'participants': participants.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String get resolutionStatusLocalized {
    switch (resolutionStatus) {
      case 'COMPLETADA':
        return 'Completada';
      case 'NO_COMPLETADA':
        return 'No Completada';
      case 'CERRADA':
        return 'Cerrada';
      default:
        return resolutionStatus;
    }
  }
}

class GeneratedByModel {
  final int id;
  final String fullName;
  final String email;

  GeneratedByModel({
    required this.id,
    required this.fullName,
    required this.email,
  });

  factory GeneratedByModel.fromJson(Map<String, dynamic> json) {
    return GeneratedByModel(
      id: json['id'] as int,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'fullName': fullName, 'email': email};
  }
}

class ReportParticipantModel {
  final int userId;
  final String fullName;
  final DateTime addedAt;

  ReportParticipantModel({
    required this.userId,
    required this.fullName,
    required this.addedAt,
  });

  factory ReportParticipantModel.fromJson(Map<String, dynamic> json) {
    return ReportParticipantModel(
      userId: json['userId'] as int,
      fullName: json['fullName'] as String,
      addedAt: DateTime.parse(json['addedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'fullName': fullName,
      'addedAt': addedAt.toIso8601String(),
    };
  }
}

/// Modelo para crear un reporte
class CreateNoveltyReportRequest {
  final int noveltyId;
  final String reportContent;
  final String? observations;
  final DateTime workStartDate;
  final DateTime workEndDate;
  final String resolutionStatus;
  final List<ParticipantRequest> participants;

  CreateNoveltyReportRequest({
    required this.noveltyId,
    required this.reportContent,
    this.observations,
    required this.workStartDate,
    required this.workEndDate,
    required this.resolutionStatus,
    required this.participants,
  });

  Map<String, dynamic> toJson() {
    return {
      'noveltyId': noveltyId,
      'reportContent': reportContent,
      'observations': observations,
      'workStartDate': workStartDate.toIso8601String(),
      'workEndDate': workEndDate.toIso8601String(),
      'resolutionStatus': resolutionStatus,
      'participants': participants.map((e) => e.toJson()).toList(),
    };
  }
}

class ParticipantRequest {
  final int userId;

  ParticipantRequest({required this.userId});

  Map<String, dynamic> toJson() {
    return {'userId': userId};
  }
}
