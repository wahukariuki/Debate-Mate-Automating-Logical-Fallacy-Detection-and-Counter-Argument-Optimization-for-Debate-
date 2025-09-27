import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debate_mate/features/auth/widgets/custom_button.dart';

void main() {
  group('Google Logo Tests', () {
    testWidgets('should render Google sign-in button with logo', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: GoogleSignInButton(
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the Google sign-in button is rendered
      expect(find.byType(GoogleSignInButton), findsOneWidget);
      
      // Verify the button text is present
      expect(find.text('Sign in with Google'), findsOneWidget);
      
      // Verify no errors occurred during rendering
      expect(tester.takeException(), isNull);
    });

    testWidgets('should display logo image correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: GoogleSignInButton(
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the Image widget is rendered (which contains our PNG logo)
      expect(find.byType(Image), findsOneWidget);
      
      // Verify no errors occurred
      expect(tester.takeException(), isNull);
    });

    testWidgets('should handle disabled state correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: GoogleSignInButton(
                onPressed: null, // Disabled
                isEnabled: false,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the button is rendered
      expect(find.byType(GoogleSignInButton), findsOneWidget);
      
      // Verify no errors occurred
      expect(tester.takeException(), isNull);
    });

    testWidgets('should handle loading state correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: GoogleSignInButton(
                onPressed: () {},
                isLoading: true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the button is rendered
      expect(find.byType(GoogleSignInButton), findsOneWidget);
      
      // Verify no errors occurred
      expect(tester.takeException(), isNull);
    });
  });
}
