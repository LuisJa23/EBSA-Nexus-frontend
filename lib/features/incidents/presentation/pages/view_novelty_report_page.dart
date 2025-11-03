// view_novelty_report_page.dart
//
// Página para visualizar reporte de resolución de novedad
//
// PROPÓSITO:
// - Mostrar información completa del reporte de resolución
// - Mostrar datos de la novedad relacionada
// - Mostrar cuadrilla y participantes que realizaron el trabajo
//
// CAPA: PRESENTATION LAYER

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_logger.dart';
import '../../data/models/novelty_model.dart';
import '../../data/models/novelty_report_model.dart';
import '../../data/services/novelty_report_service.dart';
import '../../../../config/dependency_injection/injection_container.dart';

class ViewNoveltyReportPage extends ConsumerStatefulWidget {
  final NoveltyModel novelty;

  const ViewNoveltyReportPage({super.key, required this.novelty});

  @override
  ConsumerState<ViewNoveltyReportPage> createState() =>
      _ViewNoveltyReportPageState();
}

class _ViewNoveltyReportPageState extends ConsumerState<ViewNoveltyReportPage> {
  final NoveltyReportService _reportService = sl<NoveltyReportService>();
  NoveltyReportModel? _report;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    try {
      AppLogger.info('📄 Cargando reporte de novedad ${widget.novelty.id}');
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final report = await _reportService.getReportByNoveltyId(
        widget.novelty.id,
      );

      if (report == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No se encontró el reporte de esta novedad.';
        });
        return;
      }

      AppLogger.info('✅ Reporte cargado: ID ${report.id}');
      setState(() {
        _report = report;
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.error('❌ Error al cargar reporte', error: e);
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error al cargar el reporte: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte de Resolución'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildError()
          : _buildContent(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: AppTextStyles.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadReport,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_report == null) {
      return const Center(child: Text('No hay reporte disponible'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNoveltyInfoCard(),
          const SizedBox(height: 16),
          if (widget.novelty.assignment != null &&
              widget.novelty.assignment!.crewName != null)
            _buildCrewInfoCard(),
          if (widget.novelty.assignment != null &&
              widget.novelty.assignment!.crewName != null)
            const SizedBox(height: 16),
          _buildReportInfoCard(),
          const SizedBox(height: 16),
          _buildParticipantsCard(),
          const SizedBox(height: 16),
          _buildWorkDatesCard(),
          const SizedBox(height: 16),
          _buildResolutionStatusCard(),
        ],
      ),
    );
  }

  Widget _buildCrewInfoCard() {
    final assignment = widget.novelty.assignment!;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.groups, color: AppColors.primary, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Cuadrilla Asignada',
                  style: AppTextStyles.heading3.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow('Cuadrilla', assignment.crewName ?? 'N/A'),
            if (assignment.priority != null)
              _buildInfoRow(
                'Prioridad',
                _getPriorityText(assignment.priority!),
              ),
            if (assignment.instructions != null &&
                assignment.instructions!.isNotEmpty)
              _buildInfoRow('Instrucciones', assignment.instructions!),
            if (assignment.assignedAt != null)
              _buildInfoRow(
                'Fecha de Asignación',
                DateFormat(
                  'dd/MM/yyyy HH:mm',
                ).format(assignment.assignedAt!.toLocal()),
              ),
          ],
        ),
      ),
    );
  }

  String _getPriorityText(String priority) {
    switch (priority.toUpperCase()) {
      case 'ALTA':
        return '🔴 Alta';
      case 'MEDIA':
        return '🟡 Media';
      case 'BAJA':
        return '🟢 Baja';
      default:
        return priority;
    }
  }

  Widget _buildNoveltyInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.description, color: AppColors.primary, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Información de la Novedad',
                  style: AppTextStyles.heading3.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow('ID Novedad', '#${widget.novelty.id}'),
            _buildInfoRow('Motivo', _getReasonText(widget.novelty.reason)),
            _buildInfoRow('Cuenta', widget.novelty.accountNumber),
            _buildInfoRow('Medidor', widget.novelty.meterNumber),
            _buildInfoRow('Dirección', widget.novelty.address),
            _buildInfoRow('Municipio', widget.novelty.municipality ?? 'No especificado'),
            _buildInfoRow('Descripción', widget.novelty.description),
            const SizedBox(height: 8),
            _buildStatusChip(widget.novelty.status),
          ],
        ),
      ),
    );
  }

  Widget _buildReportInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.assignment_turned_in,
                  color: AppColors.success,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Trabajo Realizado',
                  style: AppTextStyles.heading3.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow('Reporte ID', '#${_report!.id}'),
            _buildInfoRow('Generado por', _report!.generatedBy.fullName),
            _buildInfoRow('Email', _report!.generatedBy.email),
            const SizedBox(height: 12),
            Text(
              'Descripción del Trabajo:',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                _report!.reportContent,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (_report!.observations != null &&
                _report!.observations!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Observaciones:',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Text(
                  _report!.observations!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.people, color: AppColors.info, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Participantes',
                  style: AppTextStyles.heading3.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              '${_report!.participants.length} persona(s) participaron en la resolución:',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            ...(_report!.participants.map((participant) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Text(
                          participant.fullName[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              participant.fullName,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Usuario ID: ${participant.userId}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.check_circle, color: AppColors.success),
                    ],
                  ),
                ),
              );
            }).toList()),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkDatesCard() {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final duration = _report!.workEndDate.difference(_report!.workStartDate);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, color: AppColors.warning, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Fechas del Trabajo',
                  style: AppTextStyles.heading3.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(
              'Inicio',
              dateFormat.format(_report!.workStartDate.toLocal()),
            ),
            _buildInfoRow(
              'Finalización',
              dateFormat.format(_report!.workEndDate.toLocal()),
            ),
            _buildInfoRow(
              'Duración',
              '$hours horas ${minutes > 0 ? "$minutes minutos" : ""}',
            ),
            _buildInfoRow(
              'Reporte creado',
              dateFormat.format(_report!.createdAt.toLocal()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResolutionStatusCard() {
    final isCompleted = _report!.resolutionStatus == 'COMPLETADA';
    final color = isCompleted ? AppColors.success : AppColors.warning;
    final icon = isCompleted ? Icons.check_circle : Icons.warning;
    final statusText = _report!.resolutionStatusLocalized;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Estado de Resolución',
                  style: AppTextStyles.heading3.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText.toUpperCase(),
                  style: AppTextStyles.heading3.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
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
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;

    switch (status.toUpperCase()) {
      case 'COMPLETADA':
        color = AppColors.success;
        text = 'Completada';
        break;
      case 'EN_CURSO':
        color = AppColors.info;
        text = 'En Curso';
        break;
      case 'PENDIENTE':
      case 'CREADA':
        color = AppColors.warning;
        text = 'Pendiente';
        break;
      case 'CANCELADA':
        color = AppColors.error;
        text = 'Cancelada';
        break;
      default:
        color = Colors.grey;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  String _getReasonText(String reason) {
    switch (reason) {
      case 'MEDIDOR_DANADO':
        return 'Medidor Dañado';
      case 'MEDIDOR_FALTANTE':
        return 'Medidor Faltante';
      case 'LECTURA_ANORMAL':
        return 'Lectura Anormal';
      case 'ACTUALIZACION_DATOS':
        return 'Actualización de Datos';
      case 'FRAUDE':
        return 'Fraude';
      case 'OTRO':
        return 'Otro';
      default:
        return reason;
    }
  }
}
