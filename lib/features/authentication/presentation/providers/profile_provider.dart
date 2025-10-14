// profile_provider.dart
//
// Provider de estado para manejo del perfil de usuario
//
// PROPÓSITO:
// - Coordinar obtención y actualización de perfil
// - Manejar estados UI (loading, success, error)
// - Validar datos antes de enviar
// - Proporcionar feedback al usuario
//
// CAPA: PRESENTATION LAYER

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/dependency_injection/injection_container.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../domain/usecases/update_user_profile_usecase.dart';

/// Estados posibles del perfil
enum ProfileStatus {
  /// Estado inicial
  initial,

  /// Cargando datos del perfil
  loading,

  /// Perfil cargado exitosamente
  loaded,

  /// Actualizando perfil
  updating,

  /// Perfil actualizado exitosamente
  updated,

  /// Error en operación
  error,
}

/// Estado del perfil de usuario
@immutable
class ProfileState {
  /// Estado actual de la operación
  final ProfileStatus status;

  /// Usuario cargado
  final User? user;

  /// Mensaje de error (si existe)
  final String? errorMessage;

  /// Código de error (si existe)
  final String? errorCode;

  /// Campo específico con error (para validaciones)
  final String? errorField;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.user,
    this.errorMessage,
    this.errorCode,
    this.errorField,
  });

  /// Crea una copia con campos actualizados
  ProfileState copyWith({
    ProfileStatus? status,
    User? user,
    String? errorMessage,
    String? errorCode,
    String? errorField,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      errorCode: errorCode ?? this.errorCode,
      errorField: errorField ?? this.errorField,
    );
  }

  /// Estado de loading
  ProfileState toLoading() {
    return copyWith(
      status: ProfileStatus.loading,
      errorMessage: null,
      errorCode: null,
      errorField: null,
    );
  }

  /// Estado de updating
  ProfileState toUpdating() {
    return copyWith(
      status: ProfileStatus.updating,
      errorMessage: null,
      errorCode: null,
      errorField: null,
    );
  }

  /// Estado de loaded
  ProfileState toLoaded(User user) {
    return copyWith(
      status: ProfileStatus.loaded,
      user: user,
      errorMessage: null,
      errorCode: null,
      errorField: null,
    );
  }

  /// Estado de updated
  ProfileState toUpdated(User user) {
    return copyWith(
      status: ProfileStatus.updated,
      user: user,
      errorMessage: null,
      errorCode: null,
      errorField: null,
    );
  }

  /// Estado de error
  ProfileState toError({required String message, String? code, String? field}) {
    return copyWith(
      status: ProfileStatus.error,
      errorMessage: message,
      errorCode: code,
      errorField: field,
    );
  }
}

/// Notificador de estado del perfil
class ProfileNotifier extends StateNotifier<ProfileState> {
  final GetUserProfileUseCase _getUserProfileUseCase;
  final UpdateUserProfileUseCase _updateUserProfileUseCase;

  ProfileNotifier({
    required GetUserProfileUseCase getUserProfileUseCase,
    required UpdateUserProfileUseCase updateUserProfileUseCase,
  }) : _getUserProfileUseCase = getUserProfileUseCase,
       _updateUserProfileUseCase = updateUserProfileUseCase,
       super(const ProfileState());

  /// Carga el perfil del usuario actual
  Future<void> loadUserProfile() async {
    state = state.toLoading();

    final result = await _getUserProfileUseCase.call();

    result.fold(
      (failure) {
        state = state.toError(message: failure.message, code: failure.code);
      },
      (user) {
        state = state.toLoaded(user);
      },
    );
  }

  /// Actualiza el perfil del usuario
  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    state = state.toUpdating();

    final params = UpdateProfileParams(
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      phone: phone.trim(),
    );

    final result = await _updateUserProfileUseCase.call(params);

    return result.fold(
      (failure) {
        state = state.toError(
          message: failure.message,
          code: failure.code,
          field: failure is ValidationFailure ? failure.field : null,
        );
        return false;
      },
      (user) {
        state = state.toUpdated(user);
        return true;
      },
    );
  }

  /// Refresca el perfil desde el servidor
  Future<void> refreshProfile() async {
    await loadUserProfile();
  }

  /// Limpia el estado de error
  void clearError() {
    if (state.status == ProfileStatus.error) {
      state = state.copyWith(
        status: ProfileStatus.loaded,
        errorMessage: null,
        errorCode: null,
        errorField: null,
      );
    }
  }

  /// Limpia el estado de "updated" después de mostrar el mensaje
  void clearUpdatedStatus() {
    if (state.status == ProfileStatus.updated) {
      state = state.copyWith(status: ProfileStatus.loaded);
    }
  }
}

// ============================================================================
// PROVIDERS
// ============================================================================

/// Provider del notificador de perfil
///
/// **IMPORTANTE**: Obtiene las dependencias del Service Locator (get_it)
final profileProvider =
    StateNotifierProvider.autoDispose<ProfileNotifier, ProfileState>((ref) {
      return ProfileNotifier(
        getUserProfileUseCase: sl<GetUserProfileUseCase>(),
        updateUserProfileUseCase: sl<UpdateUserProfileUseCase>(),
      );
    });
