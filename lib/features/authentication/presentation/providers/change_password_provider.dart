// change_password_provider.dart
//
// Provider para manejar el cambio de contraseña
//
// PROPÓSITO:
// - Gestionar estado del cambio de contraseña
// - Coordinar use case con UI
// - Proporcionar feedback claro
//
// CAPA: PRESENTATION LAYER

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/usecases/change_password_usecase.dart';
import '../../../../config/dependency_injection/injection_container.dart';

/// Estados posibles del cambio de contraseña
enum ChangePasswordStatus {
  /// Estado inicial
  initial,

  /// Procesando cambio
  loading,

  /// Cambio exitoso
  success,

  /// Error al cambiar
  error,
}

/// Estado del cambio de contraseña
class ChangePasswordState {
  final ChangePasswordStatus status;
  final String? errorMessage;
  final String? errorCode;

  const ChangePasswordState({
    this.status = ChangePasswordStatus.initial,
    this.errorMessage,
    this.errorCode,
  });

  ChangePasswordState copyWith({
    ChangePasswordStatus? status,
    String? errorMessage,
    String? errorCode,
  }) {
    return ChangePasswordState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      errorCode: errorCode ?? this.errorCode,
    );
  }

  ChangePasswordState toLoading() {
    return const ChangePasswordState(status: ChangePasswordStatus.loading);
  }

  ChangePasswordState toSuccess() {
    return const ChangePasswordState(status: ChangePasswordStatus.success);
  }

  ChangePasswordState toError(String message, {String? code}) {
    return ChangePasswordState(
      status: ChangePasswordStatus.error,
      errorMessage: message,
      errorCode: code,
    );
  }

  ChangePasswordState toInitial() {
    return const ChangePasswordState(status: ChangePasswordStatus.initial);
  }
}

/// Notifier para manejar el cambio de contraseña
class ChangePasswordNotifier extends StateNotifier<ChangePasswordState> {
  final ChangePasswordUseCase _changePasswordUseCase;

  ChangePasswordNotifier(this._changePasswordUseCase)
    : super(const ChangePasswordState());

  /// Cambia la contraseña del usuario
  ///
  /// **Retorna**: Either con Failure o void
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    // Cambiar a estado de carga
    state = state.toLoading();

    // Ejecutar caso de uso
    final result = await _changePasswordUseCase.execute(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );

    // Actualizar estado según resultado
    result.fold(
      (failure) {
        state = state.toError(
          _mapFailureMessage(failure),
          code: _mapFailureCode(failure),
        );
      },
      (_) {
        state = state.toSuccess();
      },
    );

    return result;
  }

  /// Resetea el estado a inicial
  void reset() {
    state = state.toInitial();
  }

  /// Mapea failures a mensajes amigables
  String _mapFailureMessage(Failure failure) {
    if (failure is ValidationFailure) {
      return failure.message;
    }

    if (failure is AuthFailure) {
      // Mapear mensajes específicos de autenticación
      if (failure.code == 'INVALID_CURRENT_PASSWORD') {
        return 'La contraseña actual es incorrecta';
      }
      return failure.message;
    }

    if (failure is NetworkFailure) {
      return 'Sin conexión a internet. Por favor, verifica tu conexión.';
    }

    if (failure is ServerFailure) {
      return 'Error del servidor. Por favor, intenta más tarde.';
    }

    return 'Error desconocido. Por favor, intenta nuevamente.';
  }

  /// Mapea failures a códigos de error
  String? _mapFailureCode(Failure failure) {
    if (failure is ValidationFailure) {
      return failure.code;
    }
    if (failure is AuthFailure) {
      return failure.code;
    }
    if (failure is NetworkFailure) {
      return failure.code;
    }
    if (failure is ServerFailure) {
      return failure.code;
    }
    return null;
  }
}

/// Provider para el cambio de contraseña
final changePasswordProvider =
    StateNotifierProvider<ChangePasswordNotifier, ChangePasswordState>((ref) {
      return ChangePasswordNotifier(sl<ChangePasswordUseCase>());
    });
