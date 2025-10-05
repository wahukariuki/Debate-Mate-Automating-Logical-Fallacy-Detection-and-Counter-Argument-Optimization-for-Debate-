import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/models/fallacy_report_model.dart';
import '../../../core/models/counterargument_model.dart';
import '../../../core/theme/app_theme.dart';
import '../models/dashboard_models.dart';

/// Chat bubble widget for displaying user and AI messages
class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onFallacyTap;
  final VoidCallback? onOptimizationTap;

  const ChatBubble({
    super.key,
    required this.message,
    this.onFallacyTap,
    this.onOptimizationTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: message.isUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            _buildAvatar(theme),
            const SizedBox(width: 8),
          ],
          
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: message.isUser
                    ? AppTheme.primaryGradient.colors.first.withOpacity(0.1)
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft: message.isUser 
                      ? const Radius.circular(20)
                      : const Radius.circular(4),
                  bottomRight: message.isUser 
                      ? const Radius.circular(4)
                      : const Radius.circular(20),
                ),
                border: Border.all(
                  color: message.isUser
                      ? theme.colorScheme.primary.withOpacity(0.3)
                      : theme.colorScheme.outline.withOpacity(0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMessageHeader(theme),
                  const SizedBox(height: 8),
                  _buildMessageContent(theme),
                  if (message.fallacyReport != null && message.fallacyReport!.hasFallacies)
                    _buildFallacySection(theme),
                  if (message.counterarguments != null)
                    _buildCounterargumentSection(theme),
                  const SizedBox(height: 8),
                  _buildTimestamp(theme),
                ],
              ),
            ),
          ),
          
          if (message.isUser) ...[
            const SizedBox(width: 8),
            _buildAvatar(theme),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(
      begin: message.isUser ? 0.3 : -0.3,
      end: 0,
    );
  }

  Widget _buildAvatar(ThemeData theme) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: message.isUser 
            ? AppTheme.primaryGradient
            : LinearGradient(
                colors: [
                  theme.colorScheme.secondary,
                  theme.colorScheme.secondary.withOpacity(0.7),
                ],
              ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        message.isUser ? Icons.person : Icons.psychology_outlined,
        color: Colors.white,
        size: 18,
      ),
    );
  }

  Widget _buildMessageHeader(ThemeData theme) {
    return Row(
      children: [
        Text(
          message.isUser ? 'You' : 'AI Coach',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: message.isUser
                ? theme.colorScheme.primary
                : theme.colorScheme.secondary,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: _getMessageTypeColor(theme).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _getMessageTypeLabel(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: _getMessageTypeColor(theme),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageContent(ThemeData theme) {
    return Text(
      message.content,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface,
        height: 1.4,
      ),
    );
  }

  Widget _buildFallacySection(ThemeData theme) {
    final fallacyReport = message.fallacyReport!;
    
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_outlined,
                color: Colors.red,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Fallacies Detected (${fallacyReport.fallacyCount})',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...fallacyReport.fallacies.map((fallacy) => _buildFallacyItem(theme, fallacy)),
        ],
      ),
    );
  }

  Widget _buildFallacyItem(ThemeData theme, FallacyModel fallacy) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  fallacy.type.replaceAll('_', ' ').toUpperCase(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(fallacy.confidence * 100).round()}% confidence',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            fallacy.description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          if (fallacy.suggestion != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Colors.amber,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    fallacy.suggestion!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.amber.shade800,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCounterargumentSection(ThemeData theme) {
    final counterarguments = message.counterarguments!;
    
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.green.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Colors.green,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Counter-Arguments & Optimizations',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            counterarguments.content,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              height: 1.4,
            ),
          ),
          if (counterarguments.hasOptimizations) ...[
            const SizedBox(height: 12),
            Text(
              'Optimization Suggestions:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            ...counterarguments.optimizations.map((opt) => _buildOptimizationItem(theme, opt)),
          ],
        ],
      ),
    );
  }

  Widget _buildOptimizationItem(ThemeData theme, OptimizationModel optimization) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  optimization.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${(optimization.impact * 100).round()}% impact',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            optimization.suggestion,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimestamp(ThemeData theme) {
    final now = DateTime.now();
    final diff = now.difference(message.timestamp);
    
    String timeText;
    if (diff.inMinutes < 1) {
      timeText = 'Just now';
    } else if (diff.inMinutes < 60) {
      timeText = '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      timeText = '${diff.inHours}h ago';
    } else {
      timeText = '${diff.inDays}d ago';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          timeText,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Color _getMessageTypeColor(ThemeData theme) {
    switch (message.messageType) {
      case ChatMessageType.welcome:
        return Colors.blue;
      case ChatMessageType.userInput:
        return theme.colorScheme.primary;
      case ChatMessageType.aiResponse:
        return Colors.green;
      case ChatMessageType.error:
        return Colors.red;
    }
  }

  String _getMessageTypeLabel() {
    switch (message.messageType) {
      case ChatMessageType.welcome:
        return 'Welcome';
      case ChatMessageType.userInput:
        return 'Input';
      case ChatMessageType.aiResponse:
        return 'Analysis';
      case ChatMessageType.error:
        return 'Error';
    }
  }
}
