import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

/// Beautiful signup screen with role selection and 2FA preferences
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authNotifierProvider);
    final authNotifier = ref.read(authNotifierProvider.notifier);
    
    // Listen to auth state changes
    ref.listen(authNotifierProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: theme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
      
      // Navigate to login screen after successful signup
      if (next.isSignupSuccess) {
        // Clear the signup success flag
        authNotifier.clearSignupSuccess();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Account created successfully! Please sign in to continue.'),
            backgroundColor: theme.colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
        context.go('/login');
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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      
                      // Header
                      _buildHeader(theme),
                      
                      const SizedBox(height: 24),
                  
                  // Signup form
                  _buildSignupForm(theme, authState, authNotifier),
                  
                  const SizedBox(height: 20),
                  
                  // Social signup
                  _buildSocialSignup(theme, authState, authNotifier),
                  
                  const SizedBox(height: 24),
                  
                  // Login link
                  _buildLoginLink(theme),
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
            ),
          ),
        ),
      ),
    ),
    );
  }


  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        // Back button
        Row(
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
            const Spacer(),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // App logo
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
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
        ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
        
        const SizedBox(height: 16),
        
        Text(
          'Create Account',
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.black,
            fontSize: 28,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 800.ms, delay: 200.ms).slideY(begin: 0.3, end: 0),
        
        const SizedBox(height: 6),
        
        Text(
          'Join the debate community and enhance your skills',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 800.ms, delay: 400.ms).slideY(begin: 0.3, end: 0),
      ],
    );
  }

  Widget _buildSignupForm(ThemeData theme, AuthState authState, AuthNotifier authNotifier) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Sign Up',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontSize: 24,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 600.ms, delay: 600.ms).slideY(begin: 0.2, end: 0),
          
          const SizedBox(height: 32),
          
          // Email field
          CustomTextField(
            label: 'Email Address',
            hint: 'Enter your email',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            focusNode: _emailFocusNode,
            textInputAction: TextInputAction.next,
            prefixIcon: Icon(
              Icons.email_outlined,
              color: theme.colorScheme.primary,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
            onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
          ),
          
          const SizedBox(height: 20),
          
          // Password field
          CustomTextField(
            label: 'Password',
            hint: 'Create a strong password',
            controller: _passwordController,
            obscureText: _obscurePassword,
            focusNode: _passwordFocusNode,
            textInputAction: TextInputAction.next,
            prefixIcon: Icon(
              Icons.lock_outlined,
              color: theme.colorScheme.primary,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 8) {
                return 'Password must be at least 8 characters';
              }
              if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
                return 'Password must contain uppercase, lowercase, and number';
              }
              return null;
            },
            onFieldSubmitted: (_) => _confirmPasswordFocusNode.requestFocus(),
          ),
          
          const SizedBox(height: 20),
          
          // Confirm password field
          CustomTextField(
            label: 'Confirm Password',
            hint: 'Re-enter your password',
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            focusNode: _confirmPasswordFocusNode,
            textInputAction: TextInputAction.next,
            prefixIcon: Icon(
              Icons.lock_outlined,
              color: theme.colorScheme.primary,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
            onFieldSubmitted: (_) => _confirmPasswordFocusNode.requestFocus(),
          ),
          
          const SizedBox(height: 20),
          
          
          const SizedBox(height: 24),
          
          // Terms and conditions
          Row(
            children: [
              Checkbox(
                value: _acceptTerms,
                onChanged: (value) {
                  setState(() {
                    _acceptTerms = value ?? false;
                  });
                },
                activeColor: theme.colorScheme.primary,
              ),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    children: [
                      const TextSpan(text: 'I agree to the '),
                      TextSpan(
                        text: 'Terms of Service',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(duration: 600.ms, delay: 1000.ms).slideX(begin: 0.2, end: 0),
          
          const SizedBox(height: 24),
          
          // Signup button
          Center(
            child: CustomButton(
              text: 'Create Account',
              onPressed: authState.isLoading || !_acceptTerms 
                  ? null 
                  : () => _handleSignup(authNotifier),
              isLoading: authState.isLoading,
              type: CustomButtonType.white,
              size: CustomButtonSize.medium,
            ).animate().fadeIn(duration: 600.ms, delay: 1200.ms).slideY(begin: 0.3, end: 0),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialSignup(ThemeData theme, AuthState authState, AuthNotifier authNotifier) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Divider(
                color: Colors.black,
                thickness: 1.5,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Or sign up with',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: Colors.black,
                thickness: 1.5,
              ),
            ),
          ],
        ).animate().fadeIn(duration: 600.ms, delay: 1400.ms),
        
        const SizedBox(height: 24),
        
        Center(
          child: GoogleSignInButton(
            onPressed: authState.isLoading ? null : () => _handleGoogleSignIn(authNotifier),
            isLoading: authState.isLoading,
          ).animate().fadeIn(duration: 600.ms, delay: 1600.ms).slideY(begin: 0.2, end: 0),
        ),
      ],
    );
  }

  Widget _buildLoginLink(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        TextButton(
          onPressed: () => context.go('/login'),
          child: Text(
            'Sign In',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
              decorationColor: Colors.black,
              decorationThickness: 2,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms, delay: 1800.ms).slideY(begin: 0.2, end: 0);
  }

  void _handleSignup(AuthNotifier authNotifier) {
    if (_formKey.currentState?.validate() ?? false) {
      authNotifier.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        twoFactorPreference: 'email',
        phone: null,
      );
    }
  }

  void _handleGoogleSignIn(AuthNotifier authNotifier) {
    authNotifier.signInWithGoogle();
  }
}
