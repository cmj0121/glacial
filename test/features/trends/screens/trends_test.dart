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

  group('Trends widget', () {
    test('is a StatefulWidget', () {
      final widget = Trends(
        type: TrendsType.statuses,
        status: const AccessStatusSchema(domain: null, accessToken: 'test'),
      );
      expect(widget, isA<StatefulWidget>());
    });

    test('accepts type and status parameters', () {
      const status = AccessStatusSchema(domain: null, accessToken: 'test');
      final widget = Trends(type: TrendsType.links, status: status);
      expect(widget.type, TrendsType.links);
    });

    testWidgets('renders with no-domain status', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: Trends(
              type: TrendsType.statuses,
              status: const AccessStatusSchema(domain: null, accessToken: 'test'),
            ),
          ),
        ));
        await tester.pump();
      });

      expect(find.byType(Trends), findsOneWidget);
    });

    testWidgets('shows Align at topCenter', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: Trends(
              type: TrendsType.tags,
              status: const AccessStatusSchema(domain: null, accessToken: 'test'),
            ),
          ),
        ));
        await tester.pump();
      });

      expect(find.byType(Align), findsWidgets);
      expect(find.byType(Column), findsWidgets);
    });
  });

  group('TrendsTab empty domain', () {
    testWidgets('shows SizedBox.shrink with empty domain', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: TrendsTab()),
          accessStatus: const AccessStatusSchema(domain: '', accessToken: 'test'),
        ));
        await tester.pump();
      });

      // Empty domain shows SizedBox.shrink
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('users tab is disabled when not signed in', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: TrendsTab()),
          accessStatus: const AccessStatusSchema(domain: 'example.com', accessToken: null),
        ));
        await tester.pump();
      });

      // The users tab icon should be rendered with disabled color
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });
  });

  group('Trends loading states', () {
    testWidgets('shows NoResult when load completes with empty data', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: Trends(
              type: TrendsType.tags,
              status: const AccessStatusSchema(domain: null, accessToken: 'test'),
            ),
          ),
        ));
        await tester.pump();
        // Allow onLoad to fail (null domain) → empty trends
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await tester.pump();
      });

      expect(find.byType(NoResult), findsOneWidget);
    });

    testWidgets('renders for each TrendsType', (tester) async {
      for (final type in TrendsType.values) {
        await tester.runAsync(() async {
          await tester.pumpWidget(createTestWidgetRaw(
            child: Scaffold(
              body: Trends(
                type: type,
                status: const AccessStatusSchema(domain: null, accessToken: 'test'),
              ),
            ),
          ));
          await tester.pump();
        });

        expect(find.byType(Trends), findsOneWidget);
      }
    });
  });

  group('SuggestionSourceType', () {
    test('fromString parses staff', () {
      expect(SuggestionSourceType.fromString('staff'), SuggestionSourceType.staff);
    });

    test('fromString parses past_interactions', () {
      expect(SuggestionSourceType.fromString('past_interactions'), SuggestionSourceType.pastInteractions);
    });

    test('fromString parses global', () {
      expect(SuggestionSourceType.fromString('global'), SuggestionSourceType.global);
    });

    test('fromString throws on unknown', () {
      expect(() => SuggestionSourceType.fromString('xyz'), throwsArgumentError);
    });
  });

  group('SuggestionSchema', () {
    test('fromJson parses all fields', () {
      final json = {
        'source': 'staff',
        'sources': ['staff', 'global'],
        'account': {
          'id': '1',
          'username': 'test',
          'acct': 'test',
          'display_name': 'Test',
          'url': 'https://example.com/@test',
          'note': '',
          'avatar': '',
          'avatar_static': '',
          'header': '',
          'header_static': '',
          'locked': false,
          'bot': false,
          'indexable': false,
          'created_at': '2024-01-01T00:00:00.000Z',
          'followers_count': 0,
          'following_count': 0,
          'statuses_count': 0,
          'emojis': <dynamic>[],
          'fields': <dynamic>[],
        },
      };
      final suggestion = SuggestionSchema.fromJson(json);
      expect(suggestion.source, SuggestionSourceType.staff);
      expect(suggestion.sources, ['staff', 'global']);
      expect(suggestion.account.username, 'test');
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
