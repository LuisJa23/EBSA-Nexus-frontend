// analytics_dashboard_page.dart
// Página principal de analytics y estadísticas

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/analytics_provider.dart';
import '../widgets/charts/novelty_status_pie_chart.dart';
import '../widgets/charts/novelty_trends_line_chart.dart';
import '../widgets/charts/crew_performance_bar_chart.dart';
import '../widgets/charts/area_distribution_pie_chart.dart';
import '../widgets/stats_card.dart';

class AnalyticsDashboardPage extends ConsumerStatefulWidget {
  const AnalyticsDashboardPage({super.key});

  @override
  ConsumerState<AnalyticsDashboardPage> createState() =>
      _AnalyticsDashboardPageState();
}

class _AnalyticsDashboardPageState
    extends ConsumerState<AnalyticsDashboardPage> {
  DateRangeFilter? _currentFilter;
  String _selectedPeriod = 'monthly'; // 'daily', 'weekly', 'monthly'

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(
      analyticsDashboardProvider(_currentFilter),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Análisis y Estadísticas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(analyticsDashboardProvider);
            },
          ),
        ],
      ),
      body: dashboardAsync.when(
        data: (dashboard) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(analyticsDashboardProvider);
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filtro actual
                if (_currentFilter != null) _buildFilterChip(),
                const SizedBox(height: 16),

                // KPIs Principales
                _buildKPICards(dashboard.overview),
                const SizedBox(height: 24),

                // Distribución por Estado
                _buildSectionTitle('Distribución por Estado'),
                const SizedBox(height: 12),
                NoveltyStatusPieChart(data: dashboard.overview.byStatus),
                const SizedBox(height: 24),

                // Distribución por Área
                _buildSectionTitle('Distribución por Área'),
                const SizedBox(height: 12),
                AreaDistributionPieChart(data: dashboard.overview.byArea),
                const SizedBox(height: 24),

                // Tendencia Temporal
                _buildSectionTitle('Tendencia Temporal'),
                const SizedBox(height: 8),
                _buildPeriodSelector(),
                const SizedBox(height: 12),
                NoveltyTrendsLineChart(trends: dashboard.trends),
                const SizedBox(height: 24),

                // Rendimiento de Cuadrillas
                _buildSectionTitle('Top 5 Cuadrillas'),
                const SizedBox(height: 12),
                CrewPerformanceBarChart(
                  crews: dashboard.topCrews.take(5).toList(),
                ),
                const SizedBox(height: 24),

                // Tabla de Top Usuarios
                _buildSectionTitle('Top 5 Usuarios'),
                const SizedBox(height: 12),
                _buildTopUsersTable(dashboard.topUsers.take(5).toList()),
                const SizedBox(height: 24),

                // Distribución Geográfica
                if (dashboard.byMunicipality.isNotEmpty) ...[
                  _buildSectionTitle('Distribución por Municipio'),
                  const SizedBox(height: 12),
                  _buildMunicipalityTable(dashboard.byMunicipality),
                ],
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                'Error al cargar estadísticas',
                style: AppTextStyles.bodyLarge,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(analyticsDashboardProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip() {
    return Chip(
      label: Text(_getFilterDescription()),
      onDeleted: () {
        setState(() {
          _currentFilter = null;
        });
      },
    );
  }

  String _getFilterDescription() {
    if (_currentFilter == null) return 'Todos los datos';
    final parts = <String>[];
    if (_currentFilter!.startDate != null) {
      parts.add(
        'Desde ${DateFormat('dd/MM/yyyy').format(_currentFilter!.startDate!)}',
      );
    }
    if (_currentFilter!.endDate != null) {
      parts.add(
        'Hasta ${DateFormat('dd/MM/yyyy').format(_currentFilter!.endDate!)}',
      );
    }
    return parts.isEmpty ? 'Filtro activo' : parts.join(' - ');
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.heading2.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildKPICards(overview) {
    return Row(
      children: [
        Expanded(
          child: StatsCard(
            title: 'Total Novedades',
            value: overview.totalNovelties.toString(),
            icon: Icons.assignment,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatsCard(
            title: 'Resueltas',
            value: overview.resolvedNovelties.toString(),
            icon: Icons.check_circle,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatsCard(
            title: 'Pendientes',
            value: overview.pendingNovelties.toString(),
            icon: Icons.pending,
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: 'daily', label: Text('Diario')),
        ButtonSegment(value: 'weekly', label: Text('Semanal')),
        ButtonSegment(value: 'monthly', label: Text('Mensual')),
      ],
      selected: {_selectedPeriod},
      onSelectionChanged: (Set<String> newSelection) {
        setState(() {
          _selectedPeriod = newSelection.first;
        });
      },
    );
  }

  Widget _buildTopUsersTable(List topUsers) {
    if (topUsers.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No hay datos de usuarios disponibles'),
        ),
      );
    }

    return Card(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Usuario')),
          DataColumn(label: Text('Resueltas')),
          DataColumn(label: Text('Tiempo Prom.')),
        ],
        rows: topUsers.map((user) {
          return DataRow(
            cells: [
              DataCell(Text(user.fullName)),
              DataCell(Text(user.noveltiesCompleted.toString())),
              DataCell(
                Text('${user.averageResolutionTimeHours.toStringAsFixed(1)}h'),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMunicipalityTable(List municipalities) {
    return Card(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Municipio')),
          DataColumn(label: Text('Total')),
          DataColumn(label: Text('Completadas')),
          DataColumn(label: Text('Pendientes')),
        ],
        rows: municipalities.map((m) {
          return DataRow(
            cells: [
              DataCell(Text(m.municipality)),
              DataCell(Text(m.totalNovelties.toString())),
              DataCell(Text(m.completed.toString())),
              DataCell(Text(m.pending.toString())),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showFilterDialog() async {
    // Implementar diálogo de filtros
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (result != null) {
      setState(() {
        _currentFilter = DateRangeFilter(
          startDate: result.start,
          endDate: result.end,
        );
      });
    }
  }
}
