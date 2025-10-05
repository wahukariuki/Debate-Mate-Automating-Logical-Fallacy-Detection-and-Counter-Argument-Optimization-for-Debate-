import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/providers/auth_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

/// Email link sign-in screen for passwordless authentication
class EmailLinkScreen extends ConsumerStatefulWidget {
  const EmailLinkScreen({super.key});

  @override
  ConsumerState<EmailLinkScreen> createState() => _EmailLinkScreenState();
}

class _EmailLinkScreenState extends ConsumerState<EmailLinkScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLinkSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendSignInLink() async {
    if (!_formKey.currentState!.validate()) return;

    final authNotifier = ref.read(authNotifierProvider.notifier);
    
    try {
      await authNotifier.sendSignInLinkToEmail(_emailController.text.trim());
      
      if (mounted) {
        setState(() {
          _isLinkSent = true;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign-in link sent to ${_emailController.text}'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
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
    final authState = ref.watch(authNotifierProvider);

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
                  // App Logo
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.asset(
                        'assets/icons/debate_mate_logo.png',
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ).animate()
                    .scale(duration: 600.ms, curve: Curves.easeOutBack)
                    .fadeIn(duration: 600.ms),

                  const SizedBox(height: 40),

                  // Title
                  Text(
                    _isLinkSent ? 'Check Your Email' : 'Sign in with Email Link',
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
                    _isLinkSent 
                      ? 'We\'ve sent a sign-in link to your email address. Click the link to sign in.'
                      : 'Enter your email address and we\'ll send you a secure link to sign in without a password.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ).animate()
                    .slideY(duration: 600.ms, curve: Curves.easeOutCubic, delay: 200.ms)
                    .fadeIn(duration: 600.ms, delay: 200.ms),

                  const SizedBox(height: 40),

                  if (!_isLinkSent) ...[
                    // Email Form
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: _emailController,
                            label: 'Email Address',
                            hint: 'Enter your email address',
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

                          // Send Link Button
                          CustomButton(
                            text: 'Send Sign-in Link',
                            onPressed: authState.isLoading ? null : _sendSignInLink,
                            isLoading: authState.isLoading,
                            type: CustomButtonType.primary,
                            width: double.infinity,
                          ).animate()
                            .slideY(duration: 600.ms, curve: Curves.easeOutCubic, delay: 600.ms)
                            .fadeIn(duration: 600.ms, delay: 600.ms),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Link Sent Success Message
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.mark_email_read_outlined,
                            size: 48,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Link Sent Successfully!',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Check your email and click the link to sign in.',
                            style: theme.textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ).animate()
                      .scale(duration: 600.ms, curve: Curves.easeOutBack)
                      .fadeIn(duration: 600.ms),

                    const SizedBox(height: 24),

                    // Resend Link Button
                    CustomButton(
                      text: 'Resend Link',
                      onPressed: authState.isLoading ? null : _sendSignInLink,
                      isLoading: authState.isLoading,
                      type: CustomButtonType.outline,
                      width: double.infinity,
                    ).animate()
                      .slideY(duration: 600.ms, curve: Curves.easeOutCubic, delay: 200.ms)
                      .fadeIn(duration: 600.ms, delay: 200.ms),
                  ],

                  const SizedBox(height: 32),

                  // Back to Login Button
                  CustomButton(
                    text: 'Back to Login',
                    onPressed: () => Navigator.of(context).pop(),
                    type: CustomButtonType.text,
                    width: double.infinity,
                  ).animate()
                    .slideY(duration: 600.ms, curve: Curves.easeOutCubic, delay: 800.ms)
                    .fadeIn(duration: 600.ms, delay: 800.ms),

                  const SizedBox(height: 24),

                  // Help Text
                  Text(
                    'Having trouble? Make sure to check your spam folder or contact support.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
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
