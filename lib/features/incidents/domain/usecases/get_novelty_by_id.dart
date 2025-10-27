// get_novelty_by_id.dart
//
// Caso de uso para obtener una novedad por ID
//
// PROPÓSITO:
// - Obtener detalles de una novedad específica
//
// CAPA: DOMAIN LAYER - USE CASES

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/novelty.dart';
import '../repositories/novelty_repository.dart';

/// Caso de uso para obtener una novedad por ID
class GetNoveltyById {
  final NoveltyRepository _repository;

  GetNoveltyById(this._repository);

  /// Ejecuta el caso de uso
  Future<Either<Failure, Novelty>> call(int id) async {
    return await _repository.getNoveltyById(id);
  }
}
