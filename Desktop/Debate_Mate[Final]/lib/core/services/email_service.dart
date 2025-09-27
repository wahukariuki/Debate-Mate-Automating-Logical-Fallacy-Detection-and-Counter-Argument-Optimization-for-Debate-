import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'dart:math';

/// Production-ready email service for OTP delivery
class EmailService {
  static final EmailService _instance = EmailService._internal();
  factory EmailService() => _instance;
  EmailService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();
  
  // Development mode variables
  String? _currentOTP;
  String? _currentEmail;

  /// Generate a secure 6-digit OTP
  String _generateOTP() {
    final random = Random.secure();
    return (100000 + random.nextInt(900000)).toString();
  }

  /// Store OTP in Firestore with expiration
  Future<void> _storeOTP(String email, String otp) async {
    try {
      final otpData = {
        'otp': otp,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': FieldValue.serverTimestamp(),
        'attempts': 0,
        'isUsed': false,
      };

      // Store with 5-minute expiration
      await _firestore.collection('otps').doc(email).set(otpData);
      
      // Set up automatic cleanup after 5 minutes
      await _firestore.collection('otps').doc(email).update({
        'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(minutes: 5))),
      });

      _logger.i('OTP stored for email: $email');
      
      // In development mode, also store in a global variable for easy access
      if (kDebugMode) {
        _currentOTP = otp;
        _currentEmail = email;
        _logger.i('🔧 DEVELOPMENT: Current OTP for $email is $otp');
      }
    } catch (e) {
      _logger.e('Error storing OTP: $e');
      rethrow;
    }
  }

  /// Send OTP email (production implementation)
  Future<void> sendOTPEmail(String email) async {
    try {
      _logger.i('Sending OTP email to: $email');

      // Generate secure OTP
      final otp = _generateOTP();
      
      // Store OTP in Firestore
      await _storeOTP(email, otp);

      // Send email via Firebase Functions
      await _sendEmailViaFunction(email, otp);

      _logger.i('OTP email sent successfully to: $email');
    } catch (e) {
      _logger.e('Error sending OTP email: $e');
      rethrow;
    }
  }

  /// Send email via Firebase Functions
  Future<void> _sendEmailViaFunction(String email, String otp) async {
    try {
      // Call Firebase Function to send actual email
      final callable = FirebaseFunctions.instance.httpsCallable('sendOTPEmail');
      
      final result = await callable.call({
        'email': email,
        'otp': otp,
        'template': 'otp_verification',
      });

      if (result.data['success'] != true) {
        throw Exception(result.data['error'] ?? 'Failed to send email');
      }

      _logger.i('Email sent via Firebase Functions');
    } catch (e) {
      _logger.e('Error calling Firebase Function: $e');
      
      // For development: Log the OTP so you can test
      _logger.i('DEVELOPMENT MODE: OTP for $email is $otp');
      _logger.w('Firebase Functions not deployed or email not configured');
      
      // Don't throw error in development - just log the OTP
      // In production, you would want to throw the error
      if (kDebugMode) {
        _logger.i('Using development mode - OTP logged above');
      } else {
        throw Exception('Email service temporarily unavailable. Please try again.');
      }
    }
  }

  /// Verify OTP
  Future<bool> verifyOTP(String email, String otp) async {
    try {
      _logger.i('Verifying OTP for email: $email');

      final doc = await _firestore.collection('otps').doc(email).get();
      
      if (!doc.exists) {
        _logger.w('No OTP found for email: $email');
        return false;
      }

      final data = doc.data()!;
      final storedOTP = data['otp'] as String?;
      final isUsed = data['isUsed'] as bool? ?? false;
      final attempts = data['attempts'] as int? ?? 0;
      final expiresAt = data['expiresAt'] as Timestamp?;

      // Check if OTP is expired
      if (expiresAt != null && expiresAt.toDate().isBefore(DateTime.now())) {
        _logger.w('OTP expired for email: $email');
        await _cleanupOTP(email);
        return false;
      }

      // Check if OTP is already used
      if (isUsed) {
        _logger.w('OTP already used for email: $email');
        return false;
      }

      // Check attempt limit (max 3 attempts)
      if (attempts >= 3) {
        _logger.w('Too many attempts for email: $email');
        await _cleanupOTP(email);
        return false;
      }

      // Verify OTP
      if (storedOTP == otp) {
        // Mark OTP as used
        await _firestore.collection('otps').doc(email).update({
          'isUsed': true,
          'verifiedAt': FieldValue.serverTimestamp(),
        });

        _logger.i('OTP verified successfully for email: $email');
        return true;
      } else {
        // Increment attempt count
        await _firestore.collection('otps').doc(email).update({
          'attempts': FieldValue.increment(1),
        });

        _logger.w('Invalid OTP for email: $email (attempt ${attempts + 1})');
        return false;
      }
    } catch (e) {
      _logger.e('Error verifying OTP: $e');
      return false;
    }
  }

  /// Clean up expired OTPs
  Future<void> _cleanupOTP(String email) async {
    try {
      await _firestore.collection('otps').doc(email).delete();
      _logger.i('OTP cleaned up for email: $email');
    } catch (e) {
      _logger.e('Error cleaning up OTP: $e');
    }
  }

  /// Clean up all expired OTPs (call this periodically)
  Future<void> cleanupExpiredOTPs() async {
    try {
      final now = DateTime.now();
      final query = await _firestore
          .collection('otps')
          .where('expiresAt', isLessThan: Timestamp.fromDate(now))
          .get();

      final batch = _firestore.batch();
      for (final doc in query.docs) {
        batch.delete(doc.reference);
      }

      if (query.docs.isNotEmpty) {
        await batch.commit();
        _logger.i('Cleaned up ${query.docs.length} expired OTPs');
      }
    } catch (e) {
      _logger.e('Error cleaning up expired OTPs: $e');
    }
  }

  /// Get current OTP for development mode
  String? getCurrentOTP() {
    if (kDebugMode) {
      return _currentOTP;
    }
    return null;
  }

  /// Get current email for development mode
  String? getCurrentEmail() {
    if (kDebugMode) {
      return _currentEmail;
    }
    return null;
  }

  /// Get OTP status for debugging
  Future<Map<String, dynamic>?> getOTPStatus(String email) async {
    try {
      final doc = await _firestore.collection('otps').doc(email).get();
      
      if (!doc.exists) {
        return null;
      }

      final data = doc.data()!;
      return {
        'email': email,
        'hasOTP': true,
        'isUsed': data['isUsed'] ?? false,
        'attempts': data['attempts'] ?? 0,
        'createdAt': data['createdAt'],
        'expiresAt': data['expiresAt'],
        'isExpired': data['expiresAt'] != null && 
                   (data['expiresAt'] as Timestamp).toDate().isBefore(DateTime.now()),
      };
    } catch (e) {
      _logger.e('Error getting OTP status: $e');
      return null;
    }
  }
}
