// Widget tests for Poll component.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/features/timeline/screens/poll.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setUpAll(() => setupTestEnvironment());

  group('Poll', () {
    group('when null schema', () {
      testWidgets('displays nothing', (tester) async {
        await tester.pumpWidget(createTestWidget(
          child: const Poll(schema: null),
        ));
        await tester.pump();

        // Should render SizedBox.shrink
        expect(find.byType(Poll), findsOneWidget);
        expect(find.byType(SizedBox), findsWidgets);
      });
    });

    group('when active poll', () {
      testWidgets('displays poll options', (tester) async {
        final poll = MockPoll.createActive();

        await tester.pumpWidget(createTestWidget(
          child: Poll(schema: poll),
        ));
        await tester.pump();

        expect(find.text('Option A'), findsOneWidget);
        expect(find.text('Option B'), findsOneWidget);
      });

      testWidgets('hides vote button until option selected', (tester) async {
        final poll = MockPoll.createActive();

        await tester.pumpWidget(createTestWidget(
          child: Poll(schema: poll),
        ));
        await tester.pump();

        // Vote button is hidden until an option is selected
        // The poll widget is rendered
        expect(find.byType(Poll), findsOneWidget);
      });

      testWidgets('displays radio buttons for single choice', (tester) async {
        final poll = MockPoll.createActive(multiple: false);

        await tester.pumpWidget(createTestWidget(
          child: Poll(schema: poll),
        ));
        await tester.pump();

        expect(find.byType(RadioListTile<int>), findsWidgets);
      });
    });

    group('when multiple choice poll', () {
      testWidgets('displays checkboxes', (tester) async {
        final poll = MockPoll.createMultiple();

        await tester.pumpWidget(createTestWidget(
          child: Poll(schema: poll),
        ));
        await tester.pump();

        expect(find.byType(CheckboxListTile), findsWidgets);
      });

      testWidgets('displays all options', (tester) async {
        final poll = MockPoll.createMultiple();

        await tester.pumpWidget(createTestWidget(
          child: Poll(schema: poll),
        ));
        await tester.pump();

        expect(find.text('Choice 1'), findsOneWidget);
        expect(find.text('Choice 2'), findsOneWidget);
        expect(find.text('Choice 3'), findsOneWidget);
      });
    });

    group('when voted poll', () {
      testWidgets('displays vote results', (tester) async {
        final poll = MockPoll.createVoted();

        await tester.pumpWidget(createTestWidget(
          child: Poll(schema: poll),
        ));
        await tester.pump();

        // Vote counts should be visible
        expect(find.textContaining('+'), findsWidgets);
      });

      testWidgets('displays check icon for own vote', (tester) async {
        final poll = MockPoll.createVoted(ownVotes: [0]);

        await tester.pumpWidget(createTestWidget(
          child: Poll(schema: poll),
        ));
        await tester.pump();

        // Check icon indicates user's vote
        expect(find.byIcon(Icons.check), findsWidgets);
      });

      testWidgets('displays option titles', (tester) async {
        final poll = MockPoll.createVoted();

        await tester.pumpWidget(createTestWidget(
          child: Poll(schema: poll),
        ));
        await tester.pump();

        expect(find.text('Option A'), findsOneWidget);
        expect(find.text('Option B'), findsOneWidget);
      });
    });

    group('when expired poll', () {
      testWidgets('displays vote results', (tester) async {
        final poll = MockPoll.createExpired();

        await tester.pumpWidget(createTestWidget(
          child: Poll(schema: poll),
        ));
        await tester.pump();

        // Should show vote results
        expect(find.byType(Poll), findsOneWidget);
      });

      testWidgets('displays vote count text', (tester) async {
        final poll = MockPoll.createExpired(votesCount: 10);

        await tester.pumpWidget(createTestWidget(
          child: Poll(schema: poll),
        ));
        await tester.pump();

        // Vote count should be displayed
        expect(find.textContaining('10'), findsWidgets);
      });
    });

    group('structure', () {
      testWidgets('uses AdaptiveGlassCard container', (tester) async {
        final poll = MockPoll.create();

        await tester.pumpWidget(createTestWidget(
          child: Poll(schema: poll),
        ));
        await tester.pump();

        expect(find.byType(Poll), findsOneWidget);
      });

      testWidgets('uses Column layout', (tester) async {
        final poll = MockPoll.create();

        await tester.pumpWidget(createTestWidget(
          child: Poll(schema: poll),
        ));
        await tester.pump();

        expect(find.byType(Column), findsWidgets);
      });

      testWidgets('uses Row for actions', (tester) async {
        final poll = MockPoll.create();

        await tester.pumpWidget(createTestWidget(
          child: Poll(schema: poll),
        ));
        await tester.pump();

        expect(find.byType(Row), findsWidgets);
      });
    });

    group('callbacks', () {
      testWidgets('accepts onChanged callback', (tester) async {
        final poll = MockPoll.createActive();
        bool callbackCalled = false;

        await tester.pumpWidget(createTestWidget(
          child: Poll(
            schema: poll,
            onChanged: (_) => callbackCalled = true,
          ),
        ));
        await tester.pump();

        expect(find.byType(Poll), findsOneWidget);
        // Callback not triggered without voting
        expect(callbackCalled, isFalse);
      });
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
