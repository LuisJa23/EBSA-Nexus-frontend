// crew_model.dart
//
// Modelo de cuadrilla
//
// PROPÓSITO:
// - Transformar datos de API a entidad Crew
// - Serialización y deserialización JSON
//
// CAPA: DATA LAYER

import '../../domain/entities/crew.dart';

/// Modelo de cuadrilla para comunicación con API
class CrewModel extends Crew {
  const CrewModel({
    required super.id,
    required super.name,
    required super.description,
    required super.status,
    required super.createdBy,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
    super.activeMemberCount,
    super.hasActiveAssignments,
  });

  /// Crear modelo desde JSON
  factory CrewModel.fromJson(Map<String, dynamic> json) {
    return CrewModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      createdBy: json['createdBy'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'] as String)
          : null,
      activeMemberCount: json['activeMemberCount'] as int?,
      hasActiveAssignments: json['hasActiveAssignments'] as bool?,
    );
  }

  /// Convertir modelo a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'activeMemberCount': activeMemberCount,
      'hasActiveAssignments': hasActiveAssignments,
    };
  }

  /// Convertir a entidad
  Crew toEntity() {
    return Crew(
      id: id,
      name: name,
      description: description,
      status: status,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      activeMemberCount: activeMemberCount,
      hasActiveAssignments: hasActiveAssignments,
    );
  }
}
