// work_roles_provider.dart
//
// Provider de roles de trabajo
//
// PROPÓSITO:
// - Proveer lista de roles disponibles según tipo de trabajador
// - Facilitar selección de roles en el formulario
//
// CAPA: PRESENTATION LAYER

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/work_role_model.dart';
import '../../domain/entities/work_role.dart';

/// Provider de roles internos
final internWorkRolesProvider = Provider<List<WorkRoleModel>>((ref) {
  return WorkRolesData.internRoles;
});

/// Provider de roles externos
final externWorkRolesProvider = Provider<List<WorkRoleModel>>((ref) {
  return WorkRolesData.externRoles;
});

/// Provider de roles según tipo de trabajador
final workRolesByTypeProvider =
    Provider.family<List<WorkRoleModel>, WorkType?>((ref, workType) {
  if (workType == null) return [];
  return workType == WorkType.intern
      ? ref.watch(internWorkRolesProvider)
      : ref.watch(externWorkRolesProvider);
});
