import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/forgot_password_dialog.dart';
import 'email_link_screen.dart';

/// Beautiful login screen with animations and modern design
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
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
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: theme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
      
      // Navigate to verification screen if email not verified
      if (next.isAuthenticated && next.userData != null && !next.isEmailVerified) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Login successful! Please verify your email.'),
            backgroundColor: theme.colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
        
        // Navigate to email verification screen
        context.go('/verification');
      }
      
      // Navigate to appropriate dashboard after successful email verification
      if (next.isAuthenticated && next.userData != null && next.isEmailVerified) {
        if (next.userData!.isAdmin) {
          context.go('/admin-dashboard');
        } else {
          context.go('/debater-dashboard');
        }
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.backgroundGradient,
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
                          
                          // Back button
                          _buildBackButton(theme),
                          
                          const SizedBox(height: 16),
                          
                          // Logo and title
                          _buildHeader(theme),
                          
                          const SizedBox(height: 32),
                          
                          // Login form
                          _buildLoginForm(theme, authState, authNotifier),
                          
                          const SizedBox(height: 20),
                          
                          // Social login
                          _buildSocialLogin(theme, authState, authNotifier),
                          
                          const SizedBox(height: 24),
                      
                          // Sign up link
                          _buildSignUpLink(theme),
                          
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Loading overlay
          if (authState.isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Signing you in...',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBackButton(ThemeData theme) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            // Go back to previous page or home
            if (Navigator.canPop(context)) {
              context.pop();
            } else {
              context.go('/');
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

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        // App logo
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.3),
                blurRadius: 25,
                offset: const Offset(0, 12),
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
        ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
        
        const SizedBox(height: 16),
        
        Text(
          'Debate Mate',
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.black,
            fontSize: 28,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 800.ms, delay: 200.ms).slideY(begin: 0.3, end: 0),
        
        const SizedBox(height: 6),
        
        Text(
          'Sign in to continue your debate journey',
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

  Widget _buildLoginForm(ThemeData theme, AuthState authState, AuthNotifier authNotifier) {
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
            'Welcome',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontSize: 24,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 600.ms, delay: 600.ms).slideY(begin: 0.2, end: 0),
          
          const SizedBox(height: 8),
          
          Text(
            'Sign in to your account',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.black87,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 600.ms, delay: 700.ms).slideY(begin: 0.2, end: 0),
          
          const SizedBox(height: 24),
          
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
              color: AppTheme.primaryGold,
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
          
          const SizedBox(height: 16),
          
          // Password field
          CustomTextField(
            label: 'Password',
            hint: 'Enter your password',
            controller: _passwordController,
            obscureText: _obscurePassword,
            focusNode: _passwordFocusNode,
            textInputAction: TextInputAction.done,
            prefixIcon: Icon(
              Icons.lock_outlined,
              color: AppTheme.primaryGold,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: AppTheme.primaryGold,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
            onFieldSubmitted: (_) => _handleLogin(authNotifier),
          ),
          
          const SizedBox(height: 16),
          
          // Remember me and forgot password
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (value) {
                      setState(() {
                        _rememberMe = value ?? false;
                      });
                    },
                    activeColor: AppTheme.primaryGold,
                    checkColor: AppTheme.white,
                    side: BorderSide(
                      color: AppTheme.primaryGold,
                      width: 1.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Remember Me',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => _showForgotPasswordDialog(context),
                child: Text(
                  'Forgot Password?',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.black,
                    decorationThickness: 2,
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(duration: 600.ms, delay: 1000.ms).slideX(begin: 0.2, end: 0),
          
          const SizedBox(height: 24),
          
          // Login button
          Center(
            child: CustomButton(
              text: 'Sign In',
              onPressed: authState.isLoading ? null : () => _handleLogin(authNotifier),
              isLoading: authState.isLoading,
              type: CustomButtonType.white,
              size: CustomButtonSize.medium,
            ).animate().fadeIn(duration: 600.ms, delay: 1200.ms).slideY(begin: 0.3, end: 0),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLogin(ThemeData theme, AuthState authState, AuthNotifier authNotifier) {
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
                'Or continue with',
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
        
        const SizedBox(height: 12),
        
        // Email Link Sign-in Button
        Center(
          child: CustomButton(
            text: 'Email Link',
            onPressed: authState.isLoading ? null : () => _handleEmailLinkSignIn(),
            type: CustomButtonType.outline,
            size: CustomButtonSize.medium,
            icon: Icon(Icons.email_outlined, size: 16),
          ).animate().fadeIn(duration: 600.ms, delay: 1800.ms).slideY(begin: 0.2, end: 0),
        ),
      ],
    );
  }

  Widget _buildSignUpLink(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        TextButton(
          onPressed: () => context.go('/signup'),
          child: Text(
            'Sign Up',
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

  void _handleLogin(AuthNotifier authNotifier) {
    if (_formKey.currentState?.validate() ?? false) {
      authNotifier.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
  }

  void _handleGoogleSignIn(AuthNotifier authNotifier) {
    authNotifier.signInWithGoogle();
  }

  void _handleEmailLinkSignIn() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EmailLinkScreen(),
      ),
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ForgotPasswordDialog(),
    );
  }
}