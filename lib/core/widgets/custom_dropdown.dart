// custom_dropdown.dart
//
// Componente reutilizable de dropdown
//
// PROPÓSITO:
// - Dropdown personalizado con estilo consistente
// - Manejo de estados de carga
// - Validación integrada
// - Estados de error y loading
//
// CAPA: PRESENTATION LAYER - WIDGETS

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Dropdown personalizado con validación y estilo consistente
class CustomDropdown<T> extends StatelessWidget {
  /// Valor seleccionado
  final T? value;

  /// Etiqueta del campo
  final String label;

  /// Icono del campo
  final IconData icon;

  /// Lista de elementos
  final List<DropdownMenuItem<T>> items;

  /// Callback cuando cambia el valor
  final void Function(T?)? onChanged;

  /// Función de validación
  final String? Function(T?)? validator;

  /// Si el campo está habilitado
  final bool enabled;

  const CustomDropdown({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.items,
    this.onChanged,
    this.validator,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      items: items,
      onChanged: enabled ? onChanged : null,
      validator: validator,
    );
  }
}

/// Widget para mostrar estado de carga en dropdown
class DropdownLoadingWidget extends StatelessWidget {
  final String label;
  final IconData icon;
  final String loadingText;

  const DropdownLoadingWidget({
    super.key,
    required this.label,
    required this.icon,
    this.loadingText = 'Cargando...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 12),
          Text(loadingText, style: const TextStyle(color: Colors.grey)),
          const Spacer(),
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

/// Widget para mostrar error en dropdown
class DropdownErrorWidget extends StatelessWidget {
  final String label;
  final IconData icon;
  final String error;
  final VoidCallback onRetry;

  const DropdownErrorWidget({
    super.key,
    required this.label,
    required this.icon,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(Icons.error, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Error: $error',
              style: const TextStyle(color: Colors.red),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.red),
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
