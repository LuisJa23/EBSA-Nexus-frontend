// get_pending_reports_count_usecase.dart
//
// Caso de uso para obtener cantidad de reportes pendientes
//
// PROPÓSITO:
// - Obtener contador de reportes no sincronizados
// - Mostrar badge en UI con cantidad pendiente
// - Validar si hay reportes por sincronizar
//
// CAPA: DOMAIN LAYER

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/report_repository.dart';

/// Caso de uso para obtener la cantidad de reportes pendientes
///
/// Retorna un contador simple para mostrar en badges de UI
class GetPendingReportsCountUseCase {
  final ReportRepository repository;

  const GetPendingReportsCountUseCase(this.repository);

  /// Obtiene el número de reportes pendientes de sincronización
  ///
  /// Retorna:
  /// - [Right(int)]: Cantidad de reportes pendientes
  /// - [Left(Failure)]: Error (retorna 0 por defecto)
  Future<Either<Failure, int>> call() async {
    return repository.getPendingReportsCount();
  }
}
