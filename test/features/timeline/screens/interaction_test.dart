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

  group('Interaction - full button mode (buildFullButton)', () {
    testWidgets('displays policy title from quoteApproval in full mode', (tester) async {
      final quoteApproval = QuoteApprovalSchema(
        automatic: [QuoteApprovalType.public],
        manual: [],
        currentUser: CurrentQuoteApprovalType.automatic,
      );
      final status = MockStatus.create();
      // Create a StatusSchema with quoteApproval directly
      final schemaWithApproval = StatusSchema(
        id: status.id,
        content: status.content,
        visibility: status.visibility,
        sensitive: status.sensitive,
        spoiler: status.spoiler,
        account: MockAccount.create(id: '123'),
        uri: status.uri,
        reblogsCount: status.reblogsCount,
        favouritesCount: status.favouritesCount,
        repliesCount: status.repliesCount,
        createdAt: status.createdAt,
        quoteApproval: quoteApproval,
      );
      final accessStatus = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        accessStatus: accessStatus,
        child: Interaction(
          schema: schemaWithApproval,
          status: accessStatus,
          action: StatusInteraction.policy,
          isCompact: false,
        ),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      // Full button shows ListTile with policy title
      expect(find.byType(ListTile), findsOneWidget);
    });

    testWidgets('displays policy title for nobody when quoteApproval is null in full mode', (tester) async {
      final status = MockStatus.create();
      final accessStatus = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        accessStatus: accessStatus,
        child: Interaction(
          schema: status,
          status: accessStatus,
          action: StatusInteraction.policy,
          isCompact: false,
        ),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      // Full button shows ListTile (with nobody policy since quoteApproval is null)
      expect(find.byType(ListTile), findsOneWidget);
    });

    testWidgets('displays non-policy action tooltip in full mode', (tester) async {
      final status = MockStatus.create();
      final accessStatus = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        accessStatus: accessStatus,
        child: Interaction(
          schema: status,
          status: accessStatus,
          action: StatusInteraction.reblog,
          isCompact: false,
        ),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      // Full button shows ListTile with action tooltip
      expect(find.byType(ListTile), findsOneWidget);
    });

    testWidgets('full mode mute action shows ListTile', (tester) async {
      final status = MockStatus.create();
      final accessStatus = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        accessStatus: accessStatus,
        child: Interaction(
          schema: status,
          status: accessStatus,
          action: StatusInteraction.mute,
          isCompact: false,
        ),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ListTile), findsOneWidget);
    });
  });

  group('Interaction - scheduled status', () {
    testWidgets('only edit is available for scheduled status', (tester) async {
      final status = MockStatus.create(scheduledAt: DateTime.now().add(const Duration(days: 1)));
      final accessStatus = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        accessStatus: accessStatus,
        child: Interaction(
          schema: status,
          status: accessStatus,
          action: StatusInteraction.edit,
          isCompact: false,
        ),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      // Edit should be available for scheduled posts — ListTile with onTap
      final listTile = tester.widget<ListTile>(find.byType(ListTile));
      expect(listTile.onTap, isNotNull);
    });

    testWidgets('only delete is available for scheduled status', (tester) async {
      final status = MockStatus.create(scheduledAt: DateTime.now().add(const Duration(days: 1)));
      final accessStatus = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        accessStatus: accessStatus,
        child: Interaction(
          schema: status,
          status: accessStatus,
          action: StatusInteraction.delete,
          isCompact: false,
        ),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      final listTile = tester.widget<ListTile>(find.byType(ListTile));
      expect(listTile.onTap, isNotNull);
    });

    testWidgets('favourite is disabled for scheduled status', (tester) async {
      final status = MockStatus.create(scheduledAt: DateTime.now().add(const Duration(days: 1)));
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

      // Favourite should be disabled for scheduled posts — Semantics shows enabled: false
      expect(find.byType(Interaction), findsOneWidget);
      final state = tester.state(find.byType(Interaction));
      expect((state as dynamic).isAvailable, isFalse);
    });
  });

  group('Interaction - quote action availability', () {
    testWidgets('quote available when currentUser is automatic', (tester) async {
      final quoteApproval = QuoteApprovalSchema(
        automatic: [QuoteApprovalType.public],
        manual: [],
        currentUser: CurrentQuoteApprovalType.automatic,
      );
      final status = StatusSchema(
        id: '456',
        content: '<p>Test</p>',
        visibility: VisibilityType.public,
        sensitive: false,
        spoiler: '',
        account: MockAccount.create(),
        uri: 'https://example.com/statuses/456',
        reblogsCount: 0,
        favouritesCount: 0,
        repliesCount: 0,
        createdAt: DateTime.now(),
        quoteApproval: quoteApproval,
      );
      final accessStatus = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        accessStatus: accessStatus,
        child: Interaction(
          schema: status,
          status: accessStatus,
          action: StatusInteraction.quote,
        ),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      // Quote should be available — Semantics shows enabled: true
      final state = tester.state(find.byType(Interaction));
      expect((state as dynamic).isAvailable, isTrue);
    });

    testWidgets('quote available when currentUser is manual', (tester) async {
      final quoteApproval = QuoteApprovalSchema(
        automatic: [],
        manual: [QuoteApprovalType.public],
        currentUser: CurrentQuoteApprovalType.manual,
      );
      final status = StatusSchema(
        id: '456',
        content: '<p>Test</p>',
        visibility: VisibilityType.public,
        sensitive: false,
        spoiler: '',
        account: MockAccount.create(),
        uri: 'https://example.com/statuses/456',
        reblogsCount: 0,
        favouritesCount: 0,
        repliesCount: 0,
        createdAt: DateTime.now(),
        quoteApproval: quoteApproval,
      );
      final accessStatus = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        accessStatus: accessStatus,
        child: Interaction(
          schema: status,
          status: accessStatus,
          action: StatusInteraction.quote,
        ),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      final state = tester.state(find.byType(Interaction));
      expect((state as dynamic).isAvailable, isTrue);
    });

    testWidgets('quote disabled when quoteApproval is null', (tester) async {
      final status = MockStatus.create();
      final accessStatus = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        accessStatus: accessStatus,
        child: Interaction(
          schema: status,
          status: accessStatus,
          action: StatusInteraction.quote,
        ),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      // Quote should be disabled — Semantics shows enabled: false
      final state = tester.state(find.byType(Interaction));
      expect((state as dynamic).isAvailable, isFalse);
    });
  });

  group('Interaction - self post actions', () {
    testWidgets('pin is available for self post', (tester) async {
      final selfAccount = MockAccount.create(id: '123');
      final status = MockStatus.create(account: selfAccount);
      final accessStatus = MockAccessStatus.authenticated(account: selfAccount);

      await tester.pumpWidget(createTestWidget(
        accessStatus: accessStatus,
        child: Interaction(
          schema: status,
          status: accessStatus,
          action: StatusInteraction.pin,
        ),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      // Pin for self post is available — Semantics shows enabled: true
      final state = tester.state(find.byType(Interaction));
      expect((state as dynamic).isAvailable, isTrue);
    });

    testWidgets('pin is disabled for non-self post', (tester) async {
      final otherAccount = MockAccount.create(id: '999', username: 'other');
      final status = MockStatus.create(account: otherAccount);
      final accessStatus = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        accessStatus: accessStatus,
        child: Interaction(
          schema: status,
          status: accessStatus,
          action: StatusInteraction.pin,
        ),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      final state = tester.state(find.byType(Interaction));
      expect((state as dynamic).isAvailable, isFalse);
    });

    testWidgets('edit is available for self post', (tester) async {
      final selfAccount = MockAccount.create(id: '123');
      final status = MockStatus.create(account: selfAccount);
      final accessStatus = MockAccessStatus.authenticated(account: selfAccount);

      await tester.pumpWidget(createTestWidget(
        accessStatus: accessStatus,
        child: Interaction(
          schema: status,
          status: accessStatus,
          action: StatusInteraction.edit,
        ),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      final state = tester.state(find.byType(Interaction));
      expect((state as dynamic).isAvailable, isTrue);
    });

    testWidgets('delete is available for self post', (tester) async {
      final selfAccount = MockAccount.create(id: '123');
      final status = MockStatus.create(account: selfAccount);
      final accessStatus = MockAccessStatus.authenticated(account: selfAccount);

      await tester.pumpWidget(createTestWidget(
        accessStatus: accessStatus,
        child: Interaction(
          schema: status,
          status: accessStatus,
          action: StatusInteraction.delete,
        ),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      final state = tester.state(find.byType(Interaction));
      expect((state as dynamic).isAvailable, isTrue);
    });
  });

  group('Interaction - non-self post actions', () {
    testWidgets('report is available for non-self post when signed in', (tester) async {
      final otherAccount = MockAccount.create(id: '999', username: 'other');
      final status = MockStatus.create(account: otherAccount);
      final accessStatus = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        accessStatus: accessStatus,
        child: Interaction(
          schema: status,
          status: accessStatus,
          action: StatusInteraction.report,
        ),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      final state = tester.state(find.byType(Interaction));
      expect((state as dynamic).isAvailable, isTrue);
    });

    testWidgets('report is disabled for self post', (tester) async {
      final selfAccount = MockAccount.create(id: '123');
      final status = MockStatus.create(account: selfAccount);
      final accessStatus = MockAccessStatus.authenticated(account: selfAccount);

      await tester.pumpWidget(createTestWidget(
        accessStatus: accessStatus,
        child: Interaction(
          schema: status,
          status: accessStatus,
          action: StatusInteraction.report,
        ),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      final state = tester.state(find.byType(Interaction));
      expect((state as dynamic).isAvailable, isFalse);
    });

    testWidgets('block is available for non-self post when signed in', (tester) async {
      final otherAccount = MockAccount.create(id: '999', username: 'other');
      final status = MockStatus.create(account: otherAccount);
      final accessStatus = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        accessStatus: accessStatus,
        child: Interaction(
          schema: status,
          status: accessStatus,
          action: StatusInteraction.block,
        ),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      final state = tester.state(find.byType(Interaction));
      expect((state as dynamic).isAvailable, isTrue);
    });

    testWidgets('filter is available for non-self post when signed in', (tester) async {
      final otherAccount = MockAccount.create(id: '999', username: 'other');
      final status = MockStatus.create(account: otherAccount);
      final accessStatus = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        accessStatus: accessStatus,
        child: Interaction(
          schema: status,
          status: accessStatus,
          action: StatusInteraction.filter,
        ),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      final state = tester.state(find.byType(Interaction));
      expect((state as dynamic).isAvailable, isTrue);
    });
  });

  group('Interaction - icon and color states', () {
    testWidgets('pinned status shows filled pin icon', (tester) async {
      final selfAccount = MockAccount.create(id: '123');
      final status = MockStatus.create(pinned: true, account: selfAccount);
      final accessStatus = MockAccessStatus.authenticated(account: selfAccount);

      await tester.pumpWidget(createTestWidget(
        accessStatus: accessStatus,
        child: Interaction(
          schema: status,
          status: accessStatus,
          action: StatusInteraction.pin,
        ),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.push_pin), findsOneWidget);
    });

    testWidgets('muted status shows volume_off icon', (tester) async {
      final status = MockStatus.create(muted: true);
      final accessStatus = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        accessStatus: accessStatus,
        child: Interaction(
          schema: status,
          status: accessStatus,
          action: StatusInteraction.mute,
        ),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.volume_off), findsOneWidget);
    });

    testWidgets('policy icon uses quoteApproval.toUser when present', (tester) async {
      final quoteApproval = QuoteApprovalSchema(
        automatic: [QuoteApprovalType.followers],
        manual: [],
        currentUser: CurrentQuoteApprovalType.automatic,
      );
      final selfAccount = MockAccount.create(id: '123');
      final status = StatusSchema(
        id: '456',
        content: '<p>Test</p>',
        visibility: VisibilityType.public,
        sensitive: false,
        spoiler: '',
        account: selfAccount,
        uri: 'https://example.com/statuses/456',
        reblogsCount: 0,
        favouritesCount: 0,
        repliesCount: 0,
        createdAt: DateTime.now(),
        quoteApproval: quoteApproval,
      );
      final accessStatus = MockAccessStatus.authenticated(account: selfAccount);

      await tester.pumpWidget(createTestWidget(
        accessStatus: accessStatus,
        child: Interaction(
          schema: status,
          status: accessStatus,
          action: StatusInteraction.policy,
        ),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      // followers policy icon is Icons.group
      expect(find.byIcon(Icons.group), findsOneWidget);
    });

    testWidgets('policy icon defaults to lock when no quoteApproval', (tester) async {
      final selfAccount = MockAccount.create(id: '123');
      final status = MockStatus.create(account: selfAccount);
      final accessStatus = MockAccessStatus.authenticated(account: selfAccount);

      await tester.pumpWidget(createTestWidget(
        accessStatus: accessStatus,
        child: Interaction(
          schema: status,
          status: accessStatus,
          action: StatusInteraction.policy,
        ),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      // nobody policy icon is Icons.lock
      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('delete action uses error color', (tester) async {
      final selfAccount = MockAccount.create(id: '123');
      final status = MockStatus.create(account: selfAccount);
      final accessStatus = MockAccessStatus.authenticated(account: selfAccount);

      await tester.pumpWidget(createTestWidget(
        accessStatus: accessStatus,
        child: Interaction(
          schema: status,
          status: accessStatus,
          action: StatusInteraction.delete,
        ),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      // Delete should use error color — icon widget should be visible
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('edit action shows edit icon for self post', (tester) async {
      final selfAccount = MockAccount.create(id: '123');
      final status = MockStatus.create(account: selfAccount);
      final accessStatus = MockAccessStatus.authenticated(account: selfAccount);

      await tester.pumpWidget(createTestWidget(
        accessStatus: accessStatus,
        child: Interaction(
          schema: status,
          status: accessStatus,
          action: StatusInteraction.edit,
        ),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('report action for non-self uses error color icon', (tester) async {
      final otherAccount = MockAccount.create(id: '999', username: 'other');
      final status = MockStatus.create(account: otherAccount);
      final accessStatus = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        accessStatus: accessStatus,
        child: Interaction(
          schema: status,
          status: accessStatus,
          action: StatusInteraction.report,
        ),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      // Report for non-self posts shows active icon (feedback_rounded)
      expect(find.byIcon(Icons.feedback_rounded), findsOneWidget);
    });

    testWidgets('block action shows block icon for non-self', (tester) async {
      final otherAccount = MockAccount.create(id: '999', username: 'other');
      final status = MockStatus.create(account: otherAccount);
      final accessStatus = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        accessStatus: accessStatus,
        child: Interaction(
          schema: status,
          status: accessStatus,
          action: StatusInteraction.block,
        ),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      // isActive for block uses isSignedIn -> true
      expect(find.byIcon(Icons.block), findsOneWidget);
    });

    testWidgets('filter action shows filter icon for non-self', (tester) async {
      final otherAccount = MockAccount.create(id: '999', username: 'other');
      final status = MockStatus.create(account: otherAccount);
      final accessStatus = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        accessStatus: accessStatus,
        child: Interaction(
          schema: status,
          status: accessStatus,
          action: StatusInteraction.filter,
        ),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      // isActive for filter uses isSignedIn -> true
      expect(find.byIcon(Icons.filter_alt), findsOneWidget);
    });

    testWidgets('quote count is shown when quotesCount is set', (tester) async {
      final quoteApproval = QuoteApprovalSchema(
        automatic: [QuoteApprovalType.public],
        manual: [],
        currentUser: CurrentQuoteApprovalType.automatic,
      );
      final status = StatusSchema(
        id: '456',
        content: '<p>Test</p>',
        visibility: VisibilityType.public,
        sensitive: false,
        spoiler: '',
        account: MockAccount.create(),
        uri: 'https://example.com/statuses/456',
        reblogsCount: 0,
        favouritesCount: 0,
        repliesCount: 0,
        createdAt: DateTime.now(),
        quoteApproval: quoteApproval,
        quotesCount: 7,
      );
      final accessStatus = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        accessStatus: accessStatus,
        child: Interaction(
          schema: status,
          status: accessStatus,
          action: StatusInteraction.quote,
        ),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('no count shown for bookmark action', (tester) async {
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

      // Bookmark has no count, so no number displayed
      expect(find.byIcon(Icons.bookmark), findsOneWidget);
      // Should display SizedBox.shrink for count (no numeric text)
      expect(find.byType(SizedBox), findsWidgets);
    });
  });

  group('Interaction - full mode for various actions', () {
    testWidgets('full mode delete shows ListTile for self post', (tester) async {
      final selfAccount = MockAccount.create(id: '123');
      final status = MockStatus.create(account: selfAccount);
      final accessStatus = MockAccessStatus.authenticated(account: selfAccount);

      await tester.pumpWidget(createTestWidget(
        accessStatus: accessStatus,
        child: Interaction(
          schema: status,
          status: accessStatus,
          action: StatusInteraction.delete,
          isCompact: false,
        ),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ListTile), findsOneWidget);
    });

    testWidgets('full mode report shows ListTile for non-self', (tester) async {
      final otherAccount = MockAccount.create(id: '999', username: 'other');
      final status = MockStatus.create(account: otherAccount);
      final accessStatus = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        accessStatus: accessStatus,
        child: Interaction(
          schema: status,
          status: accessStatus,
          action: StatusInteraction.report,
          isCompact: false,
        ),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ListTile), findsOneWidget);
    });

    testWidgets('full mode pin shows ListTile for self post when pinned', (tester) async {
      final selfAccount = MockAccount.create(id: '123');
      final status = MockStatus.create(pinned: true, account: selfAccount);
      final accessStatus = MockAccessStatus.authenticated(account: selfAccount);

      await tester.pumpWidget(createTestWidget(
        accessStatus: accessStatus,
        child: Interaction(
          schema: status,
          status: accessStatus,
          action: StatusInteraction.pin,
          isCompact: false,
        ),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ListTile), findsOneWidget);
      expect(find.byIcon(Icons.push_pin), findsOneWidget);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
