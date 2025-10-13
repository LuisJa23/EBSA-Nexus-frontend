// failures.dart
//
// Definición de tipos de fallas para manejo de errores funcional
//
// PROPÓSITO:
// - Implementar patrón Either<Failure, Success>
// - Definir jerarquía de fallas tipadas
// - Evitar exceptions no controladas
// - Facilitar testing y debugging

import 'package:equatable/equatable.dart';

/// Clase base abstracta para todos los tipos de fallas
/// Utiliza Equatable para comparación eficiente
abstract class Failure extends Equatable {
  /// Mensaje descriptivo del error
  final String message;

  /// Código de error opcional para manejo específico
  final String? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

// ============================================================================
// FALLAS DE RED Y SERVIDOR
// ============================================================================

/// Falla relacionada con problemas del servidor
class ServerFailure extends Failure {
  /// Código de estado HTTP
  final int? statusCode;

  const ServerFailure({required super.message, this.statusCode, super.code});

  @override
  List<Object?> get props => [message, code, statusCode];
}

/// Falla de conexión de red
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Error de conexión a internet',
    super.code,
  });
}

/// Falla de timeout de conexión
class TimeoutFailure extends Failure {
  const TimeoutFailure({
    super.message = 'Tiempo de espera agotado',
    super.code,
  });
}

// ============================================================================
// FALLAS DE AUTENTICACIÓN
// ============================================================================

/// Falla de autenticación
class AuthFailure extends Failure {
  const AuthFailure({super.message = 'Error de autenticación', super.code});
}

/// Falla de autorización (permisos)
class AuthorizationFailure extends Failure {
  const AuthorizationFailure({
    super.message = 'No tiene permisos para realizar esta acción',
    super.code,
  });
}

/// Token expirado
class TokenExpiredFailure extends Failure {
  const TokenExpiredFailure({
    super.message = 'La sesión ha expirado. Inicie sesión nuevamente.',
    super.code,
  });
}

// ============================================================================
// FALLAS DE ALMACENAMIENTO LOCAL
// ============================================================================

/// Falla de cache/base de datos local
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Error al acceder al almacenamiento local',
    super.code,
  });
}

/// Falla de escritura en storage
class StorageFailure extends Failure {
  const StorageFailure({
    super.message = 'Error al guardar información',
    super.code,
  });
}

// ============================================================================
// FALLAS DE VALIDACIÓN
// ============================================================================

/// Falla de validación de datos
class ValidationFailure extends Failure {
  /// Campo que falló la validación
  final String? field;

  const ValidationFailure({required super.message, this.field, super.code});

  @override
  List<Object?> get props => [message, code, field];
}

/// Falla de formato de datos
class FormatFailure extends Failure {
  const FormatFailure({
    super.message = 'Formato de datos inválido',
    super.code,
  });
}

// ============================================================================
// FALLAS DE UBICACIÓN Y PERMISOS
// ============================================================================

/// Falla de geolocalización
class LocationFailure extends Failure {
  const LocationFailure({
    super.message = 'No se pudo obtener la ubicación',
    super.code,
  });
}

/// Falla de permisos
class PermissionFailure extends Failure {
  /// Tipo de permiso denegado
  final String? permissionType;

  const PermissionFailure({
    super.message = 'Permiso denegado',
    this.permissionType,
    super.code,
  });

  @override
  List<Object?> get props => [message, code, permissionType];
}

// ============================================================================
// FALLAS DE ARCHIVOS Y MULTIMEDIA
// ============================================================================

/// Falla de manejo de archivos
class FileFailure extends Failure {
  /// Ruta del archivo que causó el error
  final String? filePath;

  const FileFailure({
    super.message = 'Error al manejar archivo',
    this.filePath,
    super.code,
  });

  @override
  List<Object?> get props => [message, code, filePath];
}

/// Falla de carga de archivos
class UploadFailure extends Failure {
  const UploadFailure({super.message = 'Error al subir archivo', super.code});
}

// ============================================================================
// FALLAS GENÉRICAS
// ============================================================================

/// Falla desconocida o no categorizada
class UnknownFailure extends Failure {
  const UnknownFailure({super.message = 'Error inesperado', super.code});
}

/// Falla de operación no soportada
class UnsupportedFailure extends Failure {
  const UnsupportedFailure({
    super.message = 'Operación no soportada',
    super.code,
  });
}
// - class ValidationFailure extends Failure
// - class AuthenticationFailure extends Failure
// - class PermissionFailure extends Failure
// - class GPSFailure extends Failure
// - class StorageFailure extends Failure
// - Cada failure con mensaje descriptivo y código de error