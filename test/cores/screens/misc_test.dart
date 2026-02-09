// Widget tests for miscellaneous screen components.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/cores/screens/misc.dart';

import '../../helpers/test_helpers.dart';

void main() {
  setUpAll(() => setupTestEnvironment());

  group('WIP', () {
    // WIP uses its own Scaffold, so use minimal MaterialApp wrapper
    Widget wrapWithMaterialApp(Widget child) {
      return MaterialApp(home: child);
    }

    testWidgets('displays default title', (tester) async {
      await tester.pumpWidget(wrapWithMaterialApp(const WIP()));
      await tester.pumpAndSettle();

      expect(find.text('Work in Progress'), findsOneWidget);
    });

    testWidgets('displays custom title when provided', (tester) async {
      await tester.pumpWidget(wrapWithMaterialApp(const WIP(title: 'Custom Title')));
      await tester.pumpAndSettle();

      expect(find.text('Custom Title'), findsOneWidget);
    });

    testWidgets('wraps in Scaffold', (tester) async {
      await tester.pumpWidget(wrapWithMaterialApp(const WIP()));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('uses SafeArea', (tester) async {
      await tester.pumpWidget(wrapWithMaterialApp(const WIP()));
      await tester.pumpAndSettle();

      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('centers content', (tester) async {
      await tester.pumpWidget(wrapWithMaterialApp(const WIP()));
      await tester.pumpAndSettle();

      expect(find.byType(Center), findsOneWidget);
    });

    testWidgets('uses Text widget for title', (tester) async {
      await tester.pumpWidget(wrapWithMaterialApp(const WIP()));
      await tester.pumpAndSettle();

      expect(find.byType(Text), findsOneWidget);
    });
  });

  group('InkWellDone', () {
    testWidgets('displays child widget', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const InkWellDone(
          child: Text('Test Child'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Test Child'), findsOneWidget);
    });

    testWidgets('triggers onTap callback when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(createTestWidget(
        child: InkWellDone(
          onTap: () => tapped = true,
          child: const Text('Tap Me'),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tap Me'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('triggers onDoubleTap callback when double tapped', (tester) async {
      bool doubleTapped = false;

      await tester.pumpWidget(createTestWidget(
        child: InkWellDone(
          onDoubleTap: () => doubleTapped = true,
          child: const Text('Double Tap Me'),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Double Tap Me'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('Double Tap Me'));
      await tester.pumpAndSettle();

      expect(doubleTapped, isTrue);
    });

    testWidgets('triggers onLongPress callback when long pressed', (tester) async {
      bool longPressed = false;

      await tester.pumpWidget(createTestWidget(
        child: InkWellDone(
          onLongPress: () => longPressed = true,
          child: const Text('Long Press Me'),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.longPress(find.text('Long Press Me'));
      await tester.pump();

      expect(longPressed, isTrue);
    });

    testWidgets('wraps child in InkWell', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const InkWellDone(
          child: Text('Child'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(InkWell), findsOneWidget);
    });

    testWidgets('uses transparent splash color', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const InkWellDone(
          child: Text('Child'),
        ),
      ));
      await tester.pumpAndSettle();

      final inkWell = tester.widget<InkWell>(find.byType(InkWell));
      expect(inkWell.splashColor, Colors.transparent);
    });

    testWidgets('uses transparent highlight color', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const InkWellDone(
          child: Text('Child'),
        ),
      ));
      await tester.pumpAndSettle();

      final inkWell = tester.widget<InkWell>(find.byType(InkWell));
      expect(inkWell.highlightColor, Colors.transparent);
    });

    testWidgets('uses transparent hover color', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const InkWellDone(
          child: Text('Child'),
        ),
      ));
      await tester.pumpAndSettle();

      final inkWell = tester.widget<InkWell>(find.byType(InkWell));
      expect(inkWell.hoverColor, Colors.transparent);
    });
  });

  group('NoResult', () {
    testWidgets('displays default icon', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const NoResult(),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.sentiment_dissatisfied_outlined), findsOneWidget);
    });

    testWidgets('displays custom icon when provided', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const NoResult(icon: Icons.search_off),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search_off), findsOneWidget);
    });

    testWidgets('displays message text', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const NoResult(message: 'No results found'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('No results found'), findsOneWidget);
    });

    testWidgets('displays empty message by default', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const NoResult(),
      ));
      await tester.pumpAndSettle();

      expect(find.text(''), findsOneWidget);
    });

    testWidgets('uses default icon size', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const NoResult(),
      ));
      await tester.pumpAndSettle();

      final icon = tester.widget<Icon>(
        find.byIcon(Icons.sentiment_dissatisfied_outlined),
      );
      expect(icon.size, 64);
    });

    testWidgets('uses custom icon size when provided', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const NoResult(size: 100),
      ));
      await tester.pumpAndSettle();

      final icon = tester.widget<Icon>(
        find.byIcon(Icons.sentiment_dissatisfied_outlined),
      );
      expect(icon.size, 100);
    });

    testWidgets('centers content', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const NoResult(),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(Center), findsWidgets);
    });

    testWidgets('uses padding around content', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const NoResult(),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(Padding), findsWidgets);
    });

    testWidgets('uses Column layout', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const NoResult(),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(Column), findsOneWidget);
    });

    testWidgets('includes SizedBox for spacing', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const NoResult(),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(SizedBox), findsWidgets);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
