// crew_detail_provider.dart
//
// Provider para detalle de cuadrilla
//
// PROPÓSITO:
// - Gestionar estado y lógica de detalle de cuadrilla y sus miembros
//
// CAPA: PRESENTATION LAYER

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/dependency_injection/injection_container.dart';
import '../../domain/usecases/get_crew_with_members_usecase.dart';
import '../../domain/usecases/add_member_to_crew_usecase.dart';
import '../../domain/usecases/remove_member_from_crew_usecase.dart';
import '../../domain/usecases/promote_member_to_leader_usecase.dart';
import '../../domain/usecases/get_available_users_usecase.dart';
import '../state/crew_detail_state.dart';

/// Notificador para detalle de cuadrilla
class CrewDetailNotifier extends StateNotifier<CrewDetailState> {
  final GetCrewWithMembersUseCase getCrewWithMembersUseCase;
  final GetAvailableUsersUseCase getAvailableUsersUseCase;
  final AddMemberToCrewUseCase addMemberToCrewUseCase;
  final RemoveMemberFromCrewUseCase removeMemberFromCrewUseCase;
  final PromoteMemberToLeaderUseCase promoteMemberToLeaderUseCase;

  CrewDetailNotifier({
    required this.getCrewWithMembersUseCase,
    required this.getAvailableUsersUseCase,
    required this.addMemberToCrewUseCase,
    required this.removeMemberFromCrewUseCase,
    required this.promoteMemberToLeaderUseCase,
  }) : super(const CrewDetailState());

  /// Cargar detalle de cuadrilla con miembros (optimizado)
  Future<void> loadCrewWithMembers(int crewId) async {
    state = state.copyWith(
      isLoading: true,
      isLoadingMembers: true,
      errorMessage: null,
    );

    final result = await getCrewWithMembersUseCase(crewId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          isLoadingMembers: false,
          errorMessage: failure.message,
        );
      },
      (crewWithMembers) {
        state = state.copyWith(
          isLoading: false,
          isLoadingMembers: false,
          crewDetail: crewWithMembers.crewDetail,
          members: crewWithMembers.members,
          errorMessage: null,
        );
      },
    );
  }

  /// Cargar usuarios disponibles
  Future<void> loadAvailableUsers() async {
    state = state.copyWith(isLoadingAvailableUsers: true, errorMessage: null);

    final result = await getAvailableUsersUseCase();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoadingAvailableUsers: false,
          errorMessage: failure.message,
        );
      },
      (users) {
        state = state.copyWith(
          isLoadingAvailableUsers: false,
          availableUsers: users,
          errorMessage: null,
        );
      },
    );
  }

  /// Agregar miembro a cuadrilla
  Future<bool> addMember(int crewId, int userId, bool isLeader) async {
    state = state.copyWith(
      isPerformingAction: true,
      errorMessage: null,
      successMessage: null,
    );

    final params = AddMemberParams(
      crewId: crewId,
      userId: userId,
      isLeader: isLeader,
    );

    final result = await addMemberToCrewUseCase(params);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isPerformingAction: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(
          isPerformingAction: false,
          successMessage: 'Miembro agregado exitosamente',
        );
        // Recargar cuadrilla con miembros
        loadCrewWithMembers(crewId);
        return true;
      },
    );
  }

  /// Eliminar miembro de cuadrilla
  Future<bool> removeMember(int crewId, int memberId) async {
    print(
      '🔄 Provider: Eliminando miembro - CrewId: $crewId, UserId: $memberId',
    );

    state = state.copyWith(
      isPerformingAction: true,
      errorMessage: null,
      successMessage: null,
    );

    final params = RemoveMemberParams(crewId: crewId, memberId: memberId);

    final result = await removeMemberFromCrewUseCase(params);

    return result.fold(
      (failure) {
        print('❌ Provider: Error al eliminar miembro - ${failure.message}');
        state = state.copyWith(
          isPerformingAction: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        print('✅ Provider: Miembro eliminado exitosamente');
        state = state.copyWith(
          isPerformingAction: false,
          successMessage: 'Miembro eliminado exitosamente',
        );
        // Recargar cuadrilla con miembros
        loadCrewWithMembers(crewId);
        return true;
      },
    );
  }

  /// Promover miembro a líder
  Future<bool> promoteMember(int crewId, int memberId) async {
    print(
      '🔄 Provider: Promoviendo miembro a líder - CrewId: $crewId, UserId: $memberId',
    );

    state = state.copyWith(
      isPerformingAction: true,
      errorMessage: null,
      successMessage: null,
    );

    final params = PromoteMemberParams(crewId: crewId, memberId: memberId);

    final result = await promoteMemberToLeaderUseCase(params);

    return result.fold(
      (failure) {
        print('❌ Provider: Error al promover miembro - ${failure.message}');
        state = state.copyWith(
          isPerformingAction: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        print('✅ Provider: Miembro promovido a líder exitosamente');
        state = state.copyWith(
          isPerformingAction: false,
          successMessage: 'Miembro promovido a líder exitosamente',
        );
        // Recargar cuadrilla con miembros
        loadCrewWithMembers(crewId);
        return true;
      },
    );
  }

  /// Limpiar mensajes
  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }
}

/// Provider para el notificador de detalle de cuadrilla
final crewDetailProvider =
    StateNotifierProvider<CrewDetailNotifier, CrewDetailState>((ref) {
      return CrewDetailNotifier(
        getCrewWithMembersUseCase: sl<GetCrewWithMembersUseCase>(),
        getAvailableUsersUseCase: sl<GetAvailableUsersUseCase>(),
        addMemberToCrewUseCase: sl<AddMemberToCrewUseCase>(),
        removeMemberFromCrewUseCase: sl<RemoveMemberFromCrewUseCase>(),
        promoteMemberToLeaderUseCase: sl<PromoteMemberToLeaderUseCase>(),
      );
    });
