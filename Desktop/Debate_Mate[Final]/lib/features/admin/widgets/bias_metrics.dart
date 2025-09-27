import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Widget for displaying bias detection metrics
class BiasMetrics extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isLoading;

  const BiasMetrics({
    super.key,
    required this.data,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (isLoading) {
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (data.isEmpty) {
      return SizedBox(
        height: 300,
        child: Center(
          child: Text(
            'No bias data available',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    final biasTypes = [
      {'name': 'Accent Bias', 'value': data['accentBias'] ?? 0.0, 'color': Colors.red},
      {'name': 'Gender Bias', 'value': data['genderBias'] ?? 0.0, 'color': Colors.orange},
      {'name': 'Cultural Bias', 'value': data['culturalBias'] ?? 0.0, 'color': Colors.blue},
      {'name': 'Overall Bias', 'value': data['overallBias'] ?? 0.0, 'color': Colors.purple},
    ];

    return Column(
      children: [
        // Bias radar chart
        SizedBox(
          height: 250,
          child: RadarChart(
            RadarChartData(
              dataSets: [
                RadarDataSet(
                  fillColor: Colors.blue.withOpacity(0.3),
                  borderColor: Colors.blue,
                  entryRadius: 3,
                  dataEntries: biasTypes.map((bias) {
                    return RadarEntry(value: (bias['value'] as double) * 10);
                  }).toList(),
                ),
              ],
              radarBorderData: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.3),
                width: 1,
              ),
              titlePositionPercentageOffset: 0.2,
              titleTextStyle: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              getTitle: (index, angle) {
                return RadarChartTitle(
                  text: biasTypes[index]['name'] as String,
                  angle: angle,
                  positionPercentageOffset: 0.1,
                );
              },
              ticksTextStyle: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              gridBorderData: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
              tickBorderData: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Bias metrics cards
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.5,
          children: biasTypes.map((bias) => _buildBiasCard(theme, bias)).toList(),
        ),
        
        const SizedBox(height: 16),
        
        // Bias explanation
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.blue.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Lower bias scores indicate better fairness. Scores above 3.0 require attention.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBiasCard(ThemeData theme, Map<String, dynamic> bias) {
    final name = bias['name'] as String;
    final value = bias['value'] as double;
    final color = bias['color'] as Color;
    
    final biasLevel = _getBiasLevel(value);
    final isHigh = value > 3.0;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isHigh ? Colors.red.withOpacity(0.1) : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHigh ? Colors.red.withOpacity(0.3) : color.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isHigh ? Colors.red : color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                value.toStringAsFixed(1),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isHigh ? Colors.red : color,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getBiasLevelColor(biasLevel).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  biasLevel,
                  style: TextStyle(
                    color: _getBiasLevelColor(biasLevel),
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getBiasLevel(double value) {
    if (value <= 1.0) return 'Low';
    if (value <= 2.0) return 'Medium';
    if (value <= 3.0) return 'High';
    return 'Critical';
  }

  Color _getBiasLevelColor(String level) {
    switch (level) {
      case 'Low':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'High':
        return Colors.red;
      case 'Critical':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
