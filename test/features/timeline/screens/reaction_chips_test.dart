// Widget tests for the ReactionChips widget.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:glacial/features/timeline/screens/reaction_chips.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();
  databaseFactory = databaseFactoryFfi;

  group('ReactionChips', () {
    testWidgets('renders nothing when reactions list is empty', (tester) async {
      final status = MockStatus.create(reactions: []);

      await tester.pumpWidget(createTestWidget(
        child: ReactionChips(schema: status),
      ));
      await tester.pump();

      expect(find.byType(ActionChip), findsNothing);
    });

    testWidgets('renders reaction chips with emoji names and counts', (tester) async {
      final status = MockStatus.create(reactions: [
        MockReaction.create(name: '👍', count: 3),
        MockReaction.create(name: '❤️', count: 7),
      ]);

      await tester.pumpWidget(createTestWidget(
        child: ReactionChips(schema: status),
      ));
      await tester.pump();

      expect(find.byType(ActionChip), findsNWidgets(2));
      expect(find.text('3'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
      expect(find.text('👍'), findsOneWidget);
      expect(find.text('❤️'), findsOneWidget);
    });

    testWidgets('highlights chip when me is true', (tester) async {
      final status = MockStatus.create(reactions: [
        MockReaction.create(name: '🎉', count: 2, me: true),
      ]);

      await tester.pumpWidget(createTestWidget(
        accessStatus: MockAccessStatus.authenticated(),
        child: ReactionChips(schema: status),
      ));
      await tester.pump();

      final chip = tester.widget<ActionChip>(find.byType(ActionChip));
      expect(chip.backgroundColor, isNotNull);
    });

    testWidgets('renders custom emoji chip with CachedNetworkImage', (tester) async {
      final status = MockStatus.create(reactions: [
        MockReaction.create(
          name: 'blobcat',
          count: 1,
          url: 'https://example.com/emoji/blobcat.png',
        ),
      ]);

      await tester.pumpWidget(createTestWidget(
        child: ReactionChips(schema: status),
      ));
      await tester.pump();

      expect(find.byType(ActionChip), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      // Custom emoji uses CachedNetworkImage avatar, not text name
      expect(find.text('blobcat'), findsNothing);
    });

    testWidgets('chip is disabled when not signed in', (tester) async {
      final status = MockStatus.create(reactions: [
        MockReaction.create(name: '👍', count: 1),
      ]);

      await tester.pumpWidget(createTestWidget(
        accessStatus: MockAccessStatus.anonymous(),
        child: ReactionChips(schema: status),
      ));
      await tester.pump();

      final chip = tester.widget<ActionChip>(find.byType(ActionChip));
      expect(chip.onPressed, isNull);
    });

    testWidgets('chip is enabled when signed in', (tester) async {
      final status = MockStatus.create(reactions: [
        MockReaction.create(name: '👍', count: 1),
      ]);

      await tester.pumpWidget(createTestWidget(
        accessStatus: MockAccessStatus.authenticated(),
        child: ReactionChips(schema: status),
      ));
      await tester.pump();

      final chip = tester.widget<ActionChip>(find.byType(ActionChip));
      expect(chip.onPressed, isNotNull);
    });

    testWidgets('renders multiple reactions in a Wrap', (tester) async {
      final status = MockStatus.create(reactions: [
        MockReaction.create(name: '👍', count: 1),
        MockReaction.create(name: '😂', count: 2),
        MockReaction.create(name: '❤️', count: 3),
        MockReaction.create(name: '🔥', count: 4),
      ]);

      await tester.pumpWidget(createTestWidget(
        child: ReactionChips(schema: status),
      ));
      await tester.pump();

      expect(find.byType(ActionChip), findsNWidgets(4));
      expect(find.byType(Wrap), findsOneWidget);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
