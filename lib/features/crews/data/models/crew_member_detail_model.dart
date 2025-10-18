// crew_member_detail_model.dart
//
// Modelo de detalle de miembro de cuadrilla
//
// PROPÓSITO:
// - Transformar datos de API a entidad CrewMemberDetail
// - Serialización y deserialización JSON
//
// CAPA: DATA LAYER

import '../../domain/entities/crew_member_detail.dart';

/// Modelo de miembro de cuadrilla detallado para comunicación con API
class CrewMemberDetailModel extends CrewMemberDetail {
  const CrewMemberDetailModel({
    required super.id,
    required super.crewId,
    required super.userId,
    required super.isLeader,
    required super.joinedAt,
    super.leftAt,
    super.notes,
    required super.userUuid,
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

  /// Crear modelo desde JSON
  factory CrewMemberDetailModel.fromJson(Map<String, dynamic> json) {
    // El API retorna los datos del usuario en el nivel raíz del miembro
    return CrewMemberDetailModel(
      id: json['id'] as int,
      crewId: json['crewId'] ?? 0, // Puede ser null según el API
      userId: json['userId'] as int,
      isLeader: json['isLeader'] as bool,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      leftAt: json['leftAt'] != null
          ? DateTime.parse(json['leftAt'] as String)
          : null,
      notes: json['notes'] as String?,
      // Datos del usuario en el nivel raíz
      userUuid: json['userUuid'] as String? ?? 'unknown-uuid',
      username: json['username'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      roleName: json['roleName'] as String? ?? 'N/A',
      workRoleName: json['workRoleName'] as String,
      workType: json['workType'] as String? ?? 'N/A',
      documentNumber: json['documentNumber'] as String? ?? 'N/A',
      phone: json['phone'] as String? ?? 'N/A',
      active: json['active'] as bool? ?? true,
    );
  }

  /// Convertir modelo a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'crewId': crewId,
      'userId': userId,
      'isLeader': isLeader,
      'joinedAt': joinedAt.toIso8601String(),
      'leftAt': leftAt?.toIso8601String(),
      'notes': notes,
      'user': {
        'uuid': userUuid,
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
      },
    };
  }

  /// Convertir a entidad
  CrewMemberDetail toEntity() {
    return CrewMemberDetail(
      id: id,
      crewId: crewId,
      userId: userId,
      isLeader: isLeader,
      joinedAt: joinedAt,
      leftAt: leftAt,
      notes: notes,
      userUuid: userUuid,
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
