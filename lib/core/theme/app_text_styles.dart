// app_text_styles.dart
//
// Estilos de texto de la aplicación EBSA Nexus
//
// PROPÓSITO:
// - Definir tipografías consistentes
// - Estilos para headers, títulos, body text
// - Estilos específicos para formularios
// - Tamaños de fuente para diferentes densidades de pantalla

import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Estilos de texto estandarizados para toda la aplicación
class AppTextStyles {
  // ============================================================================
  // TIPOGRAFÍA BASE
  // ============================================================================

  /// Familia de fuente principal
  static const String fontFamily = 'Roboto';

  // ============================================================================
  // HEADINGS (ENCABEZADOS)
  // ============================================================================

  /// Heading 1 - Títulos principales
  static const TextStyle heading1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
    letterSpacing: -0.5,
  );

  /// Heading 2 - Títulos de sección
  static const TextStyle heading2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
    letterSpacing: -0.25,
  );

  /// Heading 3 - Subtítulos
  static const TextStyle heading3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  /// Heading 4 - Títulos menores
  static const TextStyle heading4 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // ============================================================================
  // TEXTO DE CUERPO
  // ============================================================================

  /// Texto de cuerpo principal
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  /// Texto de cuerpo mediano
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  /// Texto de cuerpo pequeño
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // ============================================================================
  // BOTONES Y FORMULARIOS
  // ============================================================================

  /// Texto de botones principales
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
    height: 1.2,
    letterSpacing: 0.25,
  );

  /// Texto de campos de entrada
  static const TextStyle input = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  /// Etiquetas de campos
  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  /// Texto de error en formularios
  static const TextStyle inputError = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.error,
    height: 1.3,
  );

  // ============================================================================
  // ESTADOS Y METADATOS
  // ============================================================================

  /// Texto de éxito
  static const TextStyle success = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.success,
    height: 1.4,
  );

  /// Texto de error
  static const TextStyle error = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.error,
    height: 1.4,
  );

  /// Texto de información
  static const TextStyle info = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.info,
    height: 1.4,
  );

  /// Texto de ayuda/descripción
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.3,
  );

  // ============================================================================
  // ESPECÍFICOS DE REPORTES
  // ============================================================================

  /// Título de reporte
  static const TextStyle reportTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  /// ID de reporte
  static const TextStyle reportId = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.2,
    letterSpacing: 0.5,
  );

  /// Estado de reporte
  static const TextStyle reportStatus = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.25,
  );
}
