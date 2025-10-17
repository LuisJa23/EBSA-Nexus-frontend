// get_crew_with_members_usecase.dart
//
// Caso de uso para obtener los detalles de una cuadrilla con sus miembros
//
// PROPÓSITO:
// - Obtener información detallada de una cuadrilla y sus miembros en una sola llamada
// - Optimización: utiliza el endpoint unificado que devuelve todo en una respuesta
//
// CAPA: DOMAIN LAYER

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/crew_with_members.dart';
import '../repositories/crew_repository.dart';

/// Caso de uso para obtener los detalles de una cuadrilla con sus miembros
class GetCrewWithMembersUseCase {
  final CrewRepository repository;

  GetCrewWithMembersUseCase(this.repository);

  /// Ejecuta el caso de uso
  ///
  /// Obtiene los detalles completos de una cuadrilla incluyendo la lista
  /// de miembros en una sola llamada optimizada al API.
  ///
  /// [crewId] ID de la cuadrilla a consultar
  ///
  /// Retorna Either<Failure, CrewWithMembers>
  Future<Either<Failure, CrewWithMembers>> call(int crewId) async {
    return await repository.getCrewWithMembers(crewId);
  }
}
