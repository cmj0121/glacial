// Widget tests for SwipeTabView tab cycling and shortcut registration.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/cores/screens/swipe_tab_view.dart';
import 'package:glacial/features/glacial/screens/home.dart';

import '../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  setUp(() {
    GlacialHome.activeTabController = null;
    GlacialHome.activeVisibleIndexes = null;
    GlacialHome.clearTabSwitchStack();
  });

  Widget buildView({
    TabController? controller,
    int itemCount = 3,
    bool Function(int)? onTabTappable,
  }) {
    return createTestWidget(
      child: SizedBox(
        width: 300,
        height: 400,
        child: SwipeTabView(
          tabController: controller,
          itemCount: itemCount,
          tabBuilder: (context, index) => Text('Tab$index'),
          itemBuilder: (context, index) => Center(child: Text('Page$index')),
          onTabTappable: onTabTappable,
        ),
      ),
    );
  }

  group('tab switch stack', () {
    testWidgets('registers onTabSwitch on mount', (tester) async {
      await tester.pumpWidget(buildView());
      await tester.pump();

      expect(GlacialHome.onTabSwitch, isNotNull);
    });

    testWidgets('clears onTabSwitch on dispose', (tester) async {
      await tester.pumpWidget(buildView());
      await tester.pump();
      expect(GlacialHome.onTabSwitch, isNotNull);

      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
      await tester.pump();

      expect(GlacialHome.onTabSwitch, isNull);
    });
  });

  group('onPageChanged guard', () {
    testWidgets('external animateTo does not crash', (tester) async {
      final controller = TabController(length: 3, vsync: const TestVSync());

      await tester.pumpWidget(buildView(controller: controller));
      await tester.pumpAndSettle();

      controller.animateTo(2);
      await tester.pumpAndSettle();

      expect(controller.index, equals(2));
    });

    testWidgets('rapid external controller changes do not throw', (tester) async {
      final controller = TabController(length: 4, vsync: const TestVSync());

      await tester.pumpWidget(buildView(controller: controller, itemCount: 4));
      await tester.pumpAndSettle();

      for (int i = 1; i < 4; i++) {
        controller.animateTo(i);
        await tester.pump(const Duration(milliseconds: 50));
      }
      await tester.pumpAndSettle();

      expect(controller.index, equals(3));
    });
  });

  group('tab rendering', () {
    testWidgets('renders tab labels and page content', (tester) async {
      await tester.pumpWidget(buildView());
      await tester.pump();

      expect(find.text('Tab0'), findsOneWidget);
      expect(find.text('Tab1'), findsOneWidget);
      expect(find.text('Tab2'), findsOneWidget);
      expect(find.text('Page0'), findsOneWidget);
    });

    testWidgets('tapping tab switches page content', (tester) async {
      final controller = TabController(length: 3, vsync: const TestVSync());

      await tester.pumpWidget(buildView(controller: controller));
      await tester.pump();

      await tester.tap(find.text('Tab1'));
      await tester.pumpAndSettle();

      expect(controller.index, equals(1));
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
