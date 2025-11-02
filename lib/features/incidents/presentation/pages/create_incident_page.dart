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
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;

import '../../../../config/dependency_injection/injection_container.dart' as di;
import '../../../../config/database/database_provider.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../incidents/data/novelty_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/widgets/evidence_capture_widget.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/errors/exceptions.dart';

/// Página para crear reportes de incidentes
///
/// Permite a los usuarios crear nuevos reportes
/// de incidentes o novedades en el sistema.
class CreateIncidentPage extends ConsumerStatefulWidget {
  const CreateIncidentPage({super.key});

  @override
  ConsumerState<CreateIncidentPage> createState() => _CreateIncidentPageState();
}

class _CreateIncidentPageState extends ConsumerState<CreateIncidentPage> {
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
  int? _selectedMunicipioId; // Cambiado a ID numérico

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

  // Lista de municipios con sus IDs (según la tabla de BD)
  final List<Map<String, dynamic>> _municipios = [
    {'id': 5, 'name': 'ARCABUCO'},
    {'id': 6, 'name': 'CHITARAQUE'},
    {'id': 7, 'name': 'GAMBITA'},
    {'id': 8, 'name': 'MONIQUIRA'},
    {'id': 9, 'name': 'SAN JOSE DE PARE'},
    {'id': 10, 'name': 'SANTANA'},
    {'id': 11, 'name': 'TOGUI'},
  ];

  // Getter para obtener el nombre del municipio seleccionado
  String get _selectedMunicipioName {
    if (_selectedMunicipioId == null) return '';
    final municipio = _municipios.firstWhere(
      (m) => m['id'] == _selectedMunicipioId,
      orElse: () => {'name': ''},
    );
    return municipio['name'] as String;
  }

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

  void _clearForm() {
    setState(() {
      _accountNumberController.clear();
      _meterNumberController.clear();
      _activeReadingController.clear();
      _reactiveReadingController.clear();
      _descriptionController.clear();
      _observationsController.clear();
      _selectedArea = null;
      _selectedMotivo = null;
      _selectedMunicipioId = null; // Cambiado a ID
      _evidenceItems.clear();
    });
    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Incidente'),
        centerTitle: true,
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
            // Validar que no exceda el límite de INT en MySQL (2,147,483,647)
            if (numValue > 2147483647) {
              return 'El valor es demasiado grande (máx: 2,147,483,647)';
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
            // Validar que no exceda el límite de INT en MySQL (2,147,483,647)
            if (numValue > 2147483647) {
              return 'El valor es demasiado grande (máx: 2,147,483,647)';
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
        CustomDropdown<int>(
          value: _selectedMunicipioId,
          label: 'Municipio',
          icon: Icons.location_city,
          items: _municipios
              .map(
                (municipio) => DropdownMenuItem(
                  value: municipio['id'] as int,
                  child: Text(municipio['name'] as String),
                ),
              )
              .toList(),
          onChanged: (value) => setState(() => _selectedMunicipioId = value),
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

    // Validaciones adicionales
    if (_selectedArea == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar un área'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedMotivo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar un motivo'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedMunicipioId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar un municipio'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe ingresar una descripción'),
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

    // Validar que exista al menos una imagen
    final imageCount = _evidenceItems
        .where(
          (item) =>
              item.type == EvidenceType.photo ||
              item.type == EvidenceType.gallery,
        )
        .length;

    if (imageCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📷 Debe capturar al menos una imagen'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // Mostrar diálogo de carga y guardar su contexto
    BuildContext? loadingDialogContext;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        loadingDialogContext = dialogContext;
        return const Center(child: CircularProgressIndicator());
      },
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
          .where(
            (item) =>
                item.type == EvidenceType.photo ||
                item.type == EvidenceType.gallery,
          )
          .toList();
      final imageFiles = imageItems.map((item) => File(item.path)).toList();

      // Obtener servicio de novedades
      final noveltyService = di.sl<NoveltyService>();

      // Obtener ID numérico del área seleccionada
      final areaId = _areaIds[_selectedArea] ?? 1;

      // Log detallado de los datos a enviar
      print('═══════════════════════════════════════════════════════');
      print('📤 PREPARANDO DATOS PARA ENVIAR AL BACKEND');
      print('═══════════════════════════════════════════════════════');
      print('🔢 areaId: $areaId (${areaId.runtimeType})');
      print('📝 reason: $_selectedMotivo');
      print('🏠 accountNumber: ${_accountNumberController.text.trim()}');
      print('⚡ meterNumber: ${_meterNumberController.text.trim()}');
      print('📊 activeReading: ${_activeReadingController.text.trim()}');
      print('📊 reactiveReading: ${_reactiveReadingController.text.trim()}');
      print(
        '📍 locationId: $_selectedMunicipioId (${_selectedMunicipioId.runtimeType})',
      );
      print('🗺️  locationName: $_selectedMunicipioName');
      print('🌐 address (GPS): $address');
      print('📄 description: ${_descriptionController.text.trim()}');
      print(
        '📝 observations: ${_observationsController.text.trim().isNotEmpty ? _observationsController.text.trim() : "null"}',
      );
      print('📷 images: ${imageFiles.length} archivo(s)');
      for (var i = 0; i < imageFiles.length; i++) {
        print('   Imagen ${i + 1}: ${imageFiles[i].path}');
      }
      print('═══════════════════════════════════════════════════════');

      // Crear novedad con locationId
      await noveltyService.createNovelty(
        areaId: areaId.toString(), // Convertir a string para el servicio
        reason: _selectedMotivo ?? '',
        accountNumber: _accountNumberController.text.trim(),
        meterNumber: _meterNumberController.text.trim(),
        activeReading: _activeReadingController.text.trim(),
        reactiveReading: _reactiveReadingController.text.trim(),
        locationId:
            _selectedMunicipioId?.toString() ?? '', // Enviar ID del municipio
        municipality:
            _selectedMunicipioName, // Enviar NOMBRE del municipio (requerido)
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
        _showSuccessDialog(imageFiles.length, address);
      }
    } on NetworkException catch (e) {
      print('════════════════════════════════════════════════════');
      print('🔴 NetworkException CAPTURADO - ERROR DE CONEXIÓN');
      print('Mensaje: ${e.message}');
      print('════════════════════════════════════════════════════');

      // Cerrar diálogo de carga
      if (loadingDialogContext != null) {
        try {
          Navigator.of(loadingDialogContext!).pop();
          print('✅ Diálogo de carga cerrado');
        } catch (popError) {
          print('❌ ERROR al cerrar diálogo: $popError');
        }
      } else if (mounted) {
        try {
          Navigator.of(context).pop();
          print('✅ Diálogo de carga cerrado (fallback)');
        } catch (popError) {
          print('❌ ERROR al cerrar diálogo: $popError');
        }
      }

      // Esperar un frame para que el pop se complete
      await Future.delayed(Duration(milliseconds: 100));

      print('════════════════════════════════════════════════════');
      print('🔴 GUARDANDO OFFLINE - NetworkException');
      print('════════════════════════════════════════════════════');

      try {
        print('💾 Llamando a _saveOffline()...');
        await _saveOffline();
        print('✅✅✅ _saveOffline() COMPLETADO EXITOSAMENTE');
      } catch (saveError) {
        print('❌❌❌ ERROR en _saveOffline(): $saveError');
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 32),
                  SizedBox(width: 12),
                  Text('Error'),
                ],
              ),
              content: Text(
                'No se pudo guardar la novedad offline:\n$saveError',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Aceptar'),
                ),
              ],
            ),
          );
        }
        return;
      }

      // Contar imágenes guardadas
      final imageCount = _evidenceItems
          .where(
            (item) =>
                item.type == EvidenceType.photo ||
                item.type == EvidenceType.gallery,
          )
          .length;

      print('Número de imágenes: $imageCount');
      print('Widget mounted? $mounted');

      // Mostrar diálogo de éxito offline
      if (mounted) {
        print('🔴 MOSTRANDO DIÁLOGO OFFLINE...');

        try {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) {
              print('✅ Builder del diálogo ejecutándose');
              return AlertDialog(
                title: Row(
                  children: [
                    Icon(Icons.cloud_off, color: Colors.orange, size: 32),
                    SizedBox(width: 12),
                    Text('¡Guardado Offline!'),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'La novedad se guardó localmente y se sincronizará cuando haya conexión.',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    _buildSummaryItem('Área', _selectedArea ?? ''),
                    _buildSummaryItem('Motivo', _selectedMotivo ?? ''),
                    _buildSummaryItem('Cuenta', _accountNumberController.text),
                    _buildSummaryItem('Medidor', _meterNumberController.text),
                    _buildSummaryItem('Municipio', _selectedMunicipioName),
                    _buildSummaryItem('Imágenes', '$imageCount'),
                    SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.orange,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Ver en: Gestionar Novedad → Novedades Offline',
                              style: TextStyle(
                                color: Colors.orange[800],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      print('🔴 Botón Aceptar presionado');
                      Navigator.of(dialogContext).pop();
                      print('✅ Diálogo cerrado');
                      Navigator.of(context).pop();
                      print('✅ Página cerrada, volviendo al menú');
                    },
                    child: Text('Aceptar'),
                  ),
                ],
              );
            },
          );
          print('✅✅✅ showDialog() COMPLETADO');
        } catch (dialogError) {
          print('❌❌❌ ERROR al mostrar diálogo: $dialogError');
        }
      } else {
        print('❌ Widget NO mounted, no se puede mostrar diálogo');
      }

      print('════════════════════════════════════════════════════');
      print('✅ FIN DEL FLUJO OFFLINE (NetworkException)');
      print('════════════════════════════════════════════════════');
    } catch (e) {
      print('════════════════════════════════════════════════════');
      print('🔴 ERROR DEL SERVIDOR CAPTURADO');
      print('Error completo: ${e.toString()}');
      print('════════════════════════════════════════════════════');

      // Cerrar diálogo de carga
      if (loadingDialogContext != null) {
        try {
          Navigator.of(loadingDialogContext!).pop();
          print('✅ Diálogo de carga cerrado');
        } catch (popError) {
          print('❌ ERROR al cerrar diálogo: $popError');
        }
      } else if (mounted) {
        try {
          Navigator.of(context).pop();
          print('✅ Diálogo de carga cerrado (fallback)');
        } catch (popError) {
          print('❌ ERROR al cerrar diálogo: $popError');
        }
      }

      await Future.delayed(Duration(milliseconds: 100));

      // Mostrar error detallado
      print('❌ Error del servidor - Mostrando al usuario');

      String userMessage = 'Error al crear novedad';

      // Intentar extraer mensaje del error
      if (e.toString().contains('500')) {
        userMessage =
            '❌ Error del servidor (500)\n\n'
            'Posibles causas:\n'
            '• Usuario sin permisos para crear novedades\n'
            '• Error de validación en el servidor\n'
            '• Problema con la base de datos\n\n'
            'Por favor contacte al administrador.';
      } else if (e.toString().contains('403')) {
        userMessage =
            '❌ Acceso denegado (403)\n\n'
            'Su usuario no tiene permisos para crear novedades.\n'
            'Contacte al administrador del sistema.';
      } else if (e.toString().contains('401')) {
        userMessage =
            '❌ Sesión expirada (401)\n\n'
            'Por favor inicie sesión nuevamente.';
      } else {
        userMessage = 'Error al crear novedad:\n${e.toString()}';
      }

      if (mounted) {
        // Mostrar diálogo de error más informativo
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 32),
                SizedBox(width: 12),
                Text('Error'),
              ],
            ),
            content: SingleChildScrollView(child: Text(userMessage)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Aceptar'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _saveOffline() async {
    try {
      // Obtener usuario actual
      final authState = ref.read(authNotifierProvider);
      final currentUserId = authState.user?.id;

      if (currentUserId == null) {
        throw Exception('Usuario no identificado');
      }

      // Intentar parsear el userId como int, usar 0 si falla
      final userId = int.tryParse(currentUserId) ?? 0;

      // Obtener base de datos
      final db = ref.read(databaseProvider);

      // Generar ID único para la novedad (usar timestamp negativo para distinguir de IDs del servidor)
      final noveltyId = -DateTime.now().millisecondsSinceEpoch;

      // Obtener ID numérico del área seleccionada
      final areaId = _areaIds[_selectedArea] ?? 1;

      // Parsear lecturas como números
      final activeReading =
          double.tryParse(_activeReadingController.text.trim()) ?? 0.0;
      final reactiveReading =
          double.tryParse(_reactiveReadingController.text.trim()) ?? 0.0;

      // IMPORTANTE: Extraer coordenadas GPS (igual que en creación normal)
      final gpsItem = _evidenceItems.firstWhere(
        (item) => item.type == EvidenceType.gps,
        orElse: () => throw Exception('No se encontró ubicación GPS'),
      );
      final address = '${gpsItem.latitude},${gpsItem.longitude}';

      final now = DateTime.now();

      // Obtener rutas de imágenes para guardar (igual que en creación normal)
      final imageItems = _evidenceItems
          .where(
            (item) =>
                item.type == EvidenceType.photo ||
                item.type == EvidenceType.gallery,
          )
          .toList();
      final imagePaths = imageItems.map((item) => item.path).toList();

      // Crear JSON con TODOS los datos necesarios para sincronización
      final rawJsonMap = {
        'offline': true,
        'created_offline': true,
        'locationId': _selectedMunicipioId, // IMPORTANTE: Guardar locationId
        'image_paths': imagePaths,
        // Guardar también valores de texto originales para referencia
        'activeReadingText': _activeReadingController.text.trim(),
        'reactiveReadingText': _reactiveReadingController.text.trim(),
      };
      final rawJsonString = jsonEncode(rawJsonMap);

      // Guardar novedad en BD local usando tabla de cache
      await db.upsertNoveltyCache(
        NoveltyCacheTableCompanion(
          noveltyId: drift.Value(noveltyId),
          areaId: drift.Value(areaId),
          reason: drift.Value(_selectedMotivo ?? ''),
          accountNumber: drift.Value(_accountNumberController.text.trim()),
          meterNumber: drift.Value(_meterNumberController.text.trim()),
          activeReading: drift.Value(activeReading),
          reactiveReading: drift.Value(reactiveReading),
          municipality: drift.Value(
            _selectedMunicipioName,
          ), // Guardar nombre del municipio
          address: drift.Value(address),
          description: drift.Value(_descriptionController.text.trim()),
          observations: drift.Value(_observationsController.text.trim()),
          status: const drift.Value('PENDIENTE'), // Estado inicial
          createdBy: drift.Value(userId),
          crewId: const drift.Value.absent(), // Sin cuadrilla asignada aún
          createdAt: drift.Value(now),
          updatedAt: drift.Value(now),
          completedAt: const drift.Value.absent(),
          closedAt: const drift.Value.absent(),
          cancelledAt: const drift.Value.absent(),
          cachedAt: drift.Value(now),
          rawJson: drift.Value(rawJsonString),
        ),
      );
    } catch (e) {
      print('❌ Error en _saveOffline: $e');
      rethrow;
    }
  }

  void _showSuccessDialog(int imageCount, String address) {
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
            _buildSummaryItem('Municipio', _selectedMunicipioName),
            _buildSummaryItem('Imágenes', '$imageCount'),
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
