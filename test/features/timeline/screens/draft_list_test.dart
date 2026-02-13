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
