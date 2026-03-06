// Widget tests for SwipeTabView and SwipeTabBar.
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/cores/screens/view.dart';

import '../../helpers/test_helpers.dart';

void main() {
  setUpAll(() => setupTestEnvironment());

  group('SwipeTabView', () {
    testWidgets('renders tabs and content', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: SizedBox(
          height: 400,
          child: SwipeTabView(
            itemCount: 3,
            tabBuilder: (context, index) => Text('Tab $index'),
            itemBuilder: (context, index) => Text('Content $index'),
          ),
        ),
      ));
      await tester.pump();

      expect(find.text('Tab 0'), findsOneWidget);
      expect(find.text('Tab 1'), findsOneWidget);
      expect(find.text('Tab 2'), findsOneWidget);
      expect(find.text('Content 0'), findsOneWidget);
    });

    testWidgets('clicking tab switches page content', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: SizedBox(
          height: 400,
          child: SwipeTabView(
            itemCount: 3,
            tabBuilder: (context, index) => Text('Tab $index'),
            itemBuilder: (context, index) => Center(child: Text('Page $index')),
          ),
        ),
      ));
      await tester.pump();

      // Initially shows page 0
      expect(find.text('Page 0'), findsOneWidget);

      // Tap on tab 1
      await tester.tap(find.text('Tab 1'));
      await tester.pumpAndSettle();

      expect(find.text('Page 1'), findsOneWidget);
    });

    testWidgets('does not pass onDoubleTap to SwipeTabBar when null', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: SizedBox(
          height: 400,
          child: SwipeTabView(
            itemCount: 2,
            tabBuilder: (context, index) => Text('Tab $index'),
            itemBuilder: (context, index) => Text('Content $index'),
            // onDoubleTap is NOT set (null)
          ),
        ),
      ));
      await tester.pump();

      // Verify SwipeTabBar is rendered
      expect(find.byType(SwipeTabBar), findsOneWidget);

      // When onDoubleTap is null, InkWell should NOT have onDoubleTap set.
      // This prevents the 300ms tap delay on desktop.
      final inkWells = tester.widgetList<InkWell>(find.byType(InkWell));
      for (final inkWell in inkWells) {
        expect(inkWell.onDoubleTap, isNull,
            reason: 'InkWell should not have onDoubleTap when SwipeTabView.onDoubleTap is null');
      }
    });

    testWidgets('passes onDoubleTap to SwipeTabBar when provided', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: SizedBox(
          height: 400,
          child: SwipeTabView(
            itemCount: 2,
            tabBuilder: (context, index) => Text('Tab $index'),
            itemBuilder: (context, index) => Text('Content $index'),
            onDoubleTap: (index) {},
          ),
        ),
      ));
      await tester.pump();

      // When onDoubleTap is provided, InkWell SHOULD have onDoubleTap set.
      final inkWells = tester.widgetList<InkWell>(find.byType(InkWell));
      final hasDoubleTap = inkWells.any((inkWell) => inkWell.onDoubleTap != null);
      expect(hasDoubleTap, isTrue,
          reason: 'At least one InkWell should have onDoubleTap when SwipeTabView.onDoubleTap is set');
    });

    testWidgets('PageView allows mouse drag via ScrollConfiguration', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: SizedBox(
          height: 400,
          child: SwipeTabView(
            itemCount: 3,
            tabBuilder: (context, index) => Text('Tab $index'),
            itemBuilder: (context, index) => Center(child: Text('Page $index')),
          ),
        ),
      ));
      await tester.pump();

      // Find the ScrollConfiguration wrapping the PageView
      final scrollConfig = tester.widget<ScrollConfiguration>(
        find.descendant(
          of: find.byType(SwipeTabView),
          matching: find.byType(ScrollConfiguration),
        ).first,
      );

      // Verify mouse is included in dragDevices
      final behavior = scrollConfig.behavior;
      final dragDevices = behavior.dragDevices;
      expect(dragDevices, contains(PointerDeviceKind.mouse),
          reason: 'ScrollConfiguration should allow mouse drag for desktop support');
      expect(dragDevices, contains(PointerDeviceKind.touch));
      expect(dragDevices, contains(PointerDeviceKind.stylus));
      expect(dragDevices, contains(PointerDeviceKind.trackpad));
    });

    testWidgets('skips non-tappable tabs in page view', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: SizedBox(
          height: 400,
          child: SwipeTabView(
            itemCount: 3,
            tabBuilder: (context, index) => Text('Tab $index'),
            itemBuilder: (context, index) => Center(child: Text('Page $index')),
            onTabTappable: (index) => index != 1, // Tab 1 is disabled
          ),
        ),
      ));
      await tester.pump();

      // Should show page 0 initially
      expect(find.text('Page 0'), findsOneWidget);

      // Tab 2 should be tappable and skip to page 2
      await tester.tap(find.text('Tab 2'));
      await tester.pumpAndSettle();

      expect(find.text('Page 2'), findsOneWidget);
    });
  });

  group('SwipeTabBar', () {
    testWidgets('renders all tab items', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: SwipeTabBar(
          itemCount: 4,
          tabBuilder: (context, index) => Text('Item $index'),
        ),
      ));
      await tester.pump();

      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);
    });

    testWidgets('tab tap triggers controller animateTo', (tester) async {
      late TabController tabController;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return _TabControllerWidget(
                  length: 3,
                  builder: (controller) {
                    tabController = controller;
                    return SwipeTabBar(
                      controller: controller,
                      itemCount: 3,
                      tabBuilder: (context, index) => Text('Tab $index'),
                    );
                  },
                );
              },
            ),
          ),
        ),
      );
      await tester.pump();

      expect(tabController.index, 0);

      // Tap tab 2
      await tester.tap(find.text('Tab 2'));
      await tester.pumpAndSettle();

      expect(tabController.index, 2);
    });

    testWidgets('non-tappable tab does not respond to tap', (tester) async {
      late TabController tabController;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _TabControllerWidget(
              length: 3,
              builder: (controller) {
                tabController = controller;
                return SwipeTabBar(
                  controller: controller,
                  itemCount: 3,
                  tabBuilder: (context, index) => Text('Tab $index'),
                  onTabTappable: (index) => index != 1, // Tab 1 disabled
                );
              },
            ),
          ),
        ),
      );
      await tester.pump();

      // Tap disabled tab 1
      await tester.tap(find.text('Tab 1'));
      await tester.pumpAndSettle();

      // Should remain at tab 0
      expect(tabController.index, 0);
    });

    testWidgets('does not set InkWell onDoubleTap when null', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: SwipeTabBar(
          itemCount: 2,
          tabBuilder: (context, index) => Text('Tab $index'),
          onDoubleTap: null,
        ),
      ));
      await tester.pump();

      final inkWells = tester.widgetList<InkWell>(find.byType(InkWell));
      for (final inkWell in inkWells) {
        expect(inkWell.onDoubleTap, isNull,
            reason: 'InkWell should not have onDoubleTap when SwipeTabBar.onDoubleTap is null');
      }
    });
  });
}

/// Helper widget that provides a TabController via TickerProviderStateMixin.
class _TabControllerWidget extends StatefulWidget {
  final int length;
  final Widget Function(TabController controller) builder;

  const _TabControllerWidget({
    required this.length,
    required this.builder,
  });

  @override
  State<_TabControllerWidget> createState() => _TabControllerWidgetState();
}

class _TabControllerWidgetState extends State<_TabControllerWidget> with TickerProviderStateMixin {
  late final TabController controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: widget.length, vsync: this);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(controller);
}

// vim: set ts=2 sw=2 sts=2 et:
