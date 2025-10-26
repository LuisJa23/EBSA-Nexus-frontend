// get_novelties.dart
//
// Caso de uso para obtener lista de novedades
//
// PROPÓSITO:
// - Obtener lista paginada de novedades con filtros
// - Implementar reglas de negocio si es necesario
//
// CAPA: DOMAIN LAYER - USE CASES

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/novelty.dart';
import '../repositories/novelty_repository.dart';

/// Caso de uso para obtener lista de novedades
class GetNovelties {
  final NoveltyRepository _repository;

  GetNovelties(this._repository);

  /// Ejecuta el caso de uso
  Future<Either<Failure, NoveltyPage>> call(NoveltyFilters filters) async {
    return await _repository.getNovelties(filters);
  }
}
