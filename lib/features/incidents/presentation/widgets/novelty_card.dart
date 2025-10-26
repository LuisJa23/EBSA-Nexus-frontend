// novelty_card.dart
//
// Widget de tarjeta de novedad
//
// PROPÓSITO:
// - Mostrar información resumida de una novedad
//
// CAPA: PRESENTATION LAYER

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../config/dependency_injection/injection_container.dart' as di;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../authentication/domain/entities/user.dart';
import '../../data/models/novelty_model.dart';
import '../../data/novelty_service.dart';

class NoveltyCard extends StatefulWidget {
  final NoveltyModel novelty;
  final VoidCallback onTap;
  final UserRole? userRole;
  final VoidCallback? onStatusChanged;

  const NoveltyCard({
    super.key,
    required this.novelty,
    required this.onTap,
    this.userRole,
    this.onStatusChanged,
  });

  @override
  State<NoveltyCard> createState() => _NoveltyCardState();
}

class _NoveltyCardState extends State<NoveltyCard> {
  bool _isUpdating = false;

  Future<void> _updateStatus(String newStatus) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Completar Novedad'),
        content: const Text(
          '¿Estás seguro de que deseas marcar esta novedad como completada?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('Sí'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isUpdating = true);

    try {
      final noveltyService = di.sl<NoveltyService>();
      await noveltyService.updateNoveltyStatus(
        noveltyId: widget.novelty.id.toString(),
        status: newStatus,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Novedad completada exitosamente'),
            backgroundColor: AppColors.success,
          ),
        );
        widget.onStatusChanged?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar estado: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canUpdateStatus =
        widget.userRole == UserRole.fieldWorker &&
        widget.novelty.status == 'EN_CURSO';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: widget.onTap,
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
                      'Cuenta: ${widget.novelty.accountNumber}',
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
              _buildInfoRow(Icons.business, 'Área', widget.novelty.areaName),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.assignment,
                'Motivo',
                widget.novelty.reasonLocalized,
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.location_city,
                'Municipio',
                widget.novelty.municipality,
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.electric_meter,
                'Medidor',
                widget.novelty.meterNumber,
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
                        DateFormat(
                          'dd/MM/yyyy',
                        ).format(widget.novelty.createdAt),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  if ((widget.novelty.imageCount ?? 0) > 0)
                    Row(
                      children: [
                        Icon(Icons.image, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.novelty.imageCount} imagen${(widget.novelty.imageCount ?? 0) > 1 ? 'es' : ''}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              // Botones de acción para jefe de cuadrilla
              if (canUpdateStatus) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isUpdating
                        ? null
                        : () => _updateStatus('COMPLETADA'),
                    icon: const Icon(Icons.check_circle, size: 18),
                    label: const Text('Completar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],

              // Botón de hacer reporte para novedades completadas
              if (widget.userRole == UserRole.fieldWorker &&
                  widget.novelty.status == 'COMPLETADA') ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Navegar a la página de reporte
                      context.push('/novelty-report/${widget.novelty.id}');
                    },
                    icon: const Icon(Icons.description, size: 18),
                    label: const Text('Hacer Reporte'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    Color backgroundColor;
    Color textColor;

    switch (widget.novelty.status) {
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
        widget.novelty.statusLocalized,
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
