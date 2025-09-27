import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/dashboard_models.dart';

/// Progress sidebar showing debate statistics and charts
class ProgressSidebar extends StatefulWidget {
  final List<ProgressData> progressData;
  final int totalSessions;
  final int totalFallacies;
  final double averageScore;
  final VoidCallback onClose;

  const ProgressSidebar({
    super.key,
    required this.progressData,
    required this.totalSessions,
    required this.totalFallacies,
    required this.averageScore,
    required this.onClose,
  });

  @override
  State<ProgressSidebar> createState() => _ProgressSidebarState();
}

class _ProgressSidebarState extends State<ProgressSidebar>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _chartController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _chartAnimation;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _chartController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));
    
    _chartAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _chartController,
      curve: Curves.easeOut,
    ));
    
    _slideController.forward();
    _chartController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _chartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        width: 320,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            left: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(-10, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            _buildHeader(theme),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsCards(theme),
                    const SizedBox(height: 24),
                    _buildScoreChart(theme),
                    const SizedBox(height: 24),
                    _buildFallacyTrend(theme),
                    const SizedBox(height: 24),
                    _buildRecentActivity(theme),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.analytics_outlined,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Text(
            'Progress Analytics',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: widget.onClose,
            icon: const Icon(Icons.close),
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.surface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                theme,
                'Sessions',
                widget.totalSessions.toString(),
                Icons.psychology_outlined,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                theme,
                'Avg Score',
                '${(widget.averageScore * 100).round()}%',
                Icons.trending_up,
                Colors.green,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                theme,
                'Fallacies',
                widget.totalFallacies.toString(),
                Icons.warning_outlined,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                theme,
                'Improvement',
                _calculateImprovement(),
                Icons.trending_up_outlined,
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const Spacer(),
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).scale(
      begin: const Offset(0.8, 0.8),
      end: const Offset(1.0, 1.0),
    );
  }

  Widget _buildScoreChart(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Score Trend',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: AnimatedBuilder(
            animation: _chartAnimation,
            builder: (context, child) {
              return LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 0.2,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: theme.colorScheme.outline.withOpacity(0.2),
                        strokeWidth: 1,
                      );
                    },
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
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          const style = TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          );
                          Widget text;
                          if (value.toInt() < widget.progressData.length) {
                            text = Text(
                              'S${value.toInt() + 1}',
                              style: style,
                            );
                          } else {
                            text = const Text('', style: style);
                          }
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 8,
                            child: text,
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 0.2,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              '${(value * 100).round()}%',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                        reservedSize: 42,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  minX: 0,
                  maxX: (widget.progressData.length - 1).toDouble(),
                  minY: 0,
                  maxY: 1,
                  lineBarsData: [
                    LineChartBarData(
                      spots: _getScoreSpots(),
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withOpacity(0.3),
                        ],
                      ),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: theme.colorScheme.primary,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withOpacity(0.3),
                            theme.colorScheme.primary.withOpacity(0.1),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  List<FlSpot> _getScoreSpots() {
    return widget.progressData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      return FlSpot(index.toDouble(), data.score * _chartAnimation.value);
    }).toList();
  }

  Widget _buildFallacyTrend(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fallacy Reduction',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        
        Container(
          height: 150,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: AnimatedBuilder(
            animation: _chartAnimation,
            builder: (context, child) {
              return BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: widget.progressData.isEmpty 
                      ? 10 
                      : widget.progressData.map((e) => e.fallaciesDetected).reduce((a, b) => a > b ? a : b).toDouble() + 2,
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
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              'S${value.toInt() + 1}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          );
                        },
                        reservedSize: 28,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  barGroups: _getBarGroups(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  List<BarChartGroupData> _getBarGroups() {
    return widget.progressData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data.fallaciesDetected.toDouble() * _chartAnimation.value,
            color: Colors.orange.withOpacity(0.7),
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildRecentActivity(ThemeData theme) {
    final recentData = widget.progressData.length > 3 
        ? widget.progressData.sublist(widget.progressData.length - 3)
        : widget.progressData;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Sessions',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        
        ...recentData.reversed.map((data) => _buildActivityItem(theme, data)),
      ],
    );
  }

  Widget _buildActivityItem(ThemeData theme, ProgressData data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getScoreColor(data.score),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Session ${widget.progressData.indexOf(data) + 1}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Score: ${(data.score * 100).round()}% • ${data.fallaciesDetected} fallacies',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(
      begin: -0.2,
      end: 0,
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 0.8) return Colors.green;
    if (score >= 0.6) return Colors.orange;
    return Colors.red;
  }

  String _calculateImprovement() {
    if (widget.progressData.length < 2) return 'N/A';
    
    final firstScore = widget.progressData.first.score;
    final lastScore = widget.progressData.last.score;
    final improvement = ((lastScore - firstScore) * 100).round();
    
    return improvement >= 0 ? '+$improvement%' : '$improvement%';
  }
}
