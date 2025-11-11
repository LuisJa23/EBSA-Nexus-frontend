// manage_users_page.dart
//
// Página para gestionar usuarios (Admin y Jefe de Área)
//
// PROPÓSITO:
// - Menú de opciones para gestión de usuarios
// - Acceso a creación (solo Admin) y listado de usuarios
// - Accesible para usuarios con rol ADMIN o AREA_MANAGER
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

/// Página para gestión de usuarios del sistema
///
/// Muestra opciones para crear (solo Admin) y listar usuarios.
/// Reutiliza el diseño de HomeActionCard para mantener
/// consistencia visual con el resto de la aplicación.
///
/// **Restricción**: 
/// - Crear Usuario: Solo ADMIN
/// - Ver Lista: ADMIN y AREA_MANAGER
class ManageUsersPage extends ConsumerWidget {
  const ManageUsersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final isAdmin = user?.role == UserRole.admin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Usuarios'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildOptionsCards(context, isAdmin),
          ],
        ),
      ),
    );
  }

  /// Construye el header de la página
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Elige la opción que deseas realizar',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// Construye las tarjetas de opciones
  Widget _buildOptionsCards(BuildContext context, bool isAdmin) {
    return Column(
      children: [
        // Opción 1: Crear Usuario (Solo Admin)
        if (isAdmin) ...[
          HomeActionCard(
            icon: Icons.person_add,
            title: 'Crear Usuario',
            subtitle: 'Añadir Usuario al Sistema',
            onTap: () => context.push(RouteNames.createUser),
          ),
          const SizedBox(height: 16),
        ],

        // Opción 2: Lista de Usuarios (Admin y Jefe de Área)
        HomeActionCard(
          icon: Icons.people_outline,
          title: 'Lista de Usuarios',
          subtitle: 'Mostrar Lista de los usuarios del...',
          onTap: () => context.push(RouteNames.listUsers),
        ),
      ],
    );
  }
}
