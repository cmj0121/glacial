// Widget tests for Timeline and TimelineTab components.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  group('TimelineTab', () {
    testWidgets('renders SwipeTabView with authenticated user', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: TimelineTab()),
          accessStatus: status,
        ));
        await tester.pump();
      });

      expect(find.byType(SwipeTabView), findsOneWidget);
    });

    testWidgets('returns empty when status is null', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(ProviderScope(
          overrides: [
            accessStatusProvider.overrideWith((ref) => null),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: const Scaffold(body: TimelineTab()),
          ),
        ));
        await tester.pump();
      });

      expect(find.byType(SwipeTabView), findsNothing);
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('shows tab icons for timeline types', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: TimelineTab()),
          accessStatus: status,
        ));
        await tester.pump();
      });

      // The default initialType is local, so local should be active
      expect(find.byIcon(Icons.groups), findsOneWidget);
      // Other tabs should show outlined icons
      expect(find.byIcon(Icons.home_outlined), findsOneWidget);
      expect(find.byIcon(Icons.account_tree_outlined), findsOneWidget);
      expect(find.byIcon(Icons.public_outlined), findsOneWidget);
      expect(find.byIcon(Icons.star_outline_outlined), findsOneWidget);
      expect(find.byIcon(Icons.bookmarks_outlined), findsOneWidget);
    });

    testWidgets('has tooltips on tab icons', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: TimelineTab()),
          accessStatus: status,
        ));
        await tester.pump();
      });

      expect(find.byType(Tooltip), findsWidgets);
    });
  });

  group('TimelineType', () {
    test('has expected number of tab types', () {
      final tabTypes = TimelineType.values.where((type) => type.inTimelineTab).toList();
      expect(tabTypes.length, 6);
    });

    test('tab types are home, local, federal, public, favourites, bookmarks', () {
      final tabTypes = TimelineType.values.where((type) => type.inTimelineTab).toList();
      expect(tabTypes, contains(TimelineType.home));
      expect(tabTypes, contains(TimelineType.local));
      expect(tabTypes, contains(TimelineType.federal));
      expect(tabTypes, contains(TimelineType.public));
      expect(tabTypes, contains(TimelineType.favourites));
      expect(tabTypes, contains(TimelineType.bookmarks));
    });

    test('each type has icon() method', () {
      for (final type in TimelineType.values) {
        expect(type.icon(), isA<IconData>());
        expect(type.icon(active: true), isA<IconData>());
      }
    });

    test('icon returns different values for active and inactive', () {
      for (final type in TimelineType.values) {
        // Active and inactive icons should differ
        expect(type.icon(active: false) != type.icon(active: true), isTrue,
          reason: '$type should have different active/inactive icons');
      }
    });

    testWidgets('each type has tooltip() method', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(createTestWidget(
        child: Builder(builder: (context) {
          capturedContext = context;
          return const SizedBox.shrink();
        }),
      ));
      await tester.pump();

      for (final type in TimelineType.values) {
        expect(type.tooltip(capturedContext), isNotEmpty);
      }
    });

    test('supportAnonymous returns correct values', () {
      expect(TimelineType.local.supportAnonymous, isTrue);
      expect(TimelineType.federal.supportAnonymous, isTrue);
      expect(TimelineType.public.supportAnonymous, isTrue);
      expect(TimelineType.home.supportAnonymous, isFalse);
      expect(TimelineType.favourites.supportAnonymous, isFalse);
      expect(TimelineType.bookmarks.supportAnonymous, isFalse);
      expect(TimelineType.list.supportAnonymous, isFalse);
      expect(TimelineType.user.supportAnonymous, isFalse);
      expect(TimelineType.pin.supportAnonymous, isFalse);
      expect(TimelineType.schedule.supportAnonymous, isFalse);
      expect(TimelineType.hashtag.supportAnonymous, isFalse);
    });

    test('non-tab types are list, user, pin, schedule, hashtag', () {
      final nonTabTypes = TimelineType.values.where((type) => !type.inTimelineTab).toList();
      expect(nonTabTypes, contains(TimelineType.list));
      expect(nonTabTypes, contains(TimelineType.user));
      expect(nonTabTypes, contains(TimelineType.pin));
      expect(nonTabTypes, contains(TimelineType.schedule));
      expect(nonTabTypes, contains(TimelineType.hashtag));
    });
  });

  group('Timeline', () {
    testWidgets('renders with required parameters', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: Timeline(
            type: TimelineType.local,
            status: status,
          ),
          accessStatus: status,
        ));
        await tester.pump();
      });

      expect(find.byType(Timeline), findsOneWidget);
    });

    testWidgets('widget accepts all optional parameters', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );
      final account = MockAccount.create();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: Timeline(
            type: TimelineType.user,
            status: status,
            account: account,
            hashtag: 'flutter',
            listId: 'list-1',
            onDeleted: () {},
          ),
          accessStatus: status,
        ));
        await tester.pump();
      });

      expect(find.byType(Timeline), findsOneWidget);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
