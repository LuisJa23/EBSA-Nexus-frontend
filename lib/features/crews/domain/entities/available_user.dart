// available_user.dart
//
// Entidad de usuario disponible para cuadrillas
//
// PROPÓSITO:
// - Representa un usuario que puede ser agregado a una cuadrilla
//
// CAPA: DOMAIN LAYER

import 'package:equatable/equatable.dart';

/// Usuario disponible para ser agregado a una cuadrilla
class AvailableUser extends Equatable {
  final int id;
  final String uuid;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String roleName;
  final String? workRoleName; // Puede ser null
  final String workType;
  final String documentNumber;
  final String phone;
  final bool active;

  const AvailableUser({
    required this.id,
    required this.uuid,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.roleName,
    this.workRoleName, // Opcional
    required this.workType,
    required this.documentNumber,
    required this.phone,
    required this.active,
  });

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [
    id,
    uuid,
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
