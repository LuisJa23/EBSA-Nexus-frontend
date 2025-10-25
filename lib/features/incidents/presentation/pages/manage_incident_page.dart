// manage_incident_page.dart
//
// Página para gestionar incidentes/novedades
//
// PROPÓSITO:
// - Menú de opciones para gestión de incidentes
// - Acceso a creación y listado de incidentes
// - Gestión completa de novedades del sistema
//
// CAPA: PRESENTATION LAYER

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/home_action_card.dart';

/// Página para gestión de incidentes/novedades del sistema
///
/// Muestra opciones para crear y listar incidentes.
/// Reutiliza el diseño de HomeActionCard para mantener
/// consistencia visual con el resto de la aplicación.
class ManageIncidentPage extends StatelessWidget {
  const ManageIncidentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildOptionsCards(context),
        ],
      ),
    );
  }

  /// Construye el header de la página
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gestionar Incidentes',
          style: AppTextStyles.heading1.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
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
  Widget _buildOptionsCards(BuildContext context) {
    return Column(
      children: [
        // Opción 1: Crear Incidente
        HomeActionCard(
          icon: Icons.add_alert,
          title: 'Crear Incidente',
          subtitle: 'Registrar Nueva Novedad',
          onTap: () => context.push(RouteNames.createIncident),
        ),
        const SizedBox(height: 16),

        // Opción 2: Lista de Incidentes
        HomeActionCard(
          icon: Icons.list_alt,
          title: 'Lista de Incidentes',
          subtitle: 'Ver Historial de Novedades',
          onTap: () => context.push(RouteNames.incidentList),
        ),
        const SizedBox(height: 16),

        // Opción 3: Novedades Offline
        HomeActionCard(
          icon: Icons.cloud_off,
          title: 'Novedades Offline',
          subtitle: 'Gestionar Novedades sin Conexión',
          onTap: () => context.push(RouteNames.offlineIncidents),
        ),
      ],
    );
  }
}
