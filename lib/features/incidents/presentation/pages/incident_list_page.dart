// incident_list_page.dart
//
// Página para consultar novedades asignadas
//
// PROPÓSITO:
// - Listar novedades/incidentes asignados al usuario
// - Filtrar y buscar novedades
// - Ver detalles de cada novedad
//
// CAPA: PRESENTATION LAYER

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Página para consultar novedades/incidentes asignados
///
/// Muestra un listado de todas las novedades asignadas
/// al usuario actual, con opciones de filtrado y búsqueda.
class IncidentListPage extends StatelessWidget {
  const IncidentListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Consultas',
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
                'La funcionalidad de consulta de novedades estará disponible próximamente.',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
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
