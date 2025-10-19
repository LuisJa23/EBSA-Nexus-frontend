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
          // Nueva estructura: miembro viene con información limitada
          return CrewMemberDetailModel(
            id: memberJson['id'] as int,
            crewId: memberJson['crewId'] as int,
            userId: memberJson['userId'] as int,
            isLeader: memberJson['isLeader'] as bool,
            joinedAt: DateTime.parse(memberJson['joinedAt'] as String),
            leftAt: memberJson['leftAt'] != null
                ? DateTime.parse(memberJson['leftAt'] as String)
                : null,
            notes: null, // No viene en esta respuesta
            userUuid: 'user-${memberJson['userId']}', // Generar UUID temporal
            username: memberJson['username'] as String? ?? 'Usuario ${memberJson['userId']}',
            email: 'usuario${memberJson['userId']}@ebsa.com.co', // Email por defecto
            firstName: _extractFirstName(memberJson['fullName'] as String?),
            lastName: _extractLastName(memberJson['fullName'] as String?),
            roleName: 'Sin rol asignado', // No viene en esta respuesta
            workRoleName: null, // No viene en esta respuesta - será null
            workType: 'Sin tipo asignado', // No viene en esta respuesta
            documentNumber: 'N/A', // No viene en esta respuesta
            phone: 'N/A', // No viene en esta respuesta
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

  /// Extraer el primer nombre del nombre completo
  static String _extractFirstName(String? fullName) {
    if (fullName == null || fullName.isEmpty) return 'Usuario';
    final parts = fullName.trim().split(' ');
    return parts.isNotEmpty ? parts.first : 'Usuario';
  }

  /// Extraer el apellido del nombre completo
  static String _extractLastName(String? fullName) {
    if (fullName == null || fullName.isEmpty) return 'Sin Apellido';
    final parts = fullName.trim().split(' ');
    return parts.length > 1 ? parts.sublist(1).join(' ') : 'Sin Apellido';
  }
}
