import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/services/debug_auth_service.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

/// Debug screen to help identify authentication issues
class DebugAuthScreen extends ConsumerStatefulWidget {
  const DebugAuthScreen({super.key});

  @override
  ConsumerState<DebugAuthScreen> createState() => _DebugAuthScreenState();
}

class _DebugAuthScreenState extends ConsumerState<DebugAuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _debugAuthService = DebugAuthService();
  
  Map<String, dynamic>? _debugInfo;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _runDebugCheck() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter email and password'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _debugInfo = null;
    });

    try {
      final debugInfo = await _debugAuthService.debugAuthFlow(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      setState(() {
        _debugInfo = debugInfo;
        _isLoading = false;
      });

      // Print to console for detailed analysis
      _debugAuthService.printDebugInfo(debugInfo);
      
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Debug check failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _createMissingUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _debugAuthService.createMissingUserData();
      
      setState(() {
        _isLoading = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User data created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Re-run debug check
        await _runDebugCheck();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create user data'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating user data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Authentication'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
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
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.bug_report,
                        size: 48,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Authentication Debug Tool',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This tool will help identify login issues by checking Firebase connection, authentication, and user data.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),

                const SizedBox(height: 24),

                // Login Form
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Test Credentials',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      CustomTextField(
                        label: 'Email',
                        hint: 'Enter your email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      CustomTextField(
                        label: 'Password',
                        hint: 'Enter your password',
                        controller: _passwordController,
                        obscureText: true,
                        prefixIcon: Icon(
                          Icons.lock_outlined,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      CustomButton(
                        text: 'Run Debug Check',
                        onPressed: _isLoading ? null : _runDebugCheck,
                        isLoading: _isLoading,
                        type: CustomButtonType.primary,
                        size: CustomButtonSize.large,
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.2, end: 0),

                const SizedBox(height: 24),

                // Debug Results
                if (_debugInfo != null) ...[
                  _buildDebugResults(theme),
                  const SizedBox(height: 16),
                  
                  // Create User Data Button
                  if (_debugInfo!['errors'].toString().contains('User data not found')) ...[
                    CustomButton(
                      text: 'Create Missing User Data',
                      onPressed: _isLoading ? null : _createMissingUserData,
                      isLoading: _isLoading,
                      type: CustomButtonType.outline,
                      size: CustomButtonSize.medium,
                    ),
                    const SizedBox(height: 24),
                  ],
                ],

                // Instructions
                _buildInstructions(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDebugResults(ThemeData theme) {
    final debugInfo = _debugInfo!;
    final checks = debugInfo['checks'] as Map<String, dynamic>;
    final errors = debugInfo['errors'] as List<String>;
    final recommendations = debugInfo['recommendations'] as List<String>;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: errors.isEmpty ? Colors.green : Colors.red,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                errors.isEmpty ? Icons.check_circle : Icons.error,
                color: errors.isEmpty ? Colors.green : Colors.red,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Debug Results',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Check Results
          Text(
            'Check Results:',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          
          ...checks.entries.map((entry) {
            final status = entry.value['status'] ?? 'unknown';
            final isSuccess = status == 'success' || status == 'found' || status == 'verified' || status == 'accessible';
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    isSuccess ? Icons.check_circle : Icons.error,
                    color: isSuccess ? Colors.green : Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${entry.key}: $status',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),

          // Errors
          if (errors.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Errors:',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            ...errors.map((error) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• $error',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.red,
                ),
              ),
            )).toList(),
          ],

          // Recommendations
          if (recommendations.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Recommendations:',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            ...recommendations.map((recommendation) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• $recommendation',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            )).toList(),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildInstructions(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'How to Use This Tool',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '1. Enter your email and password\n'
            '2. Click "Run Debug Check" to analyze the authentication flow\n'
            '3. Review the results to identify specific issues\n'
            '4. Use "Create Missing User Data" if user data is missing\n'
            '5. Check the console output for detailed technical information',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideY(begin: 0.2, end: 0);
  }
}




