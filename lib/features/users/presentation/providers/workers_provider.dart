// workers_provider.dart
//
// Provider para gestión de trabajadores
//
// PROPÓSITO:
// - Manejar estado de la lista de trabajadores
// - Implementar lógica de búsqueda y filtros
// - Coordinar con use cases del dominio
//
// CAPA: PRESENTATION LAYER

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/dependency_injection/injection_container.dart' as di;
import '../../../../core/errors/failures.dart';
import '../../domain/entities/worker.dart';
import '../../domain/usecases/get_workers_usecase.dart';
import '../state/workers_state.dart';

/// Provider del use case desde DI
final getWorkersUseCaseProvider = Provider<GetWorkersUseCase>((ref) {
  return di.sl<GetWorkersUseCase>();
});

/// Provider del StateNotifier de trabajadores
final workersProvider = StateNotifierProvider<WorkersNotifier, WorkersState>((
  ref,
) {
  final getWorkersUseCase = ref.watch(getWorkersUseCaseProvider);
  return WorkersNotifier(getWorkersUseCase);
});

/// StateNotifier para manejar el estado y lógica de trabajadores
class WorkersNotifier extends StateNotifier<WorkersState> {
  final GetWorkersUseCase _getWorkersUseCase;

  WorkersNotifier(this._getWorkersUseCase) : super(const WorkersInitial());

  // ============================================================================
  // GETTERS DE CONVENIENCIA
  // ============================================================================

  bool get isLoading => state is WorkersLoading;
  bool get hasError => state is WorkersError;
  bool get hasData => state is WorkersLoaded;

  List<Worker> get workers {
    if (state is WorkersLoaded) {
      return (state as WorkersLoaded).workers;
    }
    return [];
  }

  List<Worker> get displayWorkers {
    if (state is WorkersLoaded) {
      return (state as WorkersLoaded).displayWorkers;
    }
    return [];
  }

  String get searchQuery {
    if (state is WorkersLoaded) {
      return (state as WorkersLoaded).searchQuery;
    }
    return '';
  }

  String? get selectedWorkType {
    if (state is WorkersLoaded) {
      return (state as WorkersLoaded).selectedWorkType;
    }
    return null;
  }

  String? get errorMessage {
    if (state is WorkersError) {
      return (state as WorkersError).message;
    }
    return null;
  }

  // ============================================================================
  // ACCIONES PÚBLICAS
  // ============================================================================

  /// Carga la lista inicial de trabajadores
  Future<void> loadWorkers() async {
    state = const WorkersLoading();

    final result = await _getWorkersUseCase();

    result.fold(
      (failure) => _handleFailure(failure),
      (workers) =>
          state = WorkersLoaded(workers: workers, filteredWorkers: workers),
    );
  }

  /// Recarga la lista de trabajadores
  Future<void> refreshWorkers() async {
    await loadWorkers();
  }

  /// Busca trabajadores por texto
  void searchWorkers(String query) {
    if (state is! WorkersLoaded) return;

    final currentState = state as WorkersLoaded;
    final filteredWorkers = _filterWorkers(
      workers: currentState.workers,
      searchQuery: query,
      workType: currentState.selectedWorkType,
    );

    state = currentState.copyWith(
      filteredWorkers: filteredWorkers,
      searchQuery: query,
    );
  }

  /// Filtra trabajadores por tipo de trabajo
  void filterByWorkType(String? workType) {
    if (state is! WorkersLoaded) return;

    final currentState = state as WorkersLoaded;
    final filteredWorkers = _filterWorkers(
      workers: currentState.workers,
      searchQuery: currentState.searchQuery,
      workType: workType,
    );

    state = currentState.copyWith(
      filteredWorkers: filteredWorkers,
      selectedWorkType: workType,
    );
  }

  /// Limpia todos los filtros
  void clearFilters() {
    if (state is! WorkersLoaded) return;

    final currentState = state as WorkersLoaded;
    state = currentState.copyWith(
      filteredWorkers: currentState.workers,
      searchQuery: '',
      selectedWorkType: null,
    );
  }

  /// Obtiene trabajadores activos únicamente
  Future<void> loadActiveWorkers() async {
    state = const WorkersLoading();

    final result = await _getWorkersUseCase.getActiveWorkers();

    result.fold(
      (failure) => _handleFailure(failure),
      (workers) =>
          state = WorkersLoaded(workers: workers, filteredWorkers: workers),
    );
  }

  // ============================================================================
  // MÉTODOS PRIVADOS
  // ============================================================================

  void _handleFailure(Failure failure) {
    switch (failure.runtimeType) {
      case NetworkFailure:
        state = const WorkersNetworkError();
        break;
      case ServerFailure:
        state = const WorkersServerError();
        break;
      case AuthorizationFailure:
        state = const WorkersAuthorizationError();
        break;
      default:
        state = WorkersError(message: failure.message);
        break;
    }
  }

  List<Worker> _filterWorkers({
    required List<Worker> workers,
    required String searchQuery,
    required String? workType,
  }) {
    var filtered = workers;

    // Filtrar por búsqueda de texto
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((worker) {
        return worker.fullName.toLowerCase().contains(query) ||
            worker.username.toLowerCase().contains(query) ||
            worker.email.toLowerCase().contains(query) ||
            worker.documentNumber.contains(query);
      }).toList();
    }

    // Filtrar por tipo de trabajo
    if (workType != null && workType.isNotEmpty) {
      filtered = filtered.where((worker) {
        return worker.workType.toLowerCase() == workType.toLowerCase();
      }).toList();
    }

    return filtered;
  }

  /// Obtiene los tipos de trabajo únicos de la lista actual
  List<String> get availableWorkTypes {
    if (state is! WorkersLoaded) return [];

    final currentState = state as WorkersLoaded;
    final types = currentState.workers
        .map((worker) => worker.workType)
        .toSet()
        .toList();

    types.sort();
    return types;
  }

  /// Obtiene los tipos de trabajo únicos localizados
  List<String> get availableWorkTypesLocalized {
    return availableWorkTypes.map((type) {
      switch (type.toLowerCase()) {
        case 'intern':
          return 'Interno';
        case 'external':
          return 'Externo';
        case 'contractor':
          return 'Contratista';
        default:
          return type;
      }
    }).toList();
  }
}
