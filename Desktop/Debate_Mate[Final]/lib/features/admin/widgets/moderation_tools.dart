import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Widget for displaying moderation tools and summary statistics
class ModerationTools extends StatelessWidget {
  final int totalArguments;
  final int pendingCount;
  final int flaggedCount;
  final Function(String action)? onBulkAction;

  const ModerationTools({
    super.key,
    required this.totalArguments,
    required this.pendingCount,
    required this.flaggedCount,
    this.onBulkAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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
        children: [
          // Summary stats
          Row(
            children: [
              _buildStatItem(
                theme,
                'Total',
                totalArguments.toString(),
                Icons.queue_outlined,
                Colors.blue,
              ),
              const SizedBox(width: 16),
              _buildStatItem(
                theme,
                'Pending',
                pendingCount.toString(),
                Icons.pending_outlined,
                Colors.orange,
              ),
              const SizedBox(width: 16),
              _buildStatItem(
                theme,
                'Flagged',
                flaggedCount.toString(),
                Icons.flag_outlined,
                Colors.red,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Bulk actions
          Row(
            children: [
              Text(
                'Bulk Actions:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildBulkActionButton(
                        theme,
                        'Approve All',
                        Icons.check_circle_outline,
                        Colors.green,
                        () => onBulkAction?.call('approve'),
                      ),
                      const SizedBox(width: 8),
                      _buildBulkActionButton(
                        theme,
                        'Reject All',
                        Icons.cancel_outlined,
                        Colors.red,
                        () => onBulkAction?.call('reject'),
                      ),
                      const SizedBox(width: 8),
                      _buildBulkActionButton(
                        theme,
                        'Flag All',
                        Icons.flag_outlined,
                        Colors.orange,
                        () => onBulkAction?.call('flag'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildStatItem(ThemeData theme, String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
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
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulkActionButton(
    ThemeData theme,
    String label,
    IconData icon,
    Color color,
    VoidCallback? onPressed,
  ) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
