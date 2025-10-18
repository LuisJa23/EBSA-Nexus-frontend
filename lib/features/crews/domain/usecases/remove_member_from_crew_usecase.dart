// remove_member_from_crew_usecase.dart
//
// Caso de uso: Eliminar miembro de cuadrilla
//
// PROPÓSITO:
// - Remover un miembro de una cuadrilla
//
// CAPA: DOMAIN LAYER

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/crew_repository.dart';

/// Parámetros para eliminar miembro de cuadrilla
class RemoveMemberParams {
  final int crewId;
  final int memberId;

  RemoveMemberParams({
    required this.crewId,
    required this.memberId,
  });
}

/// Caso de uso para eliminar miembro de cuadrilla
class RemoveMemberFromCrewUseCase {
  final CrewRepository repository;

  RemoveMemberFromCrewUseCase(this.repository);

  Future<Either<Failure, void>> call(RemoveMemberParams params) async {
    return await repository.removeMemberFromCrew(
      crewId: params.crewId,
      memberId: params.memberId,
    );
  }
}
