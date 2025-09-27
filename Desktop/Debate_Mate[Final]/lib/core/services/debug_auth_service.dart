import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';


/// Debug service to help identify authentication and user data issues
class DebugAuthService {
  static final DebugAuthService _instance = DebugAuthService._internal();
  factory DebugAuthService() => _instance;
  DebugAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();

  /// Comprehensive debug check for authentication issues
  Future<Map<String, dynamic>> debugAuthFlow(String email, String password) async {
    final Map<String, dynamic> debugInfo = {
      'timestamp': DateTime.now().toIso8601String(),
      'email': email,
      'checks': <String, dynamic>{},
      'errors': <String>[],
      'recommendations': <String>[],
    };

    try {
      // 1. Check Firebase connection
      await _checkFirebaseConnection(debugInfo);

      // 2. Check user authentication
      await _checkUserAuthentication(email, password, debugInfo);

      // 3. Check Firestore connection and user data
      await _checkFirestoreUserData(debugInfo);

      // 4. Check email verification
      await _checkEmailVerification(debugInfo);

      // 5. Check Firestore rules
      await _checkFirestoreRules(debugInfo);

    } catch (e) {
      debugInfo['errors'].add('Debug check failed: $e');
    }

    return debugInfo;
  }

  /// Check Firebase connection
  Future<void> _checkFirebaseConnection(Map<String, dynamic> debugInfo) async {
    try {
      final app = _auth.app;
      debugInfo['checks']['firebase_app'] = {
        'name': app.name,
        'projectId': app.options.projectId,
        'apiKey': app.options.apiKey,
        'status': 'connected'
      };
      _logger.i('Firebase connection: OK');
    } catch (e) {
      debugInfo['checks']['firebase_app'] = {'status': 'error', 'error': e.toString()};
      debugInfo['errors'].add('Firebase connection failed: $e');
      _logger.e('Firebase connection error: $e');
    }
  }

  /// Check user authentication
  Future<void> _checkUserAuthentication(String email, String password, Map<String, dynamic> debugInfo) async {
    try {
      // Try to sign in
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;
      if (user != null) {
        debugInfo['checks']['authentication'] = {
          'status': 'success',
          'uid': user.uid,
          'email': user.email,
          'emailVerified': user.emailVerified,
          'creationTime': user.metadata.creationTime?.toIso8601String(),
          'lastSignInTime': user.metadata.lastSignInTime?.toIso8601String(),
        };
        _logger.i('Authentication: OK - UID: ${user.uid}');
      } else {
        debugInfo['checks']['authentication'] = {'status': 'failed', 'error': 'User is null'};
        debugInfo['errors'].add('Authentication failed: User is null');
      }
    } catch (e) {
      debugInfo['checks']['authentication'] = {'status': 'error', 'error': e.toString()};
      debugInfo['errors'].add('Authentication error: $e');
      _logger.e('Authentication error: $e');
    }
  }

  /// Check Firestore user data
  Future<void> _checkFirestoreUserData(Map<String, dynamic> debugInfo) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        debugInfo['checks']['firestore_user_data'] = {'status': 'skipped', 'reason': 'No authenticated user'};
        return;
      }

      // Try to fetch user data
      final DocumentSnapshot doc = await _firestore.collection('users').doc(currentUser.uid).get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        debugInfo['checks']['firestore_user_data'] = {
          'status': 'found',
          'documentId': doc.id,
          'data': data,
          'metadata': {
            'hasPendingWrites': doc.metadata.hasPendingWrites,
            'isFromCache': doc.metadata.isFromCache,
          }
        };
        _logger.i('Firestore user data: Found');
      } else {
        debugInfo['checks']['firestore_user_data'] = {'status': 'not_found', 'uid': currentUser.uid};
        debugInfo['errors'].add('User data not found in Firestore for UID: ${currentUser.uid}');
        debugInfo['recommendations'].add('Create user document in Firestore collection "users"');
        _logger.w('Firestore user data: Not found');
      }
    } catch (e) {
      debugInfo['checks']['firestore_user_data'] = {'status': 'error', 'error': e.toString()};
      debugInfo['errors'].add('Firestore user data error: $e');
      _logger.e('Firestore user data error: $e');
    }
  }

  /// Check email verification
  Future<void> _checkEmailVerification(Map<String, dynamic> debugInfo) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        debugInfo['checks']['email_verification'] = {'status': 'skipped', 'reason': 'No authenticated user'};
        return;
      }

      await currentUser.reload();
      debugInfo['checks']['email_verification'] = {
        'status': currentUser.emailVerified ? 'verified' : 'unverified',
        'email': currentUser.email,
      };

      if (!currentUser.emailVerified) {
        debugInfo['recommendations'].add('Verify email address before signing in');
      }
    } catch (e) {
      debugInfo['checks']['email_verification'] = {'status': 'error', 'error': e.toString()};
      debugInfo['errors'].add('Email verification check error: $e');
    }
  }

  /// Check Firestore rules (basic check)
  Future<void> _checkFirestoreRules(Map<String, dynamic> debugInfo) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        debugInfo['checks']['firestore_rules'] = {'status': 'skipped', 'reason': 'No authenticated user'};
        return;
      }

      // Try to write a test document to check rules
      final testDocRef = _firestore.collection('test').doc('auth_test');
      await testDocRef.set({
        'uid': currentUser.uid,
        'timestamp': FieldValue.serverTimestamp(),
        'test': true,
      });

      // Clean up test document
      await testDocRef.delete();

      debugInfo['checks']['firestore_rules'] = {'status': 'accessible'};
      _logger.i('Firestore rules: Accessible');
    } catch (e) {
      debugInfo['checks']['firestore_rules'] = {'status': 'error', 'error': e.toString()};
      debugInfo['errors'].add('Firestore rules error: $e');
      debugInfo['recommendations'].add('Check Firestore security rules for authenticated users');
      _logger.e('Firestore rules error: $e');
    }
  }

  /// Create user data if missing
  Future<bool> createMissingUserData() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        _logger.e('No authenticated user to create data for');
        return false;
      }

      final userData = {
        'email': currentUser.email,
        'role': 'debater', // Default role
        'twoFactorPreference': 'email', // Default 2FA preference
        'phone': null,
        'isEmailVerified': currentUser.emailVerified,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(currentUser.uid).set(userData);
      _logger.i('User data created successfully for UID: ${currentUser.uid}');
      return true;
    } catch (e) {
      _logger.e('Error creating user data: $e');
      return false;
    }
  }

  /// Print debug information in a readable format
  void printDebugInfo(Map<String, dynamic> debugInfo) {
    print('\n=== DEBATE MATE AUTH DEBUG REPORT ===');
    print('Timestamp: ${debugInfo['timestamp']}');
    print('Email: ${debugInfo['email']}');
    print('\n--- CHECK RESULTS ---');
    
    final checks = debugInfo['checks'] as Map<String, dynamic>;
    checks.forEach((key, value) {
      print('$key: ${value['status'] ?? 'unknown'}');
      if (value['error'] != null) {
        print('  Error: ${value['error']}');
      }
    });

    final errors = debugInfo['errors'] as List<String>;
    if (errors.isNotEmpty) {
      print('\n--- ERRORS ---');
      for (final error in errors) {
        print('• $error');
      }
    }

    final recommendations = debugInfo['recommendations'] as List<String>;
    if (recommendations.isNotEmpty) {
      print('\n--- RECOMMENDATIONS ---');
      for (final recommendation in recommendations) {
        print('• $recommendation');
      }
    }
    print('=====================================\n');
  }
}
