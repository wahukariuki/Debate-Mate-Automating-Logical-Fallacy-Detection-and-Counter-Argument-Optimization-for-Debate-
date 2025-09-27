import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/profile_section.dart';

/// Debater dashboard with beautiful design and animations
class DebaterDashboard extends ConsumerStatefulWidget {
  const DebaterDashboard({super.key});

  @override
  ConsumerState<DebaterDashboard> createState() => _DebaterDashboardState();
}

class _DebaterDashboardState extends ConsumerState<DebaterDashboard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userData = ref.watch(currentUserDataProvider);
    final authNotifier = ref.read(authNotifierProvider.notifier);

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
                
                // Quick actions
                _buildQuickActions(theme),
                
                const SizedBox(height: 32),
                
                // Features grid
                _buildFeaturesGrid(theme),
                
                const SizedBox(height: 32),
                
                // Recent activity placeholder
                _buildRecentActivity(theme),
                
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
              'Debater Dashboard',
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
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back, ${userData?.email.split('@')[0] ?? 'Debater'}!',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(duration: 800.ms, delay: 600.ms).slideY(begin: 0.3, end: 0),
          
          const SizedBox(height: 8),
          
          Text(
            'Ready to sharpen your debate skills? Let\'s dive into some practice sessions.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ).animate().fadeIn(duration: 800.ms, delay: 800.ms).slideY(begin: 0.3, end: 0),
        ],
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ).animate().fadeIn(duration: 600.ms, delay: 1000.ms).slideX(begin: -0.2, end: 0),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: DashboardCard(
                title: 'Submit Argument',
                subtitle: 'Create a new argument',
                icon: Icons.edit_outlined,
                color: theme.colorScheme.primary,
                onTap: () => context.push('/argument-submit'),
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: DashboardCard(
                title: 'My Arguments',
                subtitle: 'View your arguments',
                icon: Icons.list_outlined,
                color: theme.colorScheme.secondary,
                onTap: () => context.push('/argument-list'),
              ),
            ),
          ],
        ).animate().fadeIn(duration: 600.ms, delay: 1200.ms).slideY(begin: 0.3, end: 0),
      ],
    );
  }

  Widget _buildFeaturesGrid(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Features',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ).animate().fadeIn(duration: 600.ms, delay: 1400.ms).slideX(begin: -0.2, end: 0),
        
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
              title: 'Fallacy Detection',
              subtitle: 'AI-powered analysis',
              icon: Icons.psychology_outlined,
              color: Colors.orange,
              onTap: () => context.push('/fallacy-analysis'),
            ),
            DashboardCard(
              title: 'Counter Arguments',
              subtitle: 'Smart suggestions',
              icon: Icons.lightbulb_outline,
              color: Colors.green,
              onTap: () => context.push('/counterarguments'),
            ),
            DashboardCard(
              title: 'Speech Analysis',
              subtitle: 'Performance insights',
              icon: Icons.analytics_outlined,
              color: Colors.purple,
              onTap: () => _showComingSoon(context, 'Speech Analysis'),
            ),
            DashboardCard(
              title: 'Tournaments',
              subtitle: 'Compete with others',
              icon: Icons.emoji_events_outlined,
              color: Colors.amber,
              onTap: () => _showComingSoon(context, 'Tournaments'),
            ),
          ],
        ).animate().fadeIn(duration: 600.ms, delay: 1600.ms).slideY(begin: 0.3, end: 0),
      ],
    );
  }

  Widget _buildRecentActivity(ThemeData theme) {
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
            'Recent Activity',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 1800.ms).slideX(begin: -0.2, end: 0),
          
          const SizedBox(height: 16),
          
          _buildActivityItem(
            theme,
            'Account Created',
            'Welcome to Debate Mate!',
            Icons.person_add_outlined,
            Colors.green,
          ),
          
          const SizedBox(height: 12),
          
          _buildActivityItem(
            theme,
            'Email Verified',
            'Your account is now verified',
            Icons.verified_outlined,
            Colors.blue,
          ),
          
          const SizedBox(height: 12),
          
          _buildActivityItem(
            theme,
            '2FA Enabled',
            'Two-factor authentication activated',
            Icons.security_outlined,
            Colors.purple,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 2000.ms).slideY(begin: 0.3, end: 0);
  }

  Widget _buildActivityItem(
    ThemeData theme,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        
        const SizedBox(width: 16),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        
        Text(
          'Now',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
