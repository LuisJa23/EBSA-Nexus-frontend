// create_user_provider.dart
//
// Provider para lógica de creación de usuarios
//
// PROPÓSITO:
// - Gestionar estado del formulario
// - Validar campos en tiempo real
// - Ejecutar creación de usuario
// - Manejar errores
//
// CAPA: PRESENTATION LAYER

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/dependency_injection/injection_container.dart' as di;
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_creation_dto.dart';
import '../../domain/usecases/create_user_usecase.dart';
import '../state/create_user_state.dart';

/// Provider del use case desde DI
final createUserUseCaseProvider = Provider<CreateUserUseCase>((ref) {
  return di.sl<CreateUserUseCase>();
});

/// Provider del StateNotifier de creación de usuarios
final createUserProvider =
    StateNotifierProvider<CreateUserNotifier, CreateUserState>((ref) {
      final createUserUseCase = ref.watch(createUserUseCaseProvider);
      return CreateUserNotifier(createUserUseCase);
    });

/// StateNotifier para gestionar el formulario de creación
class CreateUserNotifier extends StateNotifier<CreateUserState> {
  final CreateUserUseCase _createUserUseCase;

  CreateUserNotifier(this._createUserUseCase)
    : super(CreateUserState.initial());

  /// Crea un nuevo usuario
  Future<void> createUser({
    required String firstName,
    required String lastName,
    required String email,
    required String documentNumber,
    required String phone,
    required String username,
    required String roleName,
    String? workType,
    String? workRoleName,
  }) async {
    print('🔵 [CreateUserProvider] Iniciando creación de usuario...');
    print('   firstName: $firstName');
    print('   lastName: $lastName');
    print('   email: $email');
    print('   roleName: $roleName');
    print('   workType: $workType');
    print('   workRoleName: $workRoleName');

    // Guardar datos del formulario para persistirlos
    final formData = {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'documentNumber': documentNumber,
      'phone': phone,
      'username': username,
      'roleName': roleName,
      'workType': workType,
      'workRoleName': workRoleName,
    };

    // Cambiar a loading Y limpiar errores previos (nueva petición)
    state = state.copyWithLoading(formData: formData);
    print('🔵 [CreateUserProvider] Estado cambiado a loading');

    // Crear DTO
    final dto = UserCreationDto.fromForm(
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      email: email.trim(),
      documentNumber: documentNumber.trim(),
      phone: phone.trim(),
      username: username.trim(),
      roleName: roleName,
      workType: workType,
      workRoleName: workRoleName,
    );
    print('🔵 [CreateUserProvider] DTO creado: $dto');

    // Ejecutar use case
    print('🔵 [CreateUserProvider] Llamando al use case...');
    final result = await _createUserUseCase(dto);

    result.fold(
      (failure) {
        print('❌ [CreateUserProvider] Error recibido: ${failure.message}');
        print('   Tipo de failure: ${failure.runtimeType}');
        
        // Extraer errores de campos del servidor
        final serverErrors = _extractServerErrors(failure);
        print('   Errores de campos: $serverErrors');

        // Si hay errores específicos de campos, NO mostrar mensaje general
        // Solo mostrar mensaje general si:
        // 1. NO hay errores de campos Y
        // 2. El mensaje del failure no está vacío
        final shouldShowGeneralError =
            serverErrors.isEmpty && failure.message.isNotEmpty;

        // Error (mantiene formData para persistir datos)
        state = state.copyWithError(
          errorMessage: shouldShowGeneralError ? failure.message : null,
          serverErrors: serverErrors,
          formData: formData,
        );
        print('❌ [CreateUserProvider] Estado cambiado a error');
      },
      (user) {
        print('✅ [CreateUserProvider] Usuario creado exitosamente: ${user.email}');
        // Éxito (limpia formData)
        state = state.copyWithSuccess(user);
        print('✅ [CreateUserProvider] Estado cambiado a success');
      },
    );
  }

  /// Extrae errores del servidor del failure
  Map<String, String> _extractServerErrors(dynamic failure) {
    // Si es ValidationFailure con fieldErrors, retornarlos
    if (failure is ValidationFailure && failure.fieldErrors != null) {
      return failure.fieldErrors!;
    }
    return {};
  }

  /// Limpia errores
  void clearErrors() {
    state = state.copyWithClearedErrors();
  }

  /// Limpia el error de un campo específico
  void clearFieldError(String fieldName) {
    state = state.copyWithClearedFieldError(fieldName);
  }

  /// Reinicia el estado
  void reset() {
    state = CreateUserState.initial();
  }
}
