// crew_card.dart
//
// Widget de tarjeta de cuadrilla
//
// PROPÓSITO:
// - Mostrar información resumida de una cuadrilla
//
// CAPA: PRESENTATION LAYER

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/crew.dart';

/// Tarjeta de cuadrilla para listas
class CrewCard extends StatelessWidget {
  final Crew crew;
  final VoidCallback onTap;

  const CrewCard({super.key, required this.crew, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Ícono de cuadrilla
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: crew.isAvailable
                          ? AppColors.primary.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.groups,
                      color: crew.isAvailable ? AppColors.primary : Colors.grey,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Nombre y estado
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          crew.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _buildStatusChip(),
                      ],
                    ),
                  ),

                  // Flecha de navegación
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),

              const SizedBox(height: 12),

              // Descripción
              Text(
                crew.description,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Información adicional
              Row(
                children: [
                  if (crew.activeMemberCount != null) ...[
                    Icon(Icons.person, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${crew.activeMemberCount} miembro${crew.activeMemberCount != 1 ? 's' : ''}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 16),
                  ],

                  if (crew.hasActiveAssignments != null &&
                      crew.hasActiveAssignments!) ...[
                    Icon(Icons.assignment, size: 16, color: Colors.orange[700]),
                    const SizedBox(width: 4),
                    Text(
                      'Con asignaciones activas',
                      style: TextStyle(fontSize: 13, color: Colors.orange[700]),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    final isAvailable = crew.status == 'DISPONIBLE';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isAvailable
            ? Colors.green.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        crew.status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isAvailable ? Colors.green[700] : Colors.orange[700],
        ),
      ),
    );
  }
}
