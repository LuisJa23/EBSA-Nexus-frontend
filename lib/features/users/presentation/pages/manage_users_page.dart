// manage_users_page.dart
//
// Página para gestionar usuarios (Solo Admin)
//
// PROPÓSITO:
// - CRUD de usuarios del sistema
// - Asignación de roles y permisos
// - Gestión de usuarios activos/inactivos
// - Solo accesible para usuarios con rol ADMIN
//
// CAPA: PRESENTATION LAYER

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Página para gestión de usuarios del sistema
///
/// Permite a los administradores crear, editar, eliminar
/// y gestionar usuarios del sistema Nexus EBSA.
///
/// **Restricción**: Solo accesible para usuarios con rol ADMIN
class ManageUsersPage extends StatelessWidget {
  const ManageUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Gestionar Usuarios',
          style: AppTextStyles.heading3.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.construction,
                size: 80,
                color: AppColors.textSecondary.withOpacity(0.5),
              ),
              const SizedBox(height: 24),
              Text(
                'Página en Construcción',
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'La funcionalidad de gestión de usuarios estará disponible próximamente.',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '🔒 Solo accesible para Administradores',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.info,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Volver al Inicio'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
