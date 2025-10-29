// app_colors.dart
//
// Paleta de colores de la aplicación EBSA Nexus
//
// PROPÓSITO:
// - Definir colores corporativos de EBSA
// - Colores para estados de reportes (pendiente, enviado, error)
// - Colores de severidad de incidentes
// - Colores para indicadores de conectividad

import 'package:flutter/material.dart';

/// Paleta de colores corporativos de EBSA y estados de la aplicación
class AppColors {
  // ============================================================================
  // COLORES CORPORATIVOS EBSA
  // ============================================================================

  /// Color primario EBSA (Azul corporativo)
  static const Color primary = Color.fromARGB(255, 255, 198, 16);

  /// Variantes del color primario
  static const Color primaryLight = Color(0xFF5E92F3);
  static const Color primaryDark = Color(0xFF003C8F);

  /// Color secundario (Naranja complementario)
  static const Color secondary = Color(0xFFFF8F00);
  static const Color secondaryLight = Color(0xFFFFC046);
  static const Color secondaryDark = Color(0xFFC56000);

  /// Color de acento (Verde EBSA)
  static const Color accent = Color(0xFF2E7D32);
  static const Color accentLight = Color(0xFF60AD5E);
  static const Color accentDark = Color(0xFF005005);

  // ============================================================================
  // COLORES DE SUPERFICIE Y FONDO
  // ============================================================================

  /// Fondo principal (modo claro)
  static const Color background = Color(0xFFF5F5F5);

  /// Superficie de tarjetas y componentes
  static const Color surface = Color(0xFFFFFFFF);

  /// Color de superficie elevada
  static const Color surfaceElevated = Color(0xFFFAFAFA);

  /// Divisores y bordes
  static const Color divider = Color(0xFFE0E0E0);

  // ============================================================================
  // COLORES DE TEXTO
  // ============================================================================

  /// Texto principal
  static const Color textPrimary = Color(0xFF212121);

  /// Texto secundario
  static const Color textSecondary = Color(0xFF757575);

  /// Texto deshabilitado
  static const Color textDisabled = Color(0xFFBDBDBD);

  /// Texto en superficies primarias
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  /// Texto en superficies secundarias
  static const Color textOnSecondary = Color(0xFF000000);

  // ============================================================================
  // COLORES DE ESTADOS DE REPORTES
  // ============================================================================

  /// Estado: Borrador/Sin enviar
  static const Color statusDraft = Color(0xFF9E9E9E);

  /// Estado: Pendiente de envío
  static const Color statusPending = Color(0xFFFF8F00);

  /// Estado: Enviado exitosamente
  static const Color statusSent = Color(0xFF4CAF50);

  /// Estado: Error al enviar
  static const Color statusError = Color(0xFFF44336);

  /// Estado: Sincronizando
  static const Color statusSyncing = Color(0xFF2196F3);

  // ============================================================================
  // COLORES DE SEVERIDAD DE INCIDENTES
  // ============================================================================

  /// Severidad: Baja
  static const Color severityLow = Color(0xFF4CAF50);

  /// Severidad: Media
  static const Color severityMedium = Color(0xFFFF9800);

  /// Severidad: Alta
  static const Color severityHigh = Color(0xFFFF5722);

  /// Severidad: Crítica
  static const Color severityCritical = Color(0xFFD32F2F);

  // ============================================================================
  // COLORES DE CONECTIVIDAD
  // ============================================================================

  /// Online/Conectado
  static const Color connectionOnline = Color(0xFF4CAF50);

  /// Offline/Desconectado
  static const Color connectionOffline = Color(0xFF9E9E9E);

  /// Conectividad limitada
  static const Color connectionLimited = Color(0xFFFF9800);

  // ============================================================================
  // COLORES DE VALIDACIÓN
  // ============================================================================

  /// Éxito/Válido
  static const Color success = Color(0xFF4CAF50);

  /// Advertencia
  static const Color warning = Color(0xFFFF9800);

  /// Error/Inválido
  static const Color error = Color(0xFFF44336);

  /// Información
  static const Color info = Color(0xFF2196F3);

  // ============================================================================
  // COLORES TRANSPARENTES Y OVERLAYS
  // ============================================================================

  /// Overlay oscuro para modales
  static const Color overlayDark = Color(0x80000000);

  /// Overlay claro para loading
  static const Color overlayLight = Color(0x80FFFFFF);

  /// Shimmer para loading de contenido
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // ============================================================================
  // GRADIENTES CORPORATIVOS
  // ============================================================================

  /// Gradiente principal EBSA
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  /// Gradiente de acento
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [accent, accentDark],
  );

  /// Gradiente para botones secundarios
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [secondary, secondaryDark],
  );

  // ============================================================================
  // MÉTODOS DE UTILIDAD
  // ============================================================================

  /// Obtiene color según severidad
  static Color getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'baja':
      case 'low':
        return severityLow;
      case 'media':
      case 'medium':
        return severityMedium;
      case 'alta':
      case 'high':
        return severityHigh;
      case 'crítica':
      case 'critical':
        return severityCritical;
      default:
        return severityMedium;
    }
  }

  /// Obtiene color según estado de reporte
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
      case 'borrador':
        return statusDraft;
      case 'pending':
      case 'pendiente':
        return statusPending;
      case 'sent':
      case 'enviado':
        return statusSent;
      case 'error':
        return statusError;
      case 'syncing':
      case 'sincronizando':
        return statusSyncing;
      default:
        return statusDraft;
    }
  }

  /// Obtiene color según tipo de conectividad
  static Color getConnectionColor(bool isOnline, {bool isLimited = false}) {
    if (isOnline) {
      return isLimited ? connectionLimited : connectionOnline;
    }
    return connectionOffline;
  }
}

// - static const Color kError = Colors.red;
// - static const Color kWarning = Colors.orange;
// - static const Color kOffline = Colors.grey;
// - static const Color kSyncing = Colors.blue;
// - Colores para severidad: kCritical, kHigh, kMedium, kLow
