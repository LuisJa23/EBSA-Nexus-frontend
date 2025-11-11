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
    print('📊 [AnalyticsDashboard] Building widget...');
    
    final dashboardAsync = ref.watch(
      analyticsDashboardProvider(_currentFilter),
    );

    print('📊 [AnalyticsDashboard] dashboardAsync state: ${dashboardAsync.runtimeType}');

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Análisis y Estadísticas'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filtrar',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              print('📊 [AnalyticsDashboard] Refresh button pressed');
              ref.invalidate(analyticsDashboardProvider);
            },
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: dashboardAsync.when(
        data: (dashboard) {
          print('✅ [AnalyticsDashboard] Data loaded successfully');
          print('   Total novelties: ${dashboard.overview.totalNovelties}');
          print('   Resolved: ${dashboard.overview.resolvedNovelties}');
          print('   Pending: ${dashboard.overview.pendingNovelties}');
          
          return RefreshIndicator(
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
          );
        },
        loading: () {
          print('⏳ [AnalyticsDashboard] Loading state');
          return const Center(child: CircularProgressIndicator());
        },
        error: (error, stackTrace) {
          print('❌ [AnalyticsDashboard] Error state: $error');
          print('❌ [AnalyticsDashboard] StackTrace: $stackTrace');
          
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
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
                    onPressed: () {
                      print('🔄 [AnalyticsDashboard] Retry button pressed');
                      ref.invalidate(analyticsDashboardProvider);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.filter_list, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getFilterDescription(),
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: AppColors.primary, size: 20),
            onPressed: () {
              setState(() {
                _currentFilter = null;
              });
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
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
    return Container(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: AppColors.primary,
            width: 4,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Text(
          title,
          style: AppTextStyles.heading2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildKPICards(overview) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Si el ancho es pequeño, usar columna; si es grande, usar fila
        final useColumn = constraints.maxWidth < 600;
        
        if (useColumn) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StatsCard(
                title: 'Total Novedades',
                value: overview.totalNovelties.toString(),
                icon: Icons.assignment,
                color: AppColors.primary,
              ),
              const SizedBox(height: 12),
              StatsCard(
                title: 'Resueltas',
                value: overview.resolvedNovelties.toString(),
                icon: Icons.check_circle,
                color: AppColors.success,
              ),
              const SizedBox(height: 12),
              StatsCard(
                title: 'Pendientes',
                value: overview.pendingNovelties.toString(),
                icon: Icons.pending,
                color: AppColors.warning,
              ),
            ],
          );
        } else {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: StatsCard(
                  title: 'Total Novedades',
                  value: overview.totalNovelties.toString(),
                  icon: Icons.assignment,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: StatsCard(
                  title: 'Resueltas',
                  value: overview.resolvedNovelties.toString(),
                  icon: Icons.check_circle,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
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
      },
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPeriodButton('Diario', 'daily'),
          _buildPeriodButton('Semanal', 'weekly'),
          _buildPeriodButton('Mensual', 'monthly'),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String label, String value) {
    final isSelected = _selectedPeriod == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPeriod = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[700],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopUsersTable(List topUsers) {
    if (topUsers.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.people_outline, size: 48, color: Colors.grey),
                SizedBox(height: 12),
                Text(
                  'No hay datos de usuarios disponibles',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            AppColors.primary.withOpacity(0.1),
          ),
          dataRowMinHeight: 56,
          dataRowMaxHeight: 72,
          columnSpacing: 16,
          horizontalMargin: 16,
          columns: const [
            DataColumn(
              label: Text(
                'Usuario',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Resueltas',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Tiempo Prom.',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
          rows: topUsers.asMap().entries.map((entry) {
            final index = entry.key;
            final user = entry.value;
            return DataRow(
              color: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
                  if (index % 2 == 0) {
                    return Colors.grey.withOpacity(0.05);
                  }
                  return null;
                },
              ),
              cells: [
                DataCell(
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primary.withOpacity(0.2),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            user.fullName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      user.noveltiesCompleted.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    '${user.averageResolutionTimeHours.toStringAsFixed(1)}h',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMunicipalityTable(List municipalities) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 400),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                AppColors.secondary.withOpacity(0.1),
              ),
              dataRowMinHeight: 52,
              dataRowMaxHeight: 68,
              columnSpacing: 12,
              horizontalMargin: 16,
              columns: const [
                DataColumn(
                  label: Text(
                    'Municipio',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Total',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Completas',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Pendientes',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
              rows: municipalities.asMap().entries.map((entry) {
                final index = entry.key;
                final m = entry.value;
                return DataRow(
                  color: WidgetStateProperty.resolveWith<Color?>(
                    (Set<WidgetState> states) {
                      if (index % 2 == 0) {
                        return Colors.grey.withOpacity(0.05);
                      }
                      return null;
                    },
                  ),
                  cells: [
                    DataCell(
                      Row(
                        children: [
                          Icon(
                            Icons.location_city,
                            size: 18,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            m.municipality,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          m.totalNovelties.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          m.completed.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          m.pending.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
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
