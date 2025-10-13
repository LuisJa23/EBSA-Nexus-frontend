// extensions.dart
//
// Extensiones útiles para tipos de datos básicos
//
// PROPÓSITO:
// - Extender funcionalidad de String, DateTime, etc.
// - Facilitar operaciones comunes en la aplicación
// - Mejorar legibilidad del código
// - Añadir métodos específicos del dominio

import 'package:intl/intl.dart';

// ============================================================================
// EXTENSIONES PARA STRING
// ============================================================================

extension StringExtensions on String {
  /// Verifica si la cadena es un email válido
  bool get isValidEmail {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(this);
  }
  
  /// Verifica si la cadena está vacía o solo tiene espacios
  bool get isEmptyOrWhitespace {
    return trim().isEmpty;
  }
  
  /// Capitaliza la primera letra
  String get capitalized {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
  
  /// Capitaliza cada palabra
  String get titleCase {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalized).join(' ');
  }
  
  /// Trunca con elipsis si excede la longitud máxima
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - 3)}...';
  }
  
  /// Convierte a formato de archivo válido
  String get toValidFileName {
    return replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(' ', '_')
        .toLowerCase();
  }
  
  /// Remueve solo números
  String get digitsOnly {
    return replaceAll(RegExp(r'[^\d]'), '');
  }
  
  /// Verifica si es un número válido
  bool get isNumeric {
    return double.tryParse(this) != null;
  }
  
  /// Convierte a int de manera segura
  int? get toIntOrNull {
    return int.tryParse(this);
  }
  
  /// Convierte a double de manera segura
  double? get toDoubleOrNull {
    return double.tryParse(this);
  }
}

// ============================================================================
// EXTENSIONES PARA DATETIME
// ============================================================================

extension DateTimeExtensions on DateTime {
  /// Formatea como dd/MM/yyyy
  String get toDateString {
    return DateFormat('dd/MM/yyyy').format(this);
  }
  
  /// Formatea como HH:mm
  String get toTimeString {
    return DateFormat('HH:mm').format(this);
  }
  
  /// Formatea como dd/MM/yyyy HH:mm
  String get toDateTimeString {
    return DateFormat('dd/MM/yyyy HH:mm').format(this);
  }
  
  /// Verifica si es hoy
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
  
  /// Verifica si es ayer
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }
  
  /// Obtiene el inicio del día (00:00:00)
  DateTime get startOfDay {
    return DateTime(year, month, day);
  }
  
  /// Obtiene el fin del día (23:59:59)
  DateTime get endOfDay {
    return DateTime(year, month, day, 23, 59, 59, 999);
  }
  
  /// Tiempo transcurrido desde esta fecha
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);
    
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
}

// ============================================================================
// EXTENSIONES PARA LIST
// ============================================================================

extension ListExtensions<T> on List<T> {
  /// Verifica si la lista no es nula ni vacía
  bool get isNotNullOrEmpty {
    return isNotEmpty;
  }
  
  /// Obtiene elemento en índice de manera segura
  T? elementAtOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }
  
  /// Obtiene el primer elemento o null si está vacía
  T? get firstOrNull {
    return isEmpty ? null : first;
  }
  
  /// Obtiene el último elemento o null si está vacía
  T? get lastOrNull {
    return isEmpty ? null : last;
  }
}