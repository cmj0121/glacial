// Widget tests for trends screens: TrendsTab, TrendsType, ExplorerResultType.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  group('TrendsTab', () {
    testWidgets('renders SwipeTabView with authenticated user', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: TrendsTab()),
          accessStatus: status,
        ));
        await tester.pump();
      });

      expect(find.byType(SwipeTabView), findsOneWidget);
    });

    testWidgets('shows tab icons for trends types', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: TrendsTab()),
          accessStatus: status,
        ));
        await tester.pump();
      });

      // Active tab (statuses) shows filled chat bubble
      expect(find.byIcon(Icons.chat_bubble), findsOneWidget);
      // Other tabs show outlined icons
      expect(find.byIcon(Icons.label_outline), findsOneWidget);
      expect(find.byIcon(Icons.whatshot_outlined), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('has tooltips on tab icons', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: TrendsTab()),
          accessStatus: status,
        ));
        await tester.pump();
      });

      expect(find.byType(Tooltip), findsWidgets);
    });
  });

  group('TrendsType', () {
    test('has 4 values', () {
      expect(TrendsType.values.length, 4);
    });

    test('statuses icon returns chat_bubble icons', () {
      expect(TrendsType.statuses.icon(), Icons.chat_bubble_outline);
      expect(TrendsType.statuses.icon(active: true), Icons.chat_bubble);
    });

    test('tags icon returns label icons', () {
      expect(TrendsType.tags.icon(), Icons.label_outline);
      expect(TrendsType.tags.icon(active: true), Icons.label);
    });

    test('links icon returns whatshot icons', () {
      expect(TrendsType.links.icon(), Icons.whatshot_outlined);
      expect(TrendsType.links.icon(active: true), Icons.whatshot);
    });

    test('users icon returns person icons', () {
      expect(TrendsType.users.icon(), Icons.person_outline);
      expect(TrendsType.users.icon(active: true), Icons.person);
    });

    testWidgets('all types have localized tooltips', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(createTestWidget(
        child: Builder(builder: (context) {
          capturedContext = context;
          return const SizedBox.shrink();
        }),
      ));
      await tester.pump();

      for (final type in TrendsType.values) {
        expect(type.tooltip(capturedContext), isNotEmpty);
      }
    });
  });

  group('ExplorerResultType', () {
    test('has 3 values', () {
      expect(ExplorerResultType.values.length, 3);
    });

    test('account icon returns contact_page icons', () {
      expect(ExplorerResultType.account.icon(), Icons.contact_page_outlined);
      expect(ExplorerResultType.account.icon(active: true), Icons.contact_page);
    });

    test('status icon returns message icons', () {
      expect(ExplorerResultType.status.icon(), Icons.message_outlined);
      expect(ExplorerResultType.status.icon(active: true), Icons.message);
    });

    test('hashtag icon returns tag icons', () {
      expect(ExplorerResultType.hashtag.icon(), Icons.tag_outlined);
      expect(ExplorerResultType.hashtag.icon(active: true), Icons.tag);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
