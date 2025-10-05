import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/providers/admin_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/progress_chart.dart';
import '../widgets/engagement_chart.dart';
import '../widgets/bias_metrics.dart';

/// Screen for analytics and reporting with charts and filters
class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  DateTimeRange? _selectedDateRange;
  String _selectedUserGroup = 'all';
  String _selectedMetric = 'all';

  @override
  void initState() {
    super.initState();
    // Initialize with last 30 days
    _selectedDateRange = DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 30)),
      end: DateTime.now(),
    );
    
    // Load analytics data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateFilters();
    });
  }

  void _updateFilters() {
    ref.read(analyticsProvider.notifier).updateFilters(
      startDate: _selectedDateRange?.start,
      endDate: _selectedDateRange?.end,
      userGroup: _selectedUserGroup != 'all' ? _selectedUserGroup : null,
      metric: _selectedMetric != 'all' ? _selectedMetric : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final analyticsState = ref.watch(analyticsProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: theme.brightness == Brightness.dark 
              ? AppTheme.darkBackgroundGradient 
              : AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(theme, analyticsState),
              
              // Filters
              _buildFilters(theme, analyticsState),
              
              // Content
              Expanded(
                child: _buildContent(theme, analyticsState),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, AnalyticsState state) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back),
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.surface,
              foregroundColor: theme.colorScheme.onSurface,
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analytics & Reporting',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0),
                
                Text(
                  'Platform insights and performance metrics',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideX(begin: -0.2, end: 0),
              ],
            ),
          ),
          
          // Export button
          IconButton(
            onPressed: _exportReport,
            icon: const Icon(Icons.download_outlined),
            tooltip: 'Export report',
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.surface,
              foregroundColor: theme.colorScheme.onSurface,
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Refresh button
          IconButton(
            onPressed: () => ref.read(analyticsProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh analytics',
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.surface,
              foregroundColor: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(ThemeData theme, AnalyticsState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          // Date range picker
          Row(
            children: [
              Text(
                'Date Range:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: _selectDateRange,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.colorScheme.outline),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _selectedDateRange != null
                                ? '${DateFormat('MMM dd').format(_selectedDateRange!.start)} - ${DateFormat('MMM dd, yyyy').format(_selectedDateRange!.end)}'
                                : 'Select date range',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // User group and metric filters
          Row(
            children: [
              // User group filter
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User Group:',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: _selectedUserGroup,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All Users')),
                        DropdownMenuItem(value: 'beginners', child: Text('Beginners')),
                        DropdownMenuItem(value: 'intermediate', child: Text('Intermediate')),
                        DropdownMenuItem(value: 'advanced', child: Text('Advanced')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedUserGroup = value);
                          _updateFilters();
                        }
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Metric filter
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Metric:',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: _selectedMetric,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All Metrics')),
                        DropdownMenuItem(value: 'fallacies', child: Text('Fallacy Detection')),
                        DropdownMenuItem(value: 'engagement', child: Text('User Engagement')),
                        DropdownMenuItem(value: 'quality', child: Text('Argument Quality')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedMetric = value);
                          _updateFilters();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideY(begin: 0.3, end: 0);
  }

  Widget _buildContent(ThemeData theme, AnalyticsState state) {
    if (state.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading analytics...'),
          ],
        ),
      );
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading analytics',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.error!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ref.read(analyticsProvider.notifier).refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(analyticsProvider.notifier).refresh(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Progress Chart
            _buildSection(
              theme,
              'User Progress Trends',
              'Monthly improvement in fallacy detection and argument quality',
              ProgressChart(
                data: state.analytics['userProgress'] ?? [],
                isLoading: state.isLoading,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Engagement by Topic
            _buildSection(
              theme,
              'Engagement by Topic',
              'User engagement levels across different debate topics',
              EngagementChart(
                data: state.analytics['engagementByTopic'] ?? [],
                isLoading: state.isLoading,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Bias Metrics
            _buildSection(
              theme,
              'Bias Detection Metrics',
              'AI model bias analysis across different demographics',
              BiasMetrics(
                data: state.analytics['biasStats'] ?? {},
                isLoading: state.isLoading,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Predictive Insights
            _buildPredictiveInsights(theme, state),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String title, String subtitle, Widget content) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          content,
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0);
  }

  Widget _buildPredictiveInsights(ThemeData theme, AnalyticsState state) {
    final predictions = state.analytics['predictions'] as List<dynamic>? ?? [];
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.1),
            theme.colorScheme.secondary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology_outlined,
                color: theme.colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'AI Predictive Insights',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          if (predictions.isNotEmpty)
            ...predictions.map((prediction) => _buildInsightItem(theme, prediction)).toList()
          else
            Text(
              'No predictive insights available',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 800.ms).slideY(begin: 0.3, end: 0);
  }

  Widget _buildInsightItem(ThemeData theme, dynamic prediction) {
    String text = prediction.toString();
    Color color = Colors.blue;
    IconData icon = Icons.lightbulb_outline;
    
    if (text.toLowerCase().contains('warning') || text.toLowerCase().contains('alert')) {
      color = Colors.orange;
      icon = Icons.warning_outlined;
    } else if (text.toLowerCase().contains('improve') || text.toLowerCase().contains('increase')) {
      color = Colors.green;
      icon = Icons.trending_up;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );
    
    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
      _updateFilters();
    }
  }

  Future<void> _exportReport() async {
    try {
      // Show export dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Export Report'),
          content: const Text('Choose the format for your analytics report:'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performExport('pdf');
              },
              child: const Text('PDF'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performExport('csv');
              },
              child: const Text('CSV'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening export dialog: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _performExport(String format) async {
    try {
      // This would typically generate and download the report
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exporting $format report...'),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      // Simulate export process
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$format report exported successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting report: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
