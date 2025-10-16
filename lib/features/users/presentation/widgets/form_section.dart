// form_section.dart
//
// Componente para secciones de formulario
//
// PROPÓSITO:
// - Agrupar campos relacionados visualmente
// - Título y espaciado consistente
// - Reutilización en diferentes formularios
//
// CAPA: PRESENTATION LAYER - WIDGETS

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Sección de formulario con título y campos agrupados
class FormSection extends StatelessWidget {
  /// Título de la sección
  final String title;

  /// Widgets hijos de la sección
  final List<Widget> children;

  /// Espaciado entre elementos
  final double spacing;

  const FormSection({
    super.key,
    required this.title,
    required this.children,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.heading4.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: spacing),
        ...children
            .map(
              (child) => [
                child,
                if (child != children.last) SizedBox(height: spacing),
              ],
            )
            .expand((element) => element),
      ],
    );
  }
}
