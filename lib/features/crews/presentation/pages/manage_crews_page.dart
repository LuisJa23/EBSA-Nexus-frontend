// manage_crews_page.dart
//
// Página para gestionar cuadrillas
//
// PROPÓSITO:
// - Menú de opciones para gestión de cuadrillas
// - Acceso a creación y listado de cuadrillas
//
// CAPA: PRESENTATION LAYER

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/home_action_card.dart';
import '../../../authentication/domain/entities/user.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';

/// Página para gestión de cuadrillas del sistema
///
/// Muestra opciones para crear y listar cuadrillas.
/// Reutiliza el diseño de HomeActionCard para mantener
/// consistencia visual con el resto de la aplicación.
class ManageCrewsPage extends ConsumerWidget {
  const ManageCrewsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    // Verificar permisos según rol
    final isAdmin = user?.role == UserRole.admin;
    final isAreaManager = user?.role == UserRole.areaManager;
    final hasFullAccess = isAdmin || isAreaManager;

    return Scaffold(
      appBar: AppBar(
        title: Text(hasFullAccess ? 'Gestionar Cuadrillas' : 'Ver Cuadrillas'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(hasFullAccess),
            const SizedBox(height: 32),
            _buildOptionsCards(context, hasFullAccess),
          ],
        ),
      ),
    );
  }

  /// Construye el header de la página
  Widget _buildHeader(bool hasFullAccess) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hasFullAccess
              ? 'Elige la opción que deseas realizar'
              : 'Consulta las cuadrillas del sistema',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// Construye las tarjetas de opciones
  Widget _buildOptionsCards(BuildContext context, bool hasFullAccess) {
    return Column(
      children: [
        // Opción 1: Crear Cuadrilla (Solo Admin y Jefe de Área)
        if (hasFullAccess) ...[
          HomeActionCard(
            icon: Icons.group_add,
            title: 'Crear Cuadrilla',
            subtitle: 'Añadir nueva cuadrilla al sistema',
            onTap: () => context.push(RouteNames.createCrew),
          ),
          const SizedBox(height: 16),
        ],

        // Opción 2: Lista de Cuadrillas (Todos los roles)
        HomeActionCard(
          icon: Icons.groups_outlined,
          title: 'Lista de Cuadrillas',
          subtitle: 'Mostrar lista de cuadrillas',
          onTap: () => context.push(RouteNames.listCrews),
        ),
      ],
    );
  }
}
