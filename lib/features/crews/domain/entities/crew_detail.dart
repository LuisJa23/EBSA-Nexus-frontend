// crew_detail.dart
//
// Entidad de detalle de cuadrilla
//
// PROPÓSITO:
// - Representa el detalle completo de una cuadrilla con sus miembros
//
// CAPA: DOMAIN LAYER

import 'package:equatable/equatable.dart';

/// Detalle completo de una cuadrilla
class CrewDetail extends Equatable {
  final int id;
  final String name;
  final String description;
  final String status;
  final int createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int activeMemberCount;
  final bool hasActiveAssignments;

  const CrewDetail({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.activeMemberCount,
    required this.hasActiveAssignments,
  });

  bool get isAvailable => status == 'DISPONIBLE';
  bool get isActive => deletedAt == null;

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    status,
    createdBy,
    createdAt,
    updatedAt,
    deletedAt,
    activeMemberCount,
    hasActiveAssignments,
  ];
}
