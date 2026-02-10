// Widget tests for StatusHistory and StatusEdit components.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  group('StatusHistory', () {
    testWidgets('renders with schema', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );
      final schema = MockStatus.create();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: StatusHistory(schema: schema)),
          accessStatus: status,
        ));
        await tester.pump();
      });

      expect(find.byType(StatusHistory), findsOneWidget);
    });

    testWidgets('shows empty content initially', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );
      final schema = MockStatus.create();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: StatusHistory(schema: schema)),
          accessStatus: status,
        ));
        await tester.pump();
      });

      // History is empty before load completes, so buildContent returns SizedBox.shrink
      expect(find.byType(SizedBox), findsWidgets);
      // No PageView should be present when history is empty
      expect(find.byType(PageView), findsNothing);
    });
  });

  group('StatusEdit', () {
    testWidgets('renders with schema', (tester) async {
      final schema = MockStatusEdit.create();

      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: SizedBox(
            height: 600,
            child: StatusEdit(schema: schema),
          ),
        ),
      ));
      await tester.pump();

      expect(find.byType(StatusEdit), findsOneWidget);
    });

    testWidgets('shows account info', (tester) async {
      final account = MockAccount.create(displayName: 'Edit Author');
      final schema = MockStatusEdit.create(account: account);

      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: SizedBox(
            height: 600,
            child: StatusEdit(schema: schema),
          ),
        ),
      ));
      await tester.pump();

      expect(find.byType(Account), findsOneWidget);
    });

    testWidgets('shows date', (tester) async {
      final date = DateTime(2023, 6, 15, 14, 30);
      final schema = MockStatusEdit.create(createdAt: date);

      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: SizedBox(
            height: 600,
            child: StatusEdit(schema: schema),
          ),
        ),
      ));
      await tester.pump();

      // The date is displayed as a local string
      expect(find.textContaining('2023'), findsOneWidget);
    });

    testWidgets('shows content via HtmlDone', (tester) async {
      final schema = MockStatusEdit.create(content: '<p>Edited content.</p>');

      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: SizedBox(
            height: 600,
            child: StatusEdit(schema: schema),
          ),
        ),
      ));
      await tester.pump();

      expect(find.byType(HtmlDone), findsOneWidget);
    });

    testWidgets('shows divider', (tester) async {
      final schema = MockStatusEdit.create();

      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          body: SizedBox(
            height: 600,
            child: StatusEdit(schema: schema),
          ),
        ),
      ));
      await tester.pump();

      expect(find.byType(Divider), findsOneWidget);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
