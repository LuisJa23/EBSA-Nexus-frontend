// sync_reports_page.dart
//
// Página para sincronizar reportes offline
//
// PROPÓSITO:
// - Sincronizar reportes pendientes con el servidor
// - Mostrar progreso de sincronización
// - Manejar errores por reporte
// - Permitir reintentos manuales
//
// CAPA: PRESENTATION LAYER

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/offline_reports_provider.dart';
import '../providers/pending_count_provider.dart';
import '../providers/sync_reports_provider.dart';

/// Página para sincronizar reportes offline
class SyncReportsPage extends ConsumerWidget {
  const SyncReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncReportsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sincronizar Reportes')),
      body: _buildBody(context, ref, syncState),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    SyncReportsState state,
  ) {
    if (state.isIdle) {
      return _buildIdleView(context, ref);
    } else if (state.isSyncing) {
      return _buildSyncingView(context, state);
    } else if (state.isCompleted) {
      return _buildCompletedView(context, ref, state);
    } else {
      return _buildErrorView(context, ref, state);
    }
  }

  /// Vista cuando está inactivo
  Widget _buildIdleView(BuildContext context, WidgetRef ref) {
    final reportsState = ref.watch(offlineReportsProvider);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_upload, size: 80, color: Colors.blue.shade300),
            const SizedBox(height: 24),
            Text(
              'Sincronizar Reportes',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              reportsState.reports.isEmpty
                  ? 'No hay reportes pendientes para sincronizar'
                  : 'Tienes ${reportsState.reports.length} reporte(s) pendiente(s)',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (reportsState.reports.isNotEmpty)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref.read(syncReportsProvider.notifier).syncReports();
                  },
                  icon: const Icon(Icons.sync),
                  label: const Text('Iniciar Sincronización'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Vista durante la sincronización
  Widget _buildSyncingView(BuildContext context, SyncReportsState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              'Sincronizando...',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Por favor espera mientras se suben los reportes',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            LinearProgressIndicator(
              value: state.progress,
              backgroundColor: Colors.grey.shade200,
            ),
          ],
        ),
      ),
    );
  }

  /// Vista cuando se completó
  Widget _buildCompletedView(
    BuildContext context,
    WidgetRef ref,
    SyncReportsState state,
  ) {
    final result = state.result;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 80, color: Colors.green.shade400),
            const SizedBox(height: 24),
            Text(
              '¡Sincronización Completada!',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (result != null) ...[
              Text(
                'Exitosos: ${result.successCount}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (result.failureCount > 0)
                Text(
                  'Fallidos: ${result.failureCount}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Refrescar listas
                  ref.read(offlineReportsProvider.notifier).refresh();
                  ref.invalidate(autoRefreshPendingCountProvider);

                  // Resetear estado de sync
                  ref.read(syncReportsProvider.notifier).reset();

                  // Volver atrás
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Volver'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Vista cuando hubo error
  Widget _buildErrorView(
    BuildContext context,
    WidgetRef ref,
    SyncReportsState state,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red.shade300),
            const SizedBox(height: 24),
            Text(
              'Error de Sincronización',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              state.errorMessage ?? 'Error desconocido',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  ref.read(syncReportsProvider.notifier).syncReports();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                ref.read(syncReportsProvider.notifier).reset();
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }
}
