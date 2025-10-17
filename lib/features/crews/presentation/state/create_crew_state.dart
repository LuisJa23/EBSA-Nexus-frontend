// create_crew_state.dart
//
// Estado para creación de cuadrillas
//
// PROPÓSITO:
// - Gestionar estado del formulario de creación
// - Manejar usuarios disponibles
// - Control de errores
//
// CAPA: PRESENTATION LAYER

import 'package:equatable/equatable.dart';
import '../../domain/entities/available_user.dart';

/// Estados posibles del formulario
enum CreateCrewStatus {
  initial,
  loadingUsers,
  usersLoaded,
  submitting,
  success,
  error,
}

/// Estado del formulario de creación de cuadrilla
class CreateCrewState extends Equatable {
  final CreateCrewStatus status;
  final List<AvailableUser> availableUsers;
  final String? errorMessage;

  const CreateCrewState({
    this.status = CreateCrewStatus.initial,
    this.availableUsers = const [],
    this.errorMessage,
  });

  CreateCrewState copyWith({
    CreateCrewStatus? status,
    List<AvailableUser>? availableUsers,
    String? errorMessage,
  }) {
    return CreateCrewState(
      status: status ?? this.status,
      availableUsers: availableUsers ?? this.availableUsers,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, availableUsers, errorMessage];
}
