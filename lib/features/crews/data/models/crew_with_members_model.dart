// crew_with_members_model.dart
//
// Modelo de cuadrilla con miembros
//
// PROPÓSITO:
// - Transformar datos de API a entidad CrewWithMembers
// - Manejar respuesta que incluye miembros en una sola petición
//
// CAPA: DATA LAYER

import '../../domain/entities/crew_with_members.dart';
import '../../domain/entities/crew_member_detail.dart';
import 'crew_detail_model.dart';
import 'crew_member_detail_model.dart';

/// Modelo de cuadrilla con miembros para comunicación con API
class CrewWithMembersModel extends CrewWithMembers {
  const CrewWithMembersModel({
    required super.crewDetail,
    required super.members,
  });

  /// Crear modelo desde JSON que incluye miembros
  factory CrewWithMembersModel.fromJson(Map<String, dynamic> json) {
    // Parsear detalle de cuadrilla
    final crewDetail = CrewDetailModel.fromJson(json);

    // Parsear miembros si existen
    final List<CrewMemberDetail> members = [];
    if (json['members'] != null && json['members'] is List) {
      final membersList = json['members'] as List<dynamic>;
      members.addAll(
        membersList.map((memberJson) {
          // Adaptar estructura: el miembro viene con datos de usuario directamente
          return CrewMemberDetailModel(
            id: memberJson['id'] as int,
            crewId: json['id'] as int, // Del crew, no del member
            userId: memberJson['userId'] as int,
            isLeader: memberJson['isLeader'] as bool,
            joinedAt: DateTime.parse(memberJson['joinedAt'] as String),
            leftAt: memberJson['leftAt'] != null
                ? DateTime.parse(memberJson['leftAt'] as String)
                : null,
            notes: memberJson['notes'] as String?,
            userUuid: '', // No viene en esta respuesta
            username: memberJson['username'] as String,
            email: memberJson['email'] as String,
            firstName: memberJson['firstName'] as String,
            lastName: memberJson['lastName'] as String,
            roleName: '', // No viene en esta respuesta
            workRoleName: memberJson['workRoleName'] as String,
            workType: '', // No viene en esta respuesta
            documentNumber: '', // No viene en esta respuesta
            phone: '', // No viene en esta respuesta
            active: true, // Asumimos activo si está en la cuadrilla
          );
        }).toList(),
      );
    }

    return CrewWithMembersModel(crewDetail: crewDetail, members: members);
  }

  /// Convertir a entidad
  CrewWithMembers toEntity() {
    return CrewWithMembers(crewDetail: crewDetail, members: members);
  }
}
