import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/admin_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/user_card.dart';
import '../widgets/user_details_modal.dart';

/// Enhanced admin screen for managing users and their roles
class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedSortBy = 'createdAt';
  String _selectedSortOrder = 'desc';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    // Load users using the provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userManagementProvider.notifier).loadUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    ref.read(userManagementProvider.notifier).updateSearchQuery(query);
  }

  Future<void> _updateUserRole(String userId, String newRole) async {
    final success = await ref.read(userManagementProvider.notifier).updateUserRole(userId, newRole);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'User role updated successfully' : 'Failed to update user role'),
          backgroundColor: success ? Theme.of(context).colorScheme.primary : Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<void> _toggleUserStatus(String userId, bool isSuspended) async {
    final success = await ref.read(userManagementProvider.notifier).toggleUserStatus(userId, isSuspended);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'User status updated successfully' : 'Failed to update user status'),
          backgroundColor: success ? Theme.of(context).colorScheme.primary : Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<void> _exportUsers() async {
    try {
      // This would typically show a loading dialog and download the CSV
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Export feature coming soon'),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting users: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => UserDetailsModal(user: user),
    );
  }

  void _showRoleUpdateDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update User Role'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Update role for ${user['email']}'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: user['role'],
              decoration: const InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'debater', child: Text('Debater')),
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
              ],
              onChanged: (value) {
                if (value != null && value != user['role']) {
                  Navigator.of(context).pop();
                  _updateUserRole(user['uid'], value);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showSuspendDialog(Map<String, dynamic> user) {
    final isSuspended = user['isSuspended'] == true;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isSuspended ? 'Unsuspend User' : 'Suspend User'),
        content: Text(
          isSuspended 
              ? 'Are you sure you want to unsuspend ${user['email']}?'
              : 'Are you sure you want to suspend ${user['email']}? This will prevent them from accessing the platform.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _toggleUserStatus(user['uid'], !isSuspended);
            },
            style: TextButton.styleFrom(
              foregroundColor: isSuspended ? Colors.green : Colors.red,
            ),
            child: Text(isSuspended ? 'Unsuspend' : 'Suspend'),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userManagementState = ref.watch(userManagementProvider);
    final currentUser = ref.watch(currentUserDataProvider);

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
              _buildHeader(theme, userManagementState),
              
              // Search and filters
              _buildSearchAndFilters(theme, userManagementState),
              
              // Content
              Expanded(
                child: _buildContent(theme, userManagementState, currentUser),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, UserManagementState state) {
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
                  'User Management',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0),
                
                Text(
                  '${state.users.length} total users',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideX(begin: -0.2, end: 0),
              ],
            ),
          ),
          
          // Export button
          IconButton(
            onPressed: _exportUsers,
            icon: const Icon(Icons.download_outlined),
            tooltip: 'Export users to CSV',
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.surface,
              foregroundColor: theme.colorScheme.onSurface,
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Refresh button
          IconButton(
            onPressed: () => ref.read(userManagementProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh users',
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.surface,
              foregroundColor: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(ThemeData theme, UserManagementState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Search field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search users by email...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: state.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: theme.colorScheme.surface,
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideY(begin: 0.3, end: 0),
          
          const SizedBox(height: 16),
          
          // Filters row
          Row(
            children: [
              // Role filter
              Text(
                'Role:',
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
                      _buildRoleFilterChip(theme, 'all', 'All', state.selectedRole),
                      const SizedBox(width: 8),
                      _buildRoleFilterChip(theme, 'debater', 'Debaters', state.selectedRole),
                      const SizedBox(width: 8),
                      _buildRoleFilterChip(theme, 'admin', 'Admins', state.selectedRole),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Sort dropdown
              DropdownButton<String>(
                value: _selectedSortBy,
                hint: const Text('Sort by'),
                items: const [
                  DropdownMenuItem(value: 'createdAt', child: Text('Join Date')),
                  DropdownMenuItem(value: 'email', child: Text('Email')),
                  DropdownMenuItem(value: 'lastActive', child: Text('Last Active')),
                  DropdownMenuItem(value: 'argumentsSubmitted', child: Text('Arguments')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedSortBy = value);
                    ref.read(userManagementProvider.notifier).updateSorting(value, _selectedSortOrder);
                  }
                },
              ),
              
              const SizedBox(width: 8),
              
              // Sort order button
              IconButton(
                onPressed: () {
                  final newOrder = _selectedSortOrder == 'asc' ? 'desc' : 'asc';
                  setState(() => _selectedSortOrder = newOrder);
                  ref.read(userManagementProvider.notifier).updateSorting(_selectedSortBy, newOrder);
                },
                icon: Icon(_selectedSortOrder == 'asc' ? Icons.arrow_upward : Icons.arrow_downward),
                tooltip: 'Sort order',
              ),
            ],
          ).animate().fadeIn(duration: 600.ms, delay: 600.ms).slideY(begin: 0.3, end: 0),
        ],
      ),
    );
  }

  Widget _buildRoleFilterChip(ThemeData theme, String value, String label, String selectedRole) {
    final isSelected = selectedRole == value;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          ref.read(userManagementProvider.notifier).updateRoleFilter(value);
        }
      },
      backgroundColor: theme.colorScheme.surface,
      selectedColor: theme.colorScheme.primary.withOpacity(0.1),
      checkmarkColor: theme.colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildContent(ThemeData theme, UserManagementState state, currentUser) {
    if (state.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading users...'),
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
              'Error loading users',
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
              onPressed: () => ref.read(userManagementProvider.notifier).refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No users found',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.searchQuery.isNotEmpty || state.selectedRole != 'all'
                  ? 'Try adjusting your search or filters'
                  : 'No users registered yet',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(userManagementProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: state.users.length,
        itemBuilder: (context, index) {
          final user = state.users[index];
          final isCurrentUser = user['uid'] == currentUser?.uid;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Slidable(
              key: ValueKey(user['uid']),
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                children: [
                  if (!isCurrentUser) ...[
                    SlidableAction(
                      onPressed: (context) => _showUserDetails(user),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      icon: Icons.info_outline,
                      label: 'Details',
                    ),
                    SlidableAction(
                      onPressed: (context) => _showRoleUpdateDialog(user),
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      icon: Icons.edit,
                      label: 'Edit Role',
                    ),
                    SlidableAction(
                      onPressed: (context) => _showSuspendDialog(user),
                      backgroundColor: user['isSuspended'] == true ? Colors.green : Colors.red,
                      foregroundColor: Colors.white,
                      icon: user['isSuspended'] == true ? Icons.person_add : Icons.person_remove,
                      label: user['isSuspended'] == true ? 'Unsuspend' : 'Suspend',
                    ),
                  ],
                ],
              ),
              child: UserCard(
                user: user,
                isCurrentUser: isCurrentUser,
                onTap: () => _showUserDetails(user),
                onEditRole: () => _showRoleUpdateDialog(user),
                onToggleStatus: () => _showSuspendDialog(user),
              ),
            ),
          );
        },
      ),
    );
  }

}
