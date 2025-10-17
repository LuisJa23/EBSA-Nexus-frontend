// available_user_model.dart
//
// Modelo de usuario disponible
//
// PROPÓSITO:
// - Conversión JSON ↔ Entidad
//
// CAPA: DATA LAYER

import '../../domain/entities/available_user.dart';

class AvailableUserModel extends AvailableUser {
  const AvailableUserModel({
    required super.id,
    required super.uuid,
    required super.username,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.roleName,
    required super.workRoleName,
    required super.workType,
    required super.documentNumber,
    required super.phone,
    required super.active,
  });

  factory AvailableUserModel.fromJson(Map<String, dynamic> json) {
    return AvailableUserModel(
      id: json['id'] as int,
      uuid: json['uuid'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      roleName: json['roleName'] as String,
      workRoleName: json['workRoleName'] as String,
      workType: json['workType'] as String,
      documentNumber: json['documentNumber'] as String,
      phone: json['phone'] as String,
      active: json['active'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'uuid': uuid,
    'username': username,
    'email': email,
    'firstName': firstName,
    'lastName': lastName,
    'roleName': roleName,
    'workRoleName': workRoleName,
    'workType': workType,
    'documentNumber': documentNumber,
    'phone': phone,
    'active': active,
  };

  AvailableUser toEntity() {
    return AvailableUser(
      id: id,
      uuid: uuid,
      username: username,
      email: email,
      firstName: firstName,
      lastName: lastName,
      roleName: roleName,
      workRoleName: workRoleName,
      workType: workType,
      documentNumber: documentNumber,
      phone: phone,
      active: active,
    );
  }
}
