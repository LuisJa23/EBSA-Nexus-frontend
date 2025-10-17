// crew_list_provider.dart
//
// Provider para lista de cuadrillas
//
// PROPÓSITO:
// - Gestionar estado y lógica de lista de cuadrillas
//
// CAPA: PRESENTATION LAYER

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/dependency_injection/injection_container.dart';
import '../../domain/usecases/get_all_crews_usecase.dart';
import '../state/crew_list_state.dart';

/// Notificador para lista de cuadrillas
class CrewListNotifier extends StateNotifier<CrewListState> {
  final GetAllCrewsUseCase getAllCrewsUseCase;

  CrewListNotifier({required this.getAllCrewsUseCase})
    : super(const CrewListState());

  /// Cargar todas las cuadrillas
  Future<void> loadCrews() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await getAllCrewsUseCase();

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (crews) {
        state = state.copyWith(
          isLoading: false,
          crews: crews,
          errorMessage: null,
        );
      },
    );
  }

  /// Refrescar lista de cuadrillas
  Future<void> refreshCrews() async {
    await loadCrews();
  }
}

/// Provider para el notificador de lista de cuadrillas
final crewListProvider = StateNotifierProvider<CrewListNotifier, CrewListState>(
  (ref) {
    return CrewListNotifier(getAllCrewsUseCase: sl<GetAllCrewsUseCase>());
  },
);
