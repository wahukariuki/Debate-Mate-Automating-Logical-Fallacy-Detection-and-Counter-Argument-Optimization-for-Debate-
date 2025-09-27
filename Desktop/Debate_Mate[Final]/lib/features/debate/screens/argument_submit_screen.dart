import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
// import 'package:speech_to_text/speech_to_text.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/app_theme.dart';

/// Screen for submitting new arguments
class ArgumentSubmitScreen extends ConsumerStatefulWidget {
  const ArgumentSubmitScreen({super.key});

  @override
  ConsumerState<ArgumentSubmitScreen> createState() => _ArgumentSubmitScreenState();
}

class _ArgumentSubmitScreenState extends ConsumerState<ArgumentSubmitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _topicController = TextEditingController();
  
  String _selectedType = 'neutral';
  bool _isLoading = false;
  bool _isListening = false;
  
  // final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  @override
  void dispose() {
    _contentController.dispose();
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    // _speechEnabled = await _speechToText.initialize();
    _speechEnabled = false; // Disabled for now
    setState(() {});
  }

  Future<void> _startListening() async {
    if (!_speechEnabled) return;
    
    setState(() {
      _isListening = true;
    });

    // await _speechToText.listen(
    //   onResult: (result) {
    //     setState(() {
    //       _contentController.text = result.recognizedWords;
    //     });
    //   },
    // );
  }

  Future<void> _stopListening() async {
    // await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
  }

  Future<void> _submitArgument() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userData = ref.read(currentUserDataProvider);
      if (userData == null) {
        throw Exception('User not authenticated');
      }

      final apiService = ApiService();
      await apiService.submitArgument(
        userId: userData.uid,
        content: _contentController.text.trim(),
        type: _selectedType,
        topic: _topicController.text.trim().isEmpty ? null : _topicController.text.trim(),
        metadata: {
          'wordCount': _contentController.text.trim().split(' ').length,
          'characterCount': _contentController.text.trim().length,
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Argument submitted successfully!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        
        // Navigate back to argument list
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting argument: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final userData = ref.watch(currentUserDataProvider);

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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  
                  // Header
                  _buildHeader(theme),
                  
                  const SizedBox(height: 32),
                  
                  // Topic field
                  _buildTopicField(theme),
                  
                  const SizedBox(height: 24),
                  
                  // Argument type selection
                  _buildTypeSelection(theme),
                  
                  const SizedBox(height: 24),
                  
                  // Content field with speech input
                  _buildContentField(theme),
                  
                  const SizedBox(height: 32),
                  
                  // Submit button
                  _buildSubmitButton(theme),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
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
                'Submit Argument',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0),
              
              Text(
                'Create a new debate argument',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideX(begin: -0.2, end: 0),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopicField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Topic (Optional)',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideX(begin: -0.2, end: 0),
        
        const SizedBox(height: 8),
        
        TextFormField(
          controller: _topicController,
          decoration: InputDecoration(
            hintText: 'e.g., Climate Change, Education Policy',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: theme.colorScheme.surface,
          ),
          textInputAction: TextInputAction.next,
        ).animate().fadeIn(duration: 600.ms, delay: 600.ms).slideY(begin: 0.3, end: 0),
      ],
    );
  }

  Widget _buildTypeSelection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Argument Type',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ).animate().fadeIn(duration: 600.ms, delay: 800.ms).slideX(begin: -0.2, end: 0),
        
        const SizedBox(height: 8),
        
        Row(
          children: [
            Expanded(
              child: _buildTypeOption(theme, 'pro', 'Pro', Colors.green),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTypeOption(theme, 'con', 'Con', Colors.red),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTypeOption(theme, 'neutral', 'Neutral', Colors.blue),
            ),
          ],
        ).animate().fadeIn(duration: 600.ms, delay: 1000.ms).slideY(begin: 0.3, end: 0),
      ],
    );
  }

  Widget _buildTypeOption(ThemeData theme, String value, String label, Color color) {
    final isSelected = _selectedType == value;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedType = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : theme.colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? color : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected ? color : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Argument Content',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            
            const Spacer(),
            
            // Speech input button
            if (_speechEnabled)
              IconButton(
                onPressed: _isListening ? _stopListening : _startListening,
                icon: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: _isListening ? Colors.red : theme.colorScheme.primary,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.surface,
                ),
              ),
          ],
        ).animate().fadeIn(duration: 600.ms, delay: 1200.ms).slideX(begin: -0.2, end: 0),
        
        const SizedBox(height: 8),
        
        TextFormField(
          controller: _contentController,
          maxLines: 8,
          decoration: InputDecoration(
            hintText: 'Enter your argument here...\n\nTip: Be clear, logical, and provide evidence to support your position.',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: theme.colorScheme.surface,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your argument';
            }
            if (value.trim().length < 50) {
              return 'Argument must be at least 50 characters long';
            }
            return null;
          },
        ).animate().fadeIn(duration: 600.ms, delay: 1400.ms).slideY(begin: 0.3, end: 0),
        
        if (_isListening)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.mic, color: Colors.red, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Listening... Speak now',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0),
      ],
    );
  }

  Widget _buildSubmitButton(ThemeData theme) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitArgument,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Submitting...',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Text(
                'Submit Argument',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 1600.ms).slideY(begin: 0.3, end: 0);
  }
}
