// crew_info_card.dart
//
// Widget de información de cuadrilla
//
// PROPÓSITO:
// - Mostrar información detallada de una cuadrilla
//
// CAPA: PRESENTATION LAYER

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/crew_detail.dart';

/// Tarjeta de información de cuadrilla
class CrewInfoCard extends StatelessWidget {
  final CrewDetail crewDetail;

  const CrewInfoCard({super.key, required this.crewDetail});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con nombre e ícono
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: crewDetail.isAvailable
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.groups,
                    color: crewDetail.isAvailable
                        ? AppColors.primary
                        : Colors.grey,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        crewDetail.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildStatusChip(),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Descripción
            _buildInfoRow(
              icon: Icons.description,
              label: 'Descripción',
              value: crewDetail.description,
            ),

            const SizedBox(height: 16),

            // Número de miembros activos
            _buildInfoRow(
              icon: Icons.people,
              label: 'Miembros activos',
              value:
                  '${crewDetail.activeMemberCount} miembro${crewDetail.activeMemberCount != 1 ? 's' : ''}',
            ),

            const SizedBox(height: 16),

            // Asignaciones activas
            _buildInfoRow(
              icon: Icons.assignment,
              label: 'Asignaciones',
              value: crewDetail.hasActiveAssignments
                  ? 'Tiene asignaciones activas'
                  : 'Sin asignaciones activas',
              valueColor: crewDetail.hasActiveAssignments
                  ? Colors.orange[700]
                  : Colors.grey[600],
            ),

            const SizedBox(height: 16),

            // Fecha de creación
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: 'Fecha de creación',
              value: DateFormat(
                'dd/MM/yyyy HH:mm',
              ).format(crewDetail.createdAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    final isAvailable = crewDetail.status == 'DISPONIBLE';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isAvailable
            ? Colors.green.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        crewDetail.status,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isAvailable ? Colors.green[700] : Colors.orange[700],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  color: valueColor ?? Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
