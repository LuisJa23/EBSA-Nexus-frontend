// custom_text_field.dart
//
// Componente reutilizable de campo de texto
//
// PROPÓSITO:
// - Input personalizado con estilo consistente
// - Validación integrada
// - Manejo de errores del servidor
// - Iconografía y estados visuales
//
// CAPA: PRESENTATION LAYER - WIDGETS

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';

/// Campo de texto personalizado con validación y estilo consistente
class CustomTextField extends StatelessWidget {
  /// Controlador del texto
  final TextEditingController controller;

  /// Etiqueta del campo
  final String label;

  /// Texto de ayuda/placeholder
  final String hint;

  /// Icono del campo
  final IconData icon;

  /// Identificador del campo para manejo de errores
  final String fieldName;

  /// Texto de error del servidor
  final String? errorText;

  /// Función de validación
  final String? Function(String?)? validator;

  /// Tipo de teclado
  final TextInputType? keyboardType;

  /// Formateadores de entrada
  final List<TextInputFormatter>? inputFormatters;

  /// Callback cuando el texto cambia
  final void Function(String)? onChanged;

  /// Si el campo es requerido (para mostrar asterisco)
  final bool isRequired;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.fieldName,
    this.errorText,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.isRequired = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary),
        errorText: errorText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
      ),
      validator: validator,
    );
  }
}
