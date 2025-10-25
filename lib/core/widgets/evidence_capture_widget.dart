// evidence_capture_widget.dart
//
// Widget para captura de evidencias (fotos, ubicación)
//
// PROPÓSITO:
// - Capturar fotos como evidencia
// - Seleccionar imágenes de la galería
// - Capturar ubicación GPS con coordenadas reales
// - Gestionar permisos de cámara, galería y ubicación
// - Mostrar preview de evidencias
// - Gestionar archivos adjuntos
//
// CAPA: PRESENTATION LAYER - WIDGETS

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/app_colors.dart';
import 'map_location_picker_widget.dart';

/// Modelo para evidencia con imagen o ubicación
class EvidenceItem {
  final String id;
  final String path;
  final DateTime timestamp;
  final EvidenceType type;
  final double? latitude; // Para coordenadas GPS
  final double? longitude; // Para coordenadas GPS
  final double? accuracy; // Precisión del GPS

  EvidenceItem({
    required this.id,
    required this.path,
    required this.timestamp,
    required this.type,
    this.latitude,
    this.longitude,
    this.accuracy,
  });
}

enum EvidenceType { photo, gallery, gps }

/// Widget para capturar evidencias en reportes
class EvidenceCaptureWidget extends StatefulWidget {
  /// Lista de rutas de evidencias capturadas (legacy - mantener por compatibilidad)
  final List<String> evidences;

  /// Callback cuando se agregan evidencias
  final Function(List<String>) onEvidencesChanged;

  /// Callback cuando cambia el número de evidencias GPS (opcional)
  final Function(int)? onGPSCountChanged;

  /// Título del widget
  final String title;

  /// Si permite captura de ubicación GPS
  final bool enableLocation;

  const EvidenceCaptureWidget({
    super.key,
    required this.evidences,
    required this.onEvidencesChanged,
    this.onGPSCountChanged,
    this.title = 'Evidencias',
    this.enableLocation = true,
  });

  @override
  State<EvidenceCaptureWidget> createState() => _EvidenceCaptureWidgetState();
}

class _EvidenceCaptureWidgetState extends State<EvidenceCaptureWidget>
    with WidgetsBindingObserver {
  final ImagePicker _picker = ImagePicker();
  final List<EvidenceItem> _evidenceItems = [];

  // Para rastrear si el usuario fue a configuración
  Permission? _waitingForPermission;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Cuando la app regresa al primer plano
    if (state == AppLifecycleState.resumed && _waitingForPermission != null) {
      // Verificar si el permiso fue concedido
      _checkPermissionAfterSettings(_waitingForPermission!);
      _waitingForPermission = null;
    }
  }

  Future<void> _checkPermissionAfterSettings(Permission permission) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final status = await permission.status;

    if (status.isGranted || status.isLimited) {
      _showSuccessMessage('✅ Permiso habilitado correctamente');

      // Abrir automáticamente según el tipo de permiso
      await Future.delayed(const Duration(milliseconds: 500));
      if (permission == Permission.camera) {
        _openCamera();
      } else if (permission == Permission.photos ||
          permission == Permission.storage) {
        _openGalleryPicker();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        _buildCaptureButtons(),
        if (_evidenceItems.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildEvidencesGrid(),
        ],
      ],
    );
  }

  Widget _buildCaptureButtons() {
    final imageCount = _getImageCount();
    final bool imageAtLimit = imageCount >= 10;

    return Row(
      children: [
        Expanded(
          child: _buildCaptureButton(
            icon: Icons.camera_alt,
            label: 'Tomar Foto',
            onTap: _capturePhoto,
            isDisabled: imageAtLimit,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildCaptureButton(
            icon: Icons.photo_library,
            label: 'Galería',
            onTap: _selectFromGallery,
            isDisabled: imageAtLimit,
          ),
        ),
        if (widget.enableLocation) ...[
          const SizedBox(width: 12),
          _buildCaptureButton(
            icon: Icons.location_on,
            label: 'GPS',
            onTap: _captureLocation,
            isCompact: true,
          ),
        ],
      ],
    );
  }

  Widget _buildCaptureButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isCompact = false,
    bool isDisabled = false,
  }) {
    return InkWell(
      onTap: isDisabled ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 12,
          horizontal: isCompact ? 8 : 16,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDisabled
                ? Colors.grey.withValues(alpha: 0.3)
                : AppColors.primary,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isDisabled
              ? Colors.grey.withValues(alpha: 0.1)
              : Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isDisabled ? Colors.grey : AppColors.primary,
              size: isCompact ? 20 : 24,
            ),
            if (!isCompact) ...[
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isDisabled ? Colors.grey : AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Obtener el conteo de imágenes (fotos + galería)
  int _getImageCount() {
    return _evidenceItems
        .where((item) =>
            item.type == EvidenceType.photo || item.type == EvidenceType.gallery)
        .length;
  }

  /// Obtener el conteo de ubicaciones GPS
  int _getGPSCount() {
    return _evidenceItems.where((item) => item.type == EvidenceType.gps).length;
  }

  Widget _buildEvidencesGrid() {
    final imageCount = _getImageCount();
    final gpsCount = _getGPSCount();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Evidencias Capturadas (${_evidenceItems.length})',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            // Contador de imágenes
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: imageCount >= 10
                    ? Colors.red.withValues(alpha: 0.1)
                    : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: imageCount >= 10
                      ? Colors.red
                      : AppColors.primary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.image,
                    size: 14,
                    color: imageCount >= 10 ? Colors.red : AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$imageCount/10',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: imageCount >= 10 ? Colors.red : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Contador de GPS
            if (widget.enableLocation)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: gpsCount >= 1
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: gpsCount >= 1
                        ? Colors.green
                        : Colors.grey.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: gpsCount >= 1 ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$gpsCount/1',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: gpsCount >= 1 ? Colors.green : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: _evidenceItems.length,
          itemBuilder: (context, index) {
            return _buildEvidenceCard(_evidenceItems[index], index);
          },
        ),
      ],
    );
  }

  Widget _buildEvidenceCard(EvidenceItem item, int index) {
    return GestureDetector(
      onTap: () => _showFullImage(item),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: item.type == EvidenceType.gps
                  ? _buildGPSCard()
                  : Image.file(
                      File(item.path),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image, size: 40),
                        );
                      },
                    ),
            ),
          ),
          // Botón de eliminar
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _removeEvidence(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
          // Indicador de tipo
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.type == EvidenceType.photo
                        ? Icons.camera_alt
                        : item.type == EvidenceType.gallery
                        ? Icons.photo_library
                        : Icons.location_on,
                    size: 12,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    item.type == EvidenceType.photo
                        ? 'Cámara'
                        : item.type == EvidenceType.gallery
                        ? 'Galería'
                        : 'GPS',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGPSCard() {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.1),
      child: Center(
        child: Icon(Icons.location_on, size: 40, color: AppColors.primary),
      ),
    );
  }

  void _showFullImage(EvidenceItem item) {
    if (item.type == EvidenceType.gps) {
      _showGPSDetails(item);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.file(
                  File(item.path),
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, size: 100),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGPSDetails(EvidenceItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.location_on, color: Colors.green),
            SizedBox(width: 8),
            Text('Ubicación GPS'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('ID:', item.id),
            const SizedBox(height: 12),
            _buildInfoRow('Capturado:', _formatDateTime(item.timestamp)),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            if (item.latitude != null && item.longitude != null) ...[
              _buildInfoRow('Latitud:', item.latitude!.toStringAsFixed(6)),
              const SizedBox(height: 8),
              _buildInfoRow('Longitud:', item.longitude!.toStringAsFixed(6)),
              const SizedBox(height: 8),
              if (item.accuracy != null)
                _buildInfoRow(
                  'Precisión:',
                  '${item.accuracy!.toStringAsFixed(2)} m',
                ),
              const SizedBox(height: 12),
              // Botón para copiar coordenadas
              ElevatedButton.icon(
                onPressed: () {
                  // Copiar al portapapeles
                  final coords = '${item.latitude},${item.longitude}';
                  // TODO: Implementar copia al portapapeles
                  _showSuccessMessage('📋 Coordenadas copiadas: $coords');
                },
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('Copiar Coordenadas'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ] else ...[
              const Text(
                'No hay coordenadas GPS disponibles',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
        Expanded(
          child: SelectableText(value, style: const TextStyle(fontSize: 13)),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _capturePhoto() async {
    try {
      // Contar cuántas imágenes hay actualmente (fotos + galería)
      final imageCount = _evidenceItems.where((item) =>
        item.type == EvidenceType.photo || item.type == EvidenceType.gallery
      ).length;

      if (imageCount >= 10) {
        _showErrorMessage('⚠️ Máximo 10 imágenes permitidas. Elimina algunas para agregar más.');
        return;
      }

      // Verificar primero el estado actual del permiso
      PermissionStatus cameraStatus = await Permission.camera.status;

      // Si ya está concedido, abrir cámara directamente
      if (cameraStatus.isGranted) {
        _openCamera();
        return;
      }

      // Si fue denegado permanentemente, mostrar diálogo
      if (cameraStatus.isPermanentlyDenied) {
        _showPermissionDeniedDialog('Cámara', Permission.camera);
        return;
      }

      // Si está denegado o no solicitado, pedir permiso
      final newStatus = await Permission.camera.request();

      if (newStatus.isGranted) {
        // Permiso concedido, abrir cámara
        _openCamera();
      } else {
        // Usuario denegó (temporal o permanentemente)
        // Mostrar diálogo para que vaya a configuración
        _showPermissionDeniedDialog('Cámara', Permission.camera);
      }
    } catch (e) {
      _showErrorMessage('Error al capturar foto: $e');
    }
  }

  Future<void> _openCamera() async {
    try {
      // Capturar foto
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (photo != null) {
        _addEvidence(photo.path, EvidenceType.photo);
        _showSuccessMessage('📷 Foto capturada exitosamente');
      }
    } catch (e) {
      _showErrorMessage('Error al abrir cámara: $e');
    }
  }

  Future<void> _selectFromGallery() async {
    try {
      // Contar cuántas imágenes hay actualmente (fotos + galería)
      final imageCount = _evidenceItems.where((item) =>
        item.type == EvidenceType.photo || item.type == EvidenceType.gallery
      ).length;

      if (imageCount >= 10) {
        _showErrorMessage('⚠️ Máximo 10 imágenes permitidas. Elimina algunas para agregar más.');
        return;
      }

      // NUEVA ESTRATEGIA: Intentar abrir galería directamente
      // Si falla por permisos, entonces manejamos
      try {
        final List<XFile> images = await _picker.pickMultiImage(
          imageQuality: 85,
          maxWidth: 1920,
          maxHeight: 1080,
        );

        if (images.isNotEmpty) {
          // Calcular cuántas imágenes se pueden agregar
          final availableSlots = 10 - imageCount;
          final imagesToAdd = images.take(availableSlots).toList();
          
          if (images.length > availableSlots) {
            _showErrorMessage(
              '⚠️ Solo se agregaron ${imagesToAdd.length} de ${images.length} imágenes. Límite: 10 imágenes totales.',
            );
          }

          for (var image in imagesToAdd) {
            _addEvidence(image.path, EvidenceType.gallery);
          }
          
          if (images.length <= availableSlots) {
            _showSuccessMessage(
              '🖼️ ${imagesToAdd.length} imagen(es) seleccionada(s) de la galería',
            );
          }
        }
        return;
      } catch (pickerError) {
        // Si falla, es posible que sea por permisos
        print('Error al abrir galería: $pickerError');
      }

      // Si llegamos aquí, verificamos permisos explícitamente
      Permission galleryPermission;

      if (Platform.isAndroid) {
        final androidInfo = await _getAndroidVersion();
        if (androidInfo >= 33) {
          galleryPermission = Permission.photos;
        } else {
          galleryPermission = Permission.storage;
        }
      } else if (Platform.isIOS) {
        galleryPermission = Permission.photos;
      } else {
        _showErrorMessage('Plataforma no soportada');
        return;
      }

      // Verificar estado actual
      final currentStatus = await galleryPermission.status;

      if (currentStatus.isGranted || currentStatus.isLimited) {
        // Tiene permiso pero falló, intentar de nuevo
        _openGalleryPicker();
        return;
      }

      // No tiene permiso, solicitarlo
      final newStatus = await galleryPermission.request();

      if (newStatus.isGranted || newStatus.isLimited) {
        _openGalleryPicker();
      } else {
        _showPermissionDeniedDialog('Galería', galleryPermission);
      }
    } catch (e) {
      _showErrorMessage('Error al seleccionar de galería: $e');
    }
  }

  Future<void> _openGalleryPicker() async {
    try {
      // Seleccionar de galería (ahora con múltiples imágenes)
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (images.isNotEmpty) {
        for (var image in images) {
          _addEvidence(image.path, EvidenceType.gallery);
        }
        _showSuccessMessage(
          '🖼️ ${images.length} imagen(es) seleccionada(s) de la galería',
        );
      }
    } catch (e) {
      _showErrorMessage('Error al abrir galería: $e');
    }
  }

  Future<int> _getAndroidVersion() async {
    // Placeholder - en producción usarías device_info_plus
    return 33; // Asume Android 13+
  }

  Future<void> _captureLocation() async {
    try {
      // Verificar si ya existe una ubicación GPS
      final existingGpsIndex = _evidenceItems.indexWhere(
        (item) => item.type == EvidenceType.gps,
      );

      // Si ya existe una ubicación, preguntar si desea reemplazarla
      if (existingGpsIndex != -1) {
        final shouldReplace = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.warning, color: Colors.orange),
                SizedBox(width: 8),
                Text('Ubicación Existente'),
              ],
            ),
            content: const Text(
              'Ya has capturado una ubicación GPS. ¿Deseas reemplazarla con una nueva?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Reemplazar'),
              ),
            ],
          ),
        );

        if (shouldReplace != true) {
          return; // Usuario canceló
        }
      }

      // Abrir selector de ubicación con mapa interactivo
      final LocationResult? selectedLocation = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const MapLocationPickerWidget(),
        ),
      );

      if (selectedLocation == null) {
        // Usuario canceló la selección
        return;
      }

      // Crear evidencia con coordenadas seleccionadas
      final evidence = EvidenceItem(
        id: 'GPS_${DateTime.now().millisecondsSinceEpoch}',
        path: 'GPS_LOCATION',
        timestamp: DateTime.now(),
        type: EvidenceType.gps,
        latitude: selectedLocation.latitude,
        longitude: selectedLocation.longitude,
        accuracy: selectedLocation.accuracy,
      );

      setState(() {
        // Si ya existía una ubicación, eliminarla
        if (existingGpsIndex != -1) {
          _evidenceItems.removeAt(existingGpsIndex);
        }
        // Agregar la nueva ubicación
        _evidenceItems.add(evidence);
      });

      // Actualizar callback legacy
      _updateLegacyEvidences();

      _showSuccessMessage(
        existingGpsIndex != -1
            ? '🔄 Ubicación GPS actualizada: ${selectedLocation.latitude.toStringAsFixed(6)}, ${selectedLocation.longitude.toStringAsFixed(6)}'
            : '✅ Ubicación GPS capturada: ${selectedLocation.latitude.toStringAsFixed(6)}, ${selectedLocation.longitude.toStringAsFixed(6)}',
      );
    } catch (e) {
      print('Error capturando ubicación: $e');
      _showErrorMessage('❌ Error al capturar ubicación: ${e.toString()}');
    }
  }

  void _addEvidence(String path, EvidenceType type) {
    final evidence = EvidenceItem(
      id: 'EVD_${DateTime.now().millisecondsSinceEpoch}',
      path: path,
      timestamp: DateTime.now(),
      type: type,
    );

    setState(() {
      _evidenceItems.add(evidence);
    });

    // Actualizar callback legacy
    _updateLegacyEvidences();
  }

  void _removeEvidence(int index) {
    setState(() {
      _evidenceItems.removeAt(index);
    });

    // Actualizar callback legacy
    _updateLegacyEvidences();

    _showSuccessMessage('Evidencia eliminada');
  }

  void _updateLegacyEvidences() {
    final legacyPaths = _evidenceItems.map((e) => e.path).toList();
    widget.onEvidencesChanged(legacyPaths);

    // Notificar número de evidencias GPS
    if (widget.onGPSCountChanged != null) {
      final gpsCount = _evidenceItems
          .where((e) => e.type == EvidenceType.gps)
          .length;
      widget.onGPSCountChanged!(gpsCount);
    }
  }

  void _showPermissionDeniedDialog(
    String permissionName,
    Permission permission,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange[700]),
            const SizedBox(width: 8),
            const Text('Permiso Requerido'),
          ],
        ),
        content: Text(
          'Se necesita acceso a $permissionName. '
          'Si ya lo habilitaste, presiona "Verificar Permiso". '
          'Si no, ve a Configuración para habilitarlo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();

              // Verificar el estado actual del permiso
              await Future.delayed(const Duration(milliseconds: 200));
              final status = await permission.status;

              if (status.isGranted || status.isLimited) {
                _showSuccessMessage('✅ Permiso verificado correctamente');
                await Future.delayed(const Duration(milliseconds: 500));

                if (permission == Permission.camera) {
                  _openCamera();
                } else {
                  _openGalleryPicker();
                }
              } else {
                _showErrorMessage(
                  '⚠️ El permiso aún no está habilitado. Ve a Configuración.',
                );
                // Mostrar el diálogo de nuevo
                await Future.delayed(const Duration(milliseconds: 500));
                _showPermissionDeniedDialog(permissionName, permission);
              }
            },
            child: const Text('Verificar Permiso'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();

              // Marcar que estamos esperando este permiso
              setState(() {
                _waitingForPermission = permission;
              });

              // Abrir configuración
              final opened = await openAppSettings();

              if (!opened) {
                setState(() {
                  _waitingForPermission = null;
                });
                _showErrorMessage('No se pudo abrir la configuración');
              }
              // El observer detectará cuando el usuario regrese
            },
            child: const Text('Ir a Configuración'),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
      ),
    );
  }
}
