// create_report_state.dart
//
// Estados para creación de reporte
//
// PROPÓSITO:
// - Representar estados de la creación de reportes
//
// CAPA: PRESENTATION LAYER - STATE

import '../../../crews/domain/entities/crew_member_detail.dart';
import '../../data/models/novelty_report_model.dart';

abstract class CreateReportState {}

class CreateReportInitial extends CreateReportState {}

class CreateReportLoading extends CreateReportState {}

class CreateReportSuccess extends CreateReportState {
  final NoveltyReportModel report;

  CreateReportSuccess(this.report);
}

class CreateReportError extends CreateReportState {
  final String message;

  CreateReportError(this.message);
}

/// Estado para cargar miembros de la cuadrilla
class LoadingCrewMembers extends CreateReportState {}

class CrewMembersLoaded extends CreateReportState {
  final List<CrewMemberDetail> members;
  final Set<int> selectedParticipants;

  CrewMembersLoaded({
    required this.members,
    required this.selectedParticipants,
  });

  /// Crea una copia con cambios
  CrewMembersLoaded copyWith({
    List<CrewMemberDetail>? members,
    Set<int>? selectedParticipants,
  }) {
    return CrewMembersLoaded(
      members: members ?? this.members,
      selectedParticipants: selectedParticipants ?? this.selectedParticipants,
    );
  }
}

class CrewMembersError extends CreateReportState {
  final String message;

  CrewMembersError(this.message);
}
