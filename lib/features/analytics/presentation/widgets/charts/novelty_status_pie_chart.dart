// novelty_status_pie_chart.dart
// Gráfica de torta para distribución por estado

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class NoveltyStatusPieChart extends StatelessWidget {
  final Map<String, int> data;

  const NoveltyStatusPieChart({super.key, required this.data});

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
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {},
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

  List<PieChartSectionData> _getSections(int total) {
    final colors = _getStatusColors();

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
        badgeWidget: _Badge(entry.key, size: 40, borderColor: color),
        badgePositionPercentageOffset: 1.4,
      );
    }).toList();
  }

  Map<String, Color> _getStatusColors() {
    return {
      'CREADA': Colors.blue,
      'EN_CURSO': Colors.orange,
      'COMPLETADA': AppColors.success,
      'CERRADA': Colors.green.shade700,
      'CANCELADA': AppColors.error,
    };
  }

  Widget _buildLegend() {
    final colors = _getStatusColors();

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
              '${_getStatusLabel(entry.key)}: ${entry.value}',
              style: AppTextStyles.bodySmall,
            ),
          ],
        );
      }).toList(),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'CREADA':
        return 'Creada';
      case 'EN_CURSO':
        return 'En Curso';
      case 'COMPLETADA':
        return 'Completada';
      case 'CERRADA':
        return 'Cerrada';
      case 'CANCELADA':
        return 'Cancelada';
      default:
        return status;
    }
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.text, {required this.size, required this.borderColor});

  final String text;
  final double size;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
        ],
      ),
    );
  }
}
