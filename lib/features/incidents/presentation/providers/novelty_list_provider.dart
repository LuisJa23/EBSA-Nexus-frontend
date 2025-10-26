// novelty_list_provider.dart
//
// Provider para gestión de estado de lista de novedades
//
// PROPÓSITO:
// - Gestionar estado de carga, error y datos de novedades
// - Implementar paginación
// - Manejar filtros
//
// CAPA: PRESENTATION LAYER - PROVIDERS

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/novelty.dart';
import '../../domain/repositories/novelty_repository.dart';
import '../../domain/usecases/get_novelties.dart';

/// Estados posibles de carga de novedades
enum NoveltyListStatus {
  initial,
  loading,
  loadingMore,
  success,
  error,
}

/// Estado de la lista de novedades
class NoveltyListState {
  final NoveltyListStatus status;
  final List<Novelty> novelties;
  final String? errorMessage;
  final int currentPage;
  final int totalPages;
  final int totalElements;
  final bool hasMore;
  
  // Filtros
  final NoveltyStatus? statusFilter;
  final NoveltyPriority? priorityFilter;
  final int? areaIdFilter;
  final int? crewIdFilter;
  final String sortField;
  final String sortDirection;

  const NoveltyListState({
    this.status = NoveltyListStatus.initial,
    this.novelties = const [],
    this.errorMessage,
    this.currentPage = 0,
    this.totalPages = 0,
    this.totalElements = 0,
    this.hasMore = true,
    this.statusFilter,
    this.priorityFilter,
    this.areaIdFilter,
    this.crewIdFilter,
    this.sortField = 'createdAt',
    this.sortDirection = 'DESC',
  });

  bool get isLoading => status == NoveltyListStatus.loading;
  bool get isLoadingMore => status == NoveltyListStatus.loadingMore;
  bool get isEmpty => novelties.isEmpty && status == NoveltyListStatus.success;
  bool get hasFilters =>
      statusFilter != null ||
      priorityFilter != null ||
      areaIdFilter != null ||
      crewIdFilter != null;

  NoveltyListState copyWith({
    NoveltyListStatus? status,
    List<Novelty>? novelties,
    String? errorMessage,
    int? currentPage,
    int? totalPages,
    int? totalElements,
    bool? hasMore,
    NoveltyStatus? statusFilter,
    NoveltyPriority? priorityFilter,
    int? areaIdFilter,
    int? crewIdFilter,
    String? sortField,
    String? sortDirection,
    bool clearError = false,
    bool clearStatusFilter = false,
    bool clearPriorityFilter = false,
    bool clearAreaFilter = false,
    bool clearCrewFilter = false,
  }) {
    return NoveltyListState(
      status: status ?? this.status,
      novelties: novelties ?? this.novelties,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalElements: totalElements ?? this.totalElements,
      hasMore: hasMore ?? this.hasMore,
      statusFilter: clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      priorityFilter: clearPriorityFilter ? null : (priorityFilter ?? this.priorityFilter),
      areaIdFilter: clearAreaFilter ? null : (areaIdFilter ?? this.areaIdFilter),
      crewIdFilter: clearCrewFilter ? null : (crewIdFilter ?? this.crewIdFilter),
      sortField: sortField ?? this.sortField,
      sortDirection: sortDirection ?? this.sortDirection,
    );
  }
}

/// Notifier para la lista de novedades
class NoveltyListNotifier extends StateNotifier<NoveltyListState> {
  final GetNovelties _getNovelties;

  NoveltyListNotifier(this._getNovelties) : super(const NoveltyListState());

  /// Carga la primera página de novedades
  Future<void> loadNovelties({bool refresh = false}) async {
    if (state.status == NoveltyListStatus.loading) return;

    if (refresh) {
      state = state.copyWith(
        status: NoveltyListStatus.loading,
        currentPage: 0,
        novelties: [],
        clearError: true,
      );
    } else {
      state = state.copyWith(
        status: NoveltyListStatus.loading,
        clearError: true,
      );
    }

    final filters = NoveltyFilters(
      page: 0,
      size: 10,
      sort: state.sortField,
      direction: state.sortDirection,
      status: state.statusFilter,
      priority: state.priorityFilter,
      areaId: state.areaIdFilter,
      crewId: state.crewIdFilter,
    );

    final result = await _getNovelties(filters);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: NoveltyListStatus.error,
          errorMessage: failure.message,
        );
      },
      (page) {
        state = state.copyWith(
          status: NoveltyListStatus.success,
          novelties: page.novelties,
          currentPage: page.currentPage,
          totalPages: page.totalPages,
          totalElements: page.totalElements,
          hasMore: page.hasMore,
        );
      },
    );
  }

  /// Carga la siguiente página (scroll infinito)
  Future<void> loadMore() async {
    if (!state.hasMore || state.status == NoveltyListStatus.loadingMore) {
      return;
    }

    state = state.copyWith(status: NoveltyListStatus.loadingMore);

    final filters = NoveltyFilters(
      page: state.currentPage + 1,
      size: 10,
      sort: state.sortField,
      direction: state.sortDirection,
      status: state.statusFilter,
      priority: state.priorityFilter,
      areaId: state.areaIdFilter,
      crewId: state.crewIdFilter,
    );

    final result = await _getNovelties(filters);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: NoveltyListStatus.success,
          errorMessage: failure.message,
        );
      },
      (page) {
        final updatedNovelties = [...state.novelties, ...page.novelties];
        state = state.copyWith(
          status: NoveltyListStatus.success,
          novelties: updatedNovelties,
          currentPage: page.currentPage,
          totalPages: page.totalPages,
          totalElements: page.totalElements,
          hasMore: page.hasMore,
          clearError: true,
        );
      },
    );
  }

  /// Aplica filtro por estado
  void setStatusFilter(NoveltyStatus? status) {
    state = state.copyWith(
      statusFilter: status,
      clearStatusFilter: status == null,
    );
    loadNovelties(refresh: true);
  }

  /// Aplica filtro por prioridad
  void setPriorityFilter(NoveltyPriority? priority) {
    state = state.copyWith(
      priorityFilter: priority,
      clearPriorityFilter: priority == null,
    );
    loadNovelties(refresh: true);
  }

  /// Aplica filtro por área
  void setAreaFilter(int? areaId) {
    state = state.copyWith(
      areaIdFilter: areaId,
      clearAreaFilter: areaId == null,
    );
    loadNovelties(refresh: true);
  }

  /// Aplica filtro por cuadrilla
  void setCrewFilter(int? crewId) {
    state = state.copyWith(
      crewIdFilter: crewId,
      clearCrewFilter: crewId == null,
    );
    loadNovelties(refresh: true);
  }

  /// Cambia el ordenamiento
  void setSorting(String field, String direction) {
    state = state.copyWith(
      sortField: field,
      sortDirection: direction,
    );
    loadNovelties(refresh: true);
  }

  /// Limpia todos los filtros
  void clearFilters() {
    state = state.copyWith(
      clearStatusFilter: true,
      clearPriorityFilter: true,
      clearAreaFilter: true,
      clearCrewFilter: true,
      sortField: 'createdAt',
      sortDirection: 'DESC',
    );
    loadNovelties(refresh: true);
  }

  /// Refresca la lista (pull-to-refresh)
  Future<void> refresh() async {
    await loadNovelties(refresh: true);
  }
}

