// promote_member_to_leader_usecase.dart
//
// Caso de uso: Promover miembro a líder
//
// PROPÓSITO:
// - Promover un miembro a líder de cuadrilla
//
// CAPA: DOMAIN LAYER

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/crew_repository.dart';

/// Parámetros para promover miembro a líder
class PromoteMemberParams {
  final int crewId;
  final int memberId;

  PromoteMemberParams({
    required this.crewId,
    required this.memberId,
  });
}

/// Caso de uso para promover miembro a líder
class PromoteMemberToLeaderUseCase {
  final CrewRepository repository;

  PromoteMemberToLeaderUseCase(this.repository);

  Future<Either<Failure, void>> call(PromoteMemberParams params) async {
    return await repository.promoteMemberToLeader(
      crewId: params.crewId,
      memberId: params.memberId,
    );
  }
}
