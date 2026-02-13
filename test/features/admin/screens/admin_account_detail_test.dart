// Widget tests for AdminAccountDetail.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  group('AdminAccountDetail', () {
    testWidgets('renders with active account', (tester) async {
      final account = MockAdminAccount.create();
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminAccountDetail(schema: account),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.byType(AdminAccountDetail), findsOneWidget);
    });

    testWidgets('shows email detail row', (tester) async {
      final account = MockAdminAccount.create(email: 'user@example.com');
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminAccountDetail(schema: account),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.text('user@example.com'), findsOneWidget);
      expect(find.byIcon(Icons.email), findsOneWidget);
    });

    testWidgets('shows IP address when present', (tester) async {
      final account = MockAdminAccount.create(ip: '10.0.0.1');
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminAccountDetail(schema: account),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.text('10.0.0.1'), findsOneWidget);
      expect(find.byIcon(Icons.computer), findsOneWidget);
    });

    testWidgets('shows locale when present', (tester) async {
      final account = MockAdminAccount.create(locale: 'ja');
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminAccountDetail(schema: account),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.text('ja'), findsOneWidget);
      expect(find.byIcon(Icons.language), findsOneWidget);
    });

    testWidgets('shows confirmed status for confirmed account', (tester) async {
      final account = MockAdminAccount.create(confirmed: true);
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminAccountDetail(schema: account),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.text('Confirmed'), findsOneWidget);
    });

    testWidgets('shows unconfirmed status for unconfirmed account', (tester) async {
      final account = MockAdminAccount.create(confirmed: false);
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminAccountDetail(schema: account),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.text('Unconfirmed'), findsOneWidget);
    });

    testWidgets('shows approved status for approved account', (tester) async {
      final account = MockAdminAccount.create(approved: true);
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminAccountDetail(schema: account),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.text('Approved'), findsOneWidget);
    });

    testWidgets('shows not-approved status for unapproved account', (tester) async {
      final account = MockAdminAccount.create(approved: false);
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminAccountDetail(schema: account),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.text('Not approved'), findsOneWidget);
    });

    testWidgets('shows role name when present', (tester) async {
      final role = MockRole.create(name: 'Moderator');
      final account = MockAdminAccount.create(role: role);
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminAccountDetail(schema: account),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.text('Moderator'), findsOneWidget);
      expect(find.byIcon(Icons.badge), findsOneWidget);
    });

    testWidgets('shows approve/reject for pending account', (tester) async {
      final account = MockAdminAccount.pending();
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminAccountDetail(schema: account),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.text('Approve'), findsOneWidget);
      expect(find.text('Reject'), findsOneWidget);
    });

    testWidgets('shows silence/suspend for active account', (tester) async {
      final account = MockAdminAccount.create();
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminAccountDetail(schema: account),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.text('Silence'), findsOneWidget);
      expect(find.text('Suspend'), findsOneWidget);
    });

    testWidgets('shows enable for disabled account', (tester) async {
      final account = MockAdminAccount.createDisabled();
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminAccountDetail(schema: account),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.text('Enable'), findsOneWidget);
    });

    testWidgets('shows unsilence/suspend for silenced account', (tester) async {
      final account = MockAdminAccount.createSilenced();
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminAccountDetail(schema: account),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.text('Unsilence'), findsOneWidget);
      expect(find.text('Suspend'), findsOneWidget);
    });

    testWidgets('shows unsuspend for suspended account', (tester) async {
      final account = MockAdminAccount.createSuspended();
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminAccountDetail(schema: account),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.text('Unsuspend'), findsOneWidget);
    });

    testWidgets('shows creation date', (tester) async {
      final account = MockAdminAccount.create(createdAt: DateTime(2024, 6, 15));
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminAccountDetail(schema: account),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.text('2024-06-15'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('renders with dividers', (tester) async {
      final account = MockAdminAccount.create();
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminAccountDetail(schema: account),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.byType(Divider), findsAtLeastNWidgets(2));
    });

  });
}

// vim: set ts=2 sw=2 sts=2 et:
