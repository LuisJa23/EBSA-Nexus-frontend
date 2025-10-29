// app_theme.dart
//
// Tema principal de la aplicación EBSA Nexus
//
// PROPÓSITO:
// - Definir el ThemeData principal de la aplicación
// - Configurar temas claro y oscuro
// - Establecer estilos de componentes Material Design
// - Configurar colores, tipografías y espaciado

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// Configuración de temas de la aplicación EBSA Nexus
class AppTheme {
  /// Tema claro (modo por defecto)
  static ThemeData get lightTheme {
    return ThemeData(
      // ========================================================================
      // CONFIGURACIÓN BÁSICA
      // ========================================================================
      useMaterial3: true,
      brightness: Brightness.light,

      // ========================================================================
      // ESQUEMA DE COLORES
      // ========================================================================
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryLight,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryLight,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: AppColors.textOnPrimary,
        onSecondary: AppColors.textOnSecondary,
        onSurface: AppColors.textPrimary,
        onError: Colors.white,
        outline: AppColors.divider,
      ),

      // ========================================================================
      // COLORES ADICIONALES
      // ========================================================================
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.surface,
      cardColor: AppColors.surface,
      dividerColor: AppColors.divider,

      // ========================================================================
      // TIPOGRAFÍA
      // ========================================================================
      textTheme: const TextTheme(
        headlineLarge: AppTextStyles.heading1,
        headlineMedium: AppTextStyles.heading2,
        headlineSmall: AppTextStyles.heading3,
        titleLarge: AppTextStyles.heading4,
        titleMedium: AppTextStyles.reportTitle,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.button,
        labelMedium: AppTextStyles.label,
        labelSmall: AppTextStyles.caption,
      ),

      // ========================================================================
      // APP BAR
      // ========================================================================
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        titleTextStyle: TextStyle(
          color: AppColors.textOnPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: AppTextStyles.fontFamily,
        ),
        iconTheme: IconThemeData(color: AppColors.textOnPrimary, size: 24),
        actionsIconTheme: IconThemeData(
          color: AppColors.textOnPrimary,
          size: 24,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      // ========================================================================
      // BOTONES
      // ========================================================================
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 2,
          shadowColor: AppColors.primary.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.defaultBorderRadius,
            ),
          ),
          textStyle: AppTextStyles.button,
          minimumSize: const Size(0, AppConstants.defaultButtonHeight),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: 12,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.defaultBorderRadius,
            ),
          ),
          textStyle: AppTextStyles.button.copyWith(color: AppColors.primary),
          minimumSize: const Size(0, AppConstants.defaultButtonHeight),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: 12,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.button.copyWith(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.defaultBorderRadius,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: 12,
          ),
        ),
      ),

      // ========================================================================
      // FORMULARIOS
      // ========================================================================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: const BorderSide(color: AppColors.divider, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: const BorderSide(color: AppColors.divider, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: AppTextStyles.label,
        hintStyle: AppTextStyles.input.copyWith(color: AppColors.textSecondary),
        errorStyle: AppTextStyles.inputError,
      ),

      // ========================================================================
      // TARJETAS
      // ========================================================================
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 2,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        margin: const EdgeInsets.all(8),
      ),

      // ========================================================================
      // LISTAS
      // ========================================================================
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
          vertical: 8,
        ),
        titleTextStyle: AppTextStyles.bodyLarge,
        subtitleTextStyle: AppTextStyles.bodySmall,
        iconColor: AppColors.primary,
      ),

      // ========================================================================
      // DIÁLOGOS
      // ========================================================================
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppConstants.defaultBorderRadius * 2,
          ),
        ),
        titleTextStyle: AppTextStyles.heading4,
        contentTextStyle: AppTextStyles.bodyMedium,
      ),

      // ========================================================================
      // BOTTOM NAVIGATION
      // ========================================================================
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: AppTextStyles.caption,
        unselectedLabelStyle: AppTextStyles.caption,
      ),

      // ========================================================================
      // FLOATING ACTION BUTTON
      // ========================================================================
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // ========================================================================
      // CHIPS
      // ========================================================================
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceElevated,
        deleteIconColor: AppColors.textSecondary,
        disabledColor: AppColors.divider,
        selectedColor: AppColors.primary.withOpacity(0.12),
        secondarySelectedColor: AppColors.secondary.withOpacity(0.12),
        labelStyle: AppTextStyles.bodySmall,
        secondaryLabelStyle: AppTextStyles.bodySmall,
        brightness: Brightness.light,
        elevation: 0,
        pressElevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // ========================================================================
      // PROGRESS INDICATORS
      // ========================================================================
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.divider,
        circularTrackColor: AppColors.divider,
      ),

      // ========================================================================
      // SNACK BAR
      // ========================================================================
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 6,
      ),

      // ========================================================================
      // SWITCHES Y CHECKBOXES
      // ========================================================================
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary.withOpacity(0.5);
          }
          return AppColors.divider;
        }),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.textOnPrimary),
        side: const BorderSide(color: AppColors.divider, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }

  /// Tema oscuro (para futuro uso)
  static ThemeData get darkTheme {
    // TODO: Implementar tema oscuro cuando sea necesario
    return lightTheme;
  }
}
