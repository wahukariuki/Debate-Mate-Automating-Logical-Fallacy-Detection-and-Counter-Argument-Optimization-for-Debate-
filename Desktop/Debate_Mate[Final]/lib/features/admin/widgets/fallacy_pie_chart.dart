import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Pie chart widget for displaying fallacy statistics
class FallacyPieChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const FallacyPieChart({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // Chart
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: _buildSections(),
              centerSpaceRadius: 40,
              sectionsSpace: 2,
              startDegreeOffset: -90,
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Legend
        _buildLegend(theme),
      ],
    );
  }

  List<PieChartSectionData> _buildSections() {
    return data.map((item) {
      final color = Color(item['color'] ?? 0xFF000000);
      final percentage = item['percentage'] ?? 0.0;
      return PieChartSectionData(
        color: color,
        value: percentage,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        badgeWidget: null,
      );
    }).toList();
  }

  Widget _buildLegend(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: data.map((item) {
        final color = Color(item['color'] ?? 0xFF000000);
        final type = item['type'] ?? 'Unknown';
        final count = item['count'] ?? 0;
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                type,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '($count)',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
