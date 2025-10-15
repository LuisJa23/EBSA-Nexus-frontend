// create_user_state.dart
//
// Estados del formulario de creación de usuarios
//
// PROPÓSITO:
// - Representar todos los estados posibles del formulario
// - Manejar validaciones y errores
// - Facilitar manejo de UI reactiva
//
// CAPA: PRESENTATION LAYER

import 'package:equatable/equatable.dart';

import '../../../authentication/domain/entities/user.dart';

/// Estados del formulario de creación de usuarios
enum CreateUserStatus { initial, loading, success, error }

/// Estado del formulario de creación
class CreateUserState extends Equatable {
  /// Estado actual del formulario
  final CreateUserStatus status;

  /// Usuario creado (en caso de éxito)
  final User? createdUser;

  /// Mensaje de error general
  final String? errorMessage;

  /// Errores de validación por campo
  final Map<String, String> fieldErrors;

  /// Errores del servidor (duplicados, etc.)
  final Map<String, String> serverErrors;

  /// Datos del formulario (persistir entre navegaciones)
  final Map<String, dynamic> formData;

  const CreateUserState({
    required this.status,
    this.createdUser,
    this.errorMessage,
    this.fieldErrors = const {},
    this.serverErrors = const {},
    this.formData = const {},
  });

  /// Estado inicial
  factory CreateUserState.initial() {
    return const CreateUserState(status: CreateUserStatus.initial);
  }

  /// Estado de carga
  CreateUserState copyWithLoading({Map<String, dynamic>? formData}) {
    return CreateUserState(
      status: CreateUserStatus.loading,
      formData: formData ?? this.formData,
    );
  }

  /// Estado de éxito
  CreateUserState copyWithSuccess(User user) {
    return CreateUserState(
      status: CreateUserStatus.success,
      createdUser: user,
      // Limpiar datos del formulario tras éxito
      formData: const {},
    );
  }

  /// Estado de error (mantiene datos del formulario)
  CreateUserState copyWithError({
    String? errorMessage,
    Map<String, String>? fieldErrors,
    Map<String, String>? serverErrors,
    Map<String, dynamic>? formData,
  }) {
    return CreateUserState(
      status: CreateUserStatus.error,
      errorMessage: errorMessage,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      serverErrors: serverErrors ?? this.serverErrors,
      // IMPORTANTE: Mantener datos del formulario
      formData: formData ?? this.formData,
    );
  }

  /// Limpiar solo errores (mantiene datos del formulario)
  CreateUserState copyWithClearedErrors() {
    return CreateUserState(
      status: CreateUserStatus.initial,
      fieldErrors: const {},
      serverErrors: const {},
      // Mantener datos del formulario
      formData: formData,
    );
  }

  /// Verifica si hay errores
  bool get hasErrors =>
      fieldErrors.isNotEmpty || serverErrors.isNotEmpty || errorMessage != null;

  /// Verifica si está cargando
  bool get isLoading => status == CreateUserStatus.loading;

  /// Verifica si fue exitoso
  bool get isSuccess => status == CreateUserStatus.success;

  /// Obtiene error de un campo específico
  String? getFieldError(String fieldName) {
    return serverErrors[fieldName] ?? fieldErrors[fieldName];
  }

  @override
  List<Object?> get props => [
    status,
    createdUser,
    errorMessage,
    fieldErrors,
    serverErrors,
    formData,
  ];
}
