// crew.dart
//
// Entidad de cuadrilla
//
// PROPÓSITO:
// - Representa una cuadrilla de trabajo completa
//
// CAPA: DOMAIN LAYER

import 'package:equatable/equatable.dart';

/// Cuadrilla de trabajo
class Crew extends Equatable {
  final int id;
  final String name;
  final String description;
  final String status;
  final int createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int? activeMemberCount;
  final bool? hasActiveAssignments;

  const Crew({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.activeMemberCount,
    this.hasActiveAssignments,
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
