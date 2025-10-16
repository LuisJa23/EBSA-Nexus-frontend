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

/// Provider asíncrono de roles internos
final internWorkRolesProvider = FutureProvider<List<WorkRoleModel>>((
  ref,
) async {
  return await WorkRolesService.fetchByType(WorkType.intern);
});

/// Provider asíncrono de roles externos
final externWorkRolesProvider = FutureProvider<List<WorkRoleModel>>((
  ref,
) async {
  return await WorkRolesService.fetchByType(WorkType.extern);
});

/// Provider de roles según tipo de trabajador
final workRolesByTypeProvider =
    FutureProvider.family<List<WorkRoleModel>, WorkType?>((
      ref,
      workType,
    ) async {
      if (workType == null) return [];
      return await WorkRolesService.fetchByType(workType);
    });
