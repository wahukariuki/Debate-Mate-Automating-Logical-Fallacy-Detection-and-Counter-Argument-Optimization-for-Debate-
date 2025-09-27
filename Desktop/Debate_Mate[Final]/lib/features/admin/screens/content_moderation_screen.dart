import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';

import '../../../core/providers/admin_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/argument_card.dart';
import '../widgets/moderation_tools.dart';

/// Screen for content moderation and argument management
class ContentModerationScreen extends ConsumerStatefulWidget {
  const ContentModerationScreen({super.key});

  @override
  ConsumerState<ContentModerationScreen> createState() => _ContentModerationScreenState();
}

class _ContentModerationScreenState extends ConsumerState<ContentModerationScreen> {
  String _selectedSortBy = 'submittedAt';

  @override
  void initState() {
    super.initState();
    // Load arguments queue
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(contentModerationProvider.notifier).loadArguments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final contentModerationState = ref.watch(contentModerationProvider);

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
              _buildHeader(theme, contentModerationState),
              
              // Filters and tools
              _buildFiltersAndTools(theme, contentModerationState),
              
              // Content
              Expanded(
                child: _buildContent(theme, contentModerationState),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ContentModerationState state) {
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
                  'Content Moderation',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0),
                
                Text(
                  '${state.arguments.length} arguments in queue',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideX(begin: -0.2, end: 0),
              ],
            ),
          ),
          
          // Upload dataset button
          IconButton(
            onPressed: _uploadDataset,
            icon: const Icon(Icons.upload_file),
            tooltip: 'Upload dataset for model training',
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.surface,
              foregroundColor: theme.colorScheme.onSurface,
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Refresh button
          IconButton(
            onPressed: () => ref.read(contentModerationProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh queue',
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.surface,
              foregroundColor: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersAndTools(ThemeData theme, ContentModerationState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Status filters
          Row(
            children: [
              Text(
                'Status:',
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
                      _buildStatusFilterChip(theme, 'all', 'All', state.statusFilter),
                      const SizedBox(width: 8),
                      _buildStatusFilterChip(theme, 'pending', 'Pending', state.statusFilter),
                      const SizedBox(width: 8),
                      _buildStatusFilterChip(theme, 'flagged', 'Flagged', state.statusFilter),
                      const SizedBox(width: 8),
                      _buildStatusFilterChip(theme, 'approved', 'Approved', state.statusFilter),
                      const SizedBox(width: 8),
                      _buildStatusFilterChip(theme, 'rejected', 'Rejected', state.statusFilter),
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
                  DropdownMenuItem(value: 'submittedAt', child: Text('Submission Date')),
                  DropdownMenuItem(value: 'confidence', child: Text('AI Confidence')),
                  DropdownMenuItem(value: 'fallacies', child: Text('Fallacy Count')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedSortBy = value);
                    ref.read(contentModerationProvider.notifier).updateSorting(value);
                  }
                },
              ),
            ],
          ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideY(begin: 0.3, end: 0),
          
          const SizedBox(height: 16),
          
          // Moderation tools summary
          ModerationTools(
            totalArguments: state.arguments.length,
            pendingCount: state.arguments.where((arg) => arg['status'] == 'pending').length,
            flaggedCount: state.arguments.where((arg) => arg['status'] == 'flagged').length,
            onBulkAction: _performBulkAction,
          ).animate().fadeIn(duration: 600.ms, delay: 600.ms).slideY(begin: 0.3, end: 0),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme, ContentModerationState state) {
    if (state.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading arguments...'),
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
              'Error loading arguments',
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
              onPressed: () => ref.read(contentModerationProvider.notifier).refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.arguments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.queue_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No arguments to moderate',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.statusFilter != 'all'
                  ? 'Try adjusting your filters'
                  : 'All arguments have been reviewed',
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
      onRefresh: () => ref.read(contentModerationProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: state.arguments.length,
        itemBuilder: (context, index) {
          final argument = state.arguments[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ArgumentCard(
              argument: argument,
              onModerate: (action, reason) => _moderateArgument(argument['id'], action, reason),
              onViewDetails: () => _showArgumentDetails(argument),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusFilterChip(ThemeData theme, String value, String label, String selectedStatus) {
    final isSelected = selectedStatus == value;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          ref.read(contentModerationProvider.notifier).updateStatusFilter(value);
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

  Future<void> _uploadDataset() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'json', 'txt'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        
        // Show upload dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Upload Dataset'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('File: ${file.name}'),
                const SizedBox(height: 16),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'Describe the dataset purpose...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  
                  // Here you would typically upload the file
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Dataset upload feature coming soon'),
                      backgroundColor: Colors.blue,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Text('Upload'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting file: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _moderateArgument(String argumentId, String action, String? reason) async {
    final success = await ref.read(contentModerationProvider.notifier).moderateArgument(
      argumentId,
      action,
      reason: reason,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Argument moderated successfully' : 'Failed to moderate argument'),
          backgroundColor: success ? Theme.of(context).colorScheme.primary : Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _performBulkAction(String action) {
    // Implement bulk actions (approve all, reject all, etc.)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bulk $action feature coming soon'),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showArgumentDetails(Map<String, dynamic> argument) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Argument Details',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailSection('Topic', argument['topic'] ?? 'Unknown'),
                      _buildDetailSection('Content', argument['content'] ?? 'No content'),
                      _buildDetailSection('Transcript', argument['transcript'] ?? 'No transcript'),
                      _buildDetailSection('Detected Fallacies', 
                        (argument['detectedFallacies'] as List?)?.join(', ') ?? 'None'),
                      _buildDetailSection('AI Counterarguments', 
                        (argument['aiCounterarguments'] as List?)?.join('\n\n') ?? 'None'),
                      _buildDetailSection('Confidence', 
                        '${(argument['confidence'] ?? 0.0) * 100}%'),
                      _buildDetailSection('Status', argument['status'] ?? 'Unknown'),
                      _buildDetailSection('Submitted At', 
                        _formatDate(argument['submittedAt'])),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Text(
              content,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
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
    
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
