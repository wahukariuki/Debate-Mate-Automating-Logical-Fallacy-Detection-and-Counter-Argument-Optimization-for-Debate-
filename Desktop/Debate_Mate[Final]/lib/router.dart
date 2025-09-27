import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/signup_screen.dart';
import 'features/auth/screens/verification_screen.dart';
import 'features/auth/screens/email_link_screen.dart';
import 'features/auth/screens/email_link_callback_screen.dart';
import 'features/auth/screens/debug_auth_screen.dart';
import 'features/auth/screens/email_verification_callback_screen.dart';
import 'features/dashboard/screens/debater_dashboard.dart';
import 'features/dashboard/screens/enhanced_debater_dashboard.dart';
import 'features/dashboard/screens/admin_dashboard.dart';
import 'features/debate/screens/argument_submit_screen.dart';
import 'features/debate/screens/argument_list_screen.dart';
import 'features/admin/screens/user_management_screen.dart';
import 'features/admin/screens/content_moderation_screen.dart';
import 'features/admin/screens/analytics_screen.dart';
import 'features/admin/screens/system_management_screen.dart';

/// Router configuration with authentication guards
class AppRouter {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String verification = '/verification';
  static const String emailLink = '/email-link';
  static const String emailLinkCallback = '/email-link-callback';
  static const String emailVerificationCallback = '/verify-email';
  static const String debugAuth = '/debug-auth';
  static const String debaterDashboard = '/debater-dashboard';
  static const String adminDashboard = '/admin-dashboard';
  static const String home = '/';
  
  // Debate routes
  static const String argumentSubmit = '/argument-submit';
  static const String argumentList = '/argument-list';
  static const String fallacyAnalysis = '/fallacy-analysis';
  static const String counterarguments = '/counterarguments';
  
  // Admin routes
  static const String userManagement = '/user-management';
  static const String contentModeration = '/content-moderation';
  static const String analytics = '/analytics';
  static const String systemManagement = '/system-management';

  /// Create router configuration
  static GoRouter createRouter(Ref ref) {
    return GoRouter(
      initialLocation: home,
      redirect: (context, state) {
        final authState = ref.read(authNotifierProvider);
        final isLoading = authState.isLoading;
        final isAuthenticated = authState.isAuthenticated;
        final userData = authState.userData;
        final isEmailVerified = authState.isEmailVerified;

        // Don't redirect if loading
        if (isLoading) return null;

        // Define public routes that don't require authentication
        final publicRoutes = [
          login,
          signup,
          verification,
          emailLink,
          emailLinkCallback,
          emailVerificationCallback,
          debugAuth,
        ];

        // If user is not authenticated and trying to access protected route
        if (!isAuthenticated && !publicRoutes.contains(state.uri.path)) {
          return login;
        }

        // If user is authenticated
        if (isAuthenticated && userData != null) {
          // Check if email is verified - but allow access to login and signup pages
          // Skip email verification for new signups (they should login first)
          if (!isEmailVerified && state.uri.path != verification && state.uri.path != login && state.uri.path != signup) {
            return verification;
          }


          // Redirect to appropriate dashboard based on role
          if (state.uri.path == home || state.uri.path == login || state.uri.path == signup) {
            if (userData.isAdmin) {
              return adminDashboard;
            } else {
              return debaterDashboard;
            }
          }

          // Check role-based access
          if (state.uri.path == adminDashboard && !userData.isAdmin) {
            return debaterDashboard;
          }

          if (state.uri.path == debaterDashboard && !userData.isDebater) {
            return adminDashboard;
          }

          // Admin-only routes
          final adminOnlyRoutes = [userManagement, contentModeration, analytics, systemManagement];
          if (adminOnlyRoutes.contains(state.uri.path) && !userData.isAdmin) {
            return userData.isDebater ? debaterDashboard : adminDashboard;
          }

          // Debater-only routes
          final debaterOnlyRoutes = [argumentSubmit, argumentList, fallacyAnalysis, counterarguments];
          if (debaterOnlyRoutes.contains(state.uri.path) && !userData.isDebater) {
            return userData.isAdmin ? adminDashboard : debaterDashboard;
          }
        }

        return null; // No redirect needed
      },
      routes: [
        // Public routes
        GoRoute(
          path: login,
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: signup,
          name: 'signup',
          builder: (context, state) => const SignupScreen(),
        ),
        GoRoute(
          path: verification,
          name: 'verification',
          builder: (context, state) => const VerificationScreen(),
        ),
        
        // Email link routes
        GoRoute(
          path: emailLink,
          name: 'email-link',
          builder: (context, state) => const EmailLinkScreen(),
        ),
        GoRoute(
          path: emailLinkCallback,
          name: 'email-link-callback',
          builder: (context, state) {
            final emailLink = state.uri.queryParameters['link'] ?? '';
            return EmailLinkCallbackScreen(emailLink: emailLink);
          },
        ),
        GoRoute(
          path: emailVerificationCallback,
          name: 'email-verification-callback',
          builder: (context, state) {
            final emailLink = state.uri.queryParameters['link'] ?? '';
            final mode = state.uri.queryParameters['mode'] ?? '';
            final oobCode = state.uri.queryParameters['oobCode'] ?? '';
            return EmailVerificationCallbackScreen(
              emailLink: emailLink,
              mode: mode,
              oobCode: oobCode,
            );
          },
        ),
        
        // Debug route
        GoRoute(
          path: debugAuth,
          name: 'debug-auth',
          builder: (context, state) => const DebugAuthScreen(),
        ),
        
        
        // Protected routes
        GoRoute(
          path: debaterDashboard,
          name: 'debater-dashboard',
          builder: (context, state) => const EnhancedDebaterDashboard(),
        ),
        GoRoute(
          path: adminDashboard,
          name: 'admin-dashboard',
          builder: (context, state) => const AdminDashboard(),
        ),
        
        // Debate routes
        GoRoute(
          path: argumentSubmit,
          name: 'argument-submit',
          builder: (context, state) => const ArgumentSubmitScreen(),
        ),
        GoRoute(
          path: argumentList,
          name: 'argument-list',
          builder: (context, state) => const ArgumentListScreen(),
        ),
        GoRoute(
          path: fallacyAnalysis,
          name: 'fallacy-analysis',
          builder: (context, state) => const Scaffold(
            body: Center(
              child: Text('Fallacy Analysis - Coming Soon'),
            ),
          ),
        ),
        GoRoute(
          path: counterarguments,
          name: 'counterarguments',
          builder: (context, state) => const Scaffold(
            body: Center(
              child: Text('Counterarguments - Coming Soon'),
            ),
          ),
        ),
        
        // Admin routes
        GoRoute(
          path: userManagement,
          name: 'user-management',
          builder: (context, state) => const UserManagementScreen(),
        ),
        GoRoute(
          path: contentModeration,
          name: 'content-moderation',
          builder: (context, state) => const ContentModerationScreen(),
        ),
        GoRoute(
          path: analytics,
          name: 'analytics',
          builder: (context, state) => const AnalyticsScreen(),
        ),
        GoRoute(
          path: systemManagement,
          name: 'system-management',
          builder: (context, state) => const SystemManagementScreen(),
        ),
        
        // Home route (redirects to appropriate dashboard)
        GoRoute(
          path: home,
          name: 'home',
          builder: (context, state) => const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Page not found',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'The page you are looking for does not exist.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(home),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  return AppRouter.createRouter(ref);
});

/// Navigation helper class
class AppNavigation {
  /// Navigate to login screen
  static void goToLogin(BuildContext context) {
    context.go(AppRouter.login);
  }

  /// Navigate to signup screen
  static void goToSignup(BuildContext context) {
    context.go(AppRouter.signup);
  }


  /// Navigate to verification screen
  static void goToVerification(BuildContext context) {
    context.go(AppRouter.verification);
  }

  /// Navigate to debater dashboard
  static void goToDebaterDashboard(BuildContext context) {
    context.go(AppRouter.debaterDashboard);
  }

  /// Navigate to admin dashboard
  static void goToAdminDashboard(BuildContext context) {
    context.go(AppRouter.adminDashboard);
  }

  /// Navigate to home (will redirect to appropriate dashboard)
  static void goToHome(BuildContext context) {
    context.go(AppRouter.home);
  }

  /// Pop current screen
  static void pop(BuildContext context) {
    context.pop();
  }

  /// Pop until specific route
  static void popUntil(BuildContext context, String route) {
    context.go(route);
  }
}
