// user_error_response_model.dart
//
// Modelo de respuesta de errores de la API
//
// PROPÓSITO:
// - Parsear errores 400 de la API de creación de usuarios
// - Manejar campos duplicados (username, email, documento, teléfono)
// - Facilitar manejo de errores en la UI
//
// CAPA: DATA LAYER

import 'package:equatable/equatable.dart';

/// Modelo de respuesta de error de la API
///
/// Estructura de error 400 cuando hay campos duplicados:
/// ```json
/// {
///   "code": "DUPLICATE_FIELDS",
///   "message": "Se encontraron múltiples campos duplicados",
///   "validationErrors": {
///     "teléfono": "Ya existe un usuario con este teléfono",
///     "documento": "Ya existe un usuario con este número de documento",
///     "email": "Ya existe un usuario con este email",
///     "username": "Ya existe un usuario con este username"
///   },
///   "timestamp": "2025-10-15T00:10:19.240053675"
/// }
/// ```
class UserErrorResponseModel extends Equatable {
  /// Código del error
  final String code;

  /// Mensaje general del error
  final String message;

  /// Errores de validación específicos por campo
  final Map<String, String> validationErrors;

  /// Timestamp del error
  final String? timestamp;

  const UserErrorResponseModel({
    required this.code,
    required this.message,
    required this.validationErrors,
    this.timestamp,
  });

  /// Factory desde JSON de la API
  factory UserErrorResponseModel.fromJson(Map<String, dynamic> json) {
    return UserErrorResponseModel(
      code: json['code'] as String? ?? 'UNKNOWN_ERROR',
      message: json['message'] as String? ?? 'Error desconocido',
      validationErrors: _parseValidationErrors(json['validationErrors']),
      timestamp: json['timestamp'] as String?,
    );
  }

  /// Parsea los errores de validación del JSON
  static Map<String, String> _parseValidationErrors(dynamic errors) {
    if (errors == null) return {};
    if (errors is! Map) return {};

    final result = <String, String>{};
    errors.forEach((key, value) {
      result[_normalizeFieldName(key.toString())] = value.toString();
    });

    return result;
  }

  /// Normaliza nombres de campos para coincidir con los del formulario
  static String _normalizeFieldName(String fieldName) {
    final mapping = {
      'teléfono': 'phone',
      'telefono': 'phone',
      'documento': 'documentNumber',
      'email': 'email',
      'username': 'username',
      'nombre': 'firstName',
      'apellido': 'lastName',
    };

    return mapping[fieldName.toLowerCase()] ?? fieldName;
  }

  /// Verifica si hay errores de campos duplicados
  bool get hasDuplicateFieldsError => code == 'DUPLICATE_FIELDS';

  /// Obtiene el error para un campo específico
  String? getErrorForField(String fieldName) {
    return validationErrors[fieldName];
  }

  /// Obtiene todos los campos con errores
  List<String> get fieldsWithErrors => validationErrors.keys.toList();

  @override
  List<Object?> get props => [code, message, validationErrors, timestamp];

  @override
  String toString() {
    return 'UserErrorResponseModel(code: $code, message: $message, errors: ${validationErrors.length})';
  }
}
