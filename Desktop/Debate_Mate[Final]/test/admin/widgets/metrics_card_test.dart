import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:debate_mate/features/admin/widgets/metrics_card.dart';

void main() {
  group('MetricsCard Widget Tests', () {
    testWidgets('should display all required elements', (WidgetTester tester) async {
      // Arrange
      const title = 'Total Users';
      const value = '1,234';
      const trend = '+12%';
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MetricsCard(
              title: title,
              value: value,
              icon: Icons.people_outline,
              color: Colors.blue,
              trend: trend,
              trendUp: true,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(title), findsOneWidget);
      expect(find.text(value), findsOneWidget);
      expect(find.text(trend), findsOneWidget);
      expect(find.byIcon(Icons.people_outline), findsOneWidget);
      expect(find.byIcon(Icons.trending_up), findsOneWidget);
    });

    testWidgets('should display downward trend correctly', (WidgetTester tester) async {
      // Arrange
      const trend = '-5%';
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MetricsCard(
              title: 'Test Metric',
              value: '100',
              icon: Icons.trending_down,
              color: Colors.red,
              trend: trend,
              trendUp: false,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(trend), findsOneWidget);
      expect(find.byIcon(Icons.trending_down), findsOneWidget);
    });

    testWidgets('should handle tap events', (WidgetTester tester) async {
      // Arrange
      bool tapped = false;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MetricsCard(
              title: 'Test Metric',
              value: '100',
              icon: Icons.star,
              color: Colors.blue,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(MetricsCard));
      await tester.pump();

      // Assert
      expect(tapped, isTrue);
    });

    testWidgets('should work without optional parameters', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MetricsCard(
              title: 'Test Metric',
              value: '100',
              icon: Icons.star,
              color: Colors.blue,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Test Metric'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });
  });
}
