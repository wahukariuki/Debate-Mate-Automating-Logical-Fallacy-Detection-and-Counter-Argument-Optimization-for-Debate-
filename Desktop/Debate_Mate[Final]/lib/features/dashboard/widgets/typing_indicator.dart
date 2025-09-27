import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Typing indicator widget showing AI is processing
class TypingIndicator extends StatefulWidget {
  final String? message;
  final bool showDots;

  const TypingIndicator({
    super.key,
    this.message,
    this.showDots = true,
  });

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // AI Avatar
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.secondary,
                  theme.colorScheme.secondary.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.psychology_outlined,
              color: Colors.white,
              size: 18,
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Typing bubble
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20).copyWith(
                bottomLeft: const Radius.circular(4),
              ),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.2),
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
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.message != null) ...[
                  Text(
                    'AI Coach',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.message != null)
                      Expanded(
                        child: Text(
                          widget.message!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    
                    if (widget.showDots) ...[
                      if (widget.message != null) const SizedBox(width: 8),
                      _buildTypingDots(theme),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(
      begin: -0.3,
      end: 0,
    );
  }

  Widget _buildTypingDots(ThemeData theme) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final animationValue = (_animation.value - delay).clamp(0.0, 1.0);
            final scale = 1.0 + (0.5 * animationValue);
            final opacity = 0.3 + (0.7 * animationValue);
            
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withOpacity(opacity),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

/// Processing indicator for different analysis stages
class ProcessingIndicator extends StatefulWidget {
  final String stage;
  final String? description;

  const ProcessingIndicator({
    super.key,
    required this.stage,
    this.description,
  });

  @override
  State<ProcessingIndicator> createState() => _ProcessingIndicatorState();
}

class _ProcessingIndicatorState extends State<ProcessingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  
  final List<String> _stages = [
    'Analyzing argument...',
    'Detecting fallacies...',
    'Generating counter-arguments...',
    'Optimizing suggestions...',
  ];
  
  int _currentStageIndex = 0;

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _rotationController.repeat();
    _pulseController.repeat(reverse: true);
    
    _startStageAnimation();
  }

  void _startStageAnimation() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _currentStageIndex < _stages.length - 1) {
        setState(() {
          _currentStageIndex++;
        });
        _startStageAnimation();
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20).copyWith(
          bottomLeft: const Radius.circular(4),
        ),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Spinning icon
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationController.value * 2 * 3.14159,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.secondary,
                        theme.colorScheme.secondary.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.psychology_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(width: 12),
          
          // Stage text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'AI Coach',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _stages[_currentStageIndex],
                    key: ValueKey(_currentStageIndex),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                if (widget.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.description!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Progress dots
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (index) {
                  final delay = index * 0.2;
                  final animationValue = (_pulseController.value - delay).clamp(0.0, 1.0);
                  final scale = 1.0 + (0.3 * animationValue);
                  final opacity = 0.3 + (0.7 * animationValue);
                  
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    child: Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary.withOpacity(opacity),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(
      begin: -0.3,
      end: 0,
    );
  }
}
