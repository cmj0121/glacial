// Widget tests for relationship screens: Relationship, RelationshipType,
// FollowRequestBadge, FollowRequests.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

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
  });
}

// vim: set ts=2 sw=2 sts=2 et:
