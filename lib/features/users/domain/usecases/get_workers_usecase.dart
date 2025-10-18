// get_workers_usecase.dart
//
// Caso de uso para obtener lista de trabajadores
//
// PROPÓSITO:
// - Obtener lista de trabajadores del sistema
// - Manejar lógica de negocio relacionada
// - Validaciones y filtros si es necesario
//
// CAPA: DOMAIN LAYER

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/worker.dart';
import '../repositories/user_repository.dart';

/// Caso de uso para obtener lista de trabajadores
///
/// Este caso de uso encapsula la lógica para obtener
/// la lista de trabajadores desde el endpoint público.
class GetWorkersUseCase {
  final UserRepository repository;

  GetWorkersUseCase({required this.repository});

  /// Ejecuta el caso de uso para obtener trabajadores
  ///
  /// **Retorna:**
  /// - [Right(List<Worker>)]: Lista de trabajadores obtenida exitosamente
  /// - [Left(Failure)]: Error al obtener la lista
  Future<Either<Failure, List<Worker>>> call() async {
    return await repository.getWorkers();
  }

  /// Ejecuta el caso de uso y filtra solo trabajadores activos
  ///
  /// **Retorna:**
  /// - [Right(List<Worker>)]: Lista de trabajadores activos
  /// - [Left(Failure)]: Error al obtener la lista
  Future<Either<Failure, List<Worker>>> getActiveWorkers() async {
    final result = await repository.getWorkers();

    return result.fold((failure) => Left(failure), (workers) {
      final activeWorkers = workers.where((worker) => worker.isActive).toList();
      return Right(activeWorkers);
    });
  }

  /// Ejecuta el caso de uso y filtra por tipo de trabajo
  ///
  /// **Parámetros:**
  /// - [workType]: Tipo de trabajo a filtrar (intern, external, contractor)
  ///
  /// **Retorna:**
  /// - [Right(List<Worker>)]: Lista de trabajadores filtrada
  /// - [Left(Failure)]: Error al obtener la lista
  Future<Either<Failure, List<Worker>>> getWorkersByType(
    String workType,
  ) async {
    final result = await repository.getWorkers();

    return result.fold((failure) => Left(failure), (workers) {
      final filteredWorkers = workers
          .where(
            (worker) => worker.workType.toLowerCase() == workType.toLowerCase(),
          )
          .toList();
      return Right(filteredWorkers);
    });
  }
}
