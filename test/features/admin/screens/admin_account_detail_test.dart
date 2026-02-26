// Widget tests for AdminAccountDetail.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';
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

    testWidgets('hides email row when email is empty', (tester) async {
      final account = MockAdminAccount.create(email: '');
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminAccountDetail(schema: account),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.byIcon(Icons.email), findsNothing);
    });

    testWidgets('hides IP row when ip is null', (tester) async {
      final account = MockAdminAccount.create(ip: null);
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminAccountDetail(schema: account),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.byIcon(Icons.computer), findsNothing);
    });

    testWidgets('hides locale row when locale is null', (tester) async {
      final account = MockAdminAccount.create(locale: null);
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminAccountDetail(schema: account),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.byIcon(Icons.language), findsNothing);
    });

    testWidgets('hides role row when role is null', (tester) async {
      final account = MockAdminAccount.create(role: null);
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminAccountDetail(schema: account),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.byIcon(Icons.badge), findsNothing);
    });

    testWidgets('action buttons show Silence and Suspend text', (tester) async {
      final account = MockAdminAccount.create();
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminAccountDetail(schema: account),
        accessStatus: status,
      ));
      await tester.pump();

      // Active account should have Silence and Suspend buttons
      expect(find.text('Silence'), findsOneWidget);
      expect(find.text('Suspend'), findsOneWidget);
    });

    testWidgets('shows account widget that is tappable', (tester) async {
      final account = MockAdminAccount.create();
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminAccountDetail(schema: account),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.byType(InkWellDone), findsWidgets);
      expect(find.byType(Account), findsOneWidget);
    });

    testWidgets('actions wrapped in Wrap widget', (tester) async {
      final account = MockAdminAccount.create();
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminAccountDetail(schema: account),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.byType(Wrap), findsOneWidget);
    });

    testWidgets('active account shows silence icon and suspend icon', (tester) async {
      final account = MockAdminAccount.create();
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminAccountDetail(schema: account),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.byIcon(Icons.volume_off), findsOneWidget);
      expect(find.byIcon(Icons.block), findsOneWidget);
    });

    testWidgets('pending account shows approve icon and reject icon', (tester) async {
      final account = MockAdminAccount.pending();
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminAccountDetail(schema: account),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.byIcon(Icons.check_circle), findsWidgets);
      expect(find.byIcon(Icons.cancel), findsOneWidget);
    });

    testWidgets('disabled account shows enable icon', (tester) async {
      final account = MockAdminAccount.createDisabled();
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminAccountDetail(schema: account),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.byIcon(Icons.play_circle), findsOneWidget);
    });

    testWidgets('silenced account shows unsilence and suspend icons', (tester) async {
      final account = MockAdminAccount.createSilenced();
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminAccountDetail(schema: account),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.byIcon(Icons.volume_up), findsOneWidget);
      expect(find.byIcon(Icons.block), findsOneWidget);
    });

    testWidgets('suspended account shows unsuspend icon', (tester) async {
      final account = MockAdminAccount.createSuspended();
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminAccountDetail(schema: account),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.byIcon(Icons.lock_open), findsOneWidget);
    });

    testWidgets('renders in SingleChildScrollView', (tester) async {
      final account = MockAdminAccount.create();
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminAccountDetail(schema: account),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    testWidgets('shows all detail rows for fully populated account', (tester) async {
      final role = MockRole.create(name: 'Admin');
      final account = MockAdminAccount.create(
        email: 'admin@server.com',
        ip: '10.0.0.5',
        locale: 'fr',
        role: role,
        confirmed: true,
        approved: true,
      );
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminAccountDetail(schema: account),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.text('admin@server.com'), findsOneWidget);
      expect(find.text('10.0.0.5'), findsOneWidget);
      expect(find.text('fr'), findsOneWidget);
      expect(find.text('Admin'), findsOneWidget);
      expect(find.text('Confirmed'), findsOneWidget);
      expect(find.text('Approved'), findsOneWidget);
      expect(find.byIcon(Icons.email), findsOneWidget);
      expect(find.byIcon(Icons.computer), findsOneWidget);
      expect(find.byIcon(Icons.language), findsOneWidget);
      expect(find.byIcon(Icons.badge), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsWidgets);
      expect(find.byIcon(Icons.verified), findsOneWidget);
    });

    testWidgets('pending account does not show active/silenced buttons', (tester) async {
      final account = MockAdminAccount.pending();
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminAccountDetail(schema: account),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.text('Approve'), findsOneWidget);
      expect(find.text('Reject'), findsOneWidget);
      expect(find.text('Silence'), findsNothing);
      expect(find.text('Unsuspend'), findsNothing);
    });

    testWidgets('suspended account does not show silence or approve', (tester) async {
      final account = MockAdminAccount.createSuspended();
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminAccountDetail(schema: account),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.text('Unsuspend'), findsOneWidget);
      expect(find.text('Silence'), findsNothing);
      expect(find.text('Approve'), findsNothing);
    });

    testWidgets('tapping non-dangerous action button triggers onAction', (tester) async {
      final account = MockAdminAccount.create();
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminAccountDetail(schema: account),
        accessStatus: status,
      ));
      await tester.pump();

      // Tap the Silence button (non-dangerous — no confirm dialog)
      // This will attempt the API call which fails (no real server), but exercises
      // the _onAction code path including ElevatedButton.icon rendering
      await tester.runAsync(() async {
        await tester.tap(find.text('Silence'));
        await tester.pump();
      });

      // Widget should still be present (API failure doesn't crash the widget)
      expect(find.byType(AdminAccountDetail), findsOneWidget);
    });

    testWidgets('tapping dangerous action button shows confirm dialog', (tester) async {
      final account = MockAdminAccount.create();
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminAccountDetail(schema: account),
        accessStatus: status,
      ));
      await tester.pump();

      // Tap Suspend (dangerous action — should show confirmation dialog)
      await tester.runAsync(() async {
        await tester.tap(find.text('Suspend'));
        await tester.pump();
      });

      // Confirm dialog should appear
      expect(find.text('Confirm Action'), findsOneWidget);
    });

    testWidgets('cancelling confirm dialog does not perform action', (tester) async {
      final account = MockAdminAccount.create();
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminAccountDetail(schema: account),
        accessStatus: status,
      ));
      await tester.pump();

      await tester.runAsync(() async {
        await tester.tap(find.text('Suspend'));
        await tester.pump();
      });

      // Confirm dialog visible
      expect(find.text('Confirm Action'), findsOneWidget);

      // Tap Cancel button
      await tester.runAsync(() async {
        await tester.tap(find.text('Close'));
        await tester.pump();
      });

      // Dialog dismissed, widget still intact with same actions
      expect(find.text('Silence'), findsOneWidget);
      expect(find.text('Suspend'), findsOneWidget);
    });

    testWidgets('tapping reject on pending account shows confirm dialog', (tester) async {
      final account = MockAdminAccount.pending();
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminAccountDetail(schema: account),
        accessStatus: status,
      ));
      await tester.pump();

      await tester.runAsync(() async {
        await tester.tap(find.text('Reject'));
        await tester.pump();
      });

      // Reject is dangerous, so confirm dialog should appear
      expect(find.text('Confirm Action'), findsOneWidget);
    });

    testWidgets('tapping approve on pending account triggers action', (tester) async {
      final account = MockAdminAccount.pending();
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminAccountDetail(schema: account),
        accessStatus: status,
      ));
      await tester.pump();

      // Approve is non-dangerous — directly triggers API call
      await tester.runAsync(() async {
        await tester.tap(find.text('Approve'));
        await tester.pump();
      });

      expect(find.byType(AdminAccountDetail), findsOneWidget);
    });

    testWidgets('tapping enable on disabled account triggers action', (tester) async {
      final account = MockAdminAccount.createDisabled();
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminAccountDetail(schema: account),
        accessStatus: status,
      ));
      await tester.pump();

      await tester.runAsync(() async {
        await tester.tap(find.text('Enable'));
        await tester.pump();
      });

      expect(find.byType(AdminAccountDetail), findsOneWidget);
    });

    testWidgets('tapping unsilence on silenced account triggers action', (tester) async {
      final account = MockAdminAccount.createSilenced();
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminAccountDetail(schema: account),
        accessStatus: status,
      ));
      await tester.pump();

      await tester.runAsync(() async {
        await tester.tap(find.text('Unsilence'));
        await tester.pump();
      });

      expect(find.byType(AdminAccountDetail), findsOneWidget);
    });

    testWidgets('tapping unsuspend on suspended account triggers action', (tester) async {
      final account = MockAdminAccount.createSuspended();
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminAccountDetail(schema: account),
        accessStatus: status,
      ));
      await tester.pump();

      await tester.runAsync(() async {
        await tester.tap(find.text('Unsuspend'));
        await tester.pump();
      });

      expect(find.byType(AdminAccountDetail), findsOneWidget);
    });

    testWidgets('active account actions section has both Silence and Suspend with icons', (tester) async {
      final account = MockAdminAccount.create();
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminAccountDetail(schema: account),
        accessStatus: status,
      ));
      await tester.pump();

      // Both actions should be rendered in the Wrap widget with their icons
      expect(find.text('Silence'), findsOneWidget);
      expect(find.text('Suspend'), findsOneWidget);
      expect(find.byIcon(Icons.volume_off), findsOneWidget);
      expect(find.byIcon(Icons.block), findsOneWidget);
      expect(find.byType(Wrap), findsOneWidget);
    });

    testWidgets('account section is tappable with InkWellDone', (tester) async {
      final account = MockAdminAccount.create();
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AdminAccountDetail(schema: account),
        accessStatus: status,
      ));
      await tester.pump();

      // _buildAccount wraps Account in InkWellDone
      expect(find.byType(InkWellDone), findsWidgets);
    });
  });

  group('AdminAccountSchema', () {
    test('status getter returns active for default account', () {
      final account = MockAdminAccount.create();
      expect(account.status, AdminAccountStatus.active);
    });

    test('status getter returns pending', () {
      final account = MockAdminAccount.pending();
      expect(account.status, AdminAccountStatus.pending);
    });

    test('status getter returns suspended', () {
      final account = MockAdminAccount.createSuspended();
      expect(account.status, AdminAccountStatus.suspended);
    });

    test('status getter returns silenced', () {
      final account = MockAdminAccount.createSilenced();
      expect(account.status, AdminAccountStatus.silenced);
    });

    test('status getter returns disabled', () {
      final account = MockAdminAccount.createDisabled();
      expect(account.status, AdminAccountStatus.disabled);
    });

    test('remote account has non-null domain', () {
      final account = MockAdminAccount.remote();
      expect(account.domain, 'remote.social');
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
