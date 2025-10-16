// evidence_capture_widget.dart
//
// Widget para captura de evidencias (fotos, ubicación)
//
// PROPÓSITO:
// - Capturar fotos como evidencia
// - Obtener ubicación GPS
// - Mostrar preview de evidencias
// - Gestionar archivos adjuntos
//
// CAPA: PRESENTATION LAYER - WIDGETS

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Widget para capturar evidencias en reportes
class EvidenceCaptureWidget extends StatefulWidget {
  /// Lista de evidencias capturadas
  final List<String> evidences;

  /// Callback cuando se agregan evidencias
  final Function(List<String>) onEvidencesChanged;

  /// Título del widget
  final String title;

  /// Si permite captura de ubicación GPS
  final bool enableLocation;

  const EvidenceCaptureWidget({
    super.key,
    required this.evidences,
    required this.onEvidencesChanged,
    this.title = 'Evidencias',
    this.enableLocation = true,
  });

  @override
  State<EvidenceCaptureWidget> createState() => _EvidenceCaptureWidgetState();
}

class _EvidenceCaptureWidgetState extends State<EvidenceCaptureWidget> {
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
        if (widget.evidences.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildEvidencesList(),
        ],
      ],
    );
  }

  Widget _buildCaptureButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildCaptureButton(
            icon: Icons.camera_alt,
            label: 'Tomar Foto',
            onTap: _capturePhoto,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildCaptureButton(
            icon: Icons.photo_library,
            label: 'Galería',
            onTap: _selectFromGallery,
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
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 12,
          horizontal: isCompact ? 8 : 16,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primary, size: isCompact ? 20 : 24),
            if (!isCompact) ...[
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: AppColors.primary,
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

  Widget _buildEvidencesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Evidencias Capturadas (${widget.evidences.length})',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.evidences.asMap().entries.map((entry) {
            final index = entry.key;
            final evidence = entry.value;
            return _buildEvidenceChip(evidence, index);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEvidenceChip(String evidence, int index) {
    return Chip(
      label: Text(evidence, style: const TextStyle(fontSize: 12)),
      avatar: Icon(
        evidence.contains('GPS') ? Icons.location_on : Icons.photo,
        size: 16,
        color: AppColors.primary,
      ),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: () => _removeEvidence(index),
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
    );
  }

  void _capturePhoto() {
    // Simulación de captura de foto
    final newEvidence = 'Foto_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final updatedEvidences = [...widget.evidences, newEvidence];
    widget.onEvidencesChanged(updatedEvidences);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📷 Foto capturada exitosamente'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _selectFromGallery() {
    // Simulación de selección de galería
    final newEvidence = 'Galeria_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final updatedEvidences = [...widget.evidences, newEvidence];
    widget.onEvidencesChanged(updatedEvidences);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🖼️ Imagen seleccionada de la galería'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _captureLocation() {
    // Simulación de captura de ubicación GPS
    final newEvidence = 'GPS: ${DateTime.now().millisecondsSinceEpoch}';
    final updatedEvidences = [...widget.evidences, newEvidence];
    widget.onEvidencesChanged(updatedEvidences);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📍 Ubicación GPS capturada'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _removeEvidence(int index) {
    final updatedEvidences = [...widget.evidences];
    updatedEvidences.removeAt(index);
    widget.onEvidencesChanged(updatedEvidences);
  }
}
