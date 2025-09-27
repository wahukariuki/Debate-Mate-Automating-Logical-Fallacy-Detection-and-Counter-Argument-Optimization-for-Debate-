import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/admin_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/profile_section.dart';
import '../../admin/widgets/metrics_card.dart';
import '../../admin/widgets/activity_feed.dart';
import '../../admin/widgets/fallacy_pie_chart.dart';

/// Admin dashboard with comprehensive management features
class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    // Initialize admin data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardMetricsProvider.notifier).loadMetrics();
      ref.read(recentActivityProvider.notifier).loadActivity();
      ref.read(fallacyStatsProvider.notifier).loadStats();
      ref.read(systemHealthProvider.notifier).loadSystemHealth();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userData = ref.watch(currentUserDataProvider);
    final authNotifier = ref.read(authNotifierProvider.notifier);
    final dashboardMetrics = ref.watch(dashboardMetricsProvider);
    final recentActivity = ref.watch(recentActivityProvider);
    final fallacyStats = ref.watch(fallacyStatsProvider);
    final systemHealth = ref.watch(systemHealthProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: theme.brightness == Brightness.dark 
              ? AppTheme.darkBackgroundGradient 
              : AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                
                // Back button
                _buildBackButton(theme),
                
                const SizedBox(height: 20),
                
                // Header
                _buildHeader(theme, userData, authNotifier),
                
                const SizedBox(height: 32),
                
                // Welcome section
                _buildWelcomeSection(theme, userData),
                
                const SizedBox(height: 32),
                
                // Key metrics overview
                _buildKeyMetricsOverview(theme, dashboardMetrics),
                
                const SizedBox(height: 32),
                
                // Charts section
                _buildChartsSection(theme, fallacyStats),
                
                const SizedBox(height: 32),
                
                // Recent activity and system health
                _buildActivityAndHealthSection(theme, recentActivity, systemHealth),
                
                const SizedBox(height: 32),
                
                // Management tools
                _buildManagementTools(theme),
                
                const SizedBox(height: 32),
                
                // AI insights
                _buildAIInsights(theme),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(ThemeData theme) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            // Go back to previous page or logout
            if (Navigator.canPop(context)) {
              context.pop();
            } else {
              // If no previous page, show logout confirmation
              _showLogoutDialog(theme);
            }
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: theme.colorScheme.onSurface,
          ),
          style: IconButton.styleFrom(
            backgroundColor: theme.colorScheme.surface.withOpacity(0.8),
            foregroundColor: theme.colorScheme.onSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0);
  }

  void _showLogoutDialog(ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(authNotifierProvider.notifier).signOut();
              context.go('/login');
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, userData, AuthNotifier authNotifier) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Debate Mate',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0),
            
            Text(
              'Admin Dashboard',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideX(begin: -0.2, end: 0),
          ],
        ),
        
        const Spacer(),
        
        // Profile button
        ProfileSection(
          userData: userData,
          onSignOut: () => authNotifier.signOut(),
        ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideX(begin: 0.2, end: 0),
      ],
    );
  }

  Widget _buildWelcomeSection(ThemeData theme, userData) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.secondaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.secondary.withOpacity(0.3),
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
              Icon(
                Icons.admin_panel_settings_outlined,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Admin Panel',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ).animate().fadeIn(duration: 800.ms, delay: 600.ms).slideY(begin: 0.3, end: 0),
          
          const SizedBox(height: 8),
          
          Text(
            'Welcome, ${userData?.email.split('@')[0] ?? 'Admin'}! Manage the Debate Mate platform.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ).animate().fadeIn(duration: 800.ms, delay: 800.ms).slideY(begin: 0.3, end: 0),
        ],
      ),
    );
  }

  Widget _buildKeyMetricsOverview(ThemeData theme, DashboardMetrics dashboardMetrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Platform Overview',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            if (dashboardMetrics.isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              IconButton(
                onPressed: () => ref.read(dashboardMetricsProvider.notifier).refresh(),
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh metrics',
              ),
          ],
        ).animate().fadeIn(duration: 600.ms, delay: 1000.ms).slideX(begin: -0.2, end: 0),
        
        const SizedBox(height: 16),
        
        if (dashboardMetrics.error != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Error loading metrics: ${dashboardMetrics.error}',
                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
                  ),
                ),
              ],
            ),
          )
        else
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              MetricsCard(
                title: 'Total Users',
                value: dashboardMetrics.metrics['totalUsers']?.toString() ?? '0',
                icon: Icons.people_outline,
                color: Colors.blue,
                trend: '+12%',
                trendUp: true,
              ),
              MetricsCard(
                title: 'Active Users',
                value: dashboardMetrics.metrics['activeUsers']?.toString() ?? '0',
                icon: Icons.online_prediction,
                color: Colors.green,
                trend: '+8%',
                trendUp: true,
              ),
              MetricsCard(
                title: 'Arguments',
                value: dashboardMetrics.metrics['totalArguments']?.toString() ?? '0',
                icon: Icons.forum_outlined,
                color: Colors.purple,
                trend: '+15%',
                trendUp: true,
              ),
              MetricsCard(
                title: 'Model Accuracy',
                value: '${dashboardMetrics.metrics['modelAccuracy']?.toStringAsFixed(1) ?? '0.0'}%',
                icon: Icons.psychology_outlined,
                color: Colors.orange,
                trend: '+2.1%',
                trendUp: true,
              ),
            ],
          ).animate().fadeIn(duration: 600.ms, delay: 1200.ms).slideY(begin: 0.3, end: 0),
      ],
    );
  }

  Widget _buildChartsSection(ThemeData theme, FallacyStats fallacyStats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analytics & Insights',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ).animate().fadeIn(duration: 600.ms, delay: 1400.ms).slideX(begin: -0.2, end: 0),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
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
                        Icon(
                          Icons.pie_chart_outline,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Common Fallacies',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const Spacer(),
                        if (fallacyStats.isLoading)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: fallacyStats.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : fallacyStats.error != null
                              ? Center(
                                  child: Text(
                                    'Error loading fallacy stats',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.red,
                                    ),
                                  ),
                                )
                              : FallacyPieChart(data: fallacyStats.stats),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  _buildQuickStatCard(
                    theme,
                    'Pending Moderation',
                    '23',
                    Icons.queue_outlined,
                    Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  _buildQuickStatCard(
                    theme,
                    'System Uptime',
                    '99.9%',
                    Icons.trending_up,
                    Colors.green,
                  ),
                ],
              ),
            ),
          ],
        ).animate().fadeIn(duration: 600.ms, delay: 1600.ms).slideY(begin: 0.3, end: 0),
      ],
    );
  }

  Widget _buildActivityAndHealthSection(ThemeData theme, RecentActivity recentActivity, SystemHealthState systemHealth) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
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
            child: ActivityFeed(
              activities: recentActivity.activities,
              isLoading: recentActivity.isLoading,
              error: recentActivity.error,
              onRefresh: () => ref.read(recentActivityProvider.notifier).refresh(),
            ),
          ),
        ),
        
        const SizedBox(width: 16),
        
        Expanded(
          flex: 1,
          child: Container(
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
                    Icon(
                      Icons.monitor_heart_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'System Health',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    if (systemHealth.isLoading)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (systemHealth.error != null)
                  Text(
                    'Error loading system health',
                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
                  )
                else
                  Column(
                    children: [
                      _buildHealthItem(
                        theme,
                        'Server',
                        systemHealth.health['serverStatus'] ?? 'Unknown',
                        systemHealth.health['serverStatus'] == 'operational' ? Colors.green : Colors.red,
                      ),
                      const SizedBox(height: 8),
                      _buildHealthItem(
                        theme,
                        'Database',
                        systemHealth.health['databaseStatus'] ?? 'Unknown',
                        systemHealth.health['databaseStatus'] == 'healthy' ? Colors.green : Colors.red,
                      ),
                      const SizedBox(height: 8),
                      _buildHealthItem(
                        theme,
                        'AI Services',
                        systemHealth.health['aiServicesStatus'] ?? 'Unknown',
                        systemHealth.health['aiServicesStatus'] == 'ready' ? Colors.green : Colors.red,
                      ),
                      const SizedBox(height: 8),
                      _buildHealthItem(
                        theme,
                        'Response Time',
                        systemHealth.health['responseTime'] ?? 'Unknown',
                        Colors.blue,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms, delay: 1800.ms).slideY(begin: 0.3, end: 0);
  }

  Widget _buildAIInsights(ThemeData theme) {
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
                Icons.lightbulb_outline,
                color: theme.colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'AI Insights & Recommendations',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ).animate().fadeIn(duration: 600.ms, delay: 2000.ms).slideX(begin: -0.2, end: 0),
          
          const SizedBox(height: 16),
          
          _buildInsightCard(
            theme,
            'Low engagement detected in beginner users',
            'Consider reviewing fallacy types 3-7 for better understanding',
            Icons.school_outlined,
            Colors.blue,
          ),
          
          const SizedBox(height: 12),
          
          _buildInsightCard(
            theme,
            'High bias detected in political topics',
            'Recommend additional training data for political discourse',
            Icons.warning_outlined,
            Colors.orange,
          ),
          
          const SizedBox(height: 12),
          
          _buildInsightCard(
            theme,
            'Model performance improving',
            'F1-score increased by 2.3% this month',
            Icons.trending_up,
            Colors.green,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 2200.ms).slideY(begin: 0.3, end: 0);
  }


  Widget _buildManagementTools(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Management Tools',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ).animate().fadeIn(duration: 600.ms, delay: 1600.ms).slideX(begin: -0.2, end: 0),
        
        const SizedBox(height: 16),
        
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            DashboardCard(
              title: 'User Management',
              subtitle: 'Manage users and roles',
              icon: Icons.people_outline,
              color: Colors.blue,
              onTap: () => context.push('/user-management'),
            ),
            DashboardCard(
              title: 'Content Moderation',
              subtitle: 'Review and moderate content',
              icon: Icons.shield_outlined,
              color: Colors.green,
              onTap: () => context.push('/content-moderation'),
            ),
            DashboardCard(
              title: 'Analytics',
              subtitle: 'Platform insights',
              icon: Icons.analytics_outlined,
              color: Colors.purple,
              onTap: () => context.push('/analytics'),
            ),
            DashboardCard(
              title: 'System Management',
              subtitle: 'Configure platform',
              icon: Icons.settings_outlined,
              color: Colors.orange,
              onTap: () => context.push('/system-management'),
            ),
          ],
        ).animate().fadeIn(duration: 600.ms, delay: 1800.ms).slideY(begin: 0.3, end: 0),
      ],
    );
  }

  Widget _buildQuickStatCard(ThemeData theme, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 16,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthItem(ThemeData theme, String title, String status, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        Text(
          status,
          style: theme.textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard(ThemeData theme, String title, String description, IconData icon, Color color) {
    return Container(
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
                const SizedBox(height: 4),
                Text(
                  description,
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

}
