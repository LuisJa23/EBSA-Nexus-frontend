// list_users_page.dart
//
// Página para listar usuarios del sistema
//
// PROPÓSITO:
// - Mostrar lista de todos los usuarios registrados
// - Búsqueda y filtrado de usuarios
// - Acceso a detalles y edición de usuarios
// - Solo accesible para usuarios con rol ADMIN
//
// CAPA: PRESENTATION LAYER

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Página para visualizar lista de usuarios del sistema
///
/// Muestra todos los usuarios registrados con opciones
/// de búsqueda, filtrado y acciones de gestión.
///
/// **Restricción**: Solo accesible para usuarios con rol ADMIN
class ListUsersPage extends StatelessWidget {
  const ListUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Lista de Usuarios',
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'La lista de usuarios del sistema estará disponible próximamente.',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Volver'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
