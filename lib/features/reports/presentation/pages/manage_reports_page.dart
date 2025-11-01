// manage_reports_page.dart
//
// Página principal de gestión de reportes offline
//
// PROPÓSITO:
// - Hub central para reportes offline
// - Mostrar lista de reportes pendientes
// - Acceso a creación y sincronización
//
// CAPA: PRESENTATION LAYER

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/offline_reports_provider.dart';
import '../providers/pending_count_provider.dart';
import '../widgets/offline_report_card.dart';
import 'sync_reports_page.dart';

/// Página principal de gestión de reportes offline
///
/// Permite:
/// - Ver reportes pendientes de sincronización
/// - Crear nuevos reportes offline
/// - Acceder a sincronización
class ManageReportsPage extends ConsumerStatefulWidget {
  const ManageReportsPage({super.key});

  @override
  ConsumerState<ManageReportsPage> createState() => _ManageReportsPageState();
}

class _ManageReportsPageState extends ConsumerState<ManageReportsPage> {
  @override
  void initState() {
    super.initState();
    // Cargar reportes al iniciar
    Future.microtask(
      () => ref.read(offlineReportsProvider.notifier).loadPendingReports(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reportsState = ref.watch(offlineReportsProvider);
    final pendingCountAsync = ref.watch(autoRefreshPendingCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Reportes'),
        actions: [
          // Badge con contador de pendientes
          pendingCountAsync.when(
            data: (count) => count > 0
                ? Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Chip(
                      label: Text('$count pendiente${count > 1 ? 's' : ''}'),
                      backgroundColor: Colors.orange.shade100,
                      labelStyle: TextStyle(
                        color: Colors.orange.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Botones de acción
          _buildActionButtons(context),

          const Divider(height: 1),

          // Lista de reportes pendientes
          Expanded(child: _buildReportsList(reportsState)),
        ],
      ),
    );
  }

  /// Construye los botones de acción
  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Botón Crear Reporte
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // Navegar a página de selección de novedad para reporte offline
                context.push('/select-novelty-for-offline-report');
              },
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Crear Reporte'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Botón Sincronizar
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SyncReportsPage()),
                );
              },
              icon: const Icon(Icons.sync),
              label: const Text('Sincronizar'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye la lista de reportes
  Widget _buildReportsList(OfflineReportsState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Error al cargar reportes',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              state.error!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(offlineReportsProvider.notifier).refresh();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (state.reports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Colors.green.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay reportes pendientes',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Todos tus reportes están sincronizados',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(offlineReportsProvider.notifier).refresh();
        ref.invalidate(autoRefreshPendingCountProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.reports.length,
        itemBuilder: (context, index) {
          final report = state.reports[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: OfflineReportCard(
              report: report,
              onTap: () {
                // TODO: Navegar a detalle del reporte
                // context.push('/reports/${report.id}');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vista de detalle en desarrollo'),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
