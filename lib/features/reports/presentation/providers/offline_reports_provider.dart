// offline_reports_provider.dart
//
// Provider para gestión de reportes offline
//
// PROPÓSITO:
// - Gestionar estado de reportes pendientes
// - Cargar reportes locales
// - Actualizar UI cuando cambien los reportes
//
// CAPA: PRESENTATION LAYER

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/dependency_injection/injection_container.dart';
import '../../data/models/report_model.dart';
import '../../domain/usecases/get_pending_reports_usecase.dart';

/// Estado de reportes offline
class OfflineReportsState {
  final List<ReportModel> reports;
  final bool isLoading;
  final String? error;

  const OfflineReportsState({
    this.reports = const [],
    this.isLoading = false,
    this.error,
  });

  OfflineReportsState copyWith({
    List<ReportModel>? reports,
    bool? isLoading,
    String? error,
  }) {
    return OfflineReportsState(
      reports: reports ?? this.reports,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier para gestionar reportes offline
class OfflineReportsNotifier extends StateNotifier<OfflineReportsState> {
  final GetPendingReportsUseCase _getPendingReports;

  OfflineReportsNotifier(this._getPendingReports)
    : super(const OfflineReportsState());

  /// Carga los reportes pendientes
  Future<void> loadPendingReports() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getPendingReports();

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (reports) => state = state.copyWith(isLoading: false, reports: reports),
    );
  }

  /// Refresca la lista de reportes
  Future<void> refresh() async {
    await loadPendingReports();
  }
}

/// Provider principal para reportes offline
final offlineReportsProvider =
    StateNotifierProvider<OfflineReportsNotifier, OfflineReportsState>((ref) {
      return OfflineReportsNotifier(sl<GetPendingReportsUseCase>());
    });
