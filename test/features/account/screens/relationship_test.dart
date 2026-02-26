// Widget tests for relationship screens: Relationship, RelationshipType,
// FollowRequestBadge, FollowRequests.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  // Initialize sqflite FFI for CachedNetworkImage's cache manager in runAsync tests.
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('Relationship', () {
    setUpAll(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (MethodCall methodCall) async => Directory.systemTemp.path,
      );
    });

    testWidgets('renders Row layout', (tester) async {
      final account = MockAccount.create(id: '999');
      final status = MockAccessStatus.authenticated();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: Relationship(schema: account),
          accessStatus: status,
        ));
        await tester.pump();
      });

      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('shows more actions popup button', (tester) async {
      final account = MockAccount.create(id: '999');
      final status = MockAccessStatus.authenticated();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: Relationship(schema: account),
          accessStatus: status,
        ));
        await tester.pump();
      });

      expect(find.byIcon(Icons.more_horiz), findsOneWidget);
    });

    testWidgets('shows relationship icon button (stranger initially)', (tester) async {
      final account = MockAccount.create(id: '999');
      final status = MockAccessStatus.authenticated();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: Relationship(schema: account),
          accessStatus: status,
        ));
        await tester.pump();
      });

      // Without API response, schema is null, so relationship == stranger
      expect(find.byIcon(RelationshipType.stranger.icon()), findsOneWidget);
    });

    testWidgets('contains SizedBox spacers', (tester) async {
      final account = MockAccount.create(id: '999');
      final status = MockAccessStatus.authenticated();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: Relationship(schema: account),
          accessStatus: status,
        ));
        await tester.pump();
      });

      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('contains AnimatedSwitcher for transitions', (tester) async {
      final account = MockAccount.create(id: '999');
      final status = MockAccessStatus.authenticated();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: Relationship(schema: account),
          accessStatus: status,
        ));
        await tester.pump();
      });

      expect(find.byType(AnimatedSwitcher), findsWidgets);
    });
  });

  group('RelationshipType', () {
    test('all types have icon() method', () {
      for (final type in RelationshipType.values) {
        expect(type.icon(), isA<IconData>());
      }
    });

    testWidgets('all types have tooltip() method', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: Builder(
          builder: (context) {
            for (final type in RelationshipType.values) {
              final tooltip = type.tooltip(context);
              expect(tooltip, isA<String>());
              expect(tooltip.isNotEmpty, isTrue);
            }
            return const SizedBox.shrink();
          },
        ),
      ));
      await tester.pump();
    });

    test('isMoreActions returns correct values', () {
      // Basic types should NOT be more actions
      expect(RelationshipType.following.isMoreActions, isFalse);
      expect(RelationshipType.followedBy.isMoreActions, isFalse);
      expect(RelationshipType.followEachOther.isMoreActions, isFalse);
      expect(RelationshipType.followRequest.isMoreActions, isFalse);
      expect(RelationshipType.stranger.isMoreActions, isFalse);
      expect(RelationshipType.blockedBy.isMoreActions, isFalse);
      expect(RelationshipType.unblock.isMoreActions, isFalse);

      // More action types should be more actions
      expect(RelationshipType.mute.isMoreActions, isTrue);
      expect(RelationshipType.unmute.isMoreActions, isTrue);
      expect(RelationshipType.block.isMoreActions, isTrue);
      expect(RelationshipType.report.isMoreActions, isTrue);
    });

    test('isDangerous returns correct values for block/mute', () {
      expect(RelationshipType.mute.isDangerous, isTrue);
      expect(RelationshipType.block.isDangerous, isTrue);
      expect(RelationshipType.report.isDangerous, isTrue);

      expect(RelationshipType.following.isDangerous, isFalse);
      expect(RelationshipType.stranger.isDangerous, isFalse);
      expect(RelationshipType.unmute.isDangerous, isFalse);
      expect(RelationshipType.unblock.isDangerous, isFalse);
    });

    testWidgets('tooltip with account includes acct', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: Builder(
          builder: (context) {
            final account = MockAccount.create(username: 'alice');
            for (final type in [
              RelationshipType.mute,
              RelationshipType.unmute,
              RelationshipType.block,
              RelationshipType.unblock,
              RelationshipType.report,
            ]) {
              final tooltip = type.tooltip(context, account: account);
              expect(tooltip, contains('@alice'));
            }
            return const SizedBox.shrink();
          },
        ),
      ));
      await tester.pump();
    });
  });

  group('FollowRequestBadge', () {
    testWidgets('renders empty when no pending requests', (tester) async {
      final status = MockAccessStatus.authenticated();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: const FollowRequestBadge(),
          accessStatus: status,
        ));
        await tester.pump();
      });

      // pendingCount == 0 initially, so renders SizedBox.shrink
      expect(find.byType(SizedBox), findsWidgets);
      expect(find.byIcon(Icons.pending_actions), findsNothing);
    });

    testWidgets('is a ConsumerStatefulWidget', (tester) async {
      const widget = FollowRequestBadge();
      expect(widget, isA<ConsumerStatefulWidget>());
    });

    testWidgets('shows icon button when pending count > 0', (tester) async {
      final status = MockAccessStatus.authenticated();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: const FollowRequestBadge(),
          accessStatus: status,
        ));
        await tester.pump();

        // Inject pending count into state
        final state = tester.state(find.byType(FollowRequestBadge));
        (state as dynamic).pendingCount = 3;
        (tester.element(find.byType(FollowRequestBadge)) as StatefulElement).markNeedsBuild();
        await tester.pump();
      });

      // Should now show pending_actions icon
      expect(find.byIcon(Icons.pending_actions), findsOneWidget);
    });

    testWidgets('icon button has styled appearance', (tester) async {
      final status = MockAccessStatus.authenticated();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: const FollowRequestBadge(),
          accessStatus: status,
        ));
        await tester.pump();

        final state = tester.state(find.byType(FollowRequestBadge));
        (state as dynamic).pendingCount = 1;
        (tester.element(find.byType(FollowRequestBadge)) as StatefulElement).markNeedsBuild();
        await tester.pump();
      });

      // IconButton should be present
      expect(find.byType(IconButton), findsOneWidget);
      // Wrapped in Padding
      expect(find.byType(Padding), findsWidgets);
    });

    testWidgets('shows nothing with no-domain status', (tester) async {
      // Use no-domain auth so API calls short-circuit
      const status = AccessStatusSchema(domain: null, accessToken: 'test');

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: const FollowRequestBadge(),
          accessStatus: status,
        ));
        await tester.pump();
      });

      // No domain -> API call returns empty, pendingCount stays 0
      expect(find.byIcon(Icons.pending_actions), findsNothing);
    });

    testWidgets('renders with no-domain auth', (tester) async {
      const status = AccessStatusSchema(domain: null, accessToken: 'test');

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: const FollowRequestBadge(),
          accessStatus: status,
        ));
        await tester.pump();
      });

      // No crash, renders empty
      expect(find.byType(FollowRequestBadge), findsOneWidget);
    });
  });

  group('FollowRequests', () {
    testWidgets('renders with authenticated user', (tester) async {
      final status = MockAccessStatus.authenticated();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: const FollowRequests()),
          accessStatus: status,
        ));
        await tester.pump();
      });

      expect(find.byType(FollowRequests), findsOneWidget);
    });

    testWidgets('is a StatefulWidget', (tester) async {
      const widget = FollowRequests();
      expect(widget, isA<StatefulWidget>());
    });

    testWidgets('uses FutureBuilder for data loading', (tester) async {
      final status = MockAccessStatus.authenticated();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: const FollowRequests()),
          accessStatus: status,
        ));
        await tester.pump();
      });

      // FutureBuilder should be present
      expect(find.byType(FutureBuilder<List<AccountSchema>>), findsOneWidget);
    });

    testWidgets('shows NoResult when empty list returns', (tester) async {
      // Using no-domain auth -> fetchFollowRequests returns null -> Future.value([])
      const status = AccessStatusSchema(domain: null, accessToken: 'test');

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: const FollowRequests()),
          accessStatus: status,
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
      });

      // Empty list should show NoResult with coffee icon
      expect(find.byType(NoResult), findsOneWidget);
    });

    testWidgets('is a ConsumerStatefulWidget', (tester) async {
      const widget = FollowRequests();
      expect(widget, isA<ConsumerStatefulWidget>());
    });

    testWidgets('renders with no-domain auth', (tester) async {
      const status = AccessStatusSchema(domain: null, accessToken: 'test');

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: const FollowRequests()),
          accessStatus: status,
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
      });

      expect(find.byType(FollowRequests), findsOneWidget);
    });

    testWidgets('shows loading state initially', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: const FollowRequests()),
          accessStatus: status,
        ));
        // First pump: shows loading (ConnectionState.waiting)
        await tester.pump();
      });

      // LoadingOverlay should be present during loading
      expect(find.byType(LoadingOverlay), findsWidgets);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
