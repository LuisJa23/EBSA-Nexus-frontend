// create_report_provider.dart
//
// Provider para creación de reportes de resolución de novedades
//
// PROPÓSITO:
// - Gestionar estado de creación de reportes de resolución
// - Cargar miembros de cuadrilla asignada
// - Permitir selección de participantes
// - Enviar reporte al backend
//
// CAPA: PRESENTATION LAYER - PROVIDERS

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/novelty_service.dart';
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
      AppLogger.info('=== CARGANDO MIEMBROS DE CUADRILLA ===');
      AppLogger.info('NoveltyId: $noveltyId');

      state = LoadingCrewMembers();

      // Obtener la novedad para saber qué cuadrilla está asignada
      // AGREGAR TIMEOUT para evitar esperas infinitas
      AppLogger.debug('Obteniendo información de la novedad...');
      final novelty = await noveltyService
          .getNoveltyByIdParsed(noveltyId)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception(
                'Tiempo de espera agotado al obtener información de la novedad. '
                'Verifica tu conexión o intenta nuevamente.',
              );
            },
          );

      AppLogger.debug(
        'Novedad obtenida - CrewId: ${novelty.crewId}, Status: ${novelty.status}',
      );

      // VALIDAR ESTADO DE LA NOVEDAD
      if (novelty.status == 'COMPLETADA') {
        AppLogger.warning('La novedad ya está completada');
        state = CrewMembersError(
          'Esta novedad ya está completada y tiene un reporte de resolución. '
          'No es posible crear otro reporte.',
        );
        return;
      }

      if (novelty.status != 'EN_CURSO') {
        AppLogger.warning('La novedad no está EN_CURSO: ${novelty.status}');
        state = CrewMembersError(
          'Solo se pueden crear reportes para novedades EN_CURSO. '
          'Estado actual: ${novelty.status}. '
          'Cambia el estado a EN_CURSO antes de continuar.',
        );
        return;
      }

      if (novelty.crewId == null) {
        AppLogger.warning('La novedad no tiene cuadrilla asignada');
        state = CrewMembersError(
          'Esta novedad no tiene una cuadrilla asignada. '
          'Debe asignar una cuadrilla primero.',
        );
        return;
      }

      // Obtener los miembros de la cuadrilla con timeout
      AppLogger.debug(
        'Obteniendo miembros de la cuadrilla ${novelty.crewId}...',
      );
      final crewWithMembers = await crewDataSource
          .getCrewWithMembers(novelty.crewId!)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception(
                'Tiempo de espera agotado al obtener miembros de la cuadrilla.',
              );
            },
          );

      AppLogger.debug(
        'Cuadrilla obtenida - Total miembros: ${crewWithMembers.members.length}',
      );

      // Filtrar solo miembros activos
      final activeMembers = crewWithMembers.members
          .where((member) => member.leftAt == null)
          .toList();

      AppLogger.debug('Miembros activos: ${activeMembers.length}');

      if (activeMembers.isEmpty) {
        AppLogger.warning('La cuadrilla no tiene miembros activos');
        state = CrewMembersError(
          'La cuadrilla no tiene miembros activos. '
          'Agrega miembros a la cuadrilla antes de continuar.',
        );
        return;
      }

      // Inicialmente, todos están seleccionados
      final selectedIds = activeMembers.map((m) => m.userId).toSet();

      state = CrewMembersLoaded(
        members: activeMembers,
        selectedParticipants: selectedIds,
      );

      AppLogger.info(
        '✅ Miembros de cuadrilla cargados exitosamente: ${activeMembers.length}',
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        '❌ Error al cargar miembros de cuadrilla',
        error: e,
        stackTrace: stackTrace,
      );

      // Mensaje de error más específico
      String errorMessage = 'Error al cargar miembros de la cuadrilla';

      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('timeout') ||
          errorStr.contains('tiempo de espera')) {
        errorMessage =
            'El servidor tardó demasiado en responder. Verifica tu conexión e intenta nuevamente.';
      } else if (errorStr.contains('404') || errorStr.contains('not found')) {
        errorMessage =
            'Novedad no encontrada. Es posible que haya sido eliminada.';
      } else if (errorStr.contains('connection') ||
          errorStr.contains('network')) {
        errorMessage =
            'Error de conexión con el servidor. Verifica tu conexión a internet.';
      } else if (errorStr.contains('401') ||
          errorStr.contains('unauthorized')) {
        errorMessage = 'Sesión expirada. Inicia sesión nuevamente.';
      } else {
        errorMessage = 'Error al cargar miembros: ${e.toString()}';
      }

      state = CrewMembersError(errorMessage);
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

      AppLogger.info('=== CREANDO REPORTE DE NOVEDAD ===');
      AppLogger.info('NoveltyId: $noveltyId');
      AppLogger.info(
        'Participantes seleccionados: ${currentState.selectedParticipants.length}',
      );
      AppLogger.info('Estado de resolución: $resolutionStatus');
      AppLogger.info('Fecha inicio: ${workStartDate.toIso8601String()}');
      AppLogger.info('Fecha fin: ${workEndDate.toIso8601String()}');

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

      AppLogger.debug('Request JSON: ${request.toJson()}');

      // Enviar al backend
      final report = await reportService.createReport(request);

      AppLogger.info('✅ Reporte creado exitosamente: ID ${report.id}');
      state = CreateReportSuccess(report);
    } catch (e, stackTrace) {
      AppLogger.error(
        '❌ Error al crear reporte',
        error: e,
        stackTrace: stackTrace,
      );
      state = CreateReportError(_getErrorMessage(e));
    }
  }

  /// Obtener mensaje de error legible
  String _getErrorMessage(dynamic error) {
    final errorStr = error.toString();

    // El error viene como Exception('mensaje'), extraer el mensaje
    if (errorStr.startsWith('Exception: ')) {
      return errorStr.substring('Exception: '.length);
    }

    // Fallback para otros tipos de errores
    AppLogger.debug('Error type: ${error.runtimeType}');
    AppLogger.debug('Error message: $errorStr');

    return 'Error inesperado al crear el reporte';
  }

  /// Resetear el estado
  void reset() {
    state = CreateReportInitial();
  }
}
