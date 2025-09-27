import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/models/user_model.dart';

/// Profile section widget for dashboard headers
class ProfileSection extends StatefulWidget {
  final UserModel? userData;
  final VoidCallback? onSignOut;
  final VoidCallback? onProfileTap;

  const ProfileSection({
    super.key,
    this.userData,
    this.onSignOut,
    this.onProfileTap,
  });

  @override
  State<ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<ProfileSection> {
  bool _showMenu = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Stack(
      children: [
        // Profile button
        InkWell(
          onTap: () {
            setState(() {
              _showMenu = !_showMenu;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Avatar
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      widget.userData?.email.substring(0, 1).toUpperCase() ?? 'U',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // User info
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.userData?.email.split('@')[0] ?? 'User',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      widget.userData?.role.toUpperCase() ?? 'USER',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(width: 4),
                
                // Dropdown arrow
                Icon(
                  _showMenu ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        
        // Dropdown menu
        if (_showMenu)
          Positioned(
            top: 50,
            right: 0,
            child: Container(
              width: 200,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile info header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.userData?.email ?? 'No email',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: widget.userData?.isAdmin == true
                                    ? Colors.amber.withOpacity(0.2)
                                    : Colors.blue.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                widget.userData?.role.toUpperCase() ?? 'USER',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: widget.userData?.isAdmin == true
                                      ? Colors.amber[800]
                                      : Colors.blue[800],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              widget.userData?.hasEmail2FA == true
                                  ? Icons.email_outlined
                                  : Icons.sms_outlined,
                              color: theme.colorScheme.onSurfaceVariant,
                              size: 16,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Menu items
                  _buildMenuItem(
                    theme,
                    'Profile Settings',
                    Icons.person_outline,
                    () {
                      setState(() {
                        _showMenu = false;
                      });
                      widget.onProfileTap?.call();
                    },
                  ),
                  
                  _buildMenuItem(
                    theme,
                    'Account Settings',
                    Icons.settings_outlined,
                    () {
                      setState(() {
                        _showMenu = false;
                      });
                      // TODO: Navigate to account settings
                    },
                  ),
                  
                  _buildMenuItem(
                    theme,
                    'Help & Support',
                    Icons.help_outline,
                    () {
                      setState(() {
                        _showMenu = false;
                      });
                      // TODO: Navigate to help
                    },
                  ),
                  
                  const Divider(height: 1),
                  
                  _buildMenuItem(
                    theme,
                    'Sign Out',
                    Icons.logout_outlined,
                    () {
                      setState(() {
                        _showMenu = false;
                      });
                      widget.onSignOut?.call();
                    },
                    isDestructive: true,
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.1, end: 0),
          ),
      ],
    );
  }

  Widget _buildMenuItem(
    ThemeData theme,
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive 
                  ? theme.colorScheme.error 
                  : theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDestructive 
                      ? theme.colorScheme.error 
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple profile avatar widget
class ProfileAvatar extends StatelessWidget {
  final UserModel? userData;
  final double size;
  final VoidCallback? onTap;

  const ProfileAvatar({
    super.key,
    this.userData,
    this.size = 40,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size / 2),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(size / 2),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            userData?.email.substring(0, 1).toUpperCase() ?? 'U',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
