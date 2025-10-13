// formatters.dart
//
// Formateadores para mostrar datos en la UI
//
// PROPÓSITO:
// - Formatear fechas y horas en español
// - Formatear coordenadas GPS
// - Formatear tamaños de archivos
// - Formatear estados de reportes
// - Formatear números de teléfono

import 'package:intl/intl.dart';

/// Clase utilitaria con formateadores estáticos para presentación de datos
class Formatters {
  // ============================================================================
  // FORMATEADORES DE FECHA Y HORA
  // ============================================================================

  /// Formatea fecha y hora completa (dd/MM/yyyy HH:mm:ss)
  static String formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('dd/MM/yyyy HH:mm:ss');
    return formatter.format(dateTime);
  }

  /// Formatea solo la fecha (dd/MM/yyyy)
  static String formatDate(DateTime dateTime) {
    final formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(dateTime);
  }

  /// Formatea solo la hora (HH:mm)
  static String formatTime(DateTime dateTime) {
    final formatter = DateFormat('HH:mm');
    return formatter.format(dateTime);
  }

  /// Formatea fecha para mostrar relativa (hace X tiempo)
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return 'hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'hace unos momentos';
    }
  }

  /// Formatea timestamp para nombre de archivo (yyyyMMdd_HHmmss)
  static String formatTimestampForFile(DateTime dateTime) {
    final formatter = DateFormat('yyyyMMdd_HHmmss');
    return formatter.format(dateTime);
  }

  // ============================================================================
  // FORMATEADORES DE ARCHIVOS Y TAMAÑOS
  // ============================================================================

  /// Formatea tamaño de archivo en bytes a formato legible
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      final kb = bytes / 1024;
      return '${kb.toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      final mb = bytes / (1024 * 1024);
      return '${mb.toStringAsFixed(1)} MB';
    } else {
      final gb = bytes / (1024 * 1024 * 1024);
      return '${gb.toStringAsFixed(1)} GB';
    }
  }

  /// Formatea duración en milisegundos a formato legible
  static String formatDuration(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);

    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m ${duration.inSeconds % 60}s';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  // ============================================================================
  // FORMATEADORES DE UBICACIÓN
  // ============================================================================

  /// Formatea coordenadas GPS (lat, lng) con precisión
  static String formatCoordinates(
    double latitude,
    double longitude, {
    int precision = 6,
  }) {
    return '${latitude.toStringAsFixed(precision)}, ${longitude.toStringAsFixed(precision)}';
  }

  /// Formatea coordenadas GPS para mostrar en UI
  static String formatCoordinatesDisplay(double latitude, double longitude) {
    final latDirection = latitude >= 0 ? 'N' : 'S';
    final lngDirection = longitude >= 0 ? 'E' : 'W';

    return '${latitude.abs().toStringAsFixed(6)}°$latDirection, ${longitude.abs().toStringAsFixed(6)}°$lngDirection';
  }

  /// Formatea precisión GPS
  static String formatAccuracy(double accuracy) {
    if (accuracy < 1) {
      return '${(accuracy * 100).toStringAsFixed(0)} cm';
    } else {
      return '${accuracy.toStringAsFixed(1)} m';
    }
  }

  // ============================================================================
  // FORMATEADORES DE IDENTIFICADORES
  // ============================================================================

  /// Formatea ID de reporte con prefijo y padding
  static String formatReportId(String reportId) {
    // Asume que el ID es un número, lo formatea como RPT-000001
    if (int.tryParse(reportId) != null) {
      final numericId = int.parse(reportId);
      return 'RPT-${numericId.toString().padLeft(6, '0')}';
    }
    return 'RPT-$reportId';
  }

  /// Formatea UUID a formato corto para mostrar
  static String formatUuidShort(String uuid) {
    if (uuid.length >= 8) {
      return uuid.substring(0, 8).toUpperCase();
    }
    return uuid.toUpperCase();
  }

  // ============================================================================
  // FORMATEADORES DE TEXTO
  // ============================================================================

  /// Capitaliza la primera letra de cada palabra
  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;

    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  /// Trunca texto con elipsis
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - 3)}...';
  }

  /// Formatea número de teléfono colombiano
  static String formatPhoneNumber(String phone) {
    // Remueve caracteres no numéricos
    final numbers = phone.replaceAll(RegExp(r'[^\d]'), '');

    if (numbers.length == 10) {
      // Formato: (XXX) XXX-XXXX
      return '(${numbers.substring(0, 3)}) ${numbers.substring(3, 6)}-${numbers.substring(6)}';
    } else if (numbers.length == 7) {
      // Formato: XXX-XXXX
      return '${numbers.substring(0, 3)}-${numbers.substring(3)}';
    }

    return phone; // Retorna original si no coincide con formato esperado
  }
}

// - Configuración de locale en español
