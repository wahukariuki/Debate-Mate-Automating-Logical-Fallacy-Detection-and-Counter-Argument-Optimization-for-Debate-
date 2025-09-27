import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/providers/auth_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

/// Screen to handle email link callback and complete sign-in
class EmailLinkCallbackScreen extends ConsumerStatefulWidget {
  final String emailLink;

  const EmailLinkCallbackScreen({
    super.key,
    required this.emailLink,
  });

  @override
  ConsumerState<EmailLinkCallbackScreen> createState() => _EmailLinkCallbackScreenState();
}

class _EmailLinkCallbackScreenState extends ConsumerState<EmailLinkCallbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Try to get email from local storage or prompt user
    _loadStoredEmail();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _loadStoredEmail() {
    // In a real app, you would get this from local storage
    // For now, we'll prompt the user to enter their email
  }

  Future<void> _completeSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
    });

    final authNotifier = ref.read(authNotifierProvider.notifier);
    
    try {
      await authNotifier.signInWithEmailLink(
        _emailController.text.trim(),
        widget.emailLink,
      );
      
      if (mounted) {
        // Navigate to appropriate dashboard based on user role
        final authState = ref.read(authNotifierProvider);
        if (authState.userData != null) {
          final role = authState.userData!.role;
          if (role == 'admin') {
            Navigator.of(context).pushReplacementNamed('/admin-dashboard');
          } else {
            Navigator.of(context).pushReplacementNamed('/debater-dashboard');
          }
        } else {
          Navigator.of(context).pushReplacementNamed('/');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              theme.colorScheme.secondary.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Success Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.green,
                          Colors.green.shade300,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.check_circle_outline,
                      size: 60,
                      color: Colors.white,
                    ),
                  ).animate()
                    .scale(duration: 600.ms, curve: Curves.easeOutBack)
                    .fadeIn(duration: 600.ms),

                  const SizedBox(height: 40),

                  // Title
                  Text(
                    'Complete Sign-in',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ).animate()
                    .slideY(duration: 600.ms, curve: Curves.easeOutCubic)
                    .fadeIn(duration: 600.ms),

                  const SizedBox(height: 16),

                  // Subtitle
                  Text(
                    'Please confirm your email address to complete the sign-in process.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ).animate()
                    .slideY(duration: 600.ms, curve: Curves.easeOutCubic, delay: 200.ms)
                    .fadeIn(duration: 600.ms, delay: 200.ms),

                  const SizedBox(height: 40),

                  // Email Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        CustomTextField(
                          controller: _emailController,
                          label: 'Email Address',
                          hint: 'Enter the email address you used',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icon(Icons.email_outlined),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email address';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ).animate()
                          .slideX(duration: 600.ms, curve: Curves.easeOutCubic, delay: 400.ms)
                          .fadeIn(duration: 600.ms, delay: 400.ms),

                        const SizedBox(height: 24),

                        // Complete Sign-in Button
                        CustomButton(
                          text: 'Complete Sign-in',
                          onPressed: _isProcessing ? null : _completeSignIn,
                          isLoading: _isProcessing,
                          type: CustomButtonType.primary,
                          width: double.infinity,
                        ).animate()
                          .slideY(duration: 600.ms, curve: Curves.easeOutCubic, delay: 600.ms)
                          .fadeIn(duration: 600.ms, delay: 600.ms),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Security Notice
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.security_outlined,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'For security, please enter the same email address you used to request the sign-in link.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate()
                    .slideY(duration: 600.ms, curve: Curves.easeOutCubic, delay: 800.ms)
                    .fadeIn(duration: 600.ms, delay: 800.ms),

                  const SizedBox(height: 24),

                  // Back to Login Button
                  CustomButton(
                    text: 'Back to Login',
                    onPressed: () => Navigator.of(context).pop(),
                    type: CustomButtonType.text,
                    width: double.infinity,
                  ).animate()
                    .slideY(duration: 600.ms, curve: Curves.easeOutCubic, delay: 1000.ms)
                    .fadeIn(duration: 600.ms, delay: 1000.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
