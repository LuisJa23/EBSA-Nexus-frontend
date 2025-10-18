// workers_state.dart
//
// Estados para la gestión de trabajadores
//
// PROPÓSITO:
// - Definir estados de UI para lista de trabajadores
// - Estados de carga, éxito, error
// - Manejo de filtros y búsqueda
//
// CAPA: PRESENTATION LAYER

import '../../domain/entities/worker.dart';

/// Estados base para la gestión de trabajadores
abstract class WorkersState {
  const WorkersState();
}

/// Estado inicial - sin datos cargados
class WorkersInitial extends WorkersState {
  const WorkersInitial();
}

/// Estado de carga - obteniendo datos del servidor
class WorkersLoading extends WorkersState {
  const WorkersLoading();
}

/// Estado de éxito - datos obtenidos correctamente
class WorkersLoaded extends WorkersState {
  final List<Worker> workers;
  final List<Worker> filteredWorkers;
  final String searchQuery;
  final String? selectedWorkType;

  const WorkersLoaded({
    required this.workers,
    this.filteredWorkers = const [],
    this.searchQuery = '',
    this.selectedWorkType,
  });

  /// Copia el estado con modificaciones
  WorkersLoaded copyWith({
    List<Worker>? workers,
    List<Worker>? filteredWorkers,
    String? searchQuery,
    String? selectedWorkType,
  }) {
    return WorkersLoaded(
      workers: workers ?? this.workers,
      filteredWorkers: filteredWorkers ?? this.filteredWorkers,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedWorkType: selectedWorkType ?? this.selectedWorkType,
    );
  }

  /// Obtiene la lista a mostrar (filtrada o completa)
  List<Worker> get displayWorkers {
    return filteredWorkers.isNotEmpty ||
            searchQuery.isNotEmpty ||
            selectedWorkType != null
        ? filteredWorkers
        : workers;
  }

  /// Cantidad total de trabajadores
  int get totalWorkers => workers.length;

  /// Cantidad de trabajadores mostrados actualmente
  int get displayedWorkers => displayWorkers.length;

  /// Indica si hay filtros activos
  bool get hasActiveFilters =>
      searchQuery.isNotEmpty || selectedWorkType != null;
}

/// Estado de error - falló al obtener datos
class WorkersError extends WorkersState {
  final String message;
  final String? errorCode;

  const WorkersError({required this.message, this.errorCode});

  @override
  String toString() => 'WorkersError(message: $message, errorCode: $errorCode)';
}

/// Estado de error de red - sin conexión
class WorkersNetworkError extends WorkersError {
  const WorkersNetworkError({
    super.message =
        'Sin conexión a internet. Verifica tu conexión e intenta nuevamente.',
    super.errorCode = 'NETWORK_ERROR',
  });
}

/// Estado de error del servidor - error 500+
class WorkersServerError extends WorkersError {
  const WorkersServerError({
    super.message = 'Error del servidor. Intenta nuevamente más tarde.',
    super.errorCode = 'SERVER_ERROR',
  });
}

/// Estado de error de autorización - sin permisos
class WorkersAuthorizationError extends WorkersError {
  const WorkersAuthorizationError({
    super.message = 'No tienes permisos para ver la lista de trabajadores.',
    super.errorCode = 'AUTHORIZATION_ERROR',
  });
}
