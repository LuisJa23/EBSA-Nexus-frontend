// assignments_provider.dart
//
// Provider para asignaciones
//
// PROPÓSITO:
// - Gestionar estado de novedades asignadas
//
// CAPA: PRESENTATION LAYER

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/dependency_injection/injection_container.dart';
import '../../../../core/utils/app_logger.dart';
import '../../data/models/novelty_model.dart';
import '../../data/novelty_service.dart';

/// Estados de asignaciones
enum AssignmentsStatus { initial, loading, loaded, error }

/// Estado de asignaciones
class AssignmentsState {
  final AssignmentsStatus status;
  final List<NoveltyModel> novelties;
  final String? errorMessage;

  const AssignmentsState({
    this.status = AssignmentsStatus.initial,
    this.novelties = const [],
    this.errorMessage,
  });

  AssignmentsState copyWith({
    AssignmentsStatus? status,
    List<NoveltyModel>? novelties,
    String? errorMessage,
  }) {
    return AssignmentsState(
      status: status ?? this.status,
      novelties: novelties ?? this.novelties,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isLoading => status == AssignmentsStatus.loading;
  bool get hasError => status == AssignmentsStatus.error;
  bool get isEmpty => novelties.isEmpty && status == AssignmentsStatus.loaded;
}

/// Notifier para asignaciones
class AssignmentsNotifier extends StateNotifier<AssignmentsState> {
  final NoveltyService noveltyService;

  AssignmentsNotifier({required this.noveltyService})
    : super(const AssignmentsState());

  /// Cargar novedades del usuario
  Future<void> loadUserNovelties(String userId) async {
    AppLogger.debug(
      'AssignmentsProvider: Iniciando carga de novedades para userId: $userId',
    );
    state = state.copyWith(status: AssignmentsStatus.loading);

    try {
      final response = await noveltyService.getUserNovelties(userId);
      AppLogger.debug(
        'AssignmentsProvider: Respuesta obtenida - Status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        AppLogger.debug(
          'AssignmentsProvider: Datos obtenidos - Cantidad: ${data.length}',
        );

        final novelties = data
            .map((json) => NoveltyModel.fromJson(json as Map<String, dynamic>))
            .toList();

        state = state.copyWith(
          status: AssignmentsStatus.loaded,
          novelties: novelties,
        );
        AppLogger.debug(
          'AssignmentsProvider: Novedades cargadas exitosamente: ${novelties.length}',
        );
      } else {
        AppLogger.error(
          'AssignmentsProvider: Error en respuesta - Status: ${response.statusCode}, Data: ${response.data}',
        );
        state = state.copyWith(
          status: AssignmentsStatus.error,
          errorMessage: 'Error al obtener novedades',
        );
      }
    } catch (e) {
      AppLogger.error(
        'AssignmentsProvider: Error al cargar novedades',
        error: e,
      );
      state = state.copyWith(
        status: AssignmentsStatus.error,
        errorMessage: 'Error inesperado: $e',
      );
    }
  }

  /// Refrescar novedades
  Future<void> refreshNovelties(String userId) async {
    await loadUserNovelties(userId);
  }
}

/// Provider del notifier
final assignmentsProvider =
    StateNotifierProvider<AssignmentsNotifier, AssignmentsState>((ref) {
      final noveltyService = sl<NoveltyService>();
      return AssignmentsNotifier(noveltyService: noveltyService);
    });
