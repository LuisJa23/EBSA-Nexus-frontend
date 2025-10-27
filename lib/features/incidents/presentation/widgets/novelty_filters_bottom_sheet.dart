// novelty_filters_bottom_sheet.dart
//
// Bottom sheet para filtros de novedades
//
// PROPÓSITO:
// - Permitir filtrar novedades por estado, prioridad, etc.
// - UI amigable para aplicar y limpiar filtros
//
// CAPA: PRESENTATION LAYER - WIDGETS

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/novelty.dart';

/// Bottom sheet para filtros de novedades
class NoveltyFiltersBottomSheet extends StatefulWidget {
  final NoveltyStatus? currentStatus;
  final NoveltyPriority? currentPriority;
  final Function(NoveltyStatus?) onStatusChanged;
  final Function(NoveltyPriority?) onPriorityChanged;
  final VoidCallback onClearFilters;

  const NoveltyFiltersBottomSheet({
    super.key,
    this.currentStatus,
    this.currentPriority,
    required this.onStatusChanged,
    required this.onPriorityChanged,
    required this.onClearFilters,
  });

  @override
  State<NoveltyFiltersBottomSheet> createState() =>
      _NoveltyFiltersBottomSheetState();
}

class _NoveltyFiltersBottomSheetState extends State<NoveltyFiltersBottomSheet> {
  NoveltyStatus? _selectedStatus;
  NoveltyPriority? _selectedPriority;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.currentStatus;
    _selectedPriority = widget.currentPriority;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                'Filtros',
                style: AppTextStyles.heading3.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Filtro por Estado
          Text(
            'Estado',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildStatusChip(null, 'Todos'),
              ...NoveltyStatus.values.map(
                (status) => _buildStatusChip(status, status.label),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Filtro por Prioridad
          Text(
            'Prioridad',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildPriorityChip(null, 'Todas'),
              ...NoveltyPriority.values.map(
                (priority) => _buildPriorityChip(priority, priority.label),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Botones de acción
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _selectedStatus = null;
                      _selectedPriority = null;
                    });
                    widget.onClearFilters();
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Limpiar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onStatusChanged(_selectedStatus);
                    widget.onPriorityChanged(_selectedPriority);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Aplicar'),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  /// Construye chip de estado
  Widget _buildStatusChip(NoveltyStatus? status, String label) {
    final isSelected = _selectedStatus == status;
    final color = status != null
        ? Color(int.parse(status.colorHex.substring(1), radix: 16) + 0xFF000000)
        : AppColors.textSecondary;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedStatus = selected ? status : null;
        });
      },
      backgroundColor: Colors.grey[100],
      selectedColor: color.withOpacity(0.2),
      checkmarkColor: color,
      labelStyle: AppTextStyles.bodySmall.copyWith(
        color: isSelected ? color : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(color: isSelected ? color : Colors.grey[300]!),
    );
  }

  /// Construye chip de prioridad
  Widget _buildPriorityChip(NoveltyPriority? priority, String label) {
    final isSelected = _selectedPriority == priority;
    final color = priority != null
        ? Color(
            int.parse(priority.colorHex.substring(1), radix: 16) + 0xFF000000,
          )
        : AppColors.textSecondary;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedPriority = selected ? priority : null;
        });
      },
      backgroundColor: Colors.grey[100],
      selectedColor: color.withOpacity(0.2),
      checkmarkColor: color,
      labelStyle: AppTextStyles.bodySmall.copyWith(
        color: isSelected ? color : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(color: isSelected ? color : Colors.grey[300]!),
    );
  }
}
