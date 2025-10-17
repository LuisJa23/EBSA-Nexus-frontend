// crew_with_members.dart
//
// Entidad de cuadrilla con miembros
//
// PROPÓSITO:
// - Representa una cuadrilla con su lista de miembros incluida
//
// CAPA: DOMAIN LAYER

import 'package:equatable/equatable.dart';
import 'crew_detail.dart';
import 'crew_member_detail.dart';

/// Cuadrilla con sus miembros incluidos
class CrewWithMembers extends Equatable {
  final CrewDetail crewDetail;
  final List<CrewMemberDetail> members;

  const CrewWithMembers({required this.crewDetail, required this.members});

  @override
  List<Object?> get props => [crewDetail, members];
}
