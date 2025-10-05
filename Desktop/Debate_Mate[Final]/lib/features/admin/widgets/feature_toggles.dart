import 'package:flutter/material.dart';

/// Widget for managing feature toggles
class FeatureToggles extends StatefulWidget {
  final Function(String featureName, bool enabled)? onToggleFeature;

  const FeatureToggles({
    super.key,
    this.onToggleFeature,
  });

  @override
  State<FeatureToggles> createState() => _FeatureTogglesState();
}

class _FeatureTogglesState extends State<FeatureToggles> {
  final Map<String, bool> _features = {
    'Speech Recognition': true,
    'Real-time Fallacy Detection': true,
    'Counterargument Generation': true,
    'User Progress Tracking': true,
    'Email Notifications': false,
    'Advanced Analytics': true,
    'Model Training Mode': false,
    'Debug Mode': false,
    'Beta Features': false,
    'Maintenance Mode': false,
  };

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
                Icons.toggle_on_outlined,
                color: theme.colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Feature Management',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Feature toggles
          ..._features.entries.map((entry) => _buildFeatureToggle(theme, entry.key, entry.value)).toList(),
          
          const SizedBox(height: 20),
          
          // Bulk actions
          _buildBulkActions(theme),
        ],
      ),
    );
  }

  Widget _buildFeatureToggle(ThemeData theme, String featureName, bool isEnabled) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isEnabled 
            ? Colors.green.withOpacity(0.1)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEnabled 
              ? Colors.green.withOpacity(0.3)
              : theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // Feature icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isEnabled 
                  ? Colors.green.withOpacity(0.2)
                  : theme.colorScheme.onSurfaceVariant.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              _getFeatureIcon(featureName),
              color: isEnabled 
                  ? Colors.green
                  : theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Feature info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  featureName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getFeatureDescription(featureName),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          
          // Toggle switch
          Switch(
            value: isEnabled,
            onChanged: (value) {
              setState(() {
                _features[featureName] = value;
              });
              
              if (widget.onToggleFeature != null) {
                widget.onToggleFeature!(featureName, value);
              }
            },
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildBulkActions(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bulk Actions',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _enableAllFeatures,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Enable All'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green,
                    side: const BorderSide(color: Colors.green),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _disableAllFeatures,
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Disable All'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Use bulk actions to quickly enable or disable multiple features at once.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFeatureIcon(String featureName) {
    switch (featureName) {
      case 'Speech Recognition':
        return Icons.mic_outlined;
      case 'Real-time Fallacy Detection':
        return Icons.warning_outlined;
      case 'Counterargument Generation':
        return Icons.psychology_outlined;
      case 'User Progress Tracking':
        return Icons.trending_up_outlined;
      case 'Email Notifications':
        return Icons.email_outlined;
      case 'Advanced Analytics':
        return Icons.analytics_outlined;
      case 'Model Training Mode':
        return Icons.school_outlined;
      case 'Debug Mode':
        return Icons.bug_report_outlined;
      case 'Beta Features':
        return Icons.science_outlined;
      case 'Maintenance Mode':
        return Icons.build_outlined;
      default:
        return Icons.settings_outlined;
    }
  }

  String _getFeatureDescription(String featureName) {
    switch (featureName) {
      case 'Speech Recognition':
        return 'Enable voice input for arguments';
      case 'Real-time Fallacy Detection':
        return 'Detect logical fallacies as users type';
      case 'Counterargument Generation':
        return 'Generate AI-powered counterarguments';
      case 'User Progress Tracking':
        return 'Track and analyze user improvement';
      case 'Email Notifications':
        return 'Send email alerts and updates';
      case 'Advanced Analytics':
        return 'Enable detailed platform analytics';
      case 'Model Training Mode':
        return 'Allow model retraining with new data';
      case 'Debug Mode':
        return 'Enable detailed logging and debugging';
      case 'Beta Features':
        return 'Enable experimental features for testing';
      case 'Maintenance Mode':
        return 'Put the platform in maintenance mode';
      default:
        return 'Feature description not available';
    }
  }

  void _enableAllFeatures() {
    setState(() {
      for (String key in _features.keys) {
        _features[key] = true;
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All features enabled'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _disableAllFeatures() {
    setState(() {
      for (String key in _features.keys) {
        _features[key] = false;
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All features disabled'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
