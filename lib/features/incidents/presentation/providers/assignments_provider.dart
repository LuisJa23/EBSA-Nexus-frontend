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
      AppLogger.debug('AssignmentsProvider: Llamando getUserNovelties...');
      final response = await noveltyService.getUserNovelties(userId);

      AppLogger.debug(
        'AssignmentsProvider: Respuesta obtenida - Status: ${response.statusCode}',
      );
      AppLogger.debug(
        'AssignmentsProvider: Tipo de data: ${response.data.runtimeType}',
      );
      AppLogger.debug('AssignmentsProvider: Data completa: ${response.data}');

      if (response.statusCode == 200) {
        // Verificar si la respuesta es una lista directamente o está envuelta
        List<dynamic> data;

        if (response.data is List) {
          data = response.data as List<dynamic>;
        } else if (response.data is Map && response.data['content'] != null) {
          // Si es una respuesta paginada
          data = response.data['content'] as List<dynamic>;
        } else {
          AppLogger.warning(
            'AssignmentsProvider: Formato de respuesta inesperado: ${response.data}',
          );
          data = [];
        }

        AppLogger.debug(
          'AssignmentsProvider: Datos obtenidos - Cantidad: ${data.length}',
        );

        final novelties = data
            .map((json) {
              try {
                return NoveltyModel.fromJson(json as Map<String, dynamic>);
              } catch (e) {
                AppLogger.error(
                  'AssignmentsProvider: Error al parsear novedad: $json',
                  error: e,
                );
                return null;
              }
            })
            .whereType<NoveltyModel>()
            .toList();

        state = state.copyWith(
          status: AssignmentsStatus.loaded,
          novelties: novelties,
        );
        AppLogger.info(
          'AssignmentsProvider: ✅ Novedades cargadas exitosamente: ${novelties.length}',
        );
      } else {
        final errorMsg = 'Error ${response.statusCode}: ${response.data}';
        AppLogger.error('AssignmentsProvider: Error en respuesta - $errorMsg');
        state = state.copyWith(
          status: AssignmentsStatus.error,
          errorMessage: errorMsg,
        );
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'AssignmentsProvider: ❌ Error al cargar novedades',
        error: e,
        stackTrace: stackTrace,
      );
      state = state.copyWith(
        status: AssignmentsStatus.error,
        errorMessage: 'Error inesperado: ${e.toString()}',
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
