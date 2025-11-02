// get_pending_reports_usecase.dart
//
// Caso de uso para obtener reportes pendientes
//
// PROPÓSITO:
// - Obtener lista de reportes no sincronizados
// - Mostrar reportes pendientes en UI
// - Verificar estado de sincronización
//
// CAPA: DOMAIN LAYER

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../data/models/report_model.dart';
import '../repositories/report_repository.dart';

/// Caso de uso para obtener reportes pendientes de sincronización
///
/// Obtiene todos los reportes que han sido creados localmente
/// pero aún no han sido sincronizados con el servidor.
class GetPendingReportsUseCase {
  final ReportRepository repository;

  const GetPendingReportsUseCase(this.repository);

  /// Obtiene la lista de reportes pendientes
  ///
  /// Retorna solo los reportes donde [isSynced] = false
  ///
  /// Retorna:
  /// - [Right(List<ReportModel>)]: Lista de reportes pendientes
  /// - [Left(CacheFailure)]: Error al acceder a la base de datos local
  Future<Either<Failure, List<ReportModel>>> call() async {
    return repository.getReports(onlyPending: true);
  }
}
