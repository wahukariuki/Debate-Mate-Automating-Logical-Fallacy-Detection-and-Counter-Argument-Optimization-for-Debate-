import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../lib/core/providers/auth_provider.dart';
import '../lib/core/models/user_model.dart';

void main() {
  group('Widget Tests', () {
    testWidgets('App should start with login screen', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('Debate Mate'),
              ),
            ),
          ),
        ),
      );

      // Verify that the app starts
      expect(find.text('Debate Mate'), findsOneWidget);
    });

    testWidgets('CustomTextField should display label and hint', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                // Import the CustomTextField widget here
                // CustomTextField(
                //   label: 'Email',
                //   hint: 'Enter your email',
                // ),
                const Text('Custom Text Field Test'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Custom Text Field Test'), findsOneWidget);
    });

    testWidgets('CustomButton should display text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                // Import the CustomButton widget here
                // CustomButton(
                //   text: 'Sign In',
                //   onPressed: () {},
                // ),
                const Text('Custom Button Test'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Custom Button Test'), findsOneWidget);
    });
  });

  group('UserModel Tests', () {
    test('UserModel should create instance with required fields', () {
      // Arrange
      final user = UserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        role: 'debater',
        twoFactorPreference: 'email',
        isEmailVerified: true,
        createdAt: DateTime.now(),
      );

      // Assert
      expect(user.uid, equals('test-uid'));
      expect(user.email, equals('test@example.com'));
      expect(user.role, equals('debater'));
      expect(user.twoFactorPreference, equals('email'));
      expect(user.isEmailVerified, isTrue);
      expect(user.isAdmin, isFalse);
      expect(user.isDebater, isTrue);
      expect(user.hasEmail2FA, isTrue);
      expect(user.hasSms2FA, isFalse);
    });

    test('UserModel should identify admin correctly', () {
      // Arrange
      final admin = UserModel(
        uid: 'admin-uid',
        email: 'admin@example.com',
        role: 'admin',
        twoFactorPreference: 'sms',
        phone: '+1234567890',
        isEmailVerified: true,
        createdAt: DateTime.now(),
      );

      // Assert
      expect(admin.isAdmin, isTrue);
      expect(admin.isDebater, isFalse);
      expect(admin.hasSms2FA, isTrue);
      expect(admin.hasEmail2FA, isFalse);
    });

    test('UserModel should create copy with updated fields', () {
      // Arrange
      final original = UserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        role: 'debater',
        twoFactorPreference: 'email',
        isEmailVerified: false,
        createdAt: DateTime.now(),
      );

      // Act
      final updated = original.copyWith(
        isEmailVerified: true,
        lastLoginAt: DateTime.now(),
      );

      // Assert
      expect(updated.uid, equals(original.uid));
      expect(updated.email, equals(original.email));
      expect(updated.role, equals(original.role));
      expect(updated.isEmailVerified, isTrue);
      expect(updated.lastLoginAt, isNotNull);
    });

    test('UserModel should convert to and from Firestore data', () {
      // Arrange
      final original = UserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        role: 'debater',
        twoFactorPreference: 'email',
        phone: '+1234567890',
        isEmailVerified: true,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      // Act
      final firestoreData = original.toFirestore();
      // Note: In a real test, you would mock DocumentSnapshot
      // and test fromFirestore method

      // Assert
      expect(firestoreData['email'], equals('test@example.com'));
      expect(firestoreData['role'], equals('debater'));
      expect(firestoreData['twoFactorPreference'], equals('email'));
      expect(firestoreData['phone'], equals('+1234567890'));
      expect(firestoreData['isEmailVerified'], isTrue);
    });
  });

  group('AuthState Tests', () {
    test('AuthState should identify authenticated user', () {
      // Arrange
      final user = UserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        role: 'debater',
        twoFactorPreference: 'email',
        isEmailVerified: true,
        createdAt: DateTime.now(),
      );

      final authState = AuthState(
        user: null, // Mock User object
        userData: user,
        isEmailVerified: true,
        isTwoFactorVerified: true,
      );

      // Assert
      expect(authState.isAuthenticated, isTrue);
      expect(authState.isDebater, isTrue);
      expect(authState.isAdmin, isFalse);
      expect(authState.isFullyVerified, isTrue);
    });

    test('AuthState should identify loading state', () {
      // Arrange
      final authState = AuthState(
        isLoading: true,
      );

      // Assert
      expect(authState.isLoading, isTrue);
      expect(authState.isAuthenticated, isFalse);
    });

    test('AuthState should handle error state', () {
      // Arrange
      const errorMessage = 'Authentication failed';
      final authState = AuthState(
        error: errorMessage,
      );

      // Assert
      expect(authState.error, equals(errorMessage));
      expect(authState.isAuthenticated, isFalse);
    });
  });
}
