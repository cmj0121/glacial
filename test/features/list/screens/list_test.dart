// Widget tests for list screens: ListTimelineTab, LiteTimeline.label.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  group('ListTimelineTab', () {
    // Use domain-less access status so API calls short-circuit (getAPI returns null).
    // This causes getLists() to return an empty list without making real HTTP requests.
    AccessStatusSchema noDomainStatus() {
      return const AccessStatusSchema(
        domain: null,
        accessToken: 'test_token',
      );
    }

    testWidgets('renders with authenticated user', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: ListTimelineTab()),
          accessStatus: noDomainStatus(),
        ));
        await tester.pump();
      });

      expect(find.byType(ListTimelineTab), findsOneWidget);
    });

    testWidgets('shows create list text field with hint', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: ListTimelineTab()),
          accessStatus: noDomainStatus(),
        ));
        await tester.pump();
      });

      expect(find.byType(TextField), findsOneWidget);
      final textField = tester.widget<TextField>(find.byType(TextField));
      final decoration = textField.decoration;
      expect(decoration, isNotNull);
      expect(decoration!.hintText, isNotNull);
    });

    testWidgets('shows playlist_add icon button', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: ListTimelineTab()),
          accessStatus: noDomainStatus(),
        ));
        await tester.pump();
      });

      expect(find.byIcon(Icons.playlist_add), findsOneWidget);
      expect(find.widgetWithIcon(IconButton, Icons.playlist_add), findsOneWidget);
    });

    testWidgets('has Column with Flexible layout structure', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: ListTimelineTab()),
          accessStatus: noDomainStatus(),
        ));
        await tester.pump();
      });

      // ListTimelineTab uses Align > Column > [ListTile, Flexible]
      expect(find.byType(Align), findsWidgets);
      expect(find.byType(Column), findsWidgets);
      expect(find.byType(Flexible), findsWidgets);
    });

    testWidgets('shows NoResult after load when list is empty', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: ListTimelineTab()),
          accessStatus: noDomainStatus(),
        ));
        await tester.pump();
      });

      // After load completes with empty list, NoResult should appear
      expect(find.byType(NoResult), findsOneWidget);
    });
  });

  group('LiteTimeline.label', () {
    testWidgets('renders a ListTile with list title', (tester) async {
      final schema = MockListSchema.create(title: 'My Test List');

      await tester.pumpWidget(createTestWidget(
        child: LiteTimeline.label(schema: schema),
      ));
      await tester.pump();

      expect(find.byType(ListTile), findsOneWidget);
      expect(find.text('My Test List'), findsOneWidget);
    });

    testWidgets('shows reply policy icon', (tester) async {
      final schema = MockListSchema.create(replyPolicy: ReplyPolicyType.list);

      await tester.pumpWidget(createTestWidget(
        child: LiteTimeline.label(schema: schema),
      ));
      await tester.pump();

      expect(find.byIcon(schema.replyPolicy.icon), findsOneWidget);
    });

    testWidgets('shows exclusive icon for exclusive list', (tester) async {
      final schema = MockListSchema.create(exclusive: true);

      await tester.pumpWidget(createTestWidget(
        child: LiteTimeline.label(schema: schema),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.remove_circle_outline), findsOneWidget);
    });

    testWidgets('shows check_circle icon for non-exclusive list', (tester) async {
      final schema = MockListSchema.create(exclusive: false);

      await tester.pumpWidget(createTestWidget(
        child: LiteTimeline.label(schema: schema),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('shows delete button', (tester) async {
      final schema = MockListSchema.create();

      await tester.pumpWidget(createTestWidget(
        child: LiteTimeline.label(schema: schema, onRemove: () {}),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.delete_forever_rounded), findsOneWidget);
    });

    testWidgets('wraps content in InkWellDone', (tester) async {
      final schema = MockListSchema.create();

      await tester.pumpWidget(createTestWidget(
        child: LiteTimeline.label(schema: schema),
      ));
      await tester.pump();

      expect(find.byType(InkWellDone), findsOneWidget);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
