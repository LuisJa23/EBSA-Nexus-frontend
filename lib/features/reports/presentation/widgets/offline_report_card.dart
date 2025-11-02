// offline_report_card.dart
//
// Widget para mostrar un reporte offline en lista
//
// PROPÓSITO:
// - Mostrar información resumida del reporte
// - Indicador visual de estado de sincronización
// - Acción de tap para ver detalle
//
// CAPA: PRESENTATION LAYER

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/report_model.dart';
import 'sync_status_indicator.dart';

/// Card para mostrar un reporte offline
///
/// Muestra:
/// - Descripción del trabajo
/// - Fecha de creación
/// - Estado de sincronización
/// - Número de evidencias
class OfflineReportCard extends StatelessWidget {
  final ReportModel report;
  final VoidCallback? onTap;

  const OfflineReportCard({super.key, required this.report, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Estado y fecha
              Row(
                children: [
                  SyncStatusIndicator(isSynced: report.isSynced),
                  const Spacer(),
                  Text(
                    _formatDate(report.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Descripción del trabajo
              Text(
                report.workDescription,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              if (report.observations != null) ...[
                const SizedBox(height: 8),
                Text(
                  report.observations!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 12),

              // Footer: Info adicional
              Row(
                children: [
                  // Tiempo de trabajo
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${report.workTime} min',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),

                  const SizedBox(width: 16),

                  // Número de participantes
                  Icon(Icons.people, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    '${report.participantIds.length}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),

                  const SizedBox(width: 16),

                  // Número de evidencias
                  Icon(
                    Icons.photo_library,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${report.evidences.length}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),

                  const Spacer(),

                  // Ícono de flecha
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Formatea la fecha de creación
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Hace un momento';
        }
        return 'Hace ${difference.inMinutes} min';
      }
      return 'Hace ${difference.inHours} h';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }
}
