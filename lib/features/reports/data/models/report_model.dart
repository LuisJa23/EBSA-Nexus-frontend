// report_model.dart
//
// Modelo de datos para Reporte (Data Layer)
//
// PROPÓSITO:
// - Representar datos de reporte de la API y DB local
// - Transformación JSON ↔ Objeto ↔ Database
// - Manejo de estados de sincronización
//
// CAPA: DATA LAYER

import 'dart:convert';

import '../../../../core/database/app_database.dart';
import 'evidence_model.dart';

/// Modelo de reporte con soporte offline
///
/// Representa reportes creados localmente o descargados del servidor
class ReportModel {
  /// ID local del reporte (UUID)
  final String id;

  /// ID del servidor (null si no está sincronizado)
  final int? serverId;

  /// ID de la novedad asociada
  final int noveltyId;

  /// Descripción del trabajo realizado
  final String workDescription;

  /// Observaciones adicionales
  final String? observations;

  /// Tiempo de trabajo en minutos
  final int workTime;

  /// Fecha de inicio del trabajo
  final DateTime workStartDate;

  /// Fecha de fin del trabajo
  final DateTime workEndDate;

  /// Estado de resolución (COMPLETADO, NO_COMPLETADO)
  final String resolutionStatus;

  /// IDs de participantes
  final List<int> participantIds;

  /// Latitud GPS
  final double latitude;

  /// Longitud GPS
  final double longitude;

  /// Precisión GPS en metros
  final double? accuracy;

  /// Lista de evidencias
  final List<EvidenceModel> evidences;

  /// Fecha de creación local
  final DateTime createdAt;

  /// Fecha de última actualización
  final DateTime updatedAt;

  /// Está sincronizado con el servidor
  final bool isSynced;

  /// Fecha de sincronización exitosa
  final DateTime? syncedAt;

  /// Último intento de sincronización
  final DateTime? lastSyncAttempt;

  /// Cantidad de intentos de sincronización
  final int syncAttempts;

  /// Error de sincronización
  final String? syncError;

  const ReportModel({
    required this.id,
    this.serverId,
    required this.noveltyId,
    required this.workDescription,
    this.observations,
    required this.workTime,
    required this.workStartDate,
    required this.workEndDate,
    required this.resolutionStatus,
    required this.participantIds,
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.evidences = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
    this.syncedAt,
    this.lastSyncAttempt,
    this.syncAttempts = 0,
    this.syncError,
  });

  /// Crea desde JSON (API)
  factory ReportModel.fromJson(Map<String, dynamic> json) {
    final evidencesList =
        (json['evidences'] as List<dynamic>?)
            ?.map((e) => EvidenceModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return ReportModel(
      id: json['id']?.toString() ?? '',
      serverId: json['serverId'] as int?,
      noveltyId: json['noveltyId'] as int,
      workDescription: json['workDescription'] as String,
      observations: json['observations'] as String?,
      workTime: json['workTime'] as int,
      workStartDate: DateTime.parse(json['workStartDate'] as String),
      workEndDate: DateTime.parse(json['workEndDate'] as String),
      resolutionStatus: json['resolutionStatus'] as String? ?? 'COMPLETADO',
      participantIds: (json['participantIds'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      evidences: evidencesList,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isSynced: json['isSynced'] as bool? ?? true,
      syncedAt: json['syncedAt'] != null
          ? DateTime.parse(json['syncedAt'] as String)
          : null,
      lastSyncAttempt: json['lastSyncAttempt'] != null
          ? DateTime.parse(json['lastSyncAttempt'] as String)
          : null,
      syncAttempts: json['syncAttempts'] as int? ?? 0,
      syncError: json['syncError'] as String?,
    );
  }

  /// Convierte a JSON (para API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serverId': serverId,
      'noveltyId': noveltyId,
      'workDescription': workDescription,
      'observations': observations,
      'workTime': workTime,
      'participantIds': participantIds,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'evidences': evidences.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced,
      'syncedAt': syncedAt?.toIso8601String(),
      'lastSyncAttempt': lastSyncAttempt?.toIso8601String(),
      'syncAttempts': syncAttempts,
      'syncError': syncError,
    };
  }

  /// Crea desde datos de Drift
  factory ReportModel.fromDrift(
    ReportTableData data,
    List<EvidenceModel> evidences,
  ) {
    final participantIds = (jsonDecode(data.participantIds) as List<dynamic>)
        .map((e) => e as int)
        .toList();

    return ReportModel(
      id: data.id,
      serverId: data.serverId,
      noveltyId: data.noveltyId,
      workDescription: data.workDescription,
      observations: data.observations,
      workTime: data.workTime,
      workStartDate: data.workStartDate,
      workEndDate: data.workEndDate,
      resolutionStatus: data.resolutionStatus,
      participantIds: participantIds,
      latitude: data.latitude,
      longitude: data.longitude,
      accuracy: data.accuracy,
      evidences: evidences,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      isSynced: data.isSynced,
      syncedAt: data.syncedAt,
      lastSyncAttempt: data.lastSyncAttempt,
      syncAttempts: data.syncAttempts,
      syncError: data.syncError,
    );
  }

  /// Convierte a formato para envío al servidor
  /// Replica EXACTAMENTE el formato del flujo online (CreateNoveltyReportRequest)
  Map<String, dynamic> toServerPayload() {
    // Mapear estado local al esperado por el API
    // BD local: "COMPLETADO" y "NO_COMPLETADO"
    // API espera: "COMPLETADA" y "NO_COMPLETADA"
    final apiResolutionStatus = resolutionStatus == 'COMPLETADO'
        ? 'COMPLETADA'
        : (resolutionStatus == 'NO_COMPLETADO'
              ? 'NO_COMPLETADA'
              : resolutionStatus);

    // Convertir IDs de participantes a objetos con formato del API
    // IDÉNTICO al flujo online: List<ParticipantRequest>
    final participants = participantIds
        .map((userId) => {'userId': userId})
        .toList();

    // Payload IDÉNTICO al CreateNoveltyReportRequest del flujo online
    return {
      'noveltyId': noveltyId,
      'reportContent': workDescription, // workDescription -> reportContent
      'observations': observations,
      'workStartDate': workStartDate.toIso8601String(),
      'workEndDate': workEndDate.toIso8601String(),
      'resolutionStatus': apiResolutionStatus,
      'participants': participants,
    };
  }

  /// Copia con cambios
  ReportModel copyWith({
    String? id,
    int? serverId,
    int? noveltyId,
    String? workDescription,
    String? observations,
    int? workTime,
    DateTime? workStartDate,
    DateTime? workEndDate,
    String? resolutionStatus,
    List<int>? participantIds,
    double? latitude,
    double? longitude,
    double? accuracy,
    List<EvidenceModel>? evidences,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    DateTime? syncedAt,
    DateTime? lastSyncAttempt,
    int? syncAttempts,
    String? syncError,
  }) {
    return ReportModel(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      noveltyId: noveltyId ?? this.noveltyId,
      workDescription: workDescription ?? this.workDescription,
      observations: observations ?? this.observations,
      workTime: workTime ?? this.workTime,
      workStartDate: workStartDate ?? this.workStartDate,
      workEndDate: workEndDate ?? this.workEndDate,
      resolutionStatus: resolutionStatus ?? this.resolutionStatus,
      participantIds: participantIds ?? this.participantIds,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      evidences: evidences ?? this.evidences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      syncedAt: syncedAt ?? this.syncedAt,
      lastSyncAttempt: lastSyncAttempt ?? this.lastSyncAttempt,
      syncAttempts: syncAttempts ?? this.syncAttempts,
      syncError: syncError ?? this.syncError,
    );
  }
}
