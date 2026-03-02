// Widget tests for DraftListSheet.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:glacial/cores/storage.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await Storage.init();
  });

  group('DraftListSheet', () {
    testWidgets('renders title', (tester) async {
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: DraftListSheet(status: status),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.byType(DraftListSheet), findsOneWidget);
    });

    testWidgets('shows empty state when no drafts', (tester) async {
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: DraftListSheet(status: status),
        accessStatus: status,
      ));
      await tester.pump();
      await tester.pump();

      expect(find.byType(DraftListSheet), findsOneWidget);
    });

    testWidgets('renders draft items when drafts exist', (tester) async {
      final account = MockAccount.create(id: '12345');
      final status = MockAccessStatus.authenticated(account: account);
      final storage = Storage();

      await storage.saveDraft('mastodon.social@12345', DraftSchema(
        id: 'draft-1',
        content: 'My draft content here',
        updatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ));

      await tester.pumpWidget(createTestWidget(
        child: DraftListSheet(status: status),
        accessStatus: status,
      ));
      await tester.pump();
      await tester.pump();

      expect(find.text('My draft content here'), findsOneWidget);
    });

    testWidgets('shows reply icon for reply drafts', (tester) async {
      final account = MockAccount.create(id: '12345');
      final status = MockAccessStatus.authenticated(account: account);
      final storage = Storage();

      await storage.saveDraft('mastodon.social@12345', DraftSchema(
        id: 'draft-reply',
        content: 'Reply content',
        inReplyToId: 'status-99',
        updatedAt: DateTime.now(),
      ));

      await tester.pumpWidget(createTestWidget(
        child: DraftListSheet(status: status),
        accessStatus: status,
      ));
      await tester.pump();
      await tester.pump();

      expect(find.byIcon(Icons.reply), findsOneWidget);
    });

    testWidgets('shows edit_note icon for regular drafts', (tester) async {
      final account = MockAccount.create(id: '12345');
      final status = MockAccessStatus.authenticated(account: account);
      final storage = Storage();

      await storage.saveDraft('mastodon.social@12345', DraftSchema(
        id: 'draft-regular',
        content: 'Regular post',
        updatedAt: DateTime.now(),
      ));

      await tester.pumpWidget(createTestWidget(
        child: DraftListSheet(status: status),
        accessStatus: status,
      ));
      await tester.pump();
      await tester.pump();

      expect(find.byIcon(Icons.edit_note), findsAtLeastNWidgets(1));
    });

    testWidgets('shows poll indicator for drafts with poll', (tester) async {
      final account = MockAccount.create(id: '12345');
      final status = MockAccessStatus.authenticated(account: account);
      final storage = Storage();

      await storage.saveDraft('mastodon.social@12345', DraftSchema(
        id: 'draft-poll',
        content: 'Poll question',
        poll: NewPollSchema(options: ['A', 'B']),
        updatedAt: DateTime.now(),
      ));

      await tester.pumpWidget(createTestWidget(
        child: DraftListSheet(status: status),
        accessStatus: status,
      ));
      await tester.pump();
      await tester.pump();

      expect(find.byIcon(Icons.poll), findsOneWidget);
    });

    testWidgets('truncates long content preview', (tester) async {
      final account = MockAccount.create(id: '12345');
      final status = MockAccessStatus.authenticated(account: account);
      final storage = Storage();

      final longContent = 'A' * 100;
      await storage.saveDraft('mastodon.social@12345', DraftSchema(
        id: 'draft-long',
        content: longContent,
        updatedAt: DateTime.now(),
      ));

      await tester.pumpWidget(createTestWidget(
        child: DraftListSheet(status: status),
        accessStatus: status,
      ));
      await tester.pump();
      await tester.pump();

      // Should show truncated content (80 chars + ...)
      expect(find.textContaining('${'A' * 80}...'), findsOneWidget);
    });

    testWidgets('renders with null status gracefully', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: DraftListSheet(status: null),
        accessStatus: MockAccessStatus.anonymous(),
      ));
      await tester.pump();
      await tester.pump();

      expect(find.byType(DraftListSheet), findsOneWidget);
    });

    testWidgets('shows quote indicator for drafts with quoteToId', (tester) async {
      final account = MockAccount.create(id: '12345');
      final status = MockAccessStatus.authenticated(account: account);
      final storage = Storage();

      await storage.saveDraft('mastodon.social@12345', DraftSchema(
        id: 'draft-quote',
        content: 'Quote post',
        quoteToId: 'status-42',
        updatedAt: DateTime.now(),
      ));

      await tester.pumpWidget(createTestWidget(
        child: DraftListSheet(status: status),
        accessStatus: status,
      ));
      await tester.pump();
      await tester.pump();

      expect(find.byIcon(Icons.format_quote), findsOneWidget);
    });

    testWidgets('shows chevron trailing icon on draft tile', (tester) async {
      final account = MockAccount.create(id: '12345');
      final status = MockAccessStatus.authenticated(account: account);
      final storage = Storage();

      await storage.saveDraft('mastodon.social@12345', DraftSchema(
        id: 'draft-chevron',
        content: 'Some draft content',
        updatedAt: DateTime.now(),
      ));

      await tester.pumpWidget(createTestWidget(
        child: DraftListSheet(status: status),
        accessStatus: status,
      ));
      await tester.pump();
      await tester.pump();

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('uses spoiler as fallback when content is empty', (tester) async {
      final account = MockAccount.create(id: '12345');
      final status = MockAccessStatus.authenticated(account: account);
      final storage = Storage();

      await storage.saveDraft('mastodon.social@12345', DraftSchema(
        id: 'draft-spoiler',
        content: '',
        spoiler: 'Content Warning',
        updatedAt: DateTime.now(),
      ));

      await tester.pumpWidget(createTestWidget(
        child: DraftListSheet(status: status),
        accessStatus: status,
      ));
      await tester.pump();
      await tester.pump();

      expect(find.text('Content Warning'), findsOneWidget);
    });

    testWidgets('draft tile has onTap callback for navigation', (tester) async {
      final account = MockAccount.create(id: '12345');
      final status = MockAccessStatus.authenticated(account: account);
      final storage = Storage();

      await storage.saveDraft('mastodon.social@12345', DraftSchema(
        id: 'draft-nav',
        content: 'Navigate draft',
        updatedAt: DateTime.now(),
      ));

      await tester.pumpWidget(createTestWidget(
        child: DraftListSheet(status: status),
        accessStatus: status,
      ));
      await tester.pump();
      await tester.pump();

      // Verify the ListTile with draft content has an onTap callback
      final listTiles = tester.widgetList<ListTile>(find.byType(ListTile));
      final draftTile = listTiles.firstWhere((tile) => tile.onTap != null);
      expect(draftTile.onTap, isNotNull);
    });

    testWidgets('swiping draft removes it from list', (tester) async {
      final account = MockAccount.create(id: '12345');
      final status = MockAccessStatus.authenticated(account: account);
      final storage = Storage();

      await storage.saveDraft('mastodon.social@12345', DraftSchema(
        id: 'draft-swipe1',
        content: 'First draft to keep',
        updatedAt: DateTime.now().subtract(const Duration(minutes: 10)),
      ));
      await storage.saveDraft('mastodon.social@12345', DraftSchema(
        id: 'draft-swipe2',
        content: 'Second draft to remove',
        updatedAt: DateTime.now(),
      ));

      await tester.pumpWidget(createTestWidget(
        child: DraftListSheet(status: status),
        accessStatus: status,
      ));
      await tester.pump();
      await tester.pump();

      expect(find.text('Second draft to remove'), findsOneWidget);

      // Swipe to dismiss
      await tester.drag(find.text('Second draft to remove'), const Offset(-500, 0));
      await tester.pumpAndSettle();

      // Should be removed from the list
      expect(find.text('Second draft to remove'), findsNothing);
      expect(find.text('First draft to keep'), findsOneWidget);

      // Flush the 5-second timers from onRemoveDraft (SnackBar timer + storage delay).
      await tester.pump(const Duration(seconds: 6));
    });

    testWidgets('renders multiple drafts', (tester) async {
      final account = MockAccount.create(id: '12345');
      final status = MockAccessStatus.authenticated(account: account);
      final storage = Storage();

      await storage.saveDraft('mastodon.social@12345', DraftSchema(
        id: 'draft-1',
        content: 'First draft',
        updatedAt: DateTime.now().subtract(const Duration(minutes: 10)),
      ));
      await storage.saveDraft('mastodon.social@12345', DraftSchema(
        id: 'draft-2',
        content: 'Second draft',
        updatedAt: DateTime.now(),
      ));

      await tester.pumpWidget(createTestWidget(
        child: DraftListSheet(status: status),
        accessStatus: status,
      ));
      await tester.pump();
      await tester.pump();

      expect(find.text('First draft'), findsOneWidget);
      expect(find.text('Second draft'), findsOneWidget);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
