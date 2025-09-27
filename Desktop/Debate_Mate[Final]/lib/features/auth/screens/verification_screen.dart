import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/custom_button.dart';

/// Email verification waiting screen with beautiful animations
class VerificationScreen extends ConsumerStatefulWidget {
  const VerificationScreen({super.key});

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _startPeriodicVerificationCheck();
  }

  void _startPeriodicVerificationCheck() {
    // Check verification status every 3 seconds
    Stream.periodic(const Duration(seconds: 3)).listen((_) {
      if (mounted && !_isChecking) {
        _checkEmailVerification();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _checkEmailVerification() async {
    if (_isChecking) return; // Prevent multiple simultaneous checks
    
    setState(() {
      _isChecking = true;
    });

    try {
      final authNotifier = ref.read(authNotifierProvider.notifier);
      
      // Use the auth service to check verification status
      final isVerified = await authNotifier.checkEmailVerification();
      
      if (isVerified && mounted) {
        // Email is verified, show success message and navigate to login
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Email verified successfully! Redirecting to login...'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
        
        // Navigate to login page after a short delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            context.go('/login');
          }
        });
      }
    } catch (e) {
      // Only show error if it's not a periodic check
      if (mounted && _isChecking) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking verification: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isChecking = false;
      });
    }
  }

  void _resendVerificationEmail() async {
    final authNotifier = ref.read(authNotifierProvider.notifier);
    try {
      // Use the auth service to send email verification with proper settings
      await authNotifier.resendEmailVerification();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Verification email sent! Please check your inbox.'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send verification email: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = ref.watch(currentUserProvider);
    
    // Listen to auth state changes to detect email verification
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.isAuthenticated && next.isEmailVerified && next.userData != null) {
        // Email is verified, navigate to dashboard
        final userData = next.userData!;
        if (userData.isAdmin) {
          context.go('/admin-dashboard');
        } else {
          context.go('/debater-dashboard');
        }
      }
    });
    
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                
                // Back button
                _buildBackButton(theme),
                
                const SizedBox(height: 20),
                
                // Header
                _buildHeader(theme, currentUser),
                
                const SizedBox(height: 48),
                
                // Verification card
                _buildVerificationCard(theme, currentUser),
                
                const SizedBox(height: 32),
                
                // Action buttons
                _buildActionButtons(theme),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(ThemeData theme) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            // Go back to previous page or login
            if (Navigator.canPop(context)) {
              context.pop();
            } else {
              context.go('/login');
            }
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: theme.colorScheme.onSurface,
          ),
          style: IconButton.styleFrom(
            backgroundColor: theme.colorScheme.surface.withOpacity(0.8),
            foregroundColor: theme.colorScheme.onSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0);
  }

  Widget _buildHeader(ThemeData theme, currentUser) {
    return Column(
      children: [
        // App logo with animation
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.3),
                blurRadius: 25,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Image.asset(
              'assets/icons/debate_mate_logo.png',
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
        ).animate(onPlay: (controller) => controller.repeat())
          .scale(duration: 2000.ms, curve: Curves.easeInOut)
          .then()
          .scale(duration: 2000.ms, curve: Curves.easeInOut, begin: const Offset(1.0, 1.0), end: const Offset(1.1, 1.1)),
        
        const SizedBox(height: 32),
        
        Text(
          'Check Your Email',
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 800.ms, delay: 200.ms).slideY(begin: 0.3, end: 0),
        
        const SizedBox(height: 12),
        
        Text(
          'A verification email has been sent to',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 800.ms, delay: 400.ms).slideY(begin: 0.3, end: 0),
        
        const SizedBox(height: 8),
        
        Text(
          currentUser?.email ?? '',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 800.ms, delay: 600.ms).slideY(begin: 0.3, end: 0),
      ],
    );
  }

  Widget _buildVerificationCard(ThemeData theme, currentUser) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Email Verification',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 600.ms, delay: 800.ms).slideY(begin: 0.2, end: 0),
          
          const SizedBox(height: 24),
          
          // Instructions
          _buildInstructions(theme),
          
          const SizedBox(height: 24),
          
          // Status indicator
          _buildStatusIndicator(theme),
          
          const SizedBox(height: 24),
          
          // Check button
          CustomButton(
            text: _isChecking ? 'Checking...' : 'I\'ve Verified My Email - Check Now',
            onPressed: _isChecking ? null : _checkEmailVerification,
            isLoading: _isChecking,
            type: CustomButtonType.primary,
            size: CustomButtonSize.large,
          ).animate().fadeIn(duration: 600.ms, delay: 1200.ms).slideY(begin: 0.3, end: 0),
        ],
      ),
    );
  }

  Widget _buildInstructions(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'To complete your registration:',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ).animate().fadeIn(duration: 600.ms, delay: 1000.ms).slideX(begin: 0.2, end: 0),
        
        const SizedBox(height: 16),
        
        _buildInstructionItem(
          theme,
          '1',
          'Check your email inbox',
          'Look for an email from Debate Mate',
          Icons.inbox_outlined,
        ),
        
        const SizedBox(height: 12),
        
        _buildInstructionItem(
          theme,
          '2',
          'Click the verification link',
          'This will verify your email address',
          Icons.link_outlined,
        ),
        
        const SizedBox(height: 12),
        
        _buildInstructionItem(
          theme,
          '3',
          'Return to the app',
          'We\'ll automatically detect verification',
          Icons.check_circle_outline,
        ),
      ],
    );
  }

  Widget _buildInstructionItem(
    ThemeData theme,
    String number,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              number,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 16),
        
        Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 20,
        ),
        
        const SizedBox(width: 12),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: (1200 + int.parse(number) * 200).ms).slideX(begin: 0.2, end: 0);
  }

  Widget _buildStatusIndicator(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          if (_isChecking) ...[
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Checking verification status...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ] else ...[
            Icon(
              Icons.info_outline,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'A verification email has been sent to your email address. After clicking the verification link in your email, click the button above to check your verification status and continue to your dashboard.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 1400.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Column(
      children: [
        // Resend email button
        CustomButton(
          text: 'Resend Verification Email',
          onPressed: _resendVerificationEmail,
          type: CustomButtonType.outline,
          size: CustomButtonSize.medium,
        ).animate().fadeIn(duration: 600.ms, delay: 1600.ms).slideY(begin: 0.2, end: 0),
        
        const SizedBox(height: 16),
        
        // Change email button
        TextButton(
          onPressed: () {
            // Navigate back to signup to change email
            context.go('/signup');
          },
          child: Text(
            'Change Email Address',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ).animate().fadeIn(duration: 600.ms, delay: 1800.ms).slideY(begin: 0.2, end: 0),
        
        const SizedBox(height: 16),
        
        // Back to login button
        TextButton(
          onPressed: () {
            context.go('/login');
          },
          child: Text(
            'Back to Sign In',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ).animate().fadeIn(duration: 600.ms, delay: 2000.ms).slideY(begin: 0.2, end: 0),
      ],
    );
  }
}
