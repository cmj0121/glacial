// Widget tests for Relationship widget.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

// Use domain-null status so API calls short-circuit without HTTP.
AccessStatusSchema _noDomainAuth() {
  return const AccessStatusSchema(domain: null, accessToken: 'test');
}

void main() {
  setupTestEnvironment();

  group('Relationship', () {
    testWidgets('renders as a Row', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: Relationship(schema: MockAccount.create()),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      expect(find.byType(Relationship), findsOneWidget);
      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('shows more actions button', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: Relationship(schema: MockAccount.create()),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      expect(find.byIcon(Icons.more_horiz), findsOneWidget);
    });

    test('is a ConsumerStatefulWidget', () {
      final widget = Relationship(schema: MockAccount.create());
      expect(widget, isA<ConsumerStatefulWidget>());
    });

    test('accepts required schema parameter', () {
      final account = MockAccount.create(id: 'rel-test', displayName: 'RelTest');
      final widget = Relationship(schema: account);
      expect(widget.schema.id, 'rel-test');
    });

    testWidgets('renders with no-domain status', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: Relationship(schema: MockAccount.create()),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      expect(find.byType(Relationship), findsOneWidget);
    });
  });

  group('RelationshipType', () {
    test('has following and stranger', () {
      expect(RelationshipType.values, contains(RelationshipType.following));
      expect(RelationshipType.values, contains(RelationshipType.stranger));
    });

    test('has block and unblock', () {
      expect(RelationshipType.values, contains(RelationshipType.block));
      expect(RelationshipType.values, contains(RelationshipType.unblock));
    });

    test('has mute and unmute', () {
      expect(RelationshipType.values, contains(RelationshipType.mute));
      expect(RelationshipType.values, contains(RelationshipType.unmute));
    });

    test('isMoreActions differentiates primary from secondary', () {
      // following/stranger are primary actions (not in more menu)
      expect(RelationshipType.following.isMoreActions, false);
      expect(RelationshipType.stranger.isMoreActions, false);
      // block/mute are in the more menu
      expect(RelationshipType.block.isMoreActions, true);
      expect(RelationshipType.mute.isMoreActions, true);
    });

    test('each has icon', () {
      for (final type in RelationshipType.values) {
        expect(type.icon(), isA<IconData>());
      }
    });
  });

  group('RelationshipSchema', () {
    test('fromJson parses all fields', () {
      final rel = MockRelationship.create();
      expect(rel.following, false);
      expect(rel.blocking, false);
      expect(rel.muting, false);
    });

    test('fromJson with following true', () {
      final rel = MockRelationship.create(following: true);
      expect(rel.following, true);
    });

    test('fromJson with blocking true', () {
      final rel = MockRelationship.create(blocking: true);
      expect(rel.blocking, true);
    });

    test('fromJson with muting true', () {
      final rel = MockRelationship.create(muting: true);
      expect(rel.muting, true);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
