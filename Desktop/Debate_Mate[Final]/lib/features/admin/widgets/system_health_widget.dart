import 'package:flutter/material.dart';

/// Widget for displaying system health metrics
class SystemHealthWidget extends StatelessWidget {
  final Map<String, dynamic> health;
  final bool isLoading;
  final String? error;
  final VoidCallback? onRefresh;

  const SystemHealthWidget({
    super.key,
    required this.health,
    this.isLoading = false,
    this.error,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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
              Icon(
                Icons.monitor_heart_outlined,
                color: theme.colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'System Health',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              if (onRefresh != null)
                IconButton(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh system health',
                ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (error != null)
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
                      'Error loading system health: $error',
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: [
                // System status overview
                _buildStatusOverview(theme),
                
                const SizedBox(height: 20),
                
                // Resource usage
                _buildResourceUsage(theme),
                
                const SizedBox(height: 20),
                
                // Service status
                _buildServiceStatus(theme),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatusOverview(ThemeData theme) {
    final uptime = health['uptime'] ?? 'Unknown';
    final responseTime = health['responseTime'] ?? 'Unknown';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withOpacity(0.1),
            Colors.blue.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.green.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 30,
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'All Systems Operational',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'System uptime: $uptime',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  'Response time: $responseTime',
                  style: theme.textTheme.bodyMedium?.copyWith(
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

  Widget _buildResourceUsage(ThemeData theme) {
    final cpuUsage = health['cpuUsage']?.toDouble() ?? 0.0;
    final memoryUsage = health['memoryUsage']?.toDouble() ?? 0.0;
    final diskUsage = health['diskUsage']?.toDouble() ?? 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resource Usage',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        
        _buildUsageBar(theme, 'CPU', cpuUsage, Colors.red),
        const SizedBox(height: 8),
        _buildUsageBar(theme, 'Memory', memoryUsage, Colors.blue),
        const SizedBox(height: 8),
        _buildUsageBar(theme, 'Disk', diskUsage, Colors.green),
      ],
    );
  }

  Widget _buildServiceStatus(ThemeData theme) {
    final serverStatus = health['serverStatus'] ?? 'Unknown';
    final databaseStatus = health['databaseStatus'] ?? 'Unknown';
    final authStatus = health['authStatus'] ?? 'Unknown';
    final aiServicesStatus = health['aiServicesStatus'] ?? 'Unknown';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Service Status',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        
        _buildServiceItem(theme, 'Server', serverStatus),
        _buildServiceItem(theme, 'Database', databaseStatus),
        _buildServiceItem(theme, 'Authentication', authStatus),
        _buildServiceItem(theme, 'AI Services', aiServicesStatus),
      ],
    );
  }

  Widget _buildUsageBar(ThemeData theme, String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              '${value.toStringAsFixed(1)}%',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value / 100,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildServiceItem(ThemeData theme, String service, String status) {
    final isHealthy = status.toLowerCase().contains('operational') || 
                     status.toLowerCase().contains('healthy') ||
                     status.toLowerCase().contains('active') ||
                     status.toLowerCase().contains('ready');
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isHealthy ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              service,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Text(
            status,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isHealthy ? Colors.green : Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
