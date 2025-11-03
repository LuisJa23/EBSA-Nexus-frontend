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
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../config/dependency_injection/injection_container.dart';
import '../../../authentication/domain/entities/user.dart';
import '../../data/models/novelty_model.dart';
import '../../data/services/novelty_report_service.dart';
import '../pages/view_novelty_report_page.dart';

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
  final NoveltyReportService _reportService = sl<NoveltyReportService>();
  bool _hasReport = false;
  bool _checkingReport = false;

  @override
  void initState() {
    super.initState();
    // Solo verificar si la novedad está COMPLETADA o EN_CURSO
    if (widget.novelty.status == 'COMPLETADA' ||
        widget.novelty.status == 'EN_CURSO') {
      _checkIfReportExists();
    }
  }

  /// Verificar si ya existe un reporte para esta novedad
  Future<void> _checkIfReportExists() async {
    if (_checkingReport) return;

    setState(() {
      _checkingReport = true;
    });

    try {
      final report = await _reportService.getReportByNoveltyId(
        widget.novelty.id,
      );
      if (mounted) {
        setState(() {
          _hasReport = report != null;
          _checkingReport = false;
        });
      }
    } catch (e) {
      // Si hay error al verificar (404, red, etc.), asumir que no hay reporte
      // y permitir la creación. El backend validará finalmente.
      AppLogger.debug('⚠️ Error verificando reporte existente en card: $e');
      if (mounted) {
        setState(() {
          _hasReport = false;
          _checkingReport = false;
        });
      }
    }
  }

  /// Navegar al formulario de reporte para completar la novedad
  /// El backend cambia el estado a COMPLETADA automáticamente al crear el reporte
  void _completeNovelty() {
    // Navegar a la página de creación de reporte
    context.push('/novelty-report/${widget.novelty.id}');
  }

  /// Navegar a la vista del reporte
  void _viewReport() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewNoveltyReportPage(novelty: widget.novelty),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                widget.novelty.municipality ?? 'No especificado',
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

              // Botón para novedades EN_CURSO: Completar (crear reporte)
              // Solo si es fieldWorker, está EN_CURSO y NO tiene reporte ya
              if (widget.userRole == UserRole.fieldWorker &&
                  widget.novelty.status == 'EN_CURSO' &&
                  !_hasReport &&
                  !_checkingReport) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),

                // Botón principal: Completar (online)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _completeNovelty,
                    icon: const Icon(Icons.check_circle, size: 18),
                    label: const Text('Completar Reporte'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Botón secundario: Crear reporte offline
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Navegar a la página de crear reporte offline
                      context.push(
                        '/reports/offline/create/${widget.novelty.id}',
                      );
                    },
                    icon: const Icon(Icons.cloud_off, size: 18),
                    label: const Text('Crear Offline'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],

              // Botón para novedades COMPLETADAS o EN_CURSO con reporte: Ver Reporte
              if (widget.userRole == UserRole.fieldWorker &&
                  (_hasReport || widget.novelty.status == 'COMPLETADA') &&
                  !_checkingReport) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _viewReport,
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('Ver Reporte'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.info,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],

              // Indicador de carga mientras verifica si existe reporte
              if (_checkingReport) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                const Center(
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                const SizedBox(height: 8),
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
