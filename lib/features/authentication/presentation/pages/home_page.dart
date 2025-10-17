// home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/home_action_card.dart';
import '../../domain/entities/user.dart';
import '../providers/auth_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeHeader(),
          const SizedBox(height: 32),
          _buildActionCards(context, user),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bienvenido',
          style: AppTextStyles.heading1.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '¿Qué deseas hacer hoy?',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCards(BuildContext context, User? user) {
    // Debug: Imprimir información del usuario
    print('🔍 DEBUG Home - User: ${user?.email}');
    print('🔍 DEBUG Home - Role: ${user?.role}');

    // Verificar permisos según rol
    final isAdmin = user?.role == UserRole.admin;
    final isAreaManager = user?.role == UserRole.areaManager;
    final hasFullAccess = isAdmin || isAreaManager;

    print('🔍 DEBUG Home - isAdmin: $isAdmin');
    print('🔍 DEBUG Home - isAreaManager: $isAreaManager');
    print('🔍 DEBUG Home - hasFullAccess: $hasFullAccess');

    return Column(
      children: [
        // 1. Gestionar Novedad (Todos los roles)
        HomeActionCard(
          icon: Icons.notifications_active,
          title: 'Gestionar Novedad',
          subtitle: 'Gestiona Novedad del Sistema',
          onTap: () => context.push(RouteNames.manageIncident),
        ),
        const SizedBox(height: 16),

        // 2. Hacer Reporte (Todos los roles)
        HomeActionCard(
          icon: Icons.description,
          title: 'Hacer Reporte',
          subtitle: 'Hacer reporte de Novedad',
          onTap: () => context.push(RouteNames.createReport),
        ),

        // 3. Consultas (Solo Admin y Jefe de Área)
        if (hasFullAccess) ...[
          const SizedBox(height: 16),
          HomeActionCard(
            icon: Icons.bar_chart,
            title: 'Consultas',
            subtitle: 'Consultar Novedades asignadas',
            onTap: () => context.push(RouteNames.incidentList),
          ),
        ],

        // 4. Gestionar Usuarios (Admin y Jefe de Área)
        if (hasFullAccess) ...[
          const SizedBox(height: 16),
          HomeActionCard(
            icon: Icons.people,
            title: 'Gestionar Usuarios',
            subtitle: 'Hacer gestión de usuarios',
            onTap: () => context.push(RouteNames.manageUsers),
          ),
        ],

        // 5. Gestionar Cuadrillas
        const SizedBox(height: 16),
        HomeActionCard(
          icon: Icons.groups,
          title: 'Gestionar Cuadrillas',
          subtitle: 'Administración de cuadrillas',
          onTap: () => context.push(RouteNames.manageCrews),
        ),
      ],
    );
  }
}
