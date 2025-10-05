import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/scheduler.dart';

import 'package:debate_mate/features/admin/widgets/responsive_tab_bar.dart';
import 'package:debate_mate/features/admin/widgets/responsive_layout.dart';

void main() {
  group('ResponsiveTabBar Tests', () {
    late TabController tabController;

    setUp(() {
      tabController = TabController(length: 3, vsync: TestVSync());
    });

    tearDown(() {
      tabController.dispose();
    });

    testWidgets('should render tabs without overflow on mobile', (WidgetTester tester) async {
      // Simulate mobile screen size
      await tester.binding.setSurfaceSize(const Size(375, 667));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveTabBar(
              controller: tabController,
              tabs: const [
                TabData.withIcon(
                  text: 'System Health',
                  icon: Icons.monitor_heart_outlined,
                ),
                TabData.withIcon(
                  text: 'AI Models',
                  icon: Icons.psychology_outlined,
                ),
                TabData.withIcon(
                  text: 'Features',
                  icon: Icons.settings_outlined,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify tabs are rendered
      expect(find.text('System Health'), findsOneWidget);
      expect(find.text('AI Models'), findsOneWidget);
      expect(find.text('Features'), findsOneWidget);

      // Verify icons are present
      expect(find.byIcon(Icons.monitor_heart_outlined), findsOneWidget);
      expect(find.byIcon(Icons.psychology_outlined), findsOneWidget);
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);

      // Verify no overflow errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('should render tabs without overflow on tablet', (WidgetTester tester) async {
      // Simulate tablet screen size
      await tester.binding.setSurfaceSize(const Size(768, 1024));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveTabBar(
              controller: tabController,
              tabs: const [
                TabData.withIcon(
                  text: 'System Health',
                  icon: Icons.monitor_heart_outlined,
                ),
                TabData.withIcon(
                  text: 'AI Models',
                  icon: Icons.psychology_outlined,
                ),
                TabData.withIcon(
                  text: 'Features',
                  icon: Icons.settings_outlined,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify tabs are rendered
      expect(find.text('System Health'), findsOneWidget);
      expect(find.text('AI Models'), findsOneWidget);
      expect(find.text('Features'), findsOneWidget);

      // Verify no overflow errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('should render tabs without overflow on desktop', (WidgetTester tester) async {
      // Simulate desktop screen size
      await tester.binding.setSurfaceSize(const Size(1920, 1080));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveTabBar(
              controller: tabController,
              tabs: const [
                TabData.withIcon(
                  text: 'System Health',
                  icon: Icons.monitor_heart_outlined,
                ),
                TabData.withIcon(
                  text: 'AI Models',
                  icon: Icons.psychology_outlined,
                ),
                TabData.withIcon(
                  text: 'Features',
                  icon: Icons.settings_outlined,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify tabs are rendered
      expect(find.text('System Health'), findsOneWidget);
      expect(find.text('AI Models'), findsOneWidget);
      expect(find.text('Features'), findsOneWidget);

      // Verify no overflow errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('should handle long tab text with ellipsis', (WidgetTester tester) async {
      // Simulate mobile screen size
      await tester.binding.setSurfaceSize(const Size(375, 667));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveTabBar(
              controller: tabController,
              tabs: const [
                TabData.withIcon(
                  text: 'Very Long Tab Name That Should Overflow',
                  icon: Icons.monitor_heart_outlined,
                ),
                TabData.withIcon(
                  text: 'Another Very Long Tab Name',
                  icon: Icons.psychology_outlined,
                ),
                TabData.withIcon(
                  text: 'Short',
                  icon: Icons.settings_outlined,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify no overflow errors even with long text
      expect(tester.takeException(), isNull);
    });

    testWidgets('should be scrollable when tabs exceed screen width', (WidgetTester tester) async {
      // Simulate very narrow screen
      await tester.binding.setSurfaceSize(const Size(200, 400));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveTabBar(
              controller: tabController,
              tabs: const [
                TabData.withIcon(
                  text: 'System Health',
                  icon: Icons.monitor_heart_outlined,
                ),
                TabData.withIcon(
                  text: 'AI Models',
                  icon: Icons.psychology_outlined,
                ),
                TabData.withIcon(
                  text: 'Features',
                  icon: Icons.settings_outlined,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify tabs are still accessible through scrolling
      expect(find.text('System Health'), findsOneWidget);
      expect(find.text('AI Models'), findsOneWidget);
      expect(find.text('Features'), findsOneWidget);

      // Verify no overflow errors
      expect(tester.takeException(), isNull);
    });
  });

  group('CompactTabBar Tests', () {
    late TabController tabController;

    setUp(() {
      tabController = TabController(length: 3, vsync: TestVSync());
    });

    tearDown(() {
      tabController.dispose();
    });

    testWidgets('should render compact tabs on mobile', (WidgetTester tester) async {
      // Simulate mobile screen size
      await tester.binding.setSurfaceSize(const Size(375, 667));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactTabBar(
              controller: tabController,
              tabs: const [
                CompactTabData(
                  text: 'System Health',
                  shortText: 'Health',
                  icon: Icons.monitor_heart_outlined,
                ),
                CompactTabData(
                  text: 'AI Models',
                  shortText: 'Models',
                  icon: Icons.psychology_outlined,
                ),
                CompactTabData(
                  text: 'Features',
                  shortText: 'Settings',
                  icon: Icons.settings_outlined,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify short text is displayed
      expect(find.text('Health'), findsOneWidget);
      expect(find.text('Models'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);

      // Verify icons are present
      expect(find.byIcon(Icons.monitor_heart_outlined), findsOneWidget);
      expect(find.byIcon(Icons.psychology_outlined), findsOneWidget);
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);

      // Verify no overflow errors
      expect(tester.takeException(), isNull);
    });
  });

  group('ResponsiveLayout Tests', () {
    testWidgets('should detect mobile screen correctly', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(375, 667));

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final isMobile = ResponsiveLayout.isMobile(context);
              final isTablet = ResponsiveLayout.isTablet(context);
              final isDesktop = ResponsiveLayout.isDesktop(context);

              return Scaffold(
                body: Column(
                  children: [
                    Text('Mobile: $isMobile'),
                    Text('Tablet: $isTablet'),
                    Text('Desktop: $isDesktop'),
                  ],
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Mobile: true'), findsOneWidget);
      expect(find.text('Tablet: false'), findsOneWidget);
      expect(find.text('Desktop: false'), findsOneWidget);
    });

    testWidgets('should detect tablet screen correctly', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(768, 1024));

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final isMobile = ResponsiveLayout.isMobile(context);
              final isTablet = ResponsiveLayout.isTablet(context);
              final isDesktop = ResponsiveLayout.isDesktop(context);

              return Scaffold(
                body: Column(
                  children: [
                    Text('Mobile: $isMobile'),
                    Text('Tablet: $isTablet'),
                    Text('Desktop: $isDesktop'),
                  ],
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Mobile: false'), findsOneWidget);
      expect(find.text('Tablet: true'), findsOneWidget);
      expect(find.text('Desktop: false'), findsOneWidget);
    });

    testWidgets('should detect desktop screen correctly', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1920, 1080));

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final isMobile = ResponsiveLayout.isMobile(context);
              final isTablet = ResponsiveLayout.isTablet(context);
              final isDesktop = ResponsiveLayout.isDesktop(context);

              return Scaffold(
                body: Column(
                  children: [
                    Text('Mobile: $isMobile'),
                    Text('Tablet: $isTablet'),
                    Text('Desktop: $isDesktop'),
                  ],
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Mobile: false'), findsOneWidget);
      expect(find.text('Tablet: false'), findsOneWidget);
      expect(find.text('Desktop: true'), findsOneWidget);
    });
  });
}

/// Test implementation of TickerProvider
class TestVSync extends TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}
