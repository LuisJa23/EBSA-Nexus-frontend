// work_role_model.dart
//
// Modelo de datos para roles de trabajo
//
// PROPÓSITO:
// - Extender WorkRole para la capa de datos
// - Deserialización desde JSON (si viene del servidor)
// - Datos hardcodeados según especificaciones
//
// CAPA: DATA LAYER

import '../../domain/entities/work_role.dart';

/// Modelo de datos para rol de trabajo
///
/// Extiende la entidad del dominio y agrega funcionalidades
/// de serialización si es necesario.
class WorkRoleModel extends WorkRole {
  const WorkRoleModel({
    required super.id,
    required super.name,
    required super.workType,
    super.description,
  });

  /// Factory desde JSON (si viene del servidor)
  factory WorkRoleModel.fromJson(Map<String, dynamic> json) {
    return WorkRoleModel(
      id: json['id'] as int,
      name: json['name'] as String,
      workType: WorkType.fromString(json['workType'] as String),
      description: json['description'] as String?,
    );
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'workType': workType.value,
      'description': description,
    };
  }

  /// Factory desde entidad del dominio
  factory WorkRoleModel.fromEntity(WorkRole role) {
    return WorkRoleModel(
      id: role.id,
      name: role.name,
      workType: role.workType,
      description: role.description,
    );
  }
}

/// Datos hardcodeados de roles según especificaciones del backend
class WorkRolesData {
  WorkRolesData._();

  /// Roles de trabajadores internos
  static const List<WorkRoleModel> internRoles = [
    WorkRoleModel(
      id: 1,
      name: 'Desarrollador',
      workType: WorkType.intern,
      description: 'Desarrollador de software',
    ),
    WorkRoleModel(
      id: 4,
      name: 'Coordinación de distribución',
      workType: WorkType.intern,
      description: 'Responsable de coordinar la distribución eléctrica',
    ),
    WorkRoleModel(
      id: 5,
      name: 'Coordinador comercial',
      workType: WorkType.intern,
      description: 'Coordinador del área comercial',
    ),
    WorkRoleModel(
      id: 6,
      name: 'Jefe de Cuadrilla',
      workType: WorkType.intern,
      description: 'Líder de cuadrilla de trabajo',
    ),
    WorkRoleModel(
      id: 7,
      name: 'Liniero',
      workType: WorkType.intern,
      description: 'Técnico de líneas eléctricas',
    ),
  ];

  /// Roles de trabajadores externos
  static const List<WorkRoleModel> externRoles = [
    WorkRoleModel(
      id: 2,
      name: 'Consultor',
      workType: WorkType.extern,
      description: 'Consultor externo',
    ),
    WorkRoleModel(
      id: 8,
      name: 'Auxiliares',
      workType: WorkType.extern,
      description: 'Personal auxiliar de soporte',
    ),
    WorkRoleModel(
      id: 9,
      name: 'Aforadores',
      workType: WorkType.extern,
      description: 'Personal encargado de mediciones',
    ),
    WorkRoleModel(
      id: 10,
      name: 'Génicos',
      workType: WorkType.extern,
      description: 'Personal técnico especializado',
    ),
    WorkRoleModel(
      id: 12,
      name: 'Liniero Externo',
      workType: WorkType.extern,
      description: 'Técnico de líneas eléctricas externo',
    ),
  ];

  /// Obtener roles por tipo de trabajador
  static List<WorkRoleModel> getRolesByType(WorkType workType) {
    return workType == WorkType.intern ? internRoles : externRoles;
  }

  /// Obtener todos los roles
  static List<WorkRoleModel> getAllRoles() {
    return [...internRoles, ...externRoles];
  }

  /// Buscar rol por ID
  static WorkRoleModel? findById(int id) {
    try {
      return getAllRoles().firstWhere((role) => role.id == id);
    } catch (e) {
      return null;
    }
  }
}
