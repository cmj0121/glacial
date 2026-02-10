// Unit tests for admin models: AdminTabType, AdminActionType, AdminAccountSchema,
// AdminReportSchema, AdminIpSchema.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/features/models.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  group('AdminTabType', () {
    test('has correct number of values', () {
      expect(AdminTabType.values.length, 2);
    });

    test('reports icon returns flag icons', () {
      expect(AdminTabType.reports.icon(), Icons.flag_outlined);
      expect(AdminTabType.reports.icon(active: true), Icons.flag);
    });

    test('accounts icon returns people icons', () {
      expect(AdminTabType.accounts.icon(), Icons.people_outlined);
      expect(AdminTabType.accounts.icon(active: true), Icons.people);
    });

    testWidgets('reports tooltip returns localized text', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(createTestWidget(
        child: Builder(builder: (context) {
          capturedContext = context;
          return const SizedBox.shrink();
        }),
      ));
      await tester.pump();
      expect(AdminTabType.reports.tooltip(capturedContext), isNotEmpty);
    });

    testWidgets('accounts tooltip returns localized text', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(createTestWidget(
        child: Builder(builder: (context) {
          capturedContext = context;
          return const SizedBox.shrink();
        }),
      ));
      await tester.pump();
      expect(AdminTabType.accounts.tooltip(capturedContext), isNotEmpty);
    });
  });

  group('AdminActionType', () {
    test('has correct number of values', () {
      expect(AdminActionType.values.length, 12);
    });

    test('each action has an icon', () {
      for (final action in AdminActionType.values) {
        expect(action.icon, isA<IconData>());
      }
    });

    test('specific icons are correct', () {
      expect(AdminActionType.approve.icon, Icons.check_circle);
      expect(AdminActionType.reject.icon, Icons.cancel);
      expect(AdminActionType.suspend.icon, Icons.block);
      expect(AdminActionType.silence.icon, Icons.volume_off);
      expect(AdminActionType.enable.icon, Icons.play_circle);
      expect(AdminActionType.unsilence.icon, Icons.volume_up);
      expect(AdminActionType.unsuspend.icon, Icons.lock_open);
      expect(AdminActionType.unsensitive.icon, Icons.visibility);
      expect(AdminActionType.assignToSelf.icon, Icons.person_add);
      expect(AdminActionType.unassign.icon, Icons.person_remove);
      expect(AdminActionType.resolve.icon, Icons.done);
      expect(AdminActionType.reopen.icon, Icons.refresh);
    });

    test('isDangerous returns true for reject and suspend', () {
      expect(AdminActionType.reject.isDangerous, isTrue);
      expect(AdminActionType.suspend.isDangerous, isTrue);
    });

    test('isDangerous returns false for non-dangerous actions', () {
      expect(AdminActionType.approve.isDangerous, isFalse);
      expect(AdminActionType.silence.isDangerous, isFalse);
      expect(AdminActionType.enable.isDangerous, isFalse);
      expect(AdminActionType.resolve.isDangerous, isFalse);
      expect(AdminActionType.reopen.isDangerous, isFalse);
      expect(AdminActionType.assignToSelf.isDangerous, isFalse);
      expect(AdminActionType.unassign.isDangerous, isFalse);
    });

    testWidgets('all actions have localized labels', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(createTestWidget(
        child: Builder(builder: (context) {
          capturedContext = context;
          return const SizedBox.shrink();
        }),
      ));
      await tester.pump();

      for (final action in AdminActionType.values) {
        expect(action.label(capturedContext), isNotEmpty);
      }
    });
  });

  group('AdminAccountOrigin', () {
    test('has local and remote values', () {
      expect(AdminAccountOrigin.values, containsAll([AdminAccountOrigin.local, AdminAccountOrigin.remote]));
    });
  });

  group('AdminAccountStatus', () {
    test('has all 5 status values', () {
      expect(AdminAccountStatus.values.length, 5);
      expect(AdminAccountStatus.values, containsAll([
        AdminAccountStatus.active,
        AdminAccountStatus.pending,
        AdminAccountStatus.disabled,
        AdminAccountStatus.silenced,
        AdminAccountStatus.suspended,
      ]));
    });
  });

  group('AdminAccountSchema', () {
    test('creates with required fields', () {
      final account = MockAdminAccount.create();
      expect(account.id, 'admin-acc-1');
      expect(account.username, 'testuser');
      expect(account.email, 'test@example.com');
      expect(account.confirmed, isTrue);
      expect(account.approved, isTrue);
    });

    test('status returns active for approved confirmed account', () {
      final account = MockAdminAccount.create();
      expect(account.status, AdminAccountStatus.active);
    });

    test('status returns pending for unapproved account', () {
      final account = MockAdminAccount.pending();
      expect(account.status, AdminAccountStatus.pending);
    });

    test('status returns suspended for suspended account', () {
      final account = MockAdminAccount.createSuspended();
      expect(account.status, AdminAccountStatus.suspended);
    });

    test('status returns silenced for silenced account', () {
      final account = MockAdminAccount.createSilenced();
      expect(account.status, AdminAccountStatus.silenced);
    });

    test('status returns disabled for disabled account', () {
      final account = MockAdminAccount.createDisabled();
      expect(account.status, AdminAccountStatus.disabled);
    });

    test('isLocal returns true when domain is null', () {
      final account = MockAdminAccount.create();
      expect(account.isLocal, isTrue);
    });

    test('isLocal returns false when domain is set', () {
      final account = MockAdminAccount.remote();
      expect(account.isLocal, isFalse);
    });

    test('fromJson parses admin account correctly', () {
      final Map<String, dynamic> json = {
        'id': '42',
        'username': 'admin_user',
        'domain': null,
        'created_at': '2024-01-01T00:00:00.000Z',
        'email': 'admin@example.com',
        'ip': '10.0.0.1',
        'locale': 'en',
        'confirmed': true,
        'approved': true,
        'disabled': false,
        'silenced': false,
        'suspended': false,
        'account': {
          'id': '42',
          'username': 'admin_user',
          'acct': 'admin_user',
          'url': 'https://example.com/@admin_user',
          'display_name': 'Admin User',
          'note': '',
          'avatar': 'https://example.com/avatar.png',
          'avatar_static': 'https://example.com/avatar.png',
          'header': 'https://example.com/header.png',
          'locked': false,
          'bot': false,
          'indexable': true,
          'created_at': '2024-01-01T00:00:00.000Z',
          'statuses_count': 10,
          'followers_count': 5,
          'following_count': 3,
        },
        'ips': [
          {'ip': '10.0.0.1', 'used_at': '2024-06-01T12:00:00.000Z'},
        ],
      };

      final account = AdminAccountSchema.fromJson(json);
      expect(account.id, '42');
      expect(account.username, 'admin_user');
      expect(account.email, 'admin@example.com');
      expect(account.ip, '10.0.0.1');
      expect(account.locale, 'en');
      expect(account.confirmed, isTrue);
      expect(account.approved, isTrue);
      expect(account.ips.length, 1);
      expect(account.ips.first.ip, '10.0.0.1');
    });

    test('fromString parses JSON string correctly', () {
      final Map<String, dynamic> json = {
        'id': '99',
        'username': 'struser',
        'created_at': '2024-03-01T00:00:00.000Z',
        'confirmed': true,
        'approved': true,
        'disabled': false,
        'silenced': false,
        'suspended': false,
        'account': {
          'id': '99',
          'username': 'struser',
          'acct': 'struser',
          'url': 'https://example.com/@struser',
          'display_name': 'String User',
          'note': '',
          'avatar': 'https://example.com/avatar.png',
          'avatar_static': 'https://example.com/avatar.png',
          'header': 'https://example.com/header.png',
          'locked': false,
          'bot': false,
          'indexable': true,
          'created_at': '2024-03-01T00:00:00.000Z',
          'statuses_count': 0,
          'followers_count': 0,
          'following_count': 0,
        },
      };
      final account = AdminAccountSchema.fromString(jsonEncode(json));
      expect(account.id, '99');
      expect(account.username, 'struser');
    });

    test('status priority: suspended > silenced > disabled > pending > active', () {
      // Suspended takes priority even if also silenced
      final account = AdminAccountSchema(
        id: '1',
        username: 'test',
        createdAt: DateTime(2024),
        confirmed: true,
        approved: true,
        disabled: true,
        silenced: true,
        suspended: true,
        account: MockAccount.create(),
      );
      expect(account.status, AdminAccountStatus.suspended);
    });

    test('fromJson handles optional role', () {
      final Map<String, dynamic> json = {
        'id': '1',
        'username': 'test',
        'created_at': '2024-01-01T00:00:00.000Z',
        'confirmed': true,
        'approved': true,
        'disabled': false,
        'silenced': false,
        'suspended': false,
        'role': {
          'id': 'role-1',
          'name': 'Moderator',
          'color': '#00ff00',
          'permissions': '16',
          'highlighted': true,
        },
        'account': {
          'id': '1',
          'username': 'test',
          'acct': 'test',
          'url': 'https://example.com/@test',
          'display_name': 'Test',
          'note': '',
          'avatar': 'https://example.com/avatar.png',
          'avatar_static': 'https://example.com/avatar.png',
          'header': 'https://example.com/header.png',
          'locked': false,
          'bot': false,
          'indexable': true,
          'created_at': '2024-01-01T00:00:00.000Z',
          'statuses_count': 0,
          'followers_count': 0,
          'following_count': 0,
        },
      };
      final account = AdminAccountSchema.fromJson(json);
      expect(account.role, isNotNull);
      expect(account.role!.name, 'Moderator');
    });
  });

  group('AdminIpSchema', () {
    test('fromJson parses correctly', () {
      final ip = AdminIpSchema.fromJson({
        'ip': '192.168.1.100',
        'used_at': '2024-06-15T14:30:00.000Z',
      });
      expect(ip.ip, '192.168.1.100');
      expect(ip.usedAt.year, 2024);
      expect(ip.usedAt.month, 6);
    });
  });

  group('AdminReportSchema', () {
    test('creates with default values', () {
      final report = MockAdminReport.create();
      expect(report.id, 'report-1');
      expect(report.actionTaken, isFalse);
      expect(report.category, ReportCategoryType.spam);
      expect(report.comment, 'This is spam content');
      expect(report.forwarded, isFalse);
    });

    test('resolved factory creates resolved report', () {
      final report = MockAdminReport.resolved();
      expect(report.actionTaken, isTrue);
      expect(report.actionTakenAt, isNotNull);
      expect(report.actionTakenByAccount, isNotNull);
    });

    test('assigned factory creates assigned report', () {
      final report = MockAdminReport.assigned();
      expect(report.assignedAccount, isNotNull);
      expect(report.assignedAccount!.username, 'moderator');
    });

    test('withDetails factory creates report with statuses and rules', () {
      final report = MockAdminReport.withDetails();
      expect(report.category, ReportCategoryType.violation);
      expect(report.statuses.length, 1);
      expect(report.rules.length, 1);
      expect(report.rules.first.text, 'Be respectful');
    });

    test('fromJson parses admin report correctly', () {
      final Map<String, dynamic> accountJson = {
        'id': 'acc-1',
        'username': 'user1',
        'acct': 'user1',
        'url': 'https://example.com/@user1',
        'display_name': 'User One',
        'note': '',
        'avatar': 'https://example.com/avatar.png',
        'avatar_static': 'https://example.com/avatar.png',
        'header': 'https://example.com/header.png',
        'locked': false,
        'bot': false,
        'indexable': true,
        'created_at': '2024-01-01T00:00:00.000Z',
        'statuses_count': 0,
        'followers_count': 0,
        'following_count': 0,
      };

      final Map<String, dynamic> json = {
        'id': 'rpt-42',
        'action_taken': false,
        'category': 'spam',
        'comment': 'Posting ads',
        'forwarded': true,
        'created_at': '2024-02-15T10:00:00.000Z',
        'account': accountJson,
        'target_account': {
          ...accountJson,
          'id': 'acc-2',
          'username': 'spammer',
          'acct': 'spammer',
        },
        'statuses': [],
        'rules': [],
      };

      final report = AdminReportSchema.fromJson(json);
      expect(report.id, 'rpt-42');
      expect(report.actionTaken, isFalse);
      expect(report.category, ReportCategoryType.spam);
      expect(report.comment, 'Posting ads');
      expect(report.forwarded, isTrue);
      expect(report.account.username, 'user1');
      expect(report.targetAccount.username, 'spammer');
    });

    test('fromString parses JSON string correctly', () {
      final Map<String, dynamic> accountJson = {
        'id': 'acc-1',
        'username': 'user1',
        'acct': 'user1',
        'url': 'https://example.com/@user1',
        'display_name': 'User One',
        'note': '',
        'avatar': 'https://example.com/avatar.png',
        'avatar_static': 'https://example.com/avatar.png',
        'header': 'https://example.com/header.png',
        'locked': false,
        'bot': false,
        'indexable': true,
        'created_at': '2024-01-01T00:00:00.000Z',
        'statuses_count': 0,
        'followers_count': 0,
        'following_count': 0,
      };

      final String jsonStr = jsonEncode({
        'id': 'rpt-str',
        'action_taken': true,
        'action_taken_at': '2024-03-01T00:00:00.000Z',
        'category': 'legal',
        'comment': 'Legal issue',
        'forwarded': false,
        'created_at': '2024-02-01T00:00:00.000Z',
        'account': accountJson,
        'target_account': accountJson,
      });

      final report = AdminReportSchema.fromString(jsonStr);
      expect(report.id, 'rpt-str');
      expect(report.actionTaken, isTrue);
      expect(report.category, ReportCategoryType.legal);
    });

    test('fromJson handles assigned and action_taken_by accounts', () {
      final Map<String, dynamic> accountJson = {
        'id': 'acc-1',
        'username': 'user1',
        'acct': 'user1',
        'url': 'https://example.com/@user1',
        'display_name': 'User One',
        'note': '',
        'avatar': 'https://example.com/avatar.png',
        'avatar_static': 'https://example.com/avatar.png',
        'header': 'https://example.com/header.png',
        'locked': false,
        'bot': false,
        'indexable': true,
        'created_at': '2024-01-01T00:00:00.000Z',
        'statuses_count': 0,
        'followers_count': 0,
        'following_count': 0,
      };

      final Map<String, dynamic> json = {
        'id': 'rpt-1',
        'action_taken': true,
        'action_taken_at': '2024-03-01T00:00:00.000Z',
        'category': 'violation',
        'comment': '',
        'forwarded': false,
        'created_at': '2024-02-01T00:00:00.000Z',
        'account': accountJson,
        'target_account': accountJson,
        'assigned_account': {
          ...accountJson,
          'id': 'mod-1',
          'username': 'mod',
          'acct': 'mod',
        },
        'action_taken_by_account': {
          ...accountJson,
          'id': 'mod-1',
          'username': 'mod',
          'acct': 'mod',
        },
        'rules': [
          {'id': '1', 'text': 'No spam', 'hint': 'Do not post spam'},
        ],
      };

      final report = AdminReportSchema.fromJson(json);
      expect(report.assignedAccount, isNotNull);
      expect(report.assignedAccount!.username, 'mod');
      expect(report.actionTakenByAccount, isNotNull);
      expect(report.rules.length, 1);
      expect(report.rules.first.text, 'No spam');
    });
  });

  group('RoleSchema.hasPermission', () {
    test('administrator has all permissions', () {
      final role = MockRole.create(permissions: '1'); // administrator bit = 0x0001
      expect(role.hasPermission(PermissionBitmap.reports), isTrue);
      expect(role.hasPermission(PermissionBitmap.users), isTrue);
      expect(role.hasPermission(PermissionBitmap.federation), isTrue);
    });

    test('reports permission grants reports access', () {
      final role = MockRole.create(permissions: '16'); // 0x0010 = reports
      expect(role.hasPermission(PermissionBitmap.reports), isTrue);
      expect(role.hasPermission(PermissionBitmap.users), isFalse);
    });

    test('users permission grants users access', () {
      final role = MockRole.create(permissions: '1024'); // 0x0400 = users
      expect(role.hasPermission(PermissionBitmap.users), isTrue);
      expect(role.hasPermission(PermissionBitmap.reports), isFalse);
    });

    test('combined permissions work', () {
      final role = MockRole.create(permissions: '1040'); // 0x0410 = reports + users
      expect(role.hasPermission(PermissionBitmap.reports), isTrue);
      expect(role.hasPermission(PermissionBitmap.users), isTrue);
      expect(role.hasPermission(PermissionBitmap.federation), isFalse);
    });

    test('zero permissions denies all', () {
      final role = MockRole.create(permissions: '0');
      expect(role.hasPrivilege, isFalse);
      expect(role.hasPermission(PermissionBitmap.reports), isFalse);
      expect(role.hasPermission(PermissionBitmap.users), isFalse);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
