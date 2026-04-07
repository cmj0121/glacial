// Widget tests for SwipeTabBar indicator animation and tab switching.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/cores/screens/swipe_tab_bar.dart';

import '../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  Widget buildBar({
    required TabController controller,
    int itemCount = 3,
    bool Function(int)? onTabTappable,
  }) {
    return createTestWidget(
      child: SizedBox(
        width: 300,
        height: 50,
        child: SwipeTabBar(
          controller: controller,
          itemCount: itemCount,
          tabBuilder: (context, index) => Text('T$index'),
          onTabTappable: onTabTappable,
        ),
      ),
    );
  }

  testWidgets('renders all tab labels', (tester) async {
    await tester.pumpWidget(
      buildBar(controller: TabController(length: 3, vsync: const TestVSync())),
    );
    await tester.pump();

    expect(find.text('T0'), findsOneWidget);
    expect(find.text('T1'), findsOneWidget);
    expect(find.text('T2'), findsOneWidget);
  });

  testWidgets('tapping a tab updates selectedIndex', (tester) async {
    final controller = TabController(length: 3, vsync: const TestVSync());

    await tester.pumpWidget(buildBar(controller: controller));
    await tester.pump();

    await tester.tap(find.text('T2'));
    await tester.pumpAndSettle();

    expect(controller.index, equals(2));
  });

  testWidgets('tapping same tab is a no-op', (tester) async {
    final controller = TabController(length: 3, vsync: const TestVSync());

    await tester.pumpWidget(buildBar(controller: controller));
    await tester.pump();

    await tester.tap(find.text('T0'));
    await tester.pumpAndSettle();

    expect(controller.index, equals(0));
  });

  testWidgets('external controller change updates indicator', (tester) async {
    final controller = TabController(length: 3, vsync: const TestVSync());

    await tester.pumpWidget(buildBar(controller: controller));
    await tester.pump();

    controller.animateTo(2);
    await tester.pumpAndSettle();

    expect(controller.index, equals(2));
  });

  testWidgets('disabled tab cannot be tapped', (tester) async {
    final controller = TabController(length: 3, vsync: const TestVSync());

    await tester.pumpWidget(buildBar(
      controller: controller,
      onTabTappable: (index) => index != 1,
    ));
    await tester.pump();

    await tester.tap(find.text('T1'));
    await tester.pumpAndSettle();

    expect(controller.index, equals(0));
  });

  testWidgets('uses CustomPaint instead of LayoutBuilder', (tester) async {
    await tester.pumpWidget(
      buildBar(controller: TabController(length: 3, vsync: const TestVSync())),
    );
    await tester.pump();

    // SwipeTabBar should use CustomPaint for the indicator, not
    // LayoutBuilder which caused build-scope conflicts.
    expect(find.byType(CustomPaint), findsWidgets);
    // No LayoutBuilder should be a direct descendant of SwipeTabBar.
    expect(
      find.descendant(of: find.byType(SwipeTabBar), matching: find.byType(LayoutBuilder)),
      findsNothing,
    );
  });

  testWidgets('indicator animation completes without error', (tester) async {
    final controller = TabController(length: 4, vsync: const TestVSync());

    await tester.pumpWidget(buildBar(controller: controller, itemCount: 4));
    await tester.pump();

    for (int i = 1; i < 4; i++) {
      controller.animateTo(i);
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pumpAndSettle();

    expect(controller.index, equals(3));
  });

  testWidgets('rapid external changes do not throw', (tester) async {
    final controller = TabController(length: 4, vsync: const TestVSync());

    await tester.pumpWidget(buildBar(controller: controller, itemCount: 4));
    await tester.pump();

    // Rapidly switch through tabs (simulates fast Tab key presses)
    for (int i = 0; i < 10; i++) {
      controller.animateTo((i + 1) % 4);
      await tester.pump(const Duration(milliseconds: 30));
    }
    await tester.pumpAndSettle();

    // Should not throw any assertions
  });
}

// vim: set ts=2 sw=2 sts=2 et:
