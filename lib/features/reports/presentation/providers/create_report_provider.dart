// create_report_provider.dart
//
// Provider para creación de reportes de novedades
//
// PROPÓSITO:
// - Gestionar estado de creación de reportes
// - Cargar miembros de cuadrilla asignada
// - Permitir selección de participantes
// - Enviar reporte al backend
//
// CAPA: PRESENTATION LAYER - PROVIDERS

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../incidents/data/novelty_service.dart';
import '../../../crews/data/datasources/crew_remote_datasource.dart';
import '../../data/services/novelty_report_service.dart';
import '../../data/models/novelty_report_model.dart';
import '../state/create_report_state.dart';
import '../../../../core/utils/app_logger.dart';

class CreateReportProvider extends StateNotifier<CreateReportState> {
  final NoveltyReportService reportService;
  final CrewRemoteDataSource crewDataSource;
  final NoveltyService noveltyService;

  CreateReportProvider({
    required this.reportService,
    required this.crewDataSource,
    required this.noveltyService,
  }) : super(CreateReportInitial());

  /// Cargar miembros de la cuadrilla asignada a la novedad
  Future<void> loadCrewMembers(int noveltyId) async {
    try {
      state = LoadingCrewMembers();

      // Obtener la novedad para saber qué cuadrilla está asignada
      final novelty = await noveltyService.getNoveltyByIdParsed(noveltyId);

      if (novelty.crewId == null) {
        state = CrewMembersError(
          'Esta novedad no tiene una cuadrilla asignada',
        );
        return;
      }

      // Obtener los miembros de la cuadrilla
      final crewWithMembers = await crewDataSource.getCrewWithMembers(
        novelty.crewId!,
      );

      // Filtrar solo miembros activos
      final activeMembers = crewWithMembers.members
          .where((member) => member.leftAt == null)
          .toList();

      if (activeMembers.isEmpty) {
        state = CrewMembersError('La cuadrilla no tiene miembros activos');
        return;
      }

      // Inicialmente, todos están seleccionados
      final selectedIds = activeMembers.map((m) => m.userId).toSet();

      state = CrewMembersLoaded(
        members: activeMembers,
        selectedParticipants: selectedIds,
      );

      AppLogger.info('Miembros de cuadrilla cargados: ${activeMembers.length}');
    } catch (e) {
      AppLogger.error('Error al cargar miembros de cuadrilla', error: e);
      state = CrewMembersError('Error al cargar miembros: ${e.toString()}');
    }
  }

  /// Alternar selección de un participante
  void toggleParticipant(int userId) {
    final currentState = state;
    if (currentState is! CrewMembersLoaded) return;

    final newSelection = Set<int>.from(currentState.selectedParticipants);

    if (newSelection.contains(userId)) {
      newSelection.remove(userId);
    } else {
      newSelection.add(userId);
    }

    state = currentState.copyWith(selectedParticipants: newSelection);
  }

  /// Seleccionar todos los miembros
  void selectAll() {
    final currentState = state;
    if (currentState is! CrewMembersLoaded) return;

    final allIds = currentState.members.map((m) => m.userId).toSet();
    state = currentState.copyWith(selectedParticipants: allIds);
  }

  /// Deseleccionar todos los miembros
  void deselectAll() {
    final currentState = state;
    if (currentState is! CrewMembersLoaded) return;

    state = currentState.copyWith(selectedParticipants: {});
  }

  /// Crear el reporte
  Future<void> createReport({
    required int noveltyId,
    required String reportContent,
    String? observations,
    required DateTime workStartDate,
    required DateTime workEndDate,
    required String resolutionStatus,
  }) async {
    try {
      final currentState = state;
      if (currentState is! CrewMembersLoaded) {
        state = CreateReportError('Debe cargar los miembros primero');
        return;
      }

      if (currentState.selectedParticipants.isEmpty) {
        state = CreateReportError('Debe seleccionar al menos un participante');
        return;
      }

      state = CreateReportLoading();

      // Crear lista de participantes
      final participants = currentState.selectedParticipants
          .map((userId) => ParticipantRequest(userId: userId))
          .toList();

      // Crear request
      final request = CreateNoveltyReportRequest(
        noveltyId: noveltyId,
        reportContent: reportContent,
        observations: observations,
        workStartDate: workStartDate,
        workEndDate: workEndDate,
        resolutionStatus: resolutionStatus,
        participants: participants,
      );

      // Enviar al backend
      final report = await reportService.createReport(request);

      state = CreateReportSuccess(report);
      AppLogger.info('Reporte creado exitosamente: ${report.id}');
    } catch (e) {
      AppLogger.error('Error al crear reporte', error: e);
      state = CreateReportError(_getErrorMessage(e));
    }
  }

  /// Obtener mensaje de error legible
  String _getErrorMessage(dynamic error) {
    final errorStr = error.toString();

    if (errorStr.contains('Datos de reporte inválidos')) {
      return 'Los datos del reporte son inválidos';
    } else if (errorStr.contains('No tienes permisos')) {
      return 'No tienes permisos para crear reportes';
    } else if (errorStr.contains('Novedad no encontrada')) {
      return 'La novedad no fue encontrada';
    } else if (errorStr.contains('Ya existe un reporte')) {
      return 'Ya existe un reporte para esta novedad';
    } else {
      return 'Error al crear el reporte';
    }
  }

  /// Resetear el estado
  void reset() {
    state = CreateReportInitial();
  }
}
