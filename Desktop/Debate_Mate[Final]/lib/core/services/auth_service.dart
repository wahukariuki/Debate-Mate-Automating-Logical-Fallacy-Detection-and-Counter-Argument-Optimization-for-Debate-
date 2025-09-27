import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';

import '../models/user_model.dart';
import 'firebase_admin_service.dart';

/// Authentication service handling all auth operations
/// Includes email/password, Google sign-in, and 2FA functionality
class AuthService {
  static const String _adminEmail = 'wahuabi@gmail.com';
  
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final FirebaseFunctions _functions = FirebaseFunctions.instance; // Used by EmailService
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final Logger _logger = Logger();
  final FirebaseAdminService _adminService = FirebaseAdminService();

  /// Current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Current user
  User? get currentUser => _auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Sign up with email and password
  Future<UserCredential?> signUp({
    required String email,
    required String password,
    required String twoFactorPreference,
    String? phone,
  }) async {
    try {
      _logger.i('Starting sign up process for email: $email');
      
      // Create user with email and password
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;
      if (user == null) {
        throw Exception('Failed to create user');
      }

      // Determine role based on email - only admin email gets admin role
      final String userRole = email.toLowerCase() == _adminEmail.toLowerCase() ? 'admin' : 'debater';
      
      // Store user data in Firestore first
      await storeUserData(
        uid: user.uid,
        email: email,
        role: userRole,
        twoFactorPreference: twoFactorPreference,
        phone: phone,
        isEmailVerified: false,
      );

      // Note: Email verification will be sent during first sign-in attempt
      _logger.i('User signed up successfully: $email');

      _logger.i('User data stored in Firestore');
      
      // Log signup activity
      await _adminService.logActivity(
        userId: user.uid,
        type: 'user_registered',
        description: 'New user registered with email/password',
        userEmail: email,
        metadata: {
          'signUpMethod': 'email_password',
          'role': userRole,
          'isEmailVerified': false,
        },
      );
      
      // Sign out the user immediately after signup to force them to login
      await _auth.signOut();
      _logger.i('User signed out after signup to require login');
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      _logger.e('Firebase Auth error during sign up: ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      _logger.e('Unexpected error during sign up: $e');
      throw Exception('An unexpected error occurred during sign up');
    }
  }

  /// Sign in with email and password
  Future<UserCredential?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _logger.i('Starting sign in process for email: $email');
      
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;
      if (user == null) {
        throw Exception('Failed to sign in');
      }

      // Check email verification
      if (!user.emailVerified) {
        // Send email verification but keep user signed in for verification screen
        await sendEmailVerification();
        _logger.i('Email verification sent to: $email');
        // Don't sign out - let the user stay signed in to access verification screen
      }

      // Update last login time
      await _updateLastLogin(user.uid);

      // Log sign-in activity
      await _adminService.logActivity(
        userId: user.uid,
        type: 'user_signin',
        description: 'User signed in with email/password',
        userEmail: user.email,
        metadata: {
          'signInMethod': 'email_password',
          'isEmailVerified': user.emailVerified,
        },
      );

      _logger.i('User signed in successfully: ${user.uid}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      _logger.e('Firebase Auth error during sign in: ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      _logger.e('Unexpected error during sign in: $e');
      throw Exception('An unexpected error occurred during sign in');
    }
  }

  /// Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      _logger.i('Starting Google sign in process');
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _logger.w('Google sign in cancelled by user');
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) {
        throw Exception('Failed to sign in with Google');
      }

      // Check if this is a new user
      final bool isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
      
      if (isNewUser) {
        // Determine role based on email - only admin email gets admin role
        final String userRole = user.email!.toLowerCase() == _adminEmail.toLowerCase() ? 'admin' : 'debater';
        
        // Store user data for new Google users
        await storeUserData(
          uid: user.uid,
          email: user.email!,
          role: userRole,
          twoFactorPreference: 'email', // Default to email 2FA
          phone: null,
          isEmailVerified: true, // Google accounts are pre-verified
        );
        _logger.i('New Google user data stored: ${user.uid}');
        
        // Log Google signup activity
        await _adminService.logActivity(
          userId: user.uid,
          type: 'user_registered',
          description: 'New user registered with Google',
          userEmail: user.email,
          metadata: {
            'signUpMethod': 'google',
            'role': userRole,
            'isEmailVerified': true,
          },
        );
      } else {
        // Update last login time for existing users
        await _updateLastLogin(user.uid);
        _logger.i('Existing Google user signed in: ${user.uid}');
      }

      // Log Google sign-in activity
      await _adminService.logActivity(
        userId: user.uid,
        type: 'user_signin',
        description: 'User signed in with Google',
        userEmail: user.email,
        metadata: {
          'signInMethod': 'google',
          'isNewUser': isNewUser,
          'isEmailVerified': user.emailVerified,
        },
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      _logger.e('Firebase Auth error during Google sign in: ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      _logger.e('Unexpected error during Google sign in: $e');
      throw Exception('An unexpected error occurred during Google sign in');
    }
  }



  /// Get user data from Firestore with retry logic
  Future<UserModel?> getUserData(String uid) async {
    const int maxRetries = 3;
    const Duration retryDelay = Duration(seconds: 1);
    
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        _logger.i('Fetching user data for UID: $uid (attempt $attempt/$maxRetries)');
        
        final DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
        
        if (doc.exists && doc.data() != null) {
          final userData = UserModel.fromFirestore(doc);
          _logger.i('User data fetched successfully: ${userData.role}');
          return userData;
        } else {
          _logger.w('User data not found for UID: $uid (attempt $attempt)');
          if (attempt < maxRetries) {
            _logger.i('Retrying in ${retryDelay.inSeconds} seconds...');
            await Future.delayed(retryDelay);
            continue;
          }
          return null;
        }
      } catch (e) {
        _logger.e('Error fetching user data (attempt $attempt): $e');
        if (attempt < maxRetries) {
          _logger.i('Retrying in ${retryDelay.inSeconds} seconds...');
          await Future.delayed(retryDelay);
          continue;
        }
        return null;
      }
    }
    
    return null;
  }

  /// Update user data in Firestore
  Future<void> updateUserData(UserModel user) async {
    try {
      _logger.i('Updating user data for UID: ${user.uid}');
      
      await _firestore.collection('users').doc(user.uid).update(user.toFirestore());
      _logger.i('User data updated successfully');
    } catch (e) {
      _logger.e('Error updating user data: $e');
      throw Exception('Failed to update user data');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      _logger.i('Signing out user');
      
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      
      _logger.i('User signed out successfully');
    } catch (e) {
      _logger.e('Error signing out: $e');
      throw Exception('Failed to sign out');
    }
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user signed in');
      }

      _logger.i('Deleting user account: ${user.uid}');
      
      // Delete user data from Firestore
      await _firestore.collection('users').doc(user.uid).delete();
      
      // Delete Firebase Auth user
      await user.delete();
      
      _logger.i('User account deleted successfully');
    } catch (e) {
      _logger.e('Error deleting user account: $e');
      throw Exception('Failed to delete user account');
    }
  }

  /// Store user data in Firestore
  Future<void> storeUserData({
    required String uid,
    required String email,
    required String role,
    required String twoFactorPreference,
    String? phone,
    required bool isEmailVerified,
  }) async {
    final userData = {
      'email': email,
      'role': role,
      'twoFactorPreference': twoFactorPreference,
      'phone': phone,
      'isEmailVerified': isEmailVerified,
      'createdAt': FieldValue.serverTimestamp(),
      'lastLoginAt': null,
    };

    await _firestore.collection('users').doc(uid).set(userData);
  }

  /// Update last login time
  Future<void> _updateLastLogin(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'lastLoginAt': FieldValue.serverTimestamp(),
    });
  }


  /// Send email link for passwordless sign-in
  Future<void> sendSignInLinkToEmail(String email) async {
    try {
      final actionCodeSettings = ActionCodeSettings(
        url: 'https://debatematef.firebaseapp.com/email-link-signin',
        handleCodeInApp: true,
        iOSBundleId: 'com.debatemate.appfinal',
        androidPackageName: 'com.debatemate.appfinal',
        androidInstallApp: true,
        androidMinimumVersion: '21',
      );

      await _auth.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: actionCodeSettings,
      );

      _logger.i('Sign-in link sent to $email');
    } catch (e, st) {
      _logger.e('Error sending sign-in link: $e', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Send email verification with proper action code settings
  /// The verification link will redirect to /verify-email route in the app
  /// where the EmailVerificationCallbackScreen will handle the verification
  Future<void> sendEmailVerification() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user signed in');
      }

      final actionCodeSettings = ActionCodeSettings(
        url: 'https://debatematef.firebaseapp.com/verify-email',
        handleCodeInApp: true, // Set to true to handle in app
        iOSBundleId: 'com.debatemate.appfinal',
        androidPackageName: 'com.debatemate.appfinal',
        androidInstallApp: true,
        androidMinimumVersion: '21',
      );

      await user.sendEmailVerification(actionCodeSettings);
      _logger.i('Email verification sent to: ${user.email}');
    } catch (e, st) {
      _logger.e('Error sending email verification: $e', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      _logger.i('Sending password reset email to: $email');
      
      final actionCodeSettings = ActionCodeSettings(
        url: 'https://debatematef.firebaseapp.com/reset-password',
        handleCodeInApp: true,
        iOSBundleId: 'com.debatemate.appfinal',
        androidPackageName: 'com.debatemate.appfinal',
        androidInstallApp: true,
        androidMinimumVersion: '21',
      );

      await _auth.sendPasswordResetEmail(
        email: email,
        actionCodeSettings: actionCodeSettings,
      );

      _logger.i('Password reset email sent successfully to: $email');
    } on FirebaseAuthException catch (e) {
      _logger.e('Firebase Auth error sending password reset: ${e.message}');
      throw _handleAuthException(e);
    } catch (e, st) {
      _logger.e('Error sending password reset email: $e', error: e, stackTrace: st);
      throw Exception('Failed to send password reset email');
    }
  }

  /// Check if email is verified with user reload
  Future<bool> checkEmailVerification() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        return false;
      }

      await user.reload();
      final bool isVerified = user.emailVerified;
      _logger.i('Email verification status: $isVerified');
      
      // Update Firestore if email is verified
      if (isVerified) {
        await _updateEmailVerificationStatus(user.uid, true);
      }
      
      return isVerified;
    } catch (e) {
      _logger.e('Error checking email verification: $e');
      return false;
    }
  }

  /// Apply email verification using the verification code from email link
  Future<void> applyEmailVerification(String oobCode) async {
    try {
      _logger.i('Applying email verification with code: $oobCode');
      
      // Apply the email verification action
      await _auth.applyActionCode(oobCode);
      
      _logger.i('Email verification applied successfully');
      
      // Update Firestore with verification status
      final User? user = _auth.currentUser;
      if (user != null) {
        await _updateEmailVerificationStatus(user.uid, true);
        
        // Log email verification activity
        await _adminService.logActivity(
          userId: user.uid,
          type: 'email_verified',
          description: 'User verified their email address',
          userEmail: user.email,
          metadata: {
            'verificationMethod': 'email_link',
          },
        );
      }
    } catch (e, st) {
      _logger.e('Error applying email verification: $e', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Update email verification status in Firestore
  Future<void> _updateEmailVerificationStatus(String uid, bool isVerified) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'isEmailVerified': isVerified,
        'emailVerifiedAt': isVerified ? FieldValue.serverTimestamp() : null,
      });
      _logger.i('Updated email verification status in Firestore: $isVerified');
    } catch (e) {
      _logger.e('Error updating email verification status in Firestore: $e');
    }
  }

  /// Check if the current link is a sign-in with email link
  bool isSignInWithEmailLink(String link) {
    return _auth.isSignInWithEmailLink(link);
  }

  /// Complete sign-in with email link
  Future<UserCredential> signInWithEmailLink({
    required String email,
    required String emailLink,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailLink(
        email: email,
        emailLink: emailLink,
      );

      // If this is a new user, we need to set up their profile
      if (userCredential.additionalUserInfo?.isNewUser == true) {
        await _setupNewUserProfile(userCredential.user!);
      }

      _logger.i('User signed in with email link: ${userCredential.user?.email}');
      return userCredential;
    } catch (e, st) {
      _logger.e('Error signing in with email link: $e', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Set up profile for new user (for email link sign-in)
  Future<void> _setupNewUserProfile(User user) async {
    try {
      // Determine role based on email - only admin email gets admin role
      final String userRole = user.email!.toLowerCase() == _adminEmail.toLowerCase() ? 'admin' : 'debater';
      
      // For email link users, we'll prompt them to set their role and 2FA preference
      // after they complete the sign-in process
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'role': userRole,
        'twoFactorPreference': 'email', // Default to email for email link users
        'phone': null,
        'createdAt': FieldValue.serverTimestamp(),
        'needsProfileSetup': true, // Flag to indicate profile needs completion
      });
    } catch (e, st) {
      _logger.e('Error setting up new user profile: $e', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Validate user role for accessing specific features
  Future<bool> validateUserRole({
    required String userId,
    required String requiredRole,
  }) async {
    try {
      _logger.i('Validating user role for UID: $userId, required: $requiredRole');
      
      final UserModel? userData = await getUserData(userId);
      if (userData == null) {
        _logger.w('User data not found for role validation');
        return false;
      }
      
      final bool hasRequiredRole = userData.role == requiredRole;
      _logger.i('Role validation result: $hasRequiredRole (user role: ${userData.role})');
      
      return hasRequiredRole;
    } catch (e) {
      _logger.e('Error validating user role: $e');
      return false;
    }
  }

  /// Check if current user has admin privileges
  Future<bool> isCurrentUserAdmin() async {
    try {
      final User? user = currentUser;
      if (user == null) return false;
      
      return await validateUserRole(userId: user.uid, requiredRole: 'admin');
    } catch (e) {
      _logger.e('Error checking admin privileges: $e');
      return false;
    }
  }

  /// Check if current user has debater privileges
  Future<bool> isCurrentUserDebater() async {
    try {
      final User? user = currentUser;
      if (user == null) return false;
      
      return await validateUserRole(userId: user.uid, requiredRole: 'debater');
    } catch (e) {
      _logger.e('Error checking debater privileges: $e');
      return false;
    }
  }

  /// Get current user's role
  Future<String?> getCurrentUserRole() async {
    try {
      final User? user = currentUser;
      if (user == null) return null;
      
      final UserModel? userData = await getUserData(user.uid);
      return userData?.role;
    } catch (e) {
      _logger.e('Error getting current user role: $e');
      return null;
    }
  }

  /// Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'invalid-verification-code':
        return 'Invalid verification code.';
      case 'invalid-verification-id':
        return 'Invalid verification ID.';
      case 'credential-already-in-use':
        return 'This credential is already associated with a different user.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }
}
