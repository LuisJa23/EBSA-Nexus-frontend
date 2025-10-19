// crew_member_detail.dart
//
// Entidad de detalle de miembro de cuadrilla
//
// PROPÓSITO:
// - Representa un miembro de cuadrilla con información completa del usuario
//
// CAPA: DOMAIN LAYER

import 'package:equatable/equatable.dart';

/// Miembro de cuadrilla con información detallada
class CrewMemberDetail extends Equatable {
  final int id;
  final int crewId;
  final int userId;
  final bool isLeader;
  final DateTime joinedAt;
  final DateTime? leftAt;
  final String? notes;
  final String userUuid;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String roleName;
  final String? workRoleName;
  final String workType;
  final String documentNumber;
  final String phone;
  final bool active;

  const CrewMemberDetail({
    required this.id,
    required this.crewId,
    required this.userId,
    required this.isLeader,
    required this.joinedAt,
    this.leftAt,
    this.notes,
    required this.userUuid,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.roleName,
    this.workRoleName,
    required this.workType,
    required this.documentNumber,
    required this.phone,
    required this.active,
  });

  String get fullName => '$firstName $lastName';
  bool get isActiveMember => leftAt == null;

  @override
  List<Object?> get props => [
    id,
    crewId,
    userId,
    isLeader,
    joinedAt,
    leftAt,
    notes,
    userUuid,
    username,
    email,
    firstName,
    lastName,
    roleName,
    workRoleName,
    workType,
    documentNumber,
    phone,
    active,
  ];
}
