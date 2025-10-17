// crew_member.dart
//
// Entidad de miembro de cuadrilla
//
// PROPÓSITO:
// - Representa un miembro dentro de una cuadrilla
//
// CAPA: DOMAIN LAYER

import 'package:equatable/equatable.dart';

/// Miembro de una cuadrilla
class CrewMember extends Equatable {
  final int userId;
  final bool isLeader;

  const CrewMember({
    required this.userId,
    required this.isLeader,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'isLeader': isLeader,
      };

  @override
  List<Object?> get props => [userId, isLeader];
}
