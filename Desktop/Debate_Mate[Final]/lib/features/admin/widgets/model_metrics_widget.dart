import 'package:flutter/material.dart';

/// Widget for displaying AI model performance metrics
class ModelMetricsWidget extends StatelessWidget {
  final Map<String, dynamic> metrics;
  final bool isLoading;
  final String? error;
  final VoidCallback? onRefresh;
  final Function(String version)? onDeployModel;

  const ModelMetricsWidget({
    super.key,
    required this.metrics,
    this.isLoading = false,
    this.error,
    this.onRefresh,
    this.onDeployModel,
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
                Icons.psychology_outlined,
                color: theme.colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'AI Model Performance',
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
                  tooltip: 'Refresh model metrics',
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
                      'Error loading model metrics: $error',
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: [
                // Model performance cards
                _buildModelCards(theme),
                
                const SizedBox(height: 20),
                
                // Model deployment section
                _buildDeploymentSection(theme),
                
                const SizedBox(height: 20),
                
                // Last update info
                _buildLastUpdateInfo(theme),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildModelCards(ThemeData theme) {
    final roberta = metrics['roberta'] as Map<String, dynamic>? ?? {};
    final gpt35 = metrics['gpt35'] as Map<String, dynamic>? ?? {};
    
    return Row(
      children: [
        Expanded(
          child: _buildModelCard(
            theme,
            'RoBERTa',
            'Fallacy Detection',
            roberta,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildModelCard(
            theme,
            'GPT-3.5',
            'Counterargument Generation',
            gpt35,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildModelCard(
    ThemeData theme,
    String modelName,
    String purpose,
    Map<String, dynamic> modelData,
    Color color,
  ) {
    final accuracy = modelData['accuracy']?.toDouble() ?? 0.0;
    final latency = modelData['latency'] ?? 'Unknown';
    final errorRate = modelData['errorRate']?.toDouble() ?? 0.0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.psychology_outlined,
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
                      modelName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      purpose,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildMetricRow(theme, 'Accuracy', '${accuracy.toStringAsFixed(1)}%', color),
          _buildMetricRow(theme, 'Latency', latency, color),
          _buildMetricRow(theme, 'Error Rate', '${errorRate.toStringAsFixed(1)}%', color),
        ],
      ),
    );
  }

  Widget _buildMetricRow(ThemeData theme, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeploymentSection(ThemeData theme) {
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
            'Model Deployment',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Model Version',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: '2.1', child: Text('v2.1 (Latest)')),
                    DropdownMenuItem(value: '2.0', child: Text('v2.0 (Stable)')),
                    DropdownMenuItem(value: '1.9', child: Text('v1.9 (Previous)')),
                  ],
                  onChanged: (value) {
                    // Handle version selection
                  },
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  if (onDeployModel != null) {
                    onDeployModel!('2.1');
                  }
                },
                icon: const Icon(Icons.rocket_launch),
                label: const Text('Deploy'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Deploying a new model version will update the AI services with improved performance.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastUpdateInfo(ThemeData theme) {
    final lastUpdate = metrics['lastUpdate'];
    String updateText = 'Unknown';
    
    if (lastUpdate != null) {
      // This would typically format the timestamp properly
      updateText = 'Last updated: 6 hours ago';
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.update_outlined,
            color: Colors.blue,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            updateText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.blue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
