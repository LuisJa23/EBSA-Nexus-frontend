// novelty_card.dart
//
// Widget de tarjeta de novedad
//
// PROPÓSITO:
// - Mostrar información resumida de una novedad
//
// CAPA: PRESENTATION LAYER

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/novelty_model.dart';

class NoveltyCard extends StatelessWidget {
  final NoveltyModel novelty;
  final VoidCallback onTap;

  const NoveltyCard({super.key, required this.novelty, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado con estado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Cuenta: ${novelty.accountNumber}',
                      style: AppTextStyles.heading3.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusChip(),
                ],
              ),
              const SizedBox(height: 12),

              // Información principal
              _buildInfoRow(
                Icons.business,
                'Área ID',
                novelty.areaId.toString(),
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.assignment,
                'Motivo',
                novelty.reasonLocalized,
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.location_city,
                'Municipio',
                novelty.municipality,
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.electric_meter,
                'Medidor',
                novelty.meterNumber,
              ),

              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),

              // Footer con fecha e imágenes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('dd/MM/yyyy').format(novelty.createdAt),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  if ((novelty.imageCount ?? 0) > 0)
                    Row(
                      children: [
                        Icon(Icons.image, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${novelty.imageCount} imagen${(novelty.imageCount ?? 0) > 1 ? 'es' : ''}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    Color backgroundColor;
    Color textColor;

    switch (novelty.status) {
      case 'PENDIENTE':
        backgroundColor = Colors.orange.withValues(alpha: 0.1);
        textColor = Colors.orange;
        break;
      case 'EN_CURSO':
        backgroundColor = Colors.blue.withValues(alpha: 0.1);
        textColor = Colors.blue;
        break;
      case 'COMPLETADA':
        backgroundColor = Colors.green.withValues(alpha: 0.1);
        textColor = Colors.green;
        break;
      case 'CERRADA':
        backgroundColor = Colors.grey.withValues(alpha: 0.1);
        textColor = Colors.grey;
        break;
      case 'CANCELADA':
        backgroundColor = Colors.red.withValues(alpha: 0.1);
        textColor = Colors.red;
        break;
      default:
        backgroundColor = Colors.grey.withValues(alpha: 0.1);
        textColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        novelty.statusLocalized,
        style: AppTextStyles.bodySmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
