import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/custom_button.dart';

/// Screen that handles email verification callback when user clicks verification link
class EmailVerificationCallbackScreen extends ConsumerStatefulWidget {
  final String emailLink;
  final String mode;
  final String oobCode;

  const EmailVerificationCallbackScreen({
    super.key,
    required this.emailLink,
    required this.mode,
    required this.oobCode,
  });

  @override
  ConsumerState<EmailVerificationCallbackScreen> createState() => _EmailVerificationCallbackScreenState();
}

class _EmailVerificationCallbackScreenState extends ConsumerState<EmailVerificationCallbackScreen> {
  bool _isProcessing = false;
  bool _isSuccess = false;
  bool _isError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _processEmailVerification();
  }

  Future<void> _processEmailVerification() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _isError = false;
      _errorMessage = null;
    });

    try {
      final authNotifier = ref.read(authNotifierProvider.notifier);
      
      // Check if this is an email verification link
      if (widget.mode == 'verifyEmail' && widget.oobCode.isNotEmpty) {
        // Apply the email verification action
        await authNotifier.applyEmailVerification(widget.oobCode);
        
        setState(() {
          _isSuccess = true;
          _isProcessing = false;
        });

        // Show success message and redirect to verification screen
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Email verified successfully! You can now sign in.'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 3),
            ),
          );

          // Redirect to login after a short delay
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              context.go('/login');
            }
          });
        }
      } else {
        // Invalid verification link
        setState(() {
          _isError = true;
          _errorMessage = 'Invalid email verification link';
          _isProcessing = false;
        });
      }
    } catch (e) {
      setState(() {
        _isError = true;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: theme.brightness == Brightness.dark 
              ? AppTheme.darkBackgroundGradient 
              : AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: _isSuccess 
                          ? Colors.green.withOpacity(0.1)
                          : _isError 
                              ? Colors.red.withOpacity(0.1)
                              : theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: Icon(
                      _isSuccess 
                          ? Icons.check_circle_outline
                          : _isError 
                              ? Icons.error_outline
                              : Icons.email_outlined,
                      size: 60,
                      color: _isSuccess 
                          ? Colors.green
                          : _isError 
                              ? Colors.red
                              : theme.colorScheme.primary,
                    ),
                  ).animate().scale(duration: 600.ms, delay: 200.ms),

                  const SizedBox(height: 32),

                  // Title
                  Text(
                    _isSuccess 
                        ? 'Email Verified!'
                        : _isError 
                            ? 'Verification Failed'
                            : 'Verifying Email...',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 16),

                  // Message
                  Text(
                    _isSuccess 
                        ? 'Your email has been successfully verified. You can now sign in to your account.'
                        : _isError 
                            ? _errorMessage ?? 'There was an error verifying your email. Please try again.'
                            : 'Please wait while we verify your email address...',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(duration: 600.ms, delay: 600.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 32),

                  // Loading indicator or action buttons
                  if (_isProcessing) ...[
                    CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                    ).animate().fadeIn(duration: 400.ms),
                  ] else if (_isError) ...[
                    CustomButton(
                      text: 'Try Again',
                      onPressed: () {
                        setState(() {
                          _isError = false;
                          _errorMessage = null;
                        });
                        _processEmailVerification();
                      },
                      type: CustomButtonType.primary,
                      size: CustomButtonSize.large,
                    ).animate().fadeIn(duration: 600.ms, delay: 800.ms).slideY(begin: 0.3, end: 0),
                    
                    const SizedBox(height: 16),
                    
                    CustomButton(
                      text: 'Go to Login',
                      onPressed: () => context.go('/login'),
                      type: CustomButtonType.secondary,
                      size: CustomButtonSize.large,
                    ).animate().fadeIn(duration: 600.ms, delay: 1000.ms).slideY(begin: 0.3, end: 0),
                  ] else if (_isSuccess) ...[
                    CustomButton(
                      text: 'Sign In Now',
                      onPressed: () => context.go('/login'),
                      type: CustomButtonType.primary,
                      size: CustomButtonSize.large,
                    ).animate().fadeIn(duration: 600.ms, delay: 800.ms).slideY(begin: 0.3, end: 0),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
