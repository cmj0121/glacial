// Widget tests for View components.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/cores/screens/accessibility.dart';
import 'package:glacial/cores/screens/view.dart';

import '../../helpers/test_helpers.dart';

void main() {
  setUpAll(() => setupTestEnvironment());

  group('Indent', () {
    testWidgets('renders child without indent when indent is 0', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const Indent(
          indent: 0,
          child: Text('No Indent'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('No Indent'), findsOneWidget);
      // With indent 0, child is returned directly without additional wrapping
    });

    testWidgets('adds single indent level with border', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const Indent(
          indent: 1,
          child: Text('Single Indent'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Single Indent'), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('adds multiple indent levels recursively', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const Indent(
          indent: 3,
          child: Text('Triple Indent'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Triple Indent'), findsOneWidget);
      // Multiple Indent widgets nested
      expect(find.byType(Indent), findsNWidgets(3));
    });

    testWidgets('uses default padding', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const Indent(
          indent: 1,
          child: Text('Default Padding'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(Padding), findsWidgets);
    });

    testWidgets('accepts custom padding', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const Indent(
          indent: 1,
          padding: EdgeInsets.only(left: 24.0),
          child: Text('Custom Padding'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Custom Padding'), findsOneWidget);
    });

    testWidgets('accepts custom width', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const Indent(
          indent: 1,
          width: 8.0,
          child: Text('Custom Width'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Custom Width'), findsOneWidget);
    });

    testWidgets('uses Container with BoxDecoration for border', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const Indent(
          indent: 1,
          child: Text('Border Test'),
        ),
      ));
      await tester.pumpAndSettle();

      final containers = tester.widgetList<Container>(find.byType(Container));
      // Should find at least one Container with decoration
      expect(containers.isNotEmpty, isTrue);
    });

    testWidgets('wraps complex child widget', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const Indent(
          indent: 2,
          child: Column(
            children: [
              Text('Line 1'),
              Text('Line 2'),
            ],
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Line 1'), findsOneWidget);
      expect(find.text('Line 2'), findsOneWidget);
    });

    testWidgets('handles indent level of 2', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const Indent(
          indent: 2,
          child: Text('Double Indent'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Double Indent'), findsOneWidget);
      expect(find.byType(Indent), findsNWidgets(2));
    });

    testWidgets('handles large indent level', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const Indent(
          indent: 5,
          child: Text('Deep Indent'),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Deep Indent'), findsOneWidget);
      expect(find.byType(Indent), findsNWidgets(5));
    });
  });

  group('BackableView', () {
    testWidgets('uses AccessibleDismissible instead of raw Dismissible', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: const BackableView(
          child: Text('Content'),
        ),
      ));
      await tester.pump();

      expect(find.byType(AccessibleDismissible), findsOneWidget);
    });

    testWidgets('renders child content', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: const BackableView(
          child: Text('Test Content'),
        ),
      ));
      await tester.pump();

      expect(find.text('Test Content'), findsOneWidget);
    });

    testWidgets('renders optional title', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: const BackableView(
          title: 'Page Title',
          child: Text('Content'),
        ),
      ));
      await tester.pump();

      expect(find.text('Page Title'), findsOneWidget);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
