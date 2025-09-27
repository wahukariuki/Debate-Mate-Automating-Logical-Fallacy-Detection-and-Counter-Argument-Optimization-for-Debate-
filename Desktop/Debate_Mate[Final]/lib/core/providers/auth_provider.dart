import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

/// Auth state class to represent different authentication states
class AuthState {
  final User? user;
  final UserModel? userData;
  final bool isLoading;
  final String? error;
  final bool isEmailVerified;
  final bool isTwoFactorVerified;
  final bool isSignupSuccess;

  const AuthState({
    this.user,
    this.userData,
    this.isLoading = false,
    this.error,
    this.isEmailVerified = false,
    this.isTwoFactorVerified = false,
    this.isSignupSuccess = false,
  });

  /// Check if user is authenticated
  bool get isAuthenticated => user != null && userData != null;

  /// Check if user is an admin
  bool get isAdmin => userData?.isAdmin ?? false;

  /// Check if user is a debater
  bool get isDebater => userData?.isDebater ?? false;

  /// Check if user has completed all verification steps
  bool get isFullyVerified => isEmailVerified && isTwoFactorVerified;

  /// Create a copy with updated fields
  AuthState copyWith({
    User? user,
    UserModel? userData,
    bool? isLoading,
    String? error,
    bool? isEmailVerified,
    bool? isTwoFactorVerified,
    bool? isSignupSuccess,
  }) {
    return AuthState(
      user: user ?? this.user,
      userData: userData ?? this.userData,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isTwoFactorVerified: isTwoFactorVerified ?? this.isTwoFactorVerified,
      isSignupSuccess: isSignupSuccess ?? this.isSignupSuccess,
    );
  }

  @override
  String toString() {
    return 'AuthState(user: ${user?.uid}, userData: ${userData?.role}, isLoading: $isLoading, error: $error, isEmailVerified: $isEmailVerified, isTwoFactorVerified: $isTwoFactorVerified, isSignupSuccess: $isSignupSuccess)';
  }
}

/// Auth notifier class to manage authentication state
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final Logger _logger = Logger();

  AuthNotifier(this._authService) : super(const AuthState()) {
    _initializeAuth();
  }

  /// Initialize authentication state
  void _initializeAuth() {
    _logger.i('Initializing auth state');
    
    // Listen to auth state changes
    _authService.authStateChanges.listen((User? user) async {
      if (user != null) {
        _logger.i('User authenticated: ${user.uid}');
        await _loadUserData(user);
        
        // Start monitoring email verification status for authenticated users
        _monitorEmailVerification(user);
      } else {
        _logger.i('User signed out');
        state = const AuthState();
      }
    });
  }

  /// Monitor email verification status changes
  void _monitorEmailVerification(User user) {
    // Check verification status every 5 seconds for authenticated users
    Stream.periodic(const Duration(seconds: 5)).listen((_) async {
      if (state.user != null && state.user!.uid == user.uid && !state.isEmailVerified) {
        try {
          final isVerified = await _authService.checkEmailVerification();
          if (isVerified && state.userData != null) {
            // Update state with verified status
            state = state.copyWith(isEmailVerified: true);
            _logger.i('Email verification detected for user: ${user.uid}');
          }
        } catch (e) {
          _logger.e('Error monitoring email verification: $e');
        }
      }
    });
  }

  /// Load user data from Firestore with better error handling
  Future<void> _loadUserData(User user) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      _logger.i('Loading user data for UID: ${user.uid}');
      
      final UserModel? userData = await _authService.getUserData(user.uid);
      
      if (userData != null) {
        // Use the email verification status from Firestore instead of checking Firebase
        // This prevents issues during signup when email hasn't been verified yet
        bool isEmailVerified = userData.isEmailVerified;
        
        state = state.copyWith(
          user: user,
          userData: userData,
          isLoading: false,
          isEmailVerified: isEmailVerified,
          isTwoFactorVerified: false, // Will be set after 2FA verification
        );
        _logger.i('User data loaded successfully: ${userData.role}');
      } else {
        // If user data is not found, it might be a timing issue
        // Try to create a default user profile for new users
        _logger.w('User data not found for UID: ${user.uid}, attempting to create default profile');
        
        // Check if this is a new user (created within last 5 minutes)
        final bool isNewUser = DateTime.now().difference(user.metadata.creationTime!).inMinutes < 5;
        
        if (isNewUser) {
          _logger.i('Creating default user profile for new user');
          // Create a default user profile
          await _createDefaultUserProfile(user);
          
          // Try to fetch user data again
          final UserModel? retryUserData = await _authService.getUserData(user.uid);
          if (retryUserData != null) {
            // Check email verification
            bool isEmailVerified = await _authService.checkEmailVerification();
            
            state = state.copyWith(
              user: user,
              userData: retryUserData,
              isLoading: false,
              isEmailVerified: isEmailVerified,
              isTwoFactorVerified: false,
            );
            _logger.i('Default user profile created and loaded: ${retryUserData.role}');
            return;
          }
        }
        
        state = state.copyWith(
          isLoading: false,
          error: 'User data not found. Please contact support if this issue persists.',
        );
        _logger.e('User data not found for UID: ${user.uid}');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load user data: $e',
      );
      _logger.e('Error loading user data: $e');
    }
  }

  /// Create a default user profile for new users
  Future<void> _createDefaultUserProfile(User user) async {
    try {
      // Determine role based on email - only admin email gets admin role
      final String userRole = user.email!.toLowerCase() == 'wahuabi@gmail.com' ? 'admin' : 'debater';
      
      await _authService.storeUserData(
        uid: user.uid,
        email: user.email!,
        role: userRole,
        twoFactorPreference: 'email', // Default 2FA preference
        phone: null,
        isEmailVerified: user.emailVerified,
      );
      _logger.i('Default user profile created for UID: ${user.uid}');
    } catch (e) {
      _logger.e('Error creating default user profile: $e');
      rethrow;
    }
  }

  /// Sign up with email and password
  Future<void> signUp({
    required String email,
    required String password,
    required String twoFactorPreference,
    String? phone,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      _logger.i('Starting sign up process');

      await _authService.signUp(
        email: email,
        password: password,
        twoFactorPreference: twoFactorPreference,
        phone: phone,
      );

      // After successful signup, reset state and set a flag to indicate signup success
      state = state.copyWith(
        isLoading: false,
        isSignupSuccess: true,
      );
      _logger.i('Sign up process completed successfully');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      _logger.e('Sign up error: $e');
    }
  }

  /// Sign in with email and password
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      _logger.i('Starting sign in process');

      await _authService.signIn(
        email: email,
        password: password,
      );

      state = state.copyWith(isLoading: false);
      _logger.i('Sign in process completed');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      _logger.e('Sign in error: $e');
    }
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      _logger.i('Starting Google sign in process');

      await _authService.signInWithGoogle();

      state = state.copyWith(isLoading: false);
      _logger.i('Google sign in process completed');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      _logger.e('Google sign in error: $e');
    }
  }



  /// Update user data
  Future<void> updateUserData(UserModel userData) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      _logger.i('Updating user data');

      await _authService.updateUserData(userData);

      state = state.copyWith(
        isLoading: false,
        userData: userData,
      );
      _logger.i('User data updated successfully');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      _logger.e('Error updating user data: $e');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      _logger.i('Signing out user');

      await _authService.signOut();

      state = const AuthState();
      _logger.i('User signed out successfully');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      _logger.e('Error signing out: $e');
    }
  }

  /// Delete account
  Future<void> deleteAccount() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      _logger.i('Deleting user account');

      await _authService.deleteAccount();

      state = const AuthState();
      _logger.i('User account deleted successfully');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      _logger.e('Error deleting account: $e');
    }
  }

  /// Send sign-in link to email
  Future<void> sendSignInLinkToEmail(String email) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      _logger.i('Sending sign-in link to email');

      await _authService.sendSignInLinkToEmail(email);

      state = state.copyWith(isLoading: false);
      _logger.i('Sign-in link sent successfully');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      _logger.e('Error sending sign-in link: $e');
    }
  }

  /// Sign in with email link
  Future<void> signInWithEmailLink(String email, String emailLink) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      _logger.i('Signing in with email link');

      await _authService.signInWithEmailLink(email: email, emailLink: emailLink);

      state = state.copyWith(isLoading: false);
      _logger.i('Sign-in with email link completed');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      _logger.e('Error signing in with email link: $e');
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Clear signup success flag
  void clearSignupSuccess() {
    state = state.copyWith(isSignupSuccess: false);
  }

  /// Apply email verification using the verification code from email link
  Future<void> applyEmailVerification(String oobCode) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      _logger.i('Applying email verification');

      await _authService.applyEmailVerification(oobCode);

      // Refresh user data to get updated verification status
      if (state.user != null) {
        await _loadUserData(state.user!);
      }

      state = state.copyWith(isLoading: false);
      _logger.i('Email verification applied successfully');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      _logger.e('Email verification error: $e');
      rethrow;
    }
  }

  /// Check if email is verified
  Future<bool> checkEmailVerification() async {
    try {
      return await _authService.checkEmailVerification();
    } catch (e) {
      _logger.e('Error checking email verification: $e');
      return false;
    }
  }

  /// Resend email verification
  Future<void> resendEmailVerification() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      _logger.i('Resending email verification');

      await _authService.sendEmailVerification();

      state = state.copyWith(isLoading: false);
      _logger.i('Email verification resent successfully');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      _logger.e('Error resending email verification: $e');
      rethrow;
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      _logger.i('Sending password reset email to: $email');

      await _authService.sendPasswordResetEmail(email);

      state = state.copyWith(isLoading: false);
      _logger.i('Password reset email sent successfully');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      _logger.e('Error sending password reset email: $e');
      rethrow;
    }
  }

  /// Mark two-factor authentication as verified
  void markTwoFactorVerified() {
    state = state.copyWith(isTwoFactorVerified: true);
    _logger.i('Two-factor authentication verified');
  }

  /// Refresh user data
  Future<void> refreshUserData() async {
    if (state.user != null) {
      await _loadUserData(state.user!);
    }
  }
}

/// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Auth notifier provider
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

/// Convenience providers for specific auth state
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authNotifierProvider).user;
});

final currentUserDataProvider = Provider<UserModel?>((ref) {
  return ref.watch(authNotifierProvider).userData;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).isAuthenticated;
});

final isAdminProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).isAdmin;
});

final isDebaterProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).isDebater;
});

final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).isLoading;
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authNotifierProvider).error;
});
