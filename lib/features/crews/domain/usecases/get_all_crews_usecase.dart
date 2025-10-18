// get_all_crews_usecase.dart
//
// Caso de uso: Obtener todas las cuadrillas
//
// PROPÓSITO:
// - Recuperar lista completa de cuadrillas
//
// CAPA: DOMAIN LAYER

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/crew.dart';
import '../repositories/crew_repository.dart';

/// Caso de uso para obtener todas las cuadrillas
class GetAllCrewsUseCase {
  final CrewRepository repository;

  GetAllCrewsUseCase(this.repository);

  Future<Either<Failure, List<Crew>>> call() async {
    return await repository.getAllCrews();
  }
}
