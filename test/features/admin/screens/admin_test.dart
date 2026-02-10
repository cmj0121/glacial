// Widget tests for admin screens: AdminTab, AdminAccountDetail, AdminReportDetail.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  group('AdminTab', () {
    testWidgets('shows no permission when not signed in', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: const Scaffold(body: AdminTab()),
        accessStatus: MockAccessStatus.anonymous(),
      ));
      await tester.pump();

      expect(find.byType(NoResult), findsOneWidget);
    });

    testWidgets('shows no permission when user has no role', (tester) async {
      final account = MockAccount.create();
      final status = MockAccessStatus.authenticated(account: account);

      await tester.pumpWidget(createTestWidgetRaw(
        child: const Scaffold(body: AdminTab()),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.byType(NoResult), findsOneWidget);
    });

    testWidgets('shows no permission when role has no privilege', (tester) async {
      final role = MockRole.create(permissions: '0');
      final account = AccountSchema(
        id: '1',
        username: 'admin',
        acct: 'admin',
        url: 'https://example.com/@admin',
        displayName: 'Admin',
        note: '',
        avatar: 'https://example.com/avatar.png',
        avatarStatic: 'https://example.com/avatar.png',
        header: 'https://example.com/header.png',
        locked: false,
        bot: false,
        indexable: true,
        createdAt: DateTime(2024),
        statusesCount: 0,
        followersCount: 0,
        followingCount: 0,
        role: role,
      );
      final status = MockAccessStatus.authenticated(account: account);

      await tester.pumpWidget(createTestWidgetRaw(
        child: const Scaffold(body: AdminTab()),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.byType(NoResult), findsOneWidget);
    });

    testWidgets('does not show NoResult when user has admin role', (tester) async {
      final role = MockRole.create(permissions: '1'); // administrator
      final account = AccountSchema(
        id: '1',
        username: 'admin',
        acct: 'admin',
        url: 'https://example.com/@admin',
        displayName: 'Admin',
        note: '',
        avatar: 'https://example.com/avatar.png',
        avatarStatic: 'https://example.com/avatar.png',
        header: 'https://example.com/header.png',
        locked: false,
        bot: false,
        indexable: true,
        createdAt: DateTime(2024),
        statusesCount: 0,
        followersCount: 0,
        followingCount: 0,
        role: role,
      );
      final status = MockAccessStatus.authenticated(account: account);

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: AdminTab()),
          accessStatus: status,
        ));
        await tester.pump();
      });

      // With admin role, the tab view should render (not a NoResult)
      expect(find.byType(SwipeTabView), findsOneWidget);
      expect(find.byIcon(Icons.flag), findsOneWidget);
      expect(find.byIcon(Icons.people_outlined), findsOneWidget);
    });
  });

  group('AdminAccountDetail', () {
    testWidgets('renders account detail with email and IP', (tester) async {
      final adminAccount = MockAdminAccount.create(
        email: 'user@example.com',
        ip: '10.0.0.1',
        locale: 'en',
      );

      await tester.pumpWidget(createTestWidget(
        child: AdminAccountDetail(schema: adminAccount),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      expect(find.text('user@example.com'), findsOneWidget);
      expect(find.text('10.0.0.1'), findsOneWidget);
      expect(find.text('en'), findsOneWidget);
    });

    testWidgets('shows approve and reject for pending accounts', (tester) async {
      final adminAccount = MockAdminAccount.pending();

      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(body: AdminAccountDetail(schema: adminAccount)),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      // Should show approve and reject action icons
      expect(find.byIcon(Icons.check_circle), findsWidgets); // approve + confirmed row
      expect(find.byIcon(Icons.cancel), findsOneWidget);     // reject
    });

    testWidgets('shows silence and suspend for active accounts', (tester) async {
      final adminAccount = MockAdminAccount.create();

      await tester.pumpWidget(createTestWidget(
        child: AdminAccountDetail(schema: adminAccount),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.volume_off), findsOneWidget); // silence
      expect(find.byIcon(Icons.block), findsOneWidget);       // suspend
    });

    testWidgets('shows unsuspend for suspended accounts', (tester) async {
      final adminAccount = MockAdminAccount.createSuspended();

      await tester.pumpWidget(createTestWidget(
        child: AdminAccountDetail(schema: adminAccount),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.lock_open), findsOneWidget); // unsuspend
    });

    testWidgets('shows Confirmed/Unconfirmed status', (tester) async {
      final adminAccount = MockAdminAccount.create(confirmed: true);

      await tester.pumpWidget(createTestWidget(
        child: AdminAccountDetail(schema: adminAccount),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      expect(find.text('Confirmed'), findsOneWidget);
    });

    testWidgets('shows Approved/Not approved status', (tester) async {
      final adminAccount = MockAdminAccount.create(approved: true);

      await tester.pumpWidget(createTestWidget(
        child: AdminAccountDetail(schema: adminAccount),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      expect(find.text('Approved'), findsOneWidget);
    });

    testWidgets('shows role name when role is present', (tester) async {
      final role = MockRole.create(name: 'Moderator');
      final adminAccount = MockAdminAccount.create(role: role);

      await tester.pumpWidget(createTestWidget(
        child: AdminAccountDetail(schema: adminAccount),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      expect(find.text('Moderator'), findsOneWidget);
    });

    testWidgets('shows created date', (tester) async {
      final adminAccount = MockAdminAccount.create(
        createdAt: DateTime(2024, 6, 15),
      );

      await tester.pumpWidget(createTestWidget(
        child: AdminAccountDetail(schema: adminAccount),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      expect(find.textContaining('2024-06-15'), findsOneWidget);
    });
  });

  group('AdminReportDetail', () {
    testWidgets('renders report with category and comment', (tester) async {
      final report = MockAdminReport.create(
        category: ReportCategoryType.spam,
        comment: 'Posting spam links',
      );

      await tester.pumpWidget(createTestWidget(
        child: AdminReportDetail(schema: report),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      expect(find.text('Posting spam links'), findsOneWidget);
      expect(find.byIcon(Icons.campaign), findsOneWidget); // spam icon
    });

    testWidgets('shows target account acct', (tester) async {
      final report = MockAdminReport.create(
        targetAccount: MockAccount.create(username: 'badactor'),
      );

      await tester.pumpWidget(createTestWidget(
        child: AdminReportDetail(schema: report),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      expect(find.textContaining('@badactor'), findsWidgets);
    });

    testWidgets('shows resolve action for unresolved reports', (tester) async {
      final report = MockAdminReport.create(actionTaken: false);

      await tester.pumpWidget(createTestWidget(
        child: AdminReportDetail(schema: report),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.done), findsOneWidget); // resolve
    });

    testWidgets('shows reopen action for resolved reports', (tester) async {
      final report = MockAdminReport.resolved();

      await tester.pumpWidget(createTestWidget(
        child: AdminReportDetail(schema: report),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.refresh), findsOneWidget); // reopen
    });

    testWidgets('shows Resolved chip for resolved reports', (tester) async {
      final report = MockAdminReport.resolved();

      await tester.pumpWidget(createTestWidget(
        child: AdminReportDetail(schema: report),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      expect(find.byType(Chip), findsOneWidget);
    });

    testWidgets('shows assign to self for unassigned reports', (tester) async {
      final report = MockAdminReport.create(assignedAccount: null);

      await tester.pumpWidget(createTestWidget(
        child: AdminReportDetail(schema: report),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.person_add), findsOneWidget); // assign to self
    });

    testWidgets('shows unassign for assigned reports', (tester) async {
      final report = MockAdminReport.assigned();

      await tester.pumpWidget(createTestWidget(
        child: AdminReportDetail(schema: report),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.person_remove), findsOneWidget); // unassign
    });

    testWidgets('shows rules when present', (tester) async {
      final report = MockAdminReport.withDetails();

      await tester.pumpWidget(createTestWidget(
        child: AdminReportDetail(schema: report),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      expect(find.text('Be respectful'), findsOneWidget);
      expect(find.text('Treat others with dignity'), findsOneWidget);
    });

    testWidgets('shows reporter info', (tester) async {
      final report = MockAdminReport.create(
        account: MockAccount.create(username: 'whistle_blower'),
      );

      await tester.pumpWidget(createTestWidget(
        child: AdminReportDetail(schema: report),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      expect(find.textContaining('@whistle_blower'), findsOneWidget);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
