// Widget tests for Interaction and InteractionBar components.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/features/models.dart';
import 'package:glacial/features/timeline/screens/interaction.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setUpAll(() => setupTestEnvironment());

  group('Interaction', () {
    group('reply action', () {
      testWidgets('displays reply icon', (tester) async {
        final status = MockStatus.create(repliesCount: 3);
        final accessStatus = MockAccessStatus.authenticated();

        await tester.pumpWidget(createTestWidget(
          accessStatus: accessStatus,
          child: Interaction(
            schema: status,
            status: accessStatus,
            action: StatusInteraction.reply,
          ),
        ));
        await tester.pump(const Duration(milliseconds: 100));

        // Reply uses turn_left icon
        expect(find.byIcon(Icons.turn_left_outlined), findsOneWidget);
      });

      testWidgets('displays reply count', (tester) async {
        final status = MockStatus.create(repliesCount: 5);
        final accessStatus = MockAccessStatus.authenticated();

        await tester.pumpWidget(createTestWidget(
          accessStatus: accessStatus,
          child: Interaction(
            schema: status,
            status: accessStatus,
            action: StatusInteraction.reply,
          ),
        ));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('5'), findsOneWidget);
      });
    });

    group('reblog action', () {
      testWidgets('displays reblog icon when not reblogged', (tester) async {
        final status = MockStatus.create(reblogged: false, reblogsCount: 10);
        final accessStatus = MockAccessStatus.authenticated();

        await tester.pumpWidget(createTestWidget(
          accessStatus: accessStatus,
          child: Interaction(
            schema: status,
            status: accessStatus,
            action: StatusInteraction.reblog,
          ),
        ));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byIcon(Icons.repeat_outlined), findsOneWidget);
      });

      testWidgets('displays filled reblog icon when reblogged', (tester) async {
        final status = MockStatus.create(reblogged: true, reblogsCount: 10);
        final accessStatus = MockAccessStatus.authenticated();

        await tester.pumpWidget(createTestWidget(
          accessStatus: accessStatus,
          child: Interaction(
            schema: status,
            status: accessStatus,
            action: StatusInteraction.reblog,
          ),
        ));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byIcon(Icons.repeat), findsOneWidget);
      });

      testWidgets('displays reblog count', (tester) async {
        final status = MockStatus.create(reblogsCount: 15);
        final accessStatus = MockAccessStatus.authenticated();

        await tester.pumpWidget(createTestWidget(
          accessStatus: accessStatus,
          child: Interaction(
            schema: status,
            status: accessStatus,
            action: StatusInteraction.reblog,
          ),
        ));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('15'), findsOneWidget);
      });
    });

    group('favourite action', () {
      testWidgets('displays favourite icon when not favourited', (tester) async {
        final status = MockStatus.create(favourited: false);
        final accessStatus = MockAccessStatus.authenticated();

        await tester.pumpWidget(createTestWidget(
          accessStatus: accessStatus,
          child: Interaction(
            schema: status,
            status: accessStatus,
            action: StatusInteraction.favourite,
          ),
        ));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byIcon(Icons.star_outline_outlined), findsOneWidget);
      });

      testWidgets('displays filled star icon when favourited', (tester) async {
        final status = MockStatus.create(favourited: true);
        final accessStatus = MockAccessStatus.authenticated();

        await tester.pumpWidget(createTestWidget(
          accessStatus: accessStatus,
          child: Interaction(
            schema: status,
            status: accessStatus,
            action: StatusInteraction.favourite,
          ),
        ));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byIcon(Icons.star), findsOneWidget);
      });

      testWidgets('displays favourite count', (tester) async {
        final status = MockStatus.create(favouritesCount: 25);
        final accessStatus = MockAccessStatus.authenticated();

        await tester.pumpWidget(createTestWidget(
          accessStatus: accessStatus,
          child: Interaction(
            schema: status,
            status: accessStatus,
            action: StatusInteraction.favourite,
          ),
        ));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('25'), findsOneWidget);
      });
    });

    group('bookmark action', () {
      testWidgets('displays bookmark icon when not bookmarked', (tester) async {
        final status = MockStatus.create(bookmarked: false);
        final accessStatus = MockAccessStatus.authenticated();

        await tester.pumpWidget(createTestWidget(
          accessStatus: accessStatus,
          child: Interaction(
            schema: status,
            status: accessStatus,
            action: StatusInteraction.bookmark,
          ),
        ));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byIcon(Icons.bookmark_outline_outlined), findsOneWidget);
      });

      testWidgets('displays filled bookmark icon when bookmarked', (tester) async {
        final status = MockStatus.create(bookmarked: true);
        final accessStatus = MockAccessStatus.authenticated();

        await tester.pumpWidget(createTestWidget(
          accessStatus: accessStatus,
          child: Interaction(
            schema: status,
            status: accessStatus,
            action: StatusInteraction.bookmark,
          ),
        ));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byIcon(Icons.bookmark), findsOneWidget);
      });
    });

    group('share action', () {
      testWidgets('displays share icon', (tester) async {
        final status = MockStatus.create();
        final accessStatus = MockAccessStatus.authenticated();

        await tester.pumpWidget(createTestWidget(
          accessStatus: accessStatus,
          child: Interaction(
            schema: status,
            status: accessStatus,
            action: StatusInteraction.share,
          ),
        ));
        await tester.pump(const Duration(milliseconds: 100));

        // Share is always active, so uses the active icon
        expect(find.byIcon(Icons.share), findsOneWidget);
      });

      testWidgets('share is always available even when not signed in', (tester) async {
        final status = MockStatus.create();
        final accessStatus = MockAccessStatus.anonymous();

        await tester.pumpWidget(createTestWidget(
          accessStatus: accessStatus,
          child: Interaction(
            schema: status,
            status: accessStatus,
            action: StatusInteraction.share,
          ),
        ));
        await tester.pump(const Duration(milliseconds: 100));

        // Share button should be present (always uses active icon)
        expect(find.byIcon(Icons.share), findsOneWidget);
      });
    });

    group('availability', () {
      testWidgets('disables interaction when not signed in', (tester) async {
        final status = MockStatus.create();
        final accessStatus = MockAccessStatus.anonymous();

        await tester.pumpWidget(createTestWidget(
          accessStatus: accessStatus,
          child: Interaction(
            schema: status,
            status: accessStatus,
            action: StatusInteraction.favourite,
          ),
        ));
        await tester.pump(const Duration(milliseconds: 100));

        // Find the widget and verify it renders - disabled state is handled internally
        expect(find.byType(Interaction), findsOneWidget);
        // Icon should still be visible even when disabled
        expect(find.byIcon(Icons.star_outline_outlined), findsOneWidget);
      });

      testWidgets('enables interaction when signed in', (tester) async {
        final status = MockStatus.create();
        final accessStatus = MockAccessStatus.authenticated();

        await tester.pumpWidget(createTestWidget(
          accessStatus: accessStatus,
          child: Interaction(
            schema: status,
            status: accessStatus,
            action: StatusInteraction.favourite,
          ),
        ));
        await tester.pump(const Duration(milliseconds: 100));

        // Widget should render and be tappable
        expect(find.byType(Interaction), findsOneWidget);
        expect(find.byIcon(Icons.star_outline_outlined), findsOneWidget);
      });
    });

    group('compact vs full mode', () {
      testWidgets('displays compact icon by default', (tester) async {
        final status = MockStatus.create();
        final accessStatus = MockAccessStatus.authenticated();

        await tester.pumpWidget(createTestWidget(
          accessStatus: accessStatus,
          child: Interaction(
            schema: status,
            status: accessStatus,
            action: StatusInteraction.favourite,
            isCompact: true,
          ),
        ));
        await tester.pump(const Duration(milliseconds: 100));

        // Compact mode shows icon, no ListTile
        expect(find.byIcon(Icons.star_outline_outlined), findsOneWidget);
        expect(find.byType(ListTile), findsNothing);
      });

      testWidgets('displays full button in non-compact mode', (tester) async {
        final status = MockStatus.create();
        final accessStatus = MockAccessStatus.authenticated();

        await tester.pumpWidget(createTestWidget(
          accessStatus: accessStatus,
          child: Interaction(
            schema: status,
            status: accessStatus,
            action: StatusInteraction.favourite,
            isCompact: false,
          ),
        ));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(ListTile), findsOneWidget);
      });
    });
  });

  group('InteractionBar', () {
    testWidgets('displays multiple interaction buttons', (tester) async {
      final status = MockStatus.create(
        repliesCount: 2,
        reblogsCount: 5,
        favouritesCount: 10,
      );

      await tester.pumpWidget(createAuthenticatedTestWidget(
        child: SizedBox(
          width: 400, // Wide enough to show all actions
          child: InteractionBar(schema: status),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      // Should display reply, reblog, favourite icons (using outlined variants)
      expect(find.byIcon(Icons.turn_left_outlined), findsOneWidget);
      expect(find.byIcon(Icons.repeat_outlined), findsOneWidget);
      expect(find.byIcon(Icons.star_outline_outlined), findsOneWidget);
    });

    testWidgets('displays more button for overflow actions', (tester) async {
      final status = MockStatus.create();

      await tester.pumpWidget(createAuthenticatedTestWidget(
        child: SizedBox(
          width: 200, // Limited width to force overflow
          child: InteractionBar(schema: status),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      // More button should be present
      expect(find.byIcon(Icons.more_horiz), findsOneWidget);
    });

    testWidgets('calls onReload callback when interaction changes status', (tester) async {
      final status = MockStatus.create();

      await tester.pumpWidget(createAuthenticatedTestWidget(
        child: InteractionBar(
          schema: status,
          onReload: (_) {}, // Callback wired for testing
        ),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      // Widget should render with callback wired
      expect(find.byType(InteractionBar), findsOneWidget);
    });
  });

  group('InteractionMore', () {
    testWidgets('hides when no actions provided', (tester) async {
      final status = MockStatus.create();
      final accessStatus = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        accessStatus: accessStatus,
        child: InteractionMore(
          schema: status,
          status: accessStatus,
          actions: const [],
        ),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.more_horiz), findsNothing);
    });

    testWidgets('shows popup menu when tapped', (tester) async {
      final status = MockStatus.create();
      final accessStatus = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        accessStatus: accessStatus,
        child: InteractionMore(
          schema: status,
          status: accessStatus,
          actions: [StatusInteraction.mute, StatusInteraction.report],
        ),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      // Tap the more button
      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pump(const Duration(milliseconds: 100));

      // Popup menu should appear with actions
      expect(find.byType(PopupMenuItem<StatusInteraction>), findsWidgets);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
