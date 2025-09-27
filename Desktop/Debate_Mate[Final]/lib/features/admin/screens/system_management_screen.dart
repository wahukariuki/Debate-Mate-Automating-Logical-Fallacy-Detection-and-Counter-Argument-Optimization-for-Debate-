import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/admin_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/system_health_widget.dart';
import '../widgets/model_metrics_widget.dart';
import '../widgets/feature_toggles.dart';
import '../widgets/responsive_tab_bar.dart';

/// Screen for system and model management
class SystemManagementScreen extends ConsumerStatefulWidget {
  const SystemManagementScreen({super.key});

  @override
  ConsumerState<SystemManagementScreen> createState() => _SystemManagementScreenState();
}

class _SystemManagementScreenState extends ConsumerState<SystemManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load system data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(systemHealthProvider.notifier).loadSystemHealth();
      ref.read(modelMetricsProvider.notifier).loadModelMetrics();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final systemHealth = ref.watch(systemHealthProvider);
    final modelMetrics = ref.watch(modelMetricsProvider);

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
              _buildHeader(theme, systemHealth, modelMetrics),
              
              // Tab bar
              _buildTabBar(theme),
              
              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildSystemHealthTab(theme, systemHealth),
                    _buildModelManagementTab(theme, modelMetrics),
                    _buildFeatureManagementTab(theme),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, SystemHealthState systemHealth, ModelMetricsState modelMetrics) {
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
                  'System & Model Management',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0),
                
                Text(
                  'Monitor system health and manage AI models',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideX(begin: -0.2, end: 0),
              ],
            ),
          ),
          
          // Refresh button
          IconButton(
            onPressed: () {
              ref.read(systemHealthProvider.notifier).refresh();
              ref.read(modelMetricsProvider.notifier).refresh();
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh system data',
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.surface,
              foregroundColor: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    return ResponsiveTabBar(
      controller: _tabController,
      tabs: const [
        TabData.withIcon(
          text: 'System Health',
          icon: Icons.monitor_heart_outlined,
        ),
        TabData.withIcon(
          text: 'AI Models',
          icon: Icons.psychology_outlined,
        ),
        TabData.withIcon(
          text: 'Features',
          icon: Icons.settings_outlined,
        ),
      ],
    ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideY(begin: 0.3, end: 0);
  }

  Widget _buildSystemHealthTab(ThemeData theme, SystemHealthState systemHealth) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          SystemHealthWidget(
            health: systemHealth.health,
            isLoading: systemHealth.isLoading,
            error: systemHealth.error,
            onRefresh: () => ref.read(systemHealthProvider.notifier).refresh(),
          ),
          
          const SizedBox(height: 24),
          
          _buildSystemAlerts(theme),
          
          const SizedBox(height: 24),
          
          _buildSystemLogs(theme),
        ],
      ),
    );
  }

  Widget _buildModelManagementTab(ThemeData theme, ModelMetricsState modelMetrics) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          ModelMetricsWidget(
            metrics: modelMetrics.metrics,
            isLoading: modelMetrics.isLoading,
            error: modelMetrics.error,
            onRefresh: () => ref.read(modelMetricsProvider.notifier).refresh(),
            onDeployModel: _deployModelUpdate,
          ),
          
          const SizedBox(height: 24),
          
          _buildModelTraining(theme),
          
          const SizedBox(height: 24),
          
          _buildBiasMonitoring(theme, modelMetrics),
        ],
      ),
    );
  }

  Widget _buildFeatureManagementTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          FeatureToggles(
            onToggleFeature: _toggleFeature,
          ),
          
          const SizedBox(height: 24),
          
          _buildGlobalSettings(theme),
          
          const SizedBox(height: 24),
          
          _buildNotificationSettings(theme),
        ],
      ),
    );
  }

  Widget _buildSystemAlerts(ThemeData theme) {
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
            'System Alerts',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          
          // Mock alerts
          _buildAlertItem(
            theme,
            'High CPU Usage',
            'CPU usage is at 85%. Consider scaling resources.',
            Icons.warning_outlined,
            Colors.orange,
          ),
          
          const SizedBox(height: 12),
          
          _buildAlertItem(
            theme,
            'Model Latency Alert',
            'RoBERTa model response time is above threshold.',
            Icons.timer_outlined,
            Colors.red,
          ),
          
          const SizedBox(height: 12),
          
          _buildAlertItem(
            theme,
            'Database Connection',
            'All database connections are healthy.',
            Icons.check_circle_outline,
            Colors.green,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 600.ms).slideY(begin: 0.3, end: 0);
  }

  Widget _buildSystemLogs(ThemeData theme) {
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
          Row(
            children: [
              Text(
                'Recent System Logs',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  // Navigate to full logs view
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Full logs view coming soon'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Container(
            height: 200,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLogEntry('2024-01-15 14:30:22', 'INFO', 'User authentication successful'),
                  _buildLogEntry('2024-01-15 14:29:15', 'WARN', 'High memory usage detected'),
                  _buildLogEntry('2024-01-15 14:28:45', 'INFO', 'Model inference completed'),
                  _buildLogEntry('2024-01-15 14:27:12', 'ERROR', 'Database connection timeout'),
                  _buildLogEntry('2024-01-15 14:26:33', 'INFO', 'System health check passed'),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 800.ms).slideY(begin: 0.3, end: 0);
  }

  Widget _buildModelTraining(ThemeData theme) {
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
            'Model Training',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showTrainingDialog();
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Training'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Upload dataset feature coming soon'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  },
                  icon: const Icon(Icons.upload),
                  label: const Text('Upload Dataset'),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildTrainingProgress(theme),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 600.ms).slideY(begin: 0.3, end: 0);
  }

  Widget _buildBiasMonitoring(ThemeData theme, ModelMetricsState modelMetrics) {
    final biasStats = modelMetrics.metrics['biasStats'] as Map<String, dynamic>? ?? {};
    
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
            'Bias Monitoring',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildBiasMetric(
                  theme,
                  'Accent Bias',
                  biasStats['accentBias']?.toStringAsFixed(1) ?? '0.0',
                  Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildBiasMetric(
                  theme,
                  'Gender Bias',
                  biasStats['genderBias']?.toStringAsFixed(1) ?? '0.0',
                  Colors.orange,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildBiasMetric(
                  theme,
                  'Cultural Bias',
                  biasStats['culturalBias']?.toStringAsFixed(1) ?? '0.0',
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildBiasMetric(
                  theme,
                  'Overall Bias',
                  biasStats['overallBias']?.toStringAsFixed(1) ?? '0.0',
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 800.ms).slideY(begin: 0.3, end: 0);
  }

  Widget _buildGlobalSettings(ThemeData theme) {
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
            'Global Settings',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildSettingItem(
            theme,
            'Fallacy Types',
            'Configure the 13 logical fallacy types',
            Icons.list_outlined,
            () => _showFallacyTypesDialog(),
          ),
          
          _buildSettingItem(
            theme,
            'Notification Settings',
            'Configure system notifications',
            Icons.notifications_outlined,
            () => _showNotificationSettings(),
          ),
          
          _buildSettingItem(
            theme,
            'Backup Settings',
            'Configure automated backups',
            Icons.backup_outlined,
            () => _showBackupSettings(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 600.ms).slideY(begin: 0.3, end: 0);
  }

  Widget _buildNotificationSettings(ThemeData theme) {
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
            'Notification Preferences',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          
          SwitchListTile(
            title: const Text('System Alerts'),
            subtitle: const Text('Receive notifications for system issues'),
            value: true,
            onChanged: (value) {},
          ),
          
          SwitchListTile(
            title: const Text('Model Updates'),
            subtitle: const Text('Notifications when models are updated'),
            value: false,
            onChanged: (value) {},
          ),
          
          SwitchListTile(
            title: const Text('User Reports'),
            subtitle: const Text('Notifications for user-generated reports'),
            value: true,
            onChanged: (value) {},
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 800.ms).slideY(begin: 0.3, end: 0);
  }

  Widget _buildAlertItem(ThemeData theme, String title, String message, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogEntry(String timestamp, String level, String message) {
    final theme = Theme.of(context);
    Color levelColor = Colors.grey;
    
    switch (level) {
      case 'ERROR':
        levelColor = Colors.red;
        break;
      case 'WARN':
        levelColor = Colors.orange;
        break;
      case 'INFO':
        levelColor = Colors.blue;
        break;
    }
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              timestamp,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontFamily: 'monospace',
              ),
            ),
          ),
          Container(
            width: 50,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: levelColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              level,
              style: TextStyle(
                color: levelColor,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainingProgress(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current Training Status',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: 0.65,
          backgroundColor: theme.colorScheme.outline.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
        const SizedBox(height: 8),
        Text(
          'Training RoBERTa model - 65% complete',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildBiasMetric(ThemeData theme, String name, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Text(
            name,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(ThemeData theme, String title, String subtitle, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Future<void> _deployModelUpdate(String version) async {
    // Implement model deployment
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deploying model version $version...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<void> _toggleFeature(String featureName, bool enabled) async {
    // Implement feature toggle
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${enabled ? 'Enabling' : 'Disabling'} $featureName...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showTrainingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Model Training'),
        content: const Text('Are you sure you want to start training a new model? This process may take several hours.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Model training started successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Start Training'),
          ),
        ],
      ),
    );
  }

  void _showFallacyTypesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configure Fallacy Types'),
        content: const Text('Fallacy types configuration feature coming soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification settings feature coming soon'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showBackupSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Backup settings feature coming soon'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
