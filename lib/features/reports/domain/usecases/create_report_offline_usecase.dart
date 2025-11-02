// create_report_offline_usecase.dart
//
// Caso de uso para crear reportes offline
//
// PROPÓSITO:
// - Crear reportes localmente sin conexión a Internet
// - Generar UUID único para identificación
// - Almacenar reporte con estado de sincronización pendiente
//
// CAPA: DOMAIN LAYER

import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/failures.dart';
import '../../data/models/evidence_model.dart';
import '../../data/models/report_model.dart';
import '../repositories/report_repository.dart';

/// Caso de uso para crear reportes offline
///
/// Genera un UUID local y guarda el reporte en la base de datos local
/// para posterior sincronización con el servidor.
class CreateReportOfflineUseCase {
  final ReportRepository repository;
  final Uuid uuid;

  const CreateReportOfflineUseCase(this.repository, this.uuid);

  /// Crea un reporte localmente
  ///
  /// Parámetros:
  /// - [noveltyId]: ID de la novedad asociada
  /// - [workDescription]: Descripción del trabajo realizado
  /// - [observations]: Observaciones adicionales (opcional)
  /// - [workTime]: Tiempo de trabajo en minutos
  /// - [workStartDate]: Fecha de inicio del trabajo
  /// - [workEndDate]: Fecha de fin del trabajo
  /// - [resolutionStatus]: Estado de resolución (COMPLETADO, NO_COMPLETADO)
  /// - [participantIds]: IDs de los participantes
  /// - [latitude]: Latitud GPS
  /// - [longitude]: Longitud GPS
  /// - [accuracy]: Precisión GPS en metros (opcional)
  /// - [evidences]: Lista de evidencias multimedia (opcional)
  ///
  /// Retorna:
  /// - [Right(ReportModel)]: Reporte creado exitosamente
  /// - [Left(Failure)]: Error al crear el reporte
  Future<Either<Failure, ReportModel>> call({
    required int noveltyId,
    required String workDescription,
    String? observations,
    required int workTime,
    required DateTime workStartDate,
    required DateTime workEndDate,
    required String resolutionStatus,
    required List<int> participantIds,
    required double latitude,
    required double longitude,
    double? accuracy,
    List<EvidenceModel> evidences = const [],
  }) async {
    // Generar UUID local único
    final reportId = uuid.v4();

    // Crear modelo de reporte con TODOS los campos requeridos
    // para que coincida con el formato del flujo online
    final report = ReportModel(
      id: reportId,
      noveltyId: noveltyId,
      workDescription: workDescription,
      observations: observations,
      workTime: workTime,
      workStartDate: workStartDate,
      workEndDate: workEndDate,
      resolutionStatus: resolutionStatus,
      participantIds: participantIds,
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      evidences: evidences,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isSynced: false,
      syncAttempts: 0,
    );

    // Guardar en repositorio (local)
    return repository.createReportOffline(report);
  }
}
