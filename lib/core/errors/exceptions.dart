// exceptions.dart
//
// Excepciones personalizadas para la capa de datos
//
// PROPÓSITO:
// - Definir excepciones específicas del dominio
// - Mapear errores de servicios externos a excepciones internas
// - Facilitar conversión de exceptions a failures
// - Debugging y logging detallado

/// Clase base para excepciones personalizadas
abstract class BaseException implements Exception {
  /// Mensaje descriptivo del error
  final String message;

  /// Código de error opcional
  final String? code;

  const BaseException({required this.message, this.code});

  @override
  String toString() =>
      'Exception: $message${code != null ? ' (Code: $code)' : ''}';
}

// ============================================================================
// EXCEPCIONES DE RED Y SERVIDOR
// ============================================================================

/// Excepción relacionada con errores del servidor
class ServerException extends BaseException {
  /// Código de estado HTTP
  final int? statusCode;

  /// Respuesta del servidor
  final Map<String, dynamic>? response;

  const ServerException({
    required String message,
    this.statusCode,
    this.response,
    String? code,
  }) : super(message: message, code: code);

  @override
  String toString() =>
      'ServerException: $message (Status: $statusCode)${code != null ? ' (Code: $code)' : ''}';
}

/// Excepción de conexión de red
class NetworkException extends BaseException {
  const NetworkException({
    String message = 'Network connection failed',
    String? code,
  }) : super(message: message, code: code);
}

/// Excepción de timeout
class TimeoutException extends BaseException {
  /// Duración del timeout en milisegundos
  final int? timeoutDuration;

  const TimeoutException({
    String message = 'Request timeout',
    this.timeoutDuration,
    String? code,
  }) : super(message: message, code: code);

  @override
  String toString() =>
      'TimeoutException: $message${timeoutDuration != null ? ' (${timeoutDuration}ms)' : ''}';
}

// ============================================================================
// EXCEPCIONES DE AUTENTICACIÓN
// ============================================================================

/// Excepción de autenticación
class AuthenticationException extends BaseException {
  const AuthenticationException({
    String message = 'Authentication failed',
    String? code,
  }) : super(message: message, code: code);
}

/// Excepción de autorización
class AuthorizationException extends BaseException {
  const AuthorizationException({
    String message = 'Authorization failed',
    String? code,
  }) : super(message: message, code: code);
}

/// Excepción de token inválido o expirado
class TokenException extends BaseException {
  /// Indica si el token ha expirado
  final bool isExpired;

  const TokenException({
    String message = 'Token is invalid',
    this.isExpired = false,
    String? code,
  }) : super(message: message, code: code);

  @override
  String toString() =>
      'TokenException: $message${isExpired ? ' (Expired)' : ''}';
}

// ============================================================================
// EXCEPCIONES DE ALMACENAMIENTO LOCAL
// ============================================================================

/// Excepción de cache/base de datos local
class CacheException extends BaseException {
  /// Operación que falló
  final String? operation;

  const CacheException({
    String message = 'Cache operation failed',
    this.operation,
    String? code,
  }) : super(message: message, code: code);

  @override
  String toString() =>
      'CacheException: $message${operation != null ? ' (Operation: $operation)' : ''}';
}

/// Excepción de storage seguro
class SecureStorageException extends BaseException {
  const SecureStorageException({
    String message = 'Secure storage operation failed',
    String? code,
  }) : super(message: message, code: code);
}

// ============================================================================
// EXCEPCIONES DE VALIDACIÓN
// ============================================================================

/// Excepción de validación de datos
class ValidationException extends BaseException {
  /// Campo que falló la validación
  final String? field;

  /// Lista de errores de validación
  final List<String>? errors;

  const ValidationException({
    String message = 'Validation failed',
    this.field,
    this.errors,
    String? code,
  }) : super(message: message, code: code);

  @override
  String toString() =>
      'ValidationException: $message${field != null ? ' (Field: $field)' : ''}';
}

/// Excepción de parsing/formato
class ParseException extends BaseException {
  /// Tipo de dato que se intentaba parsear
  final String? dataType;

  const ParseException({
    String message = 'Parse operation failed',
    this.dataType,
    String? code,
  }) : super(message: message, code: code);

  @override
  String toString() =>
      'ParseException: $message${dataType != null ? ' (Type: $dataType)' : ''}';
}

// ============================================================================
// EXCEPCIONES DE UBICACIÓN Y PERMISOS
// ============================================================================

/// Excepción de servicios de ubicación
class LocationException extends BaseException {
  /// Tipo específico de error de ubicación
  final String? locationType;

  const LocationException({
    String message = 'Location service failed',
    this.locationType,
    String? code,
  }) : super(message: message, code: code);

  @override
  String toString() =>
      'LocationException: $message${locationType != null ? ' (Type: $locationType)' : ''}';
}

/// Excepción de permisos
class PermissionException extends BaseException {
  /// Tipo de permiso denegado
  final String? permissionType;

  const PermissionException({
    String message = 'Permission denied',
    this.permissionType,
    String? code,
  }) : super(message: message, code: code);

  @override
  String toString() =>
      'PermissionException: $message${permissionType != null ? ' (Permission: $permissionType)' : ''}';
}

// ============================================================================
// EXCEPCIONES DE ARCHIVOS Y MULTIMEDIA
// ============================================================================

/// Excepción de manejo de archivos
class FileException extends BaseException {
  /// Ruta del archivo
  final String? filePath;

  /// Operación que falló
  final String? operation;

  const FileException({
    String message = 'File operation failed',
    this.filePath,
    this.operation,
    String? code,
  }) : super(message: message, code: code);

  @override
  String toString() =>
      'FileException: $message${filePath != null ? ' (File: $filePath)' : ''}';
}

/// Excepción de carga/descarga
class UploadException extends BaseException {
  /// Tamaño del archivo en bytes
  final int? fileSize;

  const UploadException({
    String message = 'Upload failed',
    this.fileSize,
    String? code,
  }) : super(message: message, code: code);

  @override
  String toString() =>
      'UploadException: $message${fileSize != null ? ' (Size: ${fileSize}B)' : ''}';
}

// - class ValidationException implements Exception
// - class PermissionException implements Exception
// - class GPSException implements Exception
// - class FileException implements Exception
// - Cada excepción con mensaje y código de error opcional
