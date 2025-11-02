// crew_performance_bar_chart.dart
// Gráfica de barras para rendimiento de cuadrillas

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/analytics_stats.dart';

class CrewPerformanceBarChart extends StatelessWidget {
  final List<CrewPerformance> crews;

  const CrewPerformanceBarChart({super.key, required this.crews});

  @override
  Widget build(BuildContext context) {
    if (crews.isEmpty) {
      return const Card(
        child: SizedBox(
          height: 300,
          child: Center(child: Text('No hay datos de cuadrillas')),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _calculateMaxY(),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final crew = crews[group.x.toInt()];
                        String label;
                        if (rodIndex == 0) {
                          label = 'Completadas: ${crew.completedNovelties}';
                        } else {
                          label = 'Pendientes: ${crew.pendingNovelties}';
                        }
                        return BarTooltipItem(
                          '${crew.crewName}\n',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < crews.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                _shortenCrewName(crews[index].crewName),
                                style: const TextStyle(fontSize: 10),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                        reservedSize: 42,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 42,
                        interval: _calculateYInterval(),
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  barGroups: crews.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.completedNovelties.toDouble(),
                          color: AppColors.success,
                          width: 16,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                        ),
                        BarChartRodData(
                          toY: entry.value.pendingNovelties.toDouble(),
                          color: AppColors.warning,
                          width: 16,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: _calculateYInterval(),
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade300,
                        strokeWidth: 1,
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  double _calculateMaxY() {
    double max = 0;
    for (final crew in crews) {
      final total = crew.completedNovelties + crew.pendingNovelties.toDouble();
      if (total > max) max = total;
    }
    return (max * 1.2).ceilToDouble();
  }

  double _calculateYInterval() {
    final maxY = _calculateMaxY();
    if (maxY <= 10) return 2;
    if (maxY <= 50) return 10;
    if (maxY <= 100) return 20;
    return 50;
  }

  String _shortenCrewName(String name) {
    // Si el nombre es muy largo, tomar solo las primeras palabras
    final words = name.split(' ');
    if (words.length > 2) {
      return '${words[0]} ${words[1]}...';
    }
    if (name.length > 15) {
      return '${name.substring(0, 12)}...';
    }
    return name;
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(color: AppColors.success, label: 'Completadas'),
        const SizedBox(width: 24),
        _LegendItem(color: AppColors.warning, label: 'Pendientes'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
