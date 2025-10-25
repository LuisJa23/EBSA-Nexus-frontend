// create_incident_page.dart
//
// Página para crear reportes de incidentes
//
// PROPÓSITO:
// - Formulario para crear nuevos reportes de incidentes
// - Captura de evidencias (fotos, ubicación)
// - Selección de tipo de incidente
// - Guardado y envío de reportes
//
// CAPA: PRESENTATION LAYER

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

import '../../../../config/dependency_injection/injection_container.dart' as di;
import '../../../incidents/data/novelty_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/widgets/evidence_capture_widget.dart';

/// Página para crear reportes de incidentes
///
/// Permite a los usuarios crear nuevos reportes
/// de incidentes o novedades en el sistema.
class CreateIncidentPage extends StatefulWidget {
  const CreateIncidentPage({super.key});

  @override
  State<CreateIncidentPage> createState() => _CreateIncidentPageState();
}

class _CreateIncidentPageState extends State<CreateIncidentPage> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto
  final _accountNumberController = TextEditingController();
  final _meterNumberController = TextEditingController();
  final _activeReadingController = TextEditingController();
  final _reactiveReadingController = TextEditingController();
  final _descriptionController = TextEditingController(); // Nueva descripción
  final _observationsController = TextEditingController();

  // Variables de selección
  String? _selectedArea;
  String? _selectedMotivo;
  String? _selectedMunicipio;

  // Lista de evidencias (legacy - mantener por compatibilidad)
  List<String> _evidences = [];

  // Lista de evidencias con metadatos (incluye GPS)
  List<EvidenceItem> _evidenceItems = [];

  // Contador de evidencias GPS (obligatorio)
  int _gpsCount = 0;

  // Mapeo de áreas a sus IDs numéricos
  final Map<String, int> _areaIds = {
    'FACTURACIÓN': 1,
    'CARTERA': 2,
    'PÉRDIDAS': 3,
  };

  // Definición de áreas y sus motivos
  final Map<String, List<String>> _areaMotivos = {
    'FACTURACIÓN': ['ERROR_LECTURA', 'ACTUALIZACION_DATOS', 'OTROS'],
    'CARTERA': ['ERROR_LECTURA', 'ACTUALIZACION_DATOS', 'OTROS'],
    'PÉRDIDAS': ['ERROR_LECTURA', 'ACTUALIZACION_DATOS', 'OTROS'],
  };

  // Lista de áreas disponibles
  List<String> get _areas => _areaMotivos.keys.toList();

  // Lista de motivos según el área seleccionada
  List<String> get _motivos =>
      _selectedArea != null ? _areaMotivos[_selectedArea]! : [];

  final List<String> _municipios = [
    'Bogotá',
    'Medellín',
    'Cali',
    'Barranquilla',
    'Cartagena',
    'Cúcuta',
    'Bucaramanga',
    'Pereira',
    'Santa Marta',
    'Ibagué',
  ];

  @override
  void dispose() {
    _accountNumberController.dispose();
    _meterNumberController.dispose();
    _activeReadingController.dispose();
    _reactiveReadingController.dispose();
    _descriptionController.dispose();
    _observationsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Incidente'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildGeneralInfoSection(),
              const SizedBox(height: 24),
              _buildMeterInfoSection(),
              const SizedBox(height: 24),
              _buildReadingsSection(),
              const SizedBox(height: 24),
              _buildLocationSection(),
              const SizedBox(height: 24),
              _buildEvidenceSection(),
              const SizedBox(height: 24),
              _buildObservationsSection(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.report_problem,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nuevo Reporte de Incidente',
                  style: AppTextStyles.heading1.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Complete la información del reporte de incidente',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralInfoSection() {
    return FormSection(
      title: 'Información General',
      children: [
        CustomDropdown<String>(
          value: _selectedArea,
          label: 'Área de novedad',
          icon: Icons.business,
          items: _areas
              .map((area) => DropdownMenuItem(value: area, child: Text(area)))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedArea = value;
              // Resetear el motivo cuando cambia el área
              _selectedMotivo = null;
            });
          },
          validator: (value) => value == null ? 'Seleccione un área' : null,
        ),
        CustomDropdown<String>(
          value: _selectedMotivo,
          label: 'Motivo',
          icon: Icons.assignment,
          items: _motivos
              .map(
                (motivo) =>
                    DropdownMenuItem(value: motivo, child: Text(motivo)),
              )
              .toList(),
          onChanged: (value) => setState(() => _selectedMotivo = value),
          validator: (value) => value == null ? 'Seleccione un motivo' : null,
        ),
      ],
    );
  }

  Widget _buildMeterInfoSection() {
    return FormSection(
      title: 'Información del Servicio',
      children: [
        CustomTextField(
          controller: _accountNumberController,
          label: 'Número de la cuenta',
          hint: 'Ingrese el número de cuenta',
          icon: Icons.receipt_long,
          fieldName: 'accountNumber',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (value?.trim().isEmpty ?? true) return 'Campo requerido';
            if (value!.length < 6) return 'Mínimo 6 dígitos';
            return null;
          },
        ),
        CustomTextField(
          controller: _meterNumberController,
          label: 'Número del medidor',
          hint: 'Ingrese el número del medidor',
          icon: Icons.speed,
          fieldName: 'meterNumber',
          validator: (value) {
            if (value?.trim().isEmpty ?? true) return 'Campo requerido';
            if (value!.length < 4) return 'Mínimo 4 caracteres';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildReadingsSection() {
    return FormSection(
      title: 'Lecturas del Medidor',
      children: [
        CustomTextField(
          controller: _activeReadingController,
          label: 'Lectura Activa',
          hint: 'Valor Numérico',
          icon: Icons.electric_meter,
          fieldName: 'activeReading',
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          validator: (value) {
            if (value?.trim().isEmpty ?? true) return 'Campo requerido';
            final numValue = double.tryParse(value!);
            if (numValue == null || numValue < 0) {
              return 'Ingrese un valor válido';
            }
            return null;
          },
        ),
        CustomTextField(
          controller: _reactiveReadingController,
          label: 'Lectura Reactiva',
          hint: 'Valor Numérico',
          icon: Icons.electric_meter_outlined,
          fieldName: 'reactiveReading',
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          validator: (value) {
            if (value?.trim().isEmpty ?? true) return 'Campo requerido';
            final numValue = double.tryParse(value!);
            if (numValue == null || numValue < 0) {
              return 'Ingrese un valor válido';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return FormSection(
      title: 'Ubicación',
      children: [
        CustomDropdown<String>(
          value: _selectedMunicipio,
          label: 'Municipio',
          icon: Icons.location_city,
          items: _municipios
              .map(
                (municipio) =>
                    DropdownMenuItem(value: municipio, child: Text(municipio)),
              )
              .toList(),
          onChanged: (value) => setState(() => _selectedMunicipio = value),
          validator: (value) =>
              value == null ? 'Seleccione un municipio' : null,
        ),
      ],
    );
  }

  Widget _buildEvidenceSection() {
    return FormSection(
      title: 'Evidencias y Documentación',
      children: [
        EvidenceCaptureWidget(
          evidences: _evidences,
          onEvidencesChanged: (evidences) {
            setState(() {
              _evidences = evidences;
            });
          },
          onGPSCountChanged: (count) {
            setState(() {
              _gpsCount = count;
            });
          },
          onEvidenceItemsChanged: (items) {
            setState(() {
              _evidenceItems = items;
            });
          },
          title: 'Capturar Evidencias',
          enableLocation: true,
        ),
      ],
    );
  }

  Widget _buildObservationsSection() {
    return FormSection(
      title: 'Descripción y Observaciones',
      children: [
        TextFormField(
          controller: _descriptionController,
          decoration: InputDecoration(
            labelText: 'Descripción *',
            hintText: 'Describa detalladamente la novedad...',
            prefixIcon: Icon(Icons.description, color: AppColors.primary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            alignLabelWithHint: true,
          ),
          maxLines: 3,
          maxLength: 500,
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'La descripción es obligatoria';
            }
            if (value.length < 10) {
              return 'La descripción debe tener al menos 10 caracteres';
            }
            if (value.length > 500) {
              return 'Máximo 500 caracteres';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _observationsController,
          decoration: InputDecoration(
            labelText: 'Observaciones Adicionales',
            hintText: 'Ingrese observaciones adicionales...',
            prefixIcon: Icon(Icons.note_add, color: AppColors.primary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            alignLabelWithHint: true,
          ),
          maxLines: 4,
          maxLength: 500,
          textInputAction: TextInputAction.done,
          validator: (value) {
            if (value != null && value.length > 500) {
              return 'Máximo 500 caracteres';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return CustomButton(
      text: 'Crear Incidente',
      type: ButtonType.primary,
      icon: Icons.send,
      onPressed: _handleSubmit,
    );
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor complete todos los campos requeridos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validar que exista al menos una evidencia GPS (obligatorio)
    if (_gpsCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📍 Debe capturar al menos una ubicación GPS'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // Mostrar diálogo de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Extraer coordenadas GPS (usar la primera ubicación)
      final gpsItem = _evidenceItems.firstWhere(
        (item) => item.type == EvidenceType.gps,
        orElse: () => throw Exception('No GPS location found'),
      );
      final address = '${gpsItem.latitude},${gpsItem.longitude}';

      // Extraer solo imágenes (fotos y galería)
      final imageItems = _evidenceItems
          .where((item) =>
              item.type == EvidenceType.photo || item.type == EvidenceType.gallery)
          .toList();
      final imageFiles = imageItems.map((item) => File(item.path)).toList();

      // Obtener servicio de novedades
      final noveltyService = di.sl<NoveltyService>();

      // Obtener ID numérico del área seleccionada
      final areaId = _areaIds[_selectedArea] ?? 1;

      // Crear novedad
      await noveltyService.createNovelty(
        areaId: areaId.toString(), // Convertir a string para el servicio
        reason: _selectedMotivo ?? '',
        accountNumber: _accountNumberController.text.trim(),
        meterNumber: _meterNumberController.text.trim(),
        activeReading: _activeReadingController.text.trim(),
        reactiveReading: _reactiveReadingController.text.trim(),
        municipality: _selectedMunicipio ?? '',
        address: address,
        description: _descriptionController.text.trim(),
        observations: _observationsController.text.trim().isNotEmpty
            ? _observationsController.text.trim()
            : null,
        images: imageFiles,
      );

      // Cerrar diálogo de carga
      if (mounted) Navigator.of(context).pop();

      // Mostrar éxito
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 32),
                const SizedBox(width: 12),
                const Text('¡Éxito!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'La novedad ha sido creada exitosamente.',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                _buildSummaryItem('Área', _selectedArea ?? ''),
                _buildSummaryItem('Motivo', _selectedMotivo ?? ''),
                _buildSummaryItem('Cuenta', _accountNumberController.text),
                _buildSummaryItem('Medidor', _meterNumberController.text),
                _buildSummaryItem('Municipio', _selectedMunicipio ?? ''),
                _buildSummaryItem('Imágenes', '${imageFiles.length}'),
                _buildSummaryItem('Coordenadas', address),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Cerrar diálogo
                  Navigator.of(context).pop(); // Volver a la pantalla anterior
                },
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Cerrar diálogo de carga
      if (mounted) Navigator.of(context).pop();

      // Mostrar error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear novedad: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value.isEmpty ? 'N/A' : value)),
        ],
      ),
    );
  }
}
