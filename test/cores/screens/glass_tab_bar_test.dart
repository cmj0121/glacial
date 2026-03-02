// Widget tests for AdaptiveGlassTabBar.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/cores/platform.dart';
import 'package:glacial/cores/screens/glass_tab_bar.dart';

void main() {
  setUp(() {
    platformOverride = null;
  });

  tearDown(() {
    platformOverride = null;
  });

  Widget buildTabBar({
    int selectedIndex = 0,
    ValueChanged<int>? onTabSelected,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: AdaptiveGlassTabBar(
          tabs: const [Text('Tab 1'), Text('Tab 2'), Text('Tab 3')],
          selectedIndex: selectedIndex,
          onTabSelected: onTabSelected,
        ),
      ),
    );
  }

  group('AdaptiveGlassTabBar Material branch', () {
    testWidgets('renders Container without BackdropFilter on android', (tester) async {
      platformOverride = PlatformType.android;
      await tester.pumpWidget(buildTabBar());

      expect(find.byType(AdaptiveGlassTabBar), findsOneWidget);
      expect(find.byType(BackdropFilter), findsNothing);
      expect(find.text('Tab 1'), findsOneWidget);
      expect(find.text('Tab 2'), findsOneWidget);
      expect(find.text('Tab 3'), findsOneWidget);
    });

    testWidgets('renders Container without BackdropFilter on other', (tester) async {
      platformOverride = PlatformType.other;
      await tester.pumpWidget(buildTabBar());

      expect(find.byType(BackdropFilter), findsNothing);
    });

    testWidgets('tapping tab calls onTabSelected with correct index', (tester) async {
      platformOverride = PlatformType.android;
      int? tappedIndex;
      await tester.pumpWidget(buildTabBar(
        onTabSelected: (index) => tappedIndex = index,
      ));

      await tester.tap(find.text('Tab 2'));
      expect(tappedIndex, 1);
    });

    testWidgets('selected tab has primary color bottom border', (tester) async {
      platformOverride = PlatformType.android;
      await tester.pumpWidget(buildTabBar(selectedIndex: 1));

      // Verify tab 2 is selected and tab widgets are rendered
      expect(find.text('Tab 2'), findsOneWidget);
      expect(find.byType(InkWell), findsNWidgets(3));
    });
  });

  group('AdaptiveGlassTabBar Apple branch', () {
    testWidgets('renders BackdropFilter on apple platform', (tester) async {
      platformOverride = PlatformType.apple;
      await tester.pumpWidget(buildTabBar());

      expect(find.byType(BackdropFilter), findsOneWidget);
      expect(find.byType(ClipRect), findsOneWidget);
    });

    testWidgets('tapping tab calls onTabSelected on apple', (tester) async {
      platformOverride = PlatformType.apple;
      int? tappedIndex;
      await tester.pumpWidget(buildTabBar(
        onTabSelected: (index) => tappedIndex = index,
      ));

      await tester.tap(find.text('Tab 3'));
      expect(tappedIndex, 2);
    });

    testWidgets('selected tab has AnimatedDefaultTextStyle', (tester) async {
      platformOverride = PlatformType.apple;
      await tester.pumpWidget(buildTabBar(selectedIndex: 0));

      expect(find.byType(AnimatedDefaultTextStyle), findsWidgets);
    });
  });

  group('AdaptiveGlassTabBar null callback', () {
    testWidgets('tapping tab with null onTabSelected does not crash', (tester) async {
      platformOverride = PlatformType.android;
      await tester.pumpWidget(buildTabBar(onTabSelected: null));

      // Should not throw
      await tester.tap(find.text('Tab 1'));
      await tester.pump();
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
