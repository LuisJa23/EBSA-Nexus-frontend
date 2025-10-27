// novelty_response.dart
//
// Modelo de respuesta para una novedad individual
//
// PROPÓSITO:
// - Mapear la respuesta JSON del endpoint de novedades
// - Conversión entre DTO y entidad de dominio
//
// CAPA: DATA LAYER - MODELS

import '../../domain/entities/novelty.dart';

/// Modelo de respuesta para una novedad
class NoveltyResponse {
  final int id;
  final String description;
  final String status;
  final String priority;
  final String reason;
  final String accountNumber;
  final String meterNumber;
  final String activeReading;
  final String reactiveReading;
  final String municipality;
  final String address;
  final String? observations;
  final int? crewId;
  final String? crewName;
  final int areaId;
  final String areaName;
  final int creatorId;
  final String creatorName;
  final int imageCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  NoveltyResponse({
    required this.id,
    required this.description,
    required this.status,
    required this.priority,
    required this.reason,
    required this.accountNumber,
    required this.meterNumber,
    required this.activeReading,
    required this.reactiveReading,
    required this.municipality,
    required this.address,
    this.observations,
    this.crewId,
    this.crewName,
    required this.areaId,
    required this.areaName,
    required this.creatorId,
    required this.creatorName,
    required this.imageCount,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crea una instancia desde JSON
  factory NoveltyResponse.fromJson(Map<String, dynamic> json) {
    return NoveltyResponse(
      id: json['id'] as int,
      description: json['description'] as String,
      status: json['status'] as String,
      priority: json['priority'] as String? ?? 'NORMAL', // Default si no viene
      reason: json['reason'] as String,
      accountNumber: json['accountNumber'] as String,
      meterNumber: json['meterNumber'] as String,
      // El backend devuelve double, convertir a String
      activeReading: (json['activeReading'] as num).toString(),
      reactiveReading: (json['reactiveReading'] as num).toString(),
      municipality: json['municipality'] as String,
      address: json['address'] as String,
      observations: json['observations'] as String?,
      crewId: json['crewId'] as int?,
      crewName: json['crewName'] as String?, // Puede que no venga del backend
      areaId: json['areaId'] as int,
      areaName: json['areaName'] as String? ?? '', // Default si no viene
      creatorId: json['createdBy'] as int, // Backend usa "createdBy"
      creatorName: json['creatorName'] as String? ?? '', // Default si no viene
      imageCount: json['imageCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'status': status,
      'priority': priority,
      'reason': reason,
      'accountNumber': accountNumber,
      'meterNumber': meterNumber,
      'activeReading': activeReading,
      'reactiveReading': reactiveReading,
      'municipality': municipality,
      'address': address,
      'observations': observations,
      'crewId': crewId,
      'crewName': crewName,
      'areaId': areaId,
      'areaName': areaName,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'imageCount': imageCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Convierte a entidad de dominio
  Novelty toEntity() {
    return Novelty(
      id: id,
      description: description,
      status: NoveltyStatus.fromString(status),
      priority: NoveltyPriority.fromString(priority),
      reason: reason,
      accountNumber: accountNumber,
      meterNumber: meterNumber,
      activeReading: activeReading,
      reactiveReading: reactiveReading,
      municipality: municipality,
      address: address,
      observations: observations,
      crewId: crewId,
      crewName: crewName,
      areaId: areaId,
      areaName: areaName,
      creatorId: creatorId,
      creatorName: creatorName,
      imageCount: imageCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
