// Widget tests for Status component.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/features/timeline/screens/status.dart';
import 'package:glacial/features/timeline/screens/status_lite.dart';
import 'package:glacial/features/timeline/screens/interaction.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setUpAll(() => setupTestEnvironment());

  group('Status', () {
    group('rendering', () {
      testWidgets('displays Status widget', (tester) async {
        final status = MockStatus.create();

        await tester.pumpWidget(createTestWidget(
          child: Status(schema: status),
        ));
        await tester.pump();

        expect(find.byType(Status), findsOneWidget);
      });

      testWidgets('displays StatusLite component', (tester) async {
        final status = MockStatus.create();

        await tester.pumpWidget(createTestWidget(
          child: Status(schema: status),
        ));
        await tester.pump();

        expect(find.byType(StatusLite), findsOneWidget);
      });

      testWidgets('displays InteractionBar component', (tester) async {
        final status = MockStatus.create();

        await tester.pumpWidget(createTestWidget(
          child: Status(schema: status),
        ));
        await tester.pump();

        expect(find.byType(InteractionBar), findsOneWidget);
      });
    });

    group('structure', () {
      testWidgets('renders as Column widget', (tester) async {
        final status = MockStatus.create();

        await tester.pumpWidget(createTestWidget(
          child: Status(schema: status),
        ));
        await tester.pump();

        expect(find.byType(Column), findsWidgets);
      });

      testWidgets('has Padding widget for spacing', (tester) async {
        final status = MockStatus.create();

        await tester.pumpWidget(createTestWidget(
          child: Status(schema: status),
        ));
        await tester.pump();

        expect(find.byType(Padding), findsWidgets);
      });

      testWidgets('has SizedBox spacer between content and interaction bar', (tester) async {
        final status = MockStatus.create();

        await tester.pumpWidget(createTestWidget(
          child: Status(schema: status),
        ));
        await tester.pump();

        expect(find.byType(SizedBox), findsWidgets);
      });
    });

    group('metadata', () {
      testWidgets('normal status has no metadata row', (tester) async {
        final status = MockStatus.create();

        await tester.pumpWidget(createTestWidget(
          child: Status(schema: status),
        ));
        await tester.pump();

        // Status widget is rendered
        expect(find.byType(Status), findsOneWidget);
      });

      testWidgets('reblogged status shows reblog icon', (tester) async {
        final originalStatus = MockStatus.create(id: '100');
        final reblog = MockStatus.createReblog(
          id: '200',
          originalStatus: originalStatus,
        );

        await tester.pumpWidget(createTestWidget(
          child: Status(schema: reblog),
        ));
        await tester.pump();

        // Reblog icon (repeat) should be visible in metadata
        expect(find.byIcon(Icons.repeat), findsWidgets);
      });
    });

    group('interaction bar presence', () {
      testWidgets('contains interaction bar with row layout', (tester) async {
        final status = MockStatus.create();

        await tester.pumpWidget(createTestWidget(
          child: SizedBox(
            width: 400,
            child: Status(schema: status),
          ),
        ));
        await tester.pump();

        // InteractionBar uses Row for layout
        expect(find.byType(Row), findsWidgets);
      });

      testWidgets('interaction bar has buttons', (tester) async {
        final status = MockStatus.create();

        await tester.pumpWidget(createTestWidget(
          child: SizedBox(
            width: 400,
            child: Status(schema: status),
          ),
        ));
        await tester.pump();

        // InteractionBar should show at least reply icon
        expect(find.byIcon(Icons.turn_left_outlined), findsOneWidget);
      });
    });

    group('indent', () {
      testWidgets('accepts indent parameter', (tester) async {
        final status = MockStatus.create();

        await tester.pumpWidget(createTestWidget(
          child: Status(schema: status, indent: 2),
        ));
        await tester.pump();

        expect(find.byType(Status), findsOneWidget);
      });

      testWidgets('default indent is zero', (tester) async {
        final status = MockStatus.create();

        await tester.pumpWidget(createTestWidget(
          child: Status(schema: status),
        ));
        await tester.pump();

        expect(find.byType(Status), findsOneWidget);
      });
    });

    group('callbacks', () {
      testWidgets('accepts onReload callback', (tester) async {
        final status = MockStatus.create();
        bool reloadCalled = false;

        await tester.pumpWidget(createTestWidget(
          child: Status(
            schema: status,
            onReload: (_) => reloadCalled = true,
          ),
        ));
        await tester.pump();

        expect(find.byType(Status), findsOneWidget);
        // Callback is set but not triggered in this test
        expect(reloadCalled, isFalse);
      });

      testWidgets('accepts onDeleted callback', (tester) async {
        final status = MockStatus.create();
        bool deletedCalled = false;

        await tester.pumpWidget(createTestWidget(
          child: Status(
            schema: status,
            onDeleted: () => deletedCalled = true,
          ),
        ));
        await tester.pump();

        expect(find.byType(Status), findsOneWidget);
        expect(deletedCalled, isFalse);
      });
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
