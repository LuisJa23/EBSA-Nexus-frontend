// add_member_to_crew_usecase.dart
//
// Caso de uso: Agregar miembro a cuadrilla
//
// PROPÓSITO:
// - Agregar un usuario como miembro de una cuadrilla
//
// CAPA: DOMAIN LAYER

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/crew_repository.dart';

/// Parámetros para agregar miembro a cuadrilla
class AddMemberParams {
  final int crewId;
  final int userId;
  final bool isLeader;

  AddMemberParams({
    required this.crewId,
    required this.userId,
    required this.isLeader,
  });
}

/// Caso de uso para agregar miembro a cuadrilla
class AddMemberToCrewUseCase {
  final CrewRepository repository;

  AddMemberToCrewUseCase(this.repository);

  Future<Either<Failure, void>> call(AddMemberParams params) async {
    return await repository.addMemberToCrew(
      crewId: params.crewId,
      userId: params.userId,
      isLeader: params.isLeader,
    );
  }
}
