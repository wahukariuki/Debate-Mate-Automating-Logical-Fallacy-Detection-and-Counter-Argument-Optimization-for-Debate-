import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Card widget for displaying user information
class UserCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final bool isCurrentUser;
  final VoidCallback? onTap;
  final VoidCallback? onEditRole;
  final VoidCallback? onToggleStatus;

  const UserCard({
    super.key,
    required this.user,
    this.isCurrentUser = false,
    this.onTap,
    this.onEditRole,
    this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with email and role
              Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: _getRoleColor(user['role']).withOpacity(0.1),
                    child: Text(
                      user['email']?.substring(0, 1).toUpperCase() ?? '?',
                      style: TextStyle(
                        color: _getRoleColor(user['role']),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                user['email'] ?? 'Unknown',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isCurrentUser) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'YOU',
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'UID: ${user['uid']?.substring(0, 8)}...',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Role badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getRoleColor(user['role']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      user['role']?.toUpperCase() ?? 'UNKNOWN',
                      style: TextStyle(
                        color: _getRoleColor(user['role']),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // User stats
              Row(
                children: [
                  _buildStatItem(
                    theme,
                    Icons.calendar_today,
                    'Joined',
                    _formatDate(user['createdAt']),
                  ),
                  const SizedBox(width: 16),
                  _buildStatItem(
                    theme,
                    Icons.forum_outlined,
                    'Arguments',
                    user['argumentsSubmitted']?.toString() ?? '0',
                  ),
                  const SizedBox(width: 16),
                  _buildStatItem(
                    theme,
                    Icons.warning_outlined,
                    'Fallacies',
                    user['fallaciesDetected']?.toString() ?? '0',
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Status indicators
              Row(
                children: [
                  _buildStatusChip(
                    theme,
                    user['isEmailVerified'] == true ? 'Verified' : 'Unverified',
                    user['isEmailVerified'] == true ? Colors.green : Colors.orange,
                    Icons.verified,
                  ),
                  if (user['isSuspended'] == true) ...[
                    const SizedBox(width: 8),
                    _buildStatusChip(
                      theme,
                      'Suspended',
                      Colors.red,
                      Icons.block,
                    ),
                  ],
                  const Spacer(),
                  if (user['lastActive'] != null)
                    Text(
                      'Last active ${_formatDate(user['lastActive'])}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildStatItem(ThemeData theme, IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          '$label: $value',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(ThemeData theme, String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String? role) {
    switch (role) {
      case 'admin':
        return Colors.purple;
      case 'debater':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Unknown';
    
    DateTime dateTime;
    if (date is DateTime) {
      dateTime = date;
    } else if (date.toString().contains('Timestamp')) {
      // Handle Firestore Timestamp
      dateTime = DateTime.now(); // This would need proper timestamp handling
    } else {
      return 'Unknown';
    }
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}
