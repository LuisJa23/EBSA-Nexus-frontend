// custom_button.dart
//
// Componente reutilizable de botones
//
// PROPÓSITO:
// - Botones personalizados con estilos consistentes
// - Estados de carga y deshabilitado
// - Variantes de diseño (primario, secundario, etc.)
//
// CAPA: PRESENTATION LAYER - WIDGETS

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Tipos de botón disponibles
enum ButtonType { primary, secondary, outline, toggle }

/// Botón personalizado con diferentes variantes de estilo
class CustomButton extends StatelessWidget {
  /// Texto del botón
  final String text;

  /// Callback cuando se presiona
  final VoidCallback? onPressed;

  /// Tipo de botón
  final ButtonType type;

  /// Si está en estado de carga
  final bool isLoading;

  /// Icono opcional
  final IconData? icon;

  /// Si está seleccionado (para toggle buttons)
  final bool isSelected;

  /// Padding personalizado
  final EdgeInsets? padding;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.icon,
    this.isSelected = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePadding =
        padding ?? const EdgeInsets.symmetric(vertical: 16);

    switch (type) {
      case ButtonType.primary:
        return _buildPrimaryButton(effectivePadding);
      case ButtonType.secondary:
        return _buildSecondaryButton(effectivePadding);
      case ButtonType.outline:
        return _buildOutlineButton(effectivePadding);
      case ButtonType.toggle:
        return _buildToggleButton(effectivePadding);
    }
  }

  Widget _buildPrimaryButton(EdgeInsets padding) {
    return ElevatedButton(
      onPressed: (isLoading || onPressed == null) ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFC107),
        foregroundColor: Colors.white,
        padding: padding,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        disabledBackgroundColor: Colors.grey.shade300,
        disabledForegroundColor: Colors.grey.shade600,
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildSecondaryButton(EdgeInsets padding) {
    return ElevatedButton(
      onPressed: (isLoading || onPressed == null) ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey.shade200,
        foregroundColor: Colors.black87,
        padding: padding,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 1,
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildOutlineButton(EdgeInsets padding) {
    return OutlinedButton(
      onPressed: (isLoading || onPressed == null) ? null : onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: AppColors.primary),
        foregroundColor: AppColors.primary,
        padding: padding,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildToggleButton(EdgeInsets padding) {
    return ElevatedButton(
      onPressed: (isLoading || onPressed == null) ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? const Color(0xFFFFC107)
            : Colors.grey.shade200,
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        padding: padding,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: isSelected ? 2 : 1,
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(text, style: _getTextStyle()),
        ],
      );
    }

    return Text(text, style: _getTextStyle());
  }

  TextStyle _getTextStyle() {
    switch (type) {
      case ButtonType.primary:
        return AppTextStyles.heading4.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        );
      case ButtonType.secondary:
      case ButtonType.outline:
      case ButtonType.toggle:
        return const TextStyle(fontWeight: FontWeight.w600);
    }
  }
}

/// Botón específico para selección de tipo de trabajador
class WorkTypeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onPressed;

  const WorkTypeButton({
    super.key,
    required this.label,
    required this.isSelected,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: label,
      type: ButtonType.toggle,
      isSelected: isSelected,
      onPressed: onPressed,
    );
  }
}
