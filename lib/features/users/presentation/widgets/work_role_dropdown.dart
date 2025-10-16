// work_role_dropdown.dart
//
// Componente especializado para dropdown de roles de trabajo
//
// PROPÓSITO:
// - Dropdown específico para roles de trabajo
// - Manejo de estados asíncronos (loading, error, data)
// - Integración con providers de Riverpod
//
// CAPA: PRESENTATION LAYER - WIDGETS

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/work_role.dart';
import '../providers/work_roles_provider.dart';
import 'custom_dropdown.dart';

/// Dropdown especializado para selección de roles de trabajo
class WorkRoleDropdown extends ConsumerWidget {
  /// Tipo de trabajador (interno/externo)
  final WorkType? workType;

  /// Valor seleccionado
  final String? selectedValue;

  /// Callback cuando cambia la selección
  final void Function(String?)? onChanged;

  /// Función de validación
  final String? Function(String?)? validator;

  const WorkRoleDropdown({
    super.key,
    required this.workType,
    this.selectedValue,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rolesAsync = ref.watch(workRolesByTypeProvider(workType));

    return rolesAsync.when(
      data: (roles) => CustomDropdown<String>(
        value: selectedValue,
        label: 'Rol de Trabajo',
        icon: Icons.work,
        items: roles
            .map(
              (role) =>
                  DropdownMenuItem(value: role.name, child: Text(role.name)),
            )
            .toList(),
        onChanged: onChanged,
        validator: validator,
      ),
      loading: () => const DropdownLoadingWidget(
        label: 'Rol de Trabajo',
        icon: Icons.work,
        loadingText: 'Cargando roles...',
      ),
      error: (error, stack) => DropdownErrorWidget(
        label: 'Rol de Trabajo',
        icon: Icons.work,
        error: error.toString(),
        onRetry: () => ref.invalidate(workRolesByTypeProvider),
      ),
    );
  }
}
