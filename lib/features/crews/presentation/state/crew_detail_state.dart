// crew_detail_state.dart
//
// Estado para detalle de cuadrilla
//
// PROPÓSITO:
// - Gestionar estado del detalle de cuadrilla y sus miembros
//
// CAPA: PRESENTATION LAYER

import 'package:equatable/equatable.dart';
import '../../domain/entities/crew_detail.dart';
import '../../domain/entities/crew_member_detail.dart';
import '../../domain/entities/available_user.dart';

/// Estado del detalle de cuadrilla
class CrewDetailState extends Equatable {
  final bool isLoading;
  final bool isLoadingMembers;
  final bool isLoadingAvailableUsers;
  final bool isPerformingAction;
  final CrewDetail? crewDetail;
  final List<CrewMemberDetail> members;
  final List<AvailableUser> availableUsers;
  final String? errorMessage;
  final String? successMessage;

  const CrewDetailState({
    this.isLoading = false,
    this.isLoadingMembers = false,
    this.isLoadingAvailableUsers = false,
    this.isPerformingAction = false,
    this.crewDetail,
    this.members = const [],
    this.availableUsers = const [],
    this.errorMessage,
    this.successMessage,
  });

  CrewDetailState copyWith({
    bool? isLoading,
    bool? isLoadingMembers,
    bool? isLoadingAvailableUsers,
    bool? isPerformingAction,
    CrewDetail? crewDetail,
    List<CrewMemberDetail>? members,
    List<AvailableUser>? availableUsers,
    String? errorMessage,
    String? successMessage,
  }) {
    return CrewDetailState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMembers: isLoadingMembers ?? this.isLoadingMembers,
      isLoadingAvailableUsers: isLoadingAvailableUsers ?? this.isLoadingAvailableUsers,
      isPerformingAction: isPerformingAction ?? this.isPerformingAction,
      crewDetail: crewDetail ?? this.crewDetail,
      members: members ?? this.members,
      availableUsers: availableUsers ?? this.availableUsers,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isLoadingMembers,
        isLoadingAvailableUsers,
        isPerformingAction,
        crewDetail,
        members,
        availableUsers,
        errorMessage,
        successMessage,
      ];
}
