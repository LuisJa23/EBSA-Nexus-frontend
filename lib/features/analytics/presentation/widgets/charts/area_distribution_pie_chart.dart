// area_distribution_pie_chart.dart
// Gráfica de torta para distribución por área

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_text_styles.dart';

class AreaDistributionPieChart extends StatelessWidget {
  final Map<String, int> data;

  const AreaDistributionPieChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Card(
        child: SizedBox(
          height: 250,
          child: Center(child: Text('No hay datos disponibles')),
        ),
      );
    }

    final total = data.values.fold<int>(0, (sum, value) => sum + value);
    if (total == 0) {
      return const Card(
        child: SizedBox(
          height: 250,
          child: Center(child: Text('No hay datos disponibles')),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: _getSections(total),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  borderData: FlBorderData(show: false),
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

  List<PieChartSectionData> _getSections(int total) {
    final colors = _getAreaColors();

    return data.entries.map((entry) {
      final percentage = (entry.value / total * 100);
      final color = colors[entry.key] ?? Colors.grey;

      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Map<String, Color> _getAreaColors() {
    return {
      'FACTURACION': Colors.blue.shade600,
      'CARTERA': Colors.purple.shade600,
      'PERDIDAS': Colors.red.shade600,
    };
  }

  Widget _buildLegend() {
    final colors = _getAreaColors();

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: data.entries.map((entry) {
        final color = colors[entry.key] ?? Colors.grey;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
            Text(
              '${_getAreaLabel(entry.key)}: ${entry.value}',
              style: AppTextStyles.bodySmall,
            ),
          ],
        );
      }).toList(),
    );
  }

  String _getAreaLabel(String area) {
    switch (area) {
      case 'FACTURACION':
        return 'Facturación';
      case 'CARTERA':
        return 'Cartera';
      case 'PERDIDAS':
        return 'Pérdidas';
      default:
        return area;
    }
  }
}
