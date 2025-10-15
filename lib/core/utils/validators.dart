// validators.dart
//
// Validadores para formularios y datos de entrada
//
// PROPÓSITO:
// - Validar campos de formularios de reportes
// - Validar datos antes de envío a API
// - Validar formato de archivos multimedia
// - Validar coordenadas GPS y rangos

import '../constants/app_constants.dart';

/// Clase utilitaria con validadores estáticos para formularios
class Validators {
  // ============================================================================
  // VALIDADORES DE AUTENTICACIÓN
  // ============================================================================

  /// Valida formato de email
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'El email es requerido';
    }

    if (!RegExp(AppConstants.emailPattern).hasMatch(email)) {
      return 'Ingrese un email válido';
    }

    return null;
  }

  /// Valida contraseña
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'La contraseña es requerida';
    }

    if (password.length < AppConstants.minPasswordLength) {
      return 'La contraseña debe tener al menos ${AppConstants.minPasswordLength} caracteres';
    }

    if (password.length > AppConstants.maxPasswordLength) {
      return 'La contraseña no puede exceder ${AppConstants.maxPasswordLength} caracteres';
    }

    return null;
  }

  /// Valida confirmación de contraseña
  static String? validatePasswordConfirmation(
    String? password,
    String? confirmation,
  ) {
    if (confirmation == null || confirmation.isEmpty) {
      return 'Confirme su contraseña';
    }

    if (password != confirmation) {
      return 'Las contraseñas no coinciden';
    }

    return null;
  }

  // ============================================================================
  // VALIDADORES DE DATOS PERSONALES
  // ============================================================================

  /// Valida nombres y apellidos
  static String? validateName(String? name, {String fieldName = 'Nombre'}) {
    if (name == null || name.isEmpty) {
      return '$fieldName es requerido';
    }

    if (name.trim().length < AppConstants.minNameLength) {
      return '$fieldName debe tener al menos ${AppConstants.minNameLength} caracteres';
    }

    if (name.length > AppConstants.maxNameLength) {
      return '$fieldName no puede exceder ${AppConstants.maxNameLength} caracteres';
    }

    // Solo letras, espacios, tildes y ñ
    if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(name)) {
      return '$fieldName solo puede contener letras';
    }

    return null;
  }

  /// Valida número de teléfono colombiano
  static String? validatePhone(String? phone) {
    if (phone == null || phone.isEmpty) {
      return 'El teléfono es requerido';
    }

    if (!RegExp(AppConstants.phonePattern).hasMatch(phone)) {
      return 'Ingrese un número de teléfono válido';
    }

    return null;
  }

  // ============================================================================
  // VALIDADORES DE REPORTES
  // ============================================================================

  /// Valida título de reporte
  static String? validateReportTitle(String? title) {
    if (title == null || title.isEmpty) {
      return 'El título es requerido';
    }

    if (title.trim().length < 3) {
      return 'El título debe tener al menos 3 caracteres';
    }

    if (title.length > 100) {
      return 'El título no puede exceder 100 caracteres';
    }

    return null;
  }

  /// Valida descripción de reporte
  static String? validateReportDescription(String? description) {
    if (description == null || description.isEmpty) {
      return 'La descripción es requerida';
    }

    if (description.trim().length < 10) {
      return 'La descripción debe tener al menos 10 caracteres';
    }

    if (description.length > AppConstants.maxDescriptionLength) {
      return 'La descripción no puede exceder ${AppConstants.maxDescriptionLength} caracteres';
    }

    return null;
  }

  /// Valida que se haya seleccionado un tipo de incidente
  static String? validateIncidentType(String? incidentType) {
    if (incidentType == null || incidentType.isEmpty) {
      return 'Debe seleccionar un tipo de incidente';
    }

    return null;
  }

  // ============================================================================
  // VALIDADORES DE ARCHIVOS Y MULTIMEDIA
  // ============================================================================

  /// Valida extensión de archivo
  static bool isValidFileExtension(
    String fileName,
    List<String> allowedExtensions,
  ) {
    final extension = fileName.split('.').last.toLowerCase();
    return allowedExtensions.contains(extension);
  }

  /// Valida que sea una imagen
  static String? validateImageFile(String? filePath) {
    if (filePath == null || filePath.isEmpty) {
      return 'Debe seleccionar una imagen';
    }

    if (!isValidFileExtension(filePath, AppConstants.allowedImageFormats)) {
      return 'Formato de imagen no válido. Use: ${AppConstants.allowedImageFormats.join(', ')}';
    }

    return null;
  }

  /// Valida tamaño de archivo en MB
  static String? validateFileSize(int fileSizeBytes, int maxSizeMB) {
    final fileSizeMB = fileSizeBytes / (1024 * 1024);

    if (fileSizeMB > maxSizeMB) {
      return 'El archivo no puede exceder ${maxSizeMB}MB (actual: ${fileSizeMB.toStringAsFixed(2)}MB)';
    }

    return null;
  }

  // ============================================================================
  // VALIDADORES DE UBICACIÓN
  // ============================================================================

  /// Valida coordenadas de latitud
  static String? validateLatitude(double? latitude) {
    if (latitude == null) {
      return 'Latitud es requerida';
    }

    if (latitude < -90 || latitude > 90) {
      return 'Latitud debe estar entre -90 y 90 grados';
    }

    return null;
  }

  /// Valida coordenadas de longitud
  static String? validateLongitude(double? longitude) {
    if (longitude == null) {
      return 'Longitud es requerida';
    }

    if (longitude < -180 || longitude > 180) {
      return 'Longitud debe estar entre -180 y 180 grados';
    }

    return null;
  }

  /// Valida precisión de GPS
  static String? validateGpsAccuracy(double? accuracy) {
    if (accuracy == null) {
      return 'Precisión GPS requerida';
    }

    if (accuracy > AppConstants.minGpsAccuracy) {
      return 'Precisión GPS insuficiente (${accuracy.toStringAsFixed(2)}m). Requerido: ${AppConstants.minGpsAccuracy}m';
    }

    return null;
  }

  // ============================================================================
  // VALIDADORES GENÉRICOS
  // ============================================================================

  /// Valida que un campo no esté vacío
  static String? validateRequired(String? value, {String fieldName = 'Campo'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es requerido';
    }

    return null;
  }

  /// Valida longitud mínima y máxima
  static String? validateLength(
    String? value,
    int min,
    int max, {
    String fieldName = 'Campo',
  }) {
    if (value == null || value.isEmpty) {
      return '$fieldName es requerido';
    }

    if (value.length < min) {
      return '$fieldName debe tener al menos $min caracteres';
    }

    if (value.length > max) {
      return '$fieldName no puede exceder $max caracteres';
    }

    return null;
  }

  /// Valida que un valor esté en una lista de opciones
  static String? validateInList(
    String? value,
    List<String> options, {
    String fieldName = 'Campo',
  }) {
    if (value == null || value.isEmpty) {
      return '$fieldName es requerido';
    }

    if (!options.contains(value)) {
      return '$fieldName debe ser uno de: ${options.join(', ')}';
    }

    return null;
  }

  /// Valida formato de URL
  static String? validateUrl(String? url) {
    if (url == null || url.isEmpty) {
      return 'URL es requerida';
    }

    final uri = Uri.tryParse(url);
    if (uri == null || !uri.isAbsolute) {
      return 'Formato de URL inválido';
    }

    return null;
  }

  // ============================================================================
  // UTILIDADES DE TEXTO
  // ============================================================================

  /// Normaliza una cadena removiendo acentos y caracteres especiales
  ///
  /// Útil para enviar datos al backend que no acepta caracteres con tildes.
  ///
  /// Ejemplos:
  /// - "Coordinación de distribución" → "Coordinacion de distribucion"
  /// - "Administración" → "Administracion"
  /// - "José Pérez" → "Jose Perez"
  static String normalizeAccents(String text) {
    const accents = {
      'á': 'a',
      'é': 'e',
      'í': 'i',
      'ó': 'o',
      'ú': 'u',
      'Á': 'A',
      'É': 'E',
      'Í': 'I',
      'Ó': 'O',
      'Ú': 'U',
      'ñ': 'n',
      'Ñ': 'N',
      'ü': 'u',
      'Ü': 'U',
    };

    var normalized = text;
    accents.forEach((accented, normalized_char) {
      normalized = normalized.replaceAll(accented, normalized_char);
    });

    return normalized;
  }
}

// - static String? validateDescription(String? description)
// - static bool isValidGPSCoordinate(double? lat, double? lng)
// - static bool isValidFileSize(int sizeInBytes)
// - static bool isValidImageFormat(String extension)
// - static bool isValidAudioFormat(String extension)
// - RegExp patterns para validaciones complejas
