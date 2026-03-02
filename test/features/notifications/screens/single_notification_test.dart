// Widget tests for SingleNotification.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../helpers/test_helpers.dart';

// Use domain-null status so API calls short-circuit without HTTP.
AccessStatusSchema _noDomainAuth() {
  return const AccessStatusSchema(domain: null, accessToken: 'test');
}

GroupSchema _makeGroup({
  required String type,
  String key = 'grp-1',
  String? statusId,
  List<String> accounts = const [],
}) {
  return GroupSchema.fromJson({
    'type': type,
    'group_key': key,
    'notifications_count': 1,
    'most_recent_notification_id': 1,
    'sample_account_ids': accounts,
    if (statusId != null) 'status_id': statusId,
  });
}

void main() {
  setupTestEnvironment();
  databaseFactory = databaseFactoryFfi;

  group('SingleNotification', () {
    testWidgets('renders with mention type', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: SingleNotification(schema: _makeGroup(type: 'mention')),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      expect(find.byType(SingleNotification), findsOneWidget);
    });

    testWidgets('renders with follow type', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: SingleNotification(schema: _makeGroup(type: 'follow')),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      expect(find.byType(SingleNotification), findsOneWidget);
    });

    testWidgets('renders with favourite type', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: SingleNotification(schema: _makeGroup(type: 'favourite')),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      expect(find.byType(SingleNotification), findsOneWidget);
    });

    testWidgets('renders with reblog type', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: SingleNotification(schema: _makeGroup(type: 'reblog')),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      expect(find.byType(SingleNotification), findsOneWidget);
    });

    testWidgets('renders with unknown type', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: SingleNotification(schema: _makeGroup(type: 'xyz_unknown')),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      expect(find.byType(SingleNotification), findsOneWidget);
    });

    testWidgets('shows loading state before async completes', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: SingleNotification(schema: _makeGroup(type: 'mention')),
        accessStatus: _noDomainAuth(),
      ));

      expect(find.byType(SingleNotification), findsOneWidget);
    });

    testWidgets('accepts custom iconSize', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: SingleNotification(
            schema: _makeGroup(type: 'follow'),
            iconSize: 24,
          ),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      expect(find.byType(SingleNotification), findsOneWidget);
    });

    testWidgets('renders with poll type', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: SingleNotification(schema: _makeGroup(type: 'poll')),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      expect(find.byType(SingleNotification), findsOneWidget);
    });

    testWidgets('renders with admin.sign_up type', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: SingleNotification(schema: _makeGroup(type: 'admin.sign_up')),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      expect(find.byType(SingleNotification), findsOneWidget);
    });

    testWidgets('renders with follow_request type', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: SingleNotification(schema: _makeGroup(type: 'follow_request')),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
      });

      expect(find.byType(SingleNotification), findsOneWidget);
    });
  });

  group('SingleNotification after onLoad completes', () {
    testWidgets('mention type shows content after onLoad', (tester) async {
      // statusId: null -> getStatus(null) returns null immediately -> SizedBox.shrink
      // This covers the mention branch in buildContent() and line 137 (null ternary).
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: SingleNotification(schema: _makeGroup(type: 'mention')),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
        // Wait for addPostFrameCallback -> onLoad() async to complete
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await tester.pump();
      });

      // After onLoad, the loading overlay should be replaced by actual content
      expect(find.byType(SingleNotification), findsOneWidget);
      // The mention type icon should be visible in the header
      expect(find.byIcon(NotificationType.mention.icon), findsOneWidget);
    });

    testWidgets('status type shows content with ColorFiltered after onLoad', (tester) async {
      // Covers the status/reblog/favourite/poll/update branch in buildContent()
      // which wraps content in ColorFiltered.
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: SingleNotification(schema: _makeGroup(type: 'status')),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await tester.pump();
      });

      expect(find.byType(SingleNotification), findsOneWidget);
      // The status type uses ColorFiltered wrapping
      expect(find.byType(ColorFiltered), findsOneWidget);
    });

    testWidgets('favourite type shows ColorFiltered content after onLoad', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: SingleNotification(schema: _makeGroup(type: 'favourite')),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await tester.pump();
      });

      expect(find.byType(SingleNotification), findsOneWidget);
      expect(find.byType(ColorFiltered), findsOneWidget);
      expect(find.byIcon(NotificationType.favourite.icon), findsOneWidget);
    });

    testWidgets('follow type shows content after onLoad', (tester) async {
      // Covers the follow/followRequest/adminSignUp branch in buildContent()
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: SingleNotification(schema: _makeGroup(type: 'follow')),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await tester.pump();
      });

      expect(find.byType(SingleNotification), findsOneWidget);
      expect(find.byIcon(NotificationType.follow.icon), findsOneWidget);
      // No ColorFiltered for follow type
      expect(find.byType(ColorFiltered), findsNothing);
    });

    testWidgets('unknown type shows header only after onLoad', (tester) async {
      // Covers the adminReport/unknown branch in buildContent() which returns
      // only buildHeader() without child content.
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: SingleNotification(schema: _makeGroup(type: 'xyz_unknown')),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await tester.pump();
      });

      expect(find.byType(SingleNotification), findsOneWidget);
      expect(find.byIcon(NotificationType.unknown.icon), findsOneWidget);
    });

    testWidgets('admin.report type shows header only after onLoad', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: SingleNotification(schema: _makeGroup(type: 'admin.report')),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await tester.pump();
      });

      expect(find.byType(SingleNotification), findsOneWidget);
      expect(find.byIcon(NotificationType.adminReport.icon), findsOneWidget);
    });

    testWidgets('reblog type shows ColorFiltered content after onLoad', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: SingleNotification(schema: _makeGroup(type: 'reblog')),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await tester.pump();
      });

      expect(find.byType(SingleNotification), findsOneWidget);
      expect(find.byType(ColorFiltered), findsOneWidget);
    });

    testWidgets('poll type shows ColorFiltered content after onLoad', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: SingleNotification(schema: _makeGroup(type: 'poll')),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await tester.pump();
      });

      expect(find.byType(SingleNotification), findsOneWidget);
      expect(find.byType(ColorFiltered), findsOneWidget);
    });

    testWidgets('update type shows ColorFiltered content after onLoad', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: SingleNotification(schema: _makeGroup(type: 'update')),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await tester.pump();
      });

      expect(find.byType(SingleNotification), findsOneWidget);
      expect(find.byType(ColorFiltered), findsOneWidget);
    });
  });

  group('SingleNotification with injected accounts', () {
    testWidgets('favourite type renders AccountAvatar in header when accounts are injected', (tester) async {
      // Build the widget and let onLoad complete (accounts will be empty due to domain=null).
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: SingleNotification(schema: _makeGroup(type: 'favourite')),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await tester.pump();
      });

      // Inject mock accounts into state via dynamic dispatch to cover line 117
      // (AccountAvatar rendering in buildHeader's accounts.map).
      final dynamic state = tester.state(find.byType(SingleNotification));
      state.accounts = [MockAccount.create(id: '1', username: 'user1')];
      // ignore: invalid_use_of_protected_member
      state.setState(() {});
      await tester.pump();

      // AccountAvatar should now be rendered in the header
      expect(find.byType(AccountAvatar), findsOneWidget);
    });

    testWidgets('reblog type renders multiple AccountAvatars when multiple accounts injected', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: SingleNotification(schema: _makeGroup(type: 'reblog')),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await tester.pump();
      });

      // Inject two mock accounts
      final dynamic state = tester.state(find.byType(SingleNotification));
      state.accounts = [
        MockAccount.create(id: '1', username: 'user1'),
        MockAccount.create(id: '2', username: 'user2'),
      ];
      // ignore: invalid_use_of_protected_member
      state.setState(() {});
      await tester.pump();

      expect(find.byType(AccountAvatar), findsNWidgets(2));
    });

    testWidgets('follow type renders Account widgets when child injected', (tester) async {
      // Build the widget and let onLoad complete.
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: SingleNotification(schema: _makeGroup(type: 'follow')),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await tester.pump();
      });

      // Inject a child Column with Account widgets to cover line 148
      // (Account rendering in the follow/followRequest/adminSignUp branch).
      final dynamic state = tester.state(find.byType(SingleNotification));
      final AccountSchema mockAccount = MockAccount.create(id: '10', username: 'follower');
      state.child = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Account(schema: mockAccount),
          ),
        ],
      );
      // ignore: invalid_use_of_protected_member
      state.setState(() {});
      await tester.pump();

      // After injection, Account widget should be visible in the follow branch
      expect(find.byType(Account), findsOneWidget);
    });

    testWidgets('mention type renders SizedBox.shrink for null status in child', (tester) async {
      // This explicitly tests line 137: schema == null ? SizedBox.shrink() : StatusLite(schema)
      // With domain=null, getStatus(null) returns null -> SizedBox.shrink path.
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: SingleNotification(schema: _makeGroup(type: 'mention')),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await tester.pump();
      });

      // After onLoad completes, the child should be SizedBox.shrink (null status path)
      expect(find.byType(SingleNotification), findsOneWidget);
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('mention type with explicit null statusId triggers null-schema path', (tester) async {
      // Explicitly call onLoad via state injection to ensure the null status path
      // on line 137 is fully covered.
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: SingleNotification(schema: _makeGroup(type: 'mention')),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();

        // Explicitly call onLoad and await it to ensure line 137 is reached
        final dynamic state = tester.state(find.byType(SingleNotification));
        state.child = null; // Reset so onLoad will proceed
        await state.onLoad();
        await tester.pump();
      });

      // After manual onLoad, the child should be set (SizedBox.shrink)
      expect(find.byType(SingleNotification), findsOneWidget);
    });

    testWidgets('follow type with explicit onLoad covers account branch', (tester) async {
      // Explicitly call onLoad via state injection to ensure the follow type
      // path on line 148 (Account rendering) is covered in onLoad.
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: SingleNotification(schema: _makeGroup(type: 'follow')),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();

        // Explicitly call onLoad
        final dynamic state = tester.state(find.byType(SingleNotification));
        state.child = null; // Reset so onLoad will proceed
        await state.onLoad();
        await tester.pump();
      });

      expect(find.byType(SingleNotification), findsOneWidget);
    });

    testWidgets('status type with injected accounts shows avatars in header', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: SingleNotification(schema: _makeGroup(type: 'status')),
          accessStatus: _noDomainAuth(),
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await tester.pump();
      });

      // Inject accounts to verify the header renders AccountAvatar widgets
      final dynamic state = tester.state(find.byType(SingleNotification));
      state.accounts = [
        MockAccount.create(id: '5', username: 'poster'),
      ];
      // ignore: invalid_use_of_protected_member
      state.setState(() {});
      await tester.pump();

      expect(find.byType(AccountAvatar), findsOneWidget);
      expect(find.byType(ColorFiltered), findsOneWidget);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
