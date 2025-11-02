// sync_reports_provider.dart
//
// Provider para sincronización de reportes
//
// PROPÓSITO:
// - Gestionar proceso de sincronización
// - Mostrar progreso de sync
// - Manejar errores de sincronización
//
// CAPA: PRESENTATION LAYER

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/dependency_injection/injection_container.dart';
import '../../data/repositories/report_repository_impl.dart';
import '../../domain/usecases/sync_reports_usecase.dart';

/// Estados posibles de la sincronización
enum SyncStatus {
  idle, // No está sincronizando
  syncing, // Sincronizando
  completed, // Completado exitosamente
  error, // Error durante sync
}

/// Estado de sincronización
class SyncReportsState {
  final SyncStatus status;
  final SyncResult? result;
  final String? errorMessage;
  final double progress; // 0.0 a 1.0

  const SyncReportsState({
    this.status = SyncStatus.idle,
    this.result,
    this.errorMessage,
    this.progress = 0.0,
  });

  SyncReportsState copyWith({
    SyncStatus? status,
    SyncResult? result,
    String? errorMessage,
    double? progress,
  }) {
    return SyncReportsState(
      status: status ?? this.status,
      result: result ?? this.result,
      errorMessage: errorMessage,
      progress: progress ?? this.progress,
    );
  }

  bool get isIdle => status == SyncStatus.idle;
  bool get isSyncing => status == SyncStatus.syncing;
  bool get isCompleted => status == SyncStatus.completed;
  bool get hasError => status == SyncStatus.error;
}

/// Notifier para gestionar sincronización
class SyncReportsNotifier extends StateNotifier<SyncReportsState> {
  final SyncReportsUseCase _syncReports;

  SyncReportsNotifier(this._syncReports) : super(const SyncReportsState());

  /// Inicia la sincronización de reportes pendientes
  Future<void> syncReports() async {
    if (state.isSyncing) return; // Evitar múltiples syncs simultáneos

    state = state.copyWith(
      status: SyncStatus.syncing,
      progress: 0.0,
      errorMessage: null,
    );

    final result = await _syncReports();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: SyncStatus.error,
          errorMessage: failure.message,
          progress: 0.0,
        );
      },
      (syncResult) {
        state = state.copyWith(
          status: SyncStatus.completed,
          result: syncResult,
          progress: 1.0,
        );
      },
    );
  }

  /// Reinicia el estado a idle
  void reset() {
    state = const SyncReportsState();
  }
}

/// Provider principal para sincronización
final syncReportsProvider =
    StateNotifierProvider<SyncReportsNotifier, SyncReportsState>((ref) {
      return SyncReportsNotifier(sl<SyncReportsUseCase>());
    });
