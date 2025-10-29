// novelty_report_page.dart
//
// Página para crear reporte de resolución de novedad
//
// PROPÓSITO:
// - Permitir a jefes de cuadrilla crear reportes de resolución de novedades
// - Seleccionar participantes de la cuadrilla que trabajaron
// - Registrar fechas de trabajo y estado de resolución
//
// CAPA: PRESENTATION LAYER

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../config/dependency_injection/injection_container.dart';
import '../../data/services/novelty_report_service.dart';
import '../state/create_report_state.dart';
import '../providers/novelty_resolution_providers.dart';
import '../widgets/participant_selector.dart';

class NoveltyReportPage extends ConsumerStatefulWidget {
  final String noveltyId;

  const NoveltyReportPage({super.key, required this.noveltyId});

  @override
  ConsumerState<NoveltyReportPage> createState() => _NoveltyReportPageState();
}

class _NoveltyReportPageState extends ConsumerState<NoveltyReportPage> {
  final NoveltyReportService _reportService = sl<NoveltyReportService>();
  final _formKey = GlobalKey<FormState>();
  final _reportContentController = TextEditingController();
  final _observationsController = TextEditingController();

  DateTime? _workStartDate;
  DateTime? _workEndDate;
  String _resolutionStatus = 'COMPLETADA';
  bool _checkingExistingReport = true;
  bool _reportAlreadyExists = false;

  @override
  void initState() {
    super.initState();
    AppLogger.info(
      '🚀 NoveltyReportPage iniciando - NoveltyId: ${widget.noveltyId}',
    );

    // Verificar si ya existe un reporte antes de cargar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkExistingReport();
    });
  }

  /// Verificar si ya existe un reporte para esta novedad
  Future<void> _checkExistingReport() async {
    try {
      AppLogger.info(
        '🔍 Verificando si ya existe reporte para novedad ${widget.noveltyId}',
      );
      final report = await _reportService.getReportByNoveltyId(
        int.parse(widget.noveltyId),
      );

      if (mounted) {
        if (report != null) {
          AppLogger.error('⚠️ Ya existe un reporte para esta novedad');
          setState(() {
            _reportAlreadyExists = true;
            _checkingExistingReport = false;
          });

          // Mostrar mensaje y regresar
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Esta novedad ya tiene un reporte de resolución'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );

            // Esperar un momento para que el usuario vea el mensaje
            await Future.delayed(const Duration(seconds: 2));
            if (mounted) {
              Navigator.of(context).pop();
            }
          }
        } else {
          // No existe reporte, continuar normalmente
          setState(() {
            _checkingExistingReport = false;
          });

          // Cargar miembros de la cuadrilla
          AppLogger.info(
            '📞 Llamando a loadCrewMembers para noveltyId: ${widget.noveltyId}',
          );
          ref
              .read(createReportProvider.notifier)
              .loadCrewMembers(int.parse(widget.noveltyId));
        }
      }
    } catch (e) {
      // Si hay error al verificar (red, timeout, etc.), continuar de todas formas
      // El backend hará la validación final si es un duplicado
      AppLogger.debug(
        '⚠️ Error al verificar reporte existente, continuando: $e',
      );
      if (mounted) {
        setState(() {
          _checkingExistingReport = false;
        });

        // Continuar de todas formas cargando el formulario
        ref
            .read(createReportProvider.notifier)
            .loadCrewMembers(int.parse(widget.noveltyId));
      }
    }
  }

  @override
  void dispose() {
    _reportContentController.dispose();
    _observationsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createReportProvider);
    AppLogger.debug(
      '🔄 NoveltyReportPage build - Estado actual: ${state.runtimeType}',
    );

    // Escuchar cambios de estado para mostrar mensajes
    ref.listen<CreateReportState>(createReportProvider, (previous, next) {
      AppLogger.info(
        '📊 Cambio de estado: ${previous.runtimeType} -> ${next.runtimeType}',
      );

      if (next is CreateReportSuccess) {
        AppLogger.info('✅ Reporte creado exitosamente');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reporte creado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Regresar con éxito
      } else if (next is CreateReportError) {
        AppLogger.error('❌ Error al crear reporte: ${next.message}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message), backgroundColor: Colors.red),
        );
      } else if (next is CrewMembersError) {
        AppLogger.error('❌ Error al cargar miembros: ${next.message}');
      } else if (next is LoadingCrewMembers) {
        AppLogger.info('⏳ Cargando miembros de cuadrilla...');
      } else if (next is CrewMembersLoaded) {
        AppLogger.info('✅ Miembros cargados: ${next.members.length}');
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Reporte'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(CreateReportState state) {
    AppLogger.debug('🎨 Construyendo body para estado: ${state.runtimeType}');

    // Mostrar loading si está verificando si ya existe reporte
    if (_checkingExistingReport) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Verificando información de la novedad...'),
          ],
        ),
      );
    }

    // Si ya existe reporte, mostrar mensaje
    if (_reportAlreadyExists) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 64, color: Colors.orange[300]),
              const SizedBox(height: 16),
              Text(
                'Esta novedad ya tiene un reporte de resolución',
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'No se pueden crear reportes duplicados',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (state is LoadingCrewMembers) {
      AppLogger.debug('⏳ Mostrando indicador de carga');
      return const Center(child: CircularProgressIndicator());
    }

    if (state is CrewMembersError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                state.message,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  ref
                      .read(createReportProvider.notifier)
                      .loadCrewMembers(int.parse(widget.noveltyId));
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (state is CrewMembersLoaded || state is CreateReportLoading) {
      // Si está creando el reporte, mostrar overlay de carga
      final isCreatingReport = state is CreateReportLoading;

      return Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildSectionTitle('Información del Trabajo'),
                const SizedBox(height: 16),
                _buildReportContentField(),
                const SizedBox(height: 16),
                _buildObservationsField(),
                const SizedBox(height: 24),
                _buildSectionTitle('Fechas de Trabajo'),
                const SizedBox(height: 16),
                _buildDateFields(),
                const SizedBox(height: 24),
                _buildSectionTitle('Estado de Resolución'),
                const SizedBox(height: 16),
                _buildResolutionStatusField(),
                const SizedBox(height: 24),
                _buildSectionTitle('Participantes'),
                const SizedBox(height: 8),
                Text(
                  'Seleccione los miembros que participaron en la resolución',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                if (state is CrewMembersLoaded)
                  ParticipantSelector(state: state),
                const SizedBox(height: 32),
                _buildSubmitButton(state),
                const SizedBox(height: 16),
              ],
            ),
          ),
          // Overlay de carga mientras se crea el reporte
          if (isCreatingReport)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Creando reporte...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    }

    // Estado inicial
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.heading3.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildReportContentField() {
    return TextFormField(
      controller: _reportContentController,
      decoration: InputDecoration(
        labelText: 'Descripción del trabajo realizado *',
        hintText: 'Describa detalladamente las acciones realizadas...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.description),
      ),
      maxLines: 5,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Este campo es obligatorio';
        }
        if (value.trim().length < 20) {
          return 'La descripción debe tener al menos 20 caracteres';
        }
        return null;
      },
    );
  }

  Widget _buildObservationsField() {
    return TextFormField(
      controller: _observationsController,
      decoration: InputDecoration(
        labelText: 'Observaciones adicionales',
        hintText: 'Observaciones opcionales...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.note),
      ),
      maxLines: 3,
    );
  }

  Widget _buildDateFields() {
    return Column(
      children: [
        _buildDateField(
          label: 'Fecha y hora de inicio *',
          value: _workStartDate,
          onTap: () => _selectStartDate(context),
        ),
        const SizedBox(height: 16),
        _buildDateField(
          label: 'Fecha y hora de finalización *',
          value: _workEndDate,
          onTap: () => _selectEndDate(context),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: const Icon(Icons.calendar_today),
          suffixIcon: value != null
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    setState(() {
                      if (label.contains('inicio')) {
                        _workStartDate = null;
                      } else {
                        _workEndDate = null;
                      }
                    });
                  },
                )
              : null,
        ),
        child: Text(
          value != null
              ? DateFormat('dd/MM/yyyy HH:mm').format(value)
              : 'Seleccionar fecha y hora',
          style: value != null
              ? AppTextStyles.bodyMedium
              : AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
        ),
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _workStartDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && context.mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_workStartDate ?? DateTime.now()),
      );

      if (pickedTime != null) {
        setState(() {
          _workStartDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _workEndDate ?? _workStartDate ?? DateTime.now(),
      firstDate:
          _workStartDate ?? DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && context.mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_workEndDate ?? DateTime.now()),
      );

      if (pickedTime != null) {
        setState(() {
          _workEndDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Widget _buildResolutionStatusField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildRadioOption(
            value: 'COMPLETADA',
            title: 'Completada',
            subtitle: 'La novedad fue resuelta exitosamente',
            icon: Icons.check_circle,
            color: Colors.green,
          ),
          const Divider(height: 1),
          _buildRadioOption(
            value: 'NO_COMPLETADA',
            title: 'No Completada',
            subtitle: 'Requiere más trabajo o reasignación',
            icon: Icons.pending,
            color: Colors.orange,
          ),
          const Divider(height: 1),
          _buildRadioOption(
            value: 'CERRADA',
            title: 'Cerrada',
            subtitle: 'Se cierra definitivamente',
            icon: Icons.cancel,
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOption({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return RadioListTile<String>(
      value: value,
      groupValue: _resolutionStatus,
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            _resolutionStatus = newValue;
          });
        }
      },
      title: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildSubmitButton(CreateReportState state) {
    final isLoading = state is CreateReportLoading;

    return ElevatedButton(
      onPressed: isLoading ? null : _handleSubmit,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text(
              'Crear Reporte',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    );
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_workStartDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar la fecha de inicio'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_workEndDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar la fecha de finalización'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_workEndDate!.isBefore(_workStartDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La fecha de fin debe ser posterior a la de inicio'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final state = ref.read(createReportProvider);
    if (state is CrewMembersLoaded && state.selectedParticipants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar al menos un participante'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Crear el reporte
    ref
        .read(createReportProvider.notifier)
        .createReport(
          noveltyId: int.parse(widget.noveltyId),
          reportContent: _reportContentController.text.trim(),
          observations: _observationsController.text.trim().isNotEmpty
              ? _observationsController.text.trim()
              : null,
          workStartDate: _workStartDate!,
          workEndDate: _workEndDate!,
          resolutionStatus: _resolutionStatus,
        );
  }
}
