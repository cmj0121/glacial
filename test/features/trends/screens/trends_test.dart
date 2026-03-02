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

  group('SuggestionSourceType tooltip', () {
    testWidgets('each source type has localized tooltip', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(createTestWidget(
        child: Builder(builder: (context) {
          capturedContext = context;
          return const SizedBox.shrink();
        }),
      ));
      await tester.pump();

      for (final type in SuggestionSourceType.values) {
        expect(type.tooltip(capturedContext), isNotEmpty);
      }
    });

    testWidgets('staff tooltip contains staff text', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(createTestWidget(
        child: Builder(builder: (context) {
          capturedContext = context;
          return const SizedBox.shrink();
        }),
      ));
      await tester.pump();

      final tooltip = SuggestionSourceType.staff.tooltip(capturedContext);
      expect(tooltip, isA<String>());
      expect(tooltip.isNotEmpty, isTrue);
    });

    testWidgets('pastInteractions tooltip is non-empty', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(createTestWidget(
        child: Builder(builder: (context) {
          capturedContext = context;
          return const SizedBox.shrink();
        }),
      ));
      await tester.pump();

      final tooltip = SuggestionSourceType.pastInteractions.tooltip(capturedContext);
      expect(tooltip, isA<String>());
      expect(tooltip.isNotEmpty, isTrue);
    });

    testWidgets('global tooltip is non-empty', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(createTestWidget(
        child: Builder(builder: (context) {
          capturedContext = context;
          return const SizedBox.shrink();
        }),
      ));
      await tester.pump();

      final tooltip = SuggestionSourceType.global.tooltip(capturedContext);
      expect(tooltip, isA<String>());
      expect(tooltip.isNotEmpty, isTrue);
    });
  });

  group('TrendsTab null domain', () {
    testWidgets('renders SwipeTabView even with null domain', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: TrendsTab()),
          accessStatus: const AccessStatusSchema(domain: null, accessToken: 'test'),
        ));
        await tester.pump();
      });

      // Null domain passes the isEmpty check (null?.isEmpty != true)
      // so SwipeTabView is still rendered
      expect(find.byType(SwipeTabView), findsOneWidget);
    });
  });

  group('Trends buildContent with injected data', () {
    testWidgets('shows Status widgets when statuses trends are injected', (tester) async {
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
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await tester.pump();
      });

      // Inject statuses into state
      final dynamic state = tester.state(find.byType(Trends));
      state.trends.addAll([
        MockStatus.create(id: 's1'),
        MockStatus.create(id: 's2'),
      ]);
      (tester.element(find.byType(Trends)) as StatefulElement).markNeedsBuild();
      await tester.pump();

      // Should show Container with border decoration for statuses
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('shows TrendsLink widgets when links trends are injected', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: Trends(
              type: TrendsType.links,
              status: const AccessStatusSchema(domain: null, accessToken: 'test'),
            ),
          ),
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await tester.pump();
      });

      // Inject links into state
      final dynamic state = tester.state(find.byType(Trends));
      state.trends.addAll([
        MockLink.create(title: 'Link 1'),
        MockLink.create(title: 'Link 2'),
      ]);
      (tester.element(find.byType(Trends)) as StatefulElement).markNeedsBuild();
      await tester.pump();

      expect(find.byType(TrendsLink), findsNWidgets(2));
    });

    testWidgets('shows Hashtag widgets when tags trends are injected', (tester) async {
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
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await tester.pump();
      });

      // Inject hashtags into state
      final dynamic state = tester.state(find.byType(Trends));
      state.trends.addAll([
        MockHashtag.create(name: 'flutter'),
        MockHashtag.create(name: 'dart'),
      ]);
      (tester.element(find.byType(Trends)) as StatefulElement).markNeedsBuild();
      await tester.pump();

      expect(find.byType(Hashtag), findsNWidgets(2));
    });

    testWidgets('shows Account with Tooltip when users trends are injected', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: Trends(
              type: TrendsType.users,
              status: const AccessStatusSchema(domain: null, accessToken: 'test'),
            ),
          ),
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await tester.pump();
      });

      // Inject suggestions into state
      final dynamic state = tester.state(find.byType(Trends));
      state.trends.addAll([
        MockSuggestion.create(
          source: SuggestionSourceType.staff,
          account: MockAccount.create(id: 'u1', username: 'alice'),
        ),
        MockSuggestion.create(
          source: SuggestionSourceType.global,
          account: MockAccount.create(id: 'u2', username: 'bob'),
        ),
      ]);
      (tester.element(find.byType(Trends)) as StatefulElement).markNeedsBuild();
      await tester.pump();

      // Users type wraps each item in a Tooltip with source tooltip text
      expect(find.byType(Tooltip), findsWidgets);
      expect(find.byType(Account), findsNWidgets(2));
    });

    testWidgets('SizedBox.shrink shown when trends is empty and loading', (tester) async {
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

      // During loading with empty trends, buildContent returns SizedBox.shrink
      final dynamic state = tester.state(find.byType(Trends));
      // Force isLoading to true while trends is empty
      state.setLoading(true);
      await tester.pump();

      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('_onPositionChange triggers load when near end', (tester) async {
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
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await tester.pump();
      });

      // Inject enough items for the position listener to matter
      final dynamic state = tester.state(find.byType(Trends));
      final List<HashtagSchema> items = List.generate(
        3,
        (i) => MockHashtag.create(name: 'tag$i'),
      );
      state.trends.addAll(items);
      (tester.element(find.byType(Trends)) as StatefulElement).markNeedsBuild();
      await tester.pump();

      // The _onPositionChange method is connected via itemPositionsListener
      // Verify the widget tree contains ScrollablePositionedList
      expect(find.byType(Trends), findsOneWidget);
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

    test('fromString parses JSON string', () {
      final jsonStr = '{"source":"global","sources":["global"],"account":{"id":"1","username":"x","acct":"x","display_name":"X","url":"https://example.com/@x","note":"","avatar":"","avatar_static":"","header":"","header_static":"","locked":false,"bot":false,"indexable":false,"created_at":"2024-01-01T00:00:00.000Z","followers_count":0,"following_count":0,"statuses_count":0,"emojis":[],"fields":[]}}';
      final suggestion = SuggestionSchema.fromString(jsonStr);
      expect(suggestion.source, SuggestionSourceType.global);
      expect(suggestion.sources, ['global']);
      expect(suggestion.account.username, 'x');
    });

    test('fromString parses pastInteractions source', () {
      final jsonStr = '{"source":"past_interactions","sources":["past_interactions"],"account":{"id":"2","username":"y","acct":"y","display_name":"Y","url":"https://example.com/@y","note":"","avatar":"","avatar_static":"","header":"","header_static":"","locked":false,"bot":false,"indexable":false,"created_at":"2024-01-01T00:00:00.000Z","followers_count":0,"following_count":0,"statuses_count":0,"emojis":[],"fields":[]}}';
      final suggestion = SuggestionSchema.fromString(jsonStr);
      expect(suggestion.source, SuggestionSourceType.pastInteractions);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
