// novelty_report_page.dart
//
// Página para crear reporte de novedad
//
// PROPÓSITO:
// - Permitir a jefes de cuadrilla crear reportes de novedades completadas
//
// CAPA: PRESENTATION LAYER

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/utils/app_logger.dart';
import '../providers/novelty_resolution_providers.dart';
import '../state/create_report_state.dart';

class NoveltyReportPage extends ConsumerStatefulWidget {
  final String noveltyId;

  const NoveltyReportPage({super.key, required this.noveltyId});

  @override
  ConsumerState<NoveltyReportPage> createState() => _NoveltyReportPageState();
}

class _NoveltyReportPageState extends ConsumerState<NoveltyReportPage> {
  final _formKey = GlobalKey<FormState>();
  final _reportContentController = TextEditingController();
  final _observationsController = TextEditingController();

  DateTime? _workStartDate;
  DateTime? _workEndDate;
  String _resolutionStatus = 'COMPLETADA';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCrewMembers();
    });
  }

  @override
  void dispose() {
    _reportContentController.dispose();
    _observationsController.dispose();
    super.dispose();
  }

  void _loadCrewMembers() {
    final noveltyId = int.tryParse(widget.noveltyId);
    if (noveltyId != null) {
      ref.read(createReportProvider.notifier).loadCrewMembers(noveltyId);
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate ? _workStartDate : _workEndDate;
    final firstDate = isStartDate
        ? DateTime.now().subtract(const Duration(days: 365))
        : _workStartDate ?? DateTime.now().subtract(const Duration(days: 365));
    final lastDate = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate ?? DateTime.now()),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: AppColors.primary,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: AppColors.textPrimary,
              ),
            ),
            child: child!,
          );
        },
      );

      if (time != null && mounted) {
        final dateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          time.hour,
          time.minute,
        );

        setState(() {
          if (isStartDate) {
            _workStartDate = dateTime;
            // Si la fecha de fin es anterior a la de inicio, resetearla
            if (_workEndDate != null && _workEndDate!.isBefore(dateTime)) {
              _workEndDate = null;
            }
          } else {
            _workEndDate = dateTime;
          }
        });
      }
    }
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_workStartDate == null || _workEndDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Debes seleccionar las fechas de inicio y fin del trabajo',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final noveltyId = int.tryParse(widget.noveltyId);
    if (noveltyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID de novedad inválido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ref
        .read(createReportProvider.notifier)
        .createReport(
          noveltyId: noveltyId,
          reportContent: _reportContentController.text.trim(),
          observations: _observationsController.text.trim().isEmpty
              ? null
              : _observationsController.text.trim(),
          workStartDate: _workStartDate!,
          workEndDate: _workEndDate!,
          resolutionStatus: _resolutionStatus,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createReportProvider);

    // Escuchar cambios de estado para mostrar mensajes y navegación
    ref.listen<CreateReportState>(createReportProvider, (previous, next) {
      if (next is CreateReportSuccess) {
        AppLogger.info('✅ Reporte creado exitosamente');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reporte creado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        // Navegar de vuelta
        context.pop();
      } else if (next is CreateReportError) {
        AppLogger.error('❌ Error al crear reporte: ${next.message}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      } else if (next is CrewMembersError) {
        AppLogger.error('❌ Error al cargar miembros: ${next.message}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Reporte de Novedad'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(CreateReportState state) {
    if (state is LoadingCrewMembers) {
      return const Center(
        child: LoadingIndicator(message: 'Cargando información...'),
      );
    }

    if (state is CrewMembersError) {
      return _buildErrorView(state.message);
    }

    if (state is CrewMembersLoaded || state is CreateReportLoading) {
      return _buildForm(state);
    }

    // Estado inicial - mostrar loading
    return const Center(
      child: LoadingIndicator(message: 'Cargando información...'),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: AppColors.error),
            const SizedBox(height: 24),
            Text(
              'Error',
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Reintentar',
              onPressed: _loadCrewMembers,
              icon: Icons.refresh,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(CreateReportState state) {
    final isLoading = state is CreateReportLoading;
    final crewMembers = state is CrewMembersLoaded ? state.members : [];
    final selectedParticipants = state is CrewMembersLoaded
        ? state.selectedParticipants
        : <int>{};

    return Stack(
      children: [
        Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Información de la novedad
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Novedad #${widget.noveltyId}',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Contenido del reporte
              Text(
                'Contenido del Reporte *',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _reportContentController,
                maxLines: 5,
                enabled: !isLoading,
                decoration: InputDecoration(
                  hintText:
                      'Describe el trabajo realizado y los resultados obtenidos...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El contenido del reporte es obligatorio';
                  }
                  if (value.trim().length < 20) {
                    return 'El reporte debe tener al menos 20 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Observaciones
              Text(
                'Observaciones (Opcional)',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _observationsController,
                maxLines: 3,
                enabled: !isLoading,
                decoration: InputDecoration(
                  hintText: 'Observaciones adicionales...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              const SizedBox(height: 24),

              // Fechas de trabajo
              Text(
                'Fechas de Trabajo *',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildDateButton(
                      context,
                      'Inicio',
                      _workStartDate,
                      () => _selectDate(context, true),
                      isLoading,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDateButton(
                      context,
                      'Fin',
                      _workEndDate,
                      () => _selectDate(context, false),
                      isLoading,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Estado de resolución
              Text(
                'Estado de Resolución *',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _resolutionStatus,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'COMPLETADA',
                    child: Text('Completada'),
                  ),
                  DropdownMenuItem(
                    value: 'NO_COMPLETADA',
                    child: Text('No Completada'),
                  ),
                ],
                onChanged: isLoading
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() {
                            _resolutionStatus = value;
                          });
                        }
                      },
              ),
              const SizedBox(height: 24),

              // Participantes
              Text(
                'Participantes *',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              if (crewMembers.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'No hay miembros disponibles en la cuadrilla',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                Card(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${selectedParticipants.length} de ${crewMembers.length} seleccionados',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Row(
                              children: [
                                TextButton(
                                  onPressed: isLoading
                                      ? null
                                      : () => ref
                                            .read(createReportProvider.notifier)
                                            .selectAll(),
                                  child: const Text('Todos'),
                                ),
                                TextButton(
                                  onPressed: isLoading
                                      ? null
                                      : () => ref
                                            .read(createReportProvider.notifier)
                                            .deselectAll(),
                                  child: const Text('Ninguno'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      ...crewMembers.map((member) {
                        final isSelected = selectedParticipants.contains(
                          member.userId,
                        );
                        return CheckboxListTile(
                          title: Text(member.fullName),
                          subtitle: Text(
                            member.isLeader ? 'Líder' : 'Miembro',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: member.isLeader
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                          ),
                          value: isSelected,
                          activeColor: AppColors.primary,
                          onChanged: isLoading
                              ? null
                              : (value) {
                                  ref
                                      .read(createReportProvider.notifier)
                                      .toggleParticipant(member.userId);
                                },
                        );
                      }),
                    ],
                  ),
                ),
              const SizedBox(height: 32),

              // Botón de enviar
              CustomButton(
                text: 'Crear Reporte',
                onPressed: isLoading ? null : _handleSubmit,
                icon: Icons.send,
                isLoading: isLoading,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        if (isLoading)
          Container(
            color: Colors.black26,
            child: const Center(
              child: LoadingIndicator(message: 'Creando reporte...'),
            ),
          ),
      ],
    );
  }

  Widget _buildDateButton(
    BuildContext context,
    String label,
    DateTime? date,
    VoidCallback onPressed,
    bool isDisabled,
  ) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    return OutlinedButton.icon(
      onPressed: isDisabled ? null : onPressed,
      icon: const Icon(Icons.calendar_today),
      label: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            date != null ? dateFormat.format(date) : 'Seleccionar',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        alignment: Alignment.centerLeft,
      ),
    );
  }
}
