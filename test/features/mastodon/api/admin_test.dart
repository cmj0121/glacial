// Tests for admin API extensions.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/mastodon/extensions.dart';

import '../../../helpers/mock_http.dart';
import '../../../helpers/test_helpers.dart';

/// Build a valid admin report JSON string.
String adminReportJson({String id = 'report-1'}) {
  final account = jsonDecode(accountJson(id: 'reporter', username: 'reporter'));
  final target = jsonDecode(accountJson(id: 'target', username: 'spammer'));
  return jsonEncode({
    'id': id,
    'action_taken': false,
    'action_taken_at': null,
    'category': 'spam',
    'comment': 'spam content',
    'forwarded': false,
    'created_at': '2024-01-15T00:00:00.000Z',
    'updated_at': null,
    'account': account,
    'target_account': target,
    'assigned_account': null,
    'action_taken_by_account': null,
    'statuses': [],
    'rules': [],
  });
}

/// Build a valid admin account JSON string.
String adminAccountJson({String id = 'admin-acc-1', String username = 'testuser'}) {
  final account = jsonDecode(accountJson(id: id, username: username));
  return jsonEncode({
    'id': id,
    'username': username,
    'domain': null,
    'created_at': '2024-01-01T00:00:00.000Z',
    'email': 'test@example.com',
    'ip': '192.168.1.1',
    'locale': 'en',
    'invite_request': null,
    'role': null,
    'confirmed': true,
    'approved': true,
    'disabled': false,
    'silenced': false,
    'suspended': false,
    'account': account,
    'ips': [],
  });
}

void main() {
  const auth = AccessStatusSchema(
    domain: 'nonexistent-server-12345.invalid',
    accessToken: 'test-token',
  );

  group('AdminExtensions checkSignedIn guards', () {
    test('fetchAdminReports throws when not signed in', () {
      final status = MockAccessStatus.anonymous();
      expect(() => status.fetchAdminReports(), throwsException);
    });

    test('getAdminReport throws when not signed in', () {
      final status = MockAccessStatus.anonymous();
      expect(() => status.getAdminReport('r-1'), throwsException);
    });

    test('assignReportToSelf throws when not signed in', () {
      final status = MockAccessStatus.anonymous();
      expect(() => status.assignReportToSelf('r-1'), throwsException);
    });

    test('fetchAdminAccounts throws when not signed in', () {
      final status = MockAccessStatus.anonymous();
      expect(() => status.fetchAdminAccounts(), throwsException);
    });

    test('getAdminAccount throws when not signed in', () {
      final status = MockAccessStatus.anonymous();
      expect(() => status.getAdminAccount('acc-1'), throwsException);
    });

    test('approveAccount throws when not signed in', () {
      final status = MockAccessStatus.anonymous();
      expect(() => status.approveAccount('acc-1'), throwsException);
    });

    test('performAccountAction throws when not signed in', () {
      final status = MockAccessStatus.anonymous();
      expect(
        () => status.performAccountAction('acc-1', type: 'silence'),
        throwsException,
      );
    });
  });

  group('AdminExtensions with no domain', () {
    AccessStatusSchema noDomainAuth() =>
        const AccessStatusSchema(domain: '', accessToken: 'token');

    test('fetchAdminReports returns empty when no domain', () async {
      final result = await noDomainAuth().fetchAdminReports();
      expect(result, isEmpty);
    });

    test('fetchAdminAccounts returns empty when no domain', () async {
      final result = await noDomainAuth().fetchAdminAccounts();
      expect(result, isEmpty);
    });

    test('getAdminReport throws when no domain (model parse error)', () {
      expect(() => noDomainAuth().getAdminReport('r-1'), throwsA(anything));
    });

    test('getAdminAccount throws when no domain (model parse error)', () {
      expect(() => noDomainAuth().getAdminAccount('acc-1'), throwsA(anything));
    });
  });

  group('AdminExtensions with valid domain exercises HTTP call lines', () {
    // GET methods catch errors via getAPI
    test('fetchAdminReports returns empty on network error', () async {
      final result = await auth.fetchAdminReports();
      expect(result, isEmpty);
    });

    test('fetchAdminAccounts returns empty on network error', () async {
      final result = await auth.fetchAdminAccounts();
      expect(result, isEmpty);
    });

    test('getAdminReport throws on network error (model parse error)', () {
      expect(() => auth.getAdminReport('r-1'), throwsA(anything));
    });

    test('getAdminAccount throws on network error (model parse error)', () {
      expect(() => auth.getAdminAccount('acc-1'), throwsA(anything));
    });

    // POST methods throw on network error
    test('assignReportToSelf throws on network error', () {
      expect(() => auth.assignReportToSelf('r-1'), throwsA(anything));
    });

    test('unassignReport throws on network error', () {
      expect(() => auth.unassignReport('r-1'), throwsA(anything));
    });

    test('resolveReport throws on network error', () {
      expect(() => auth.resolveReport('r-1'), throwsA(anything));
    });

    test('reopenReport throws on network error', () {
      expect(() => auth.reopenReport('r-1'), throwsA(anything));
    });

    test('approveAccount throws on network error', () {
      expect(() => auth.approveAccount('acc-1'), throwsA(anything));
    });

    test('rejectAccount throws on network error', () {
      expect(() => auth.rejectAccount('acc-1'), throwsA(anything));
    });

    test('performAccountAction throws on network error', () {
      expect(
        () => auth.performAccountAction('acc-1', type: 'silence'),
        throwsA(anything),
      );
    });

    test('enableAccount throws on network error', () {
      expect(() => auth.enableAccount('acc-1'), throwsA(anything));
    });

    test('unsilenceAccount throws on network error', () {
      expect(() => auth.unsilenceAccount('acc-1'), throwsA(anything));
    });

    test('unsuspendAccount throws on network error', () {
      expect(() => auth.unsuspendAccount('acc-1'), throwsA(anything));
    });

    test('unsensitiveAccount throws on network error', () {
      expect(() => auth.unsensitiveAccount('acc-1'), throwsA(anything));
    });
  });

  group('AdminExtensions with mock HTTP (success paths)', () {
    late HttpOverrides? originalOverrides;

    setUp(() {
      originalOverrides = HttpOverrides.current;
    });

    tearDown(() {
      HttpOverrides.global = originalOverrides;
    });

    test('fetchAdminReports with query params returns parsed reports', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        expect(url.queryParameters['resolved'], 'true');
        expect(url.queryParameters['account_id'], 'acc-1');
        expect(url.queryParameters['target_account_id'], 'acc-2');
        return (200, '[${adminReportJson()}]');
      });

      final result = await auth.fetchAdminReports(
        resolved: true,
        accountId: 'acc-1',
        targetAccountId: 'acc-2',
      );
      expect(result.length, 1);
      expect(result.first.id, 'report-1');
    });

    test('assignReportToSelf returns parsed report', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        expect(method, 'POST');
        return (200, adminReportJson(id: 'report-assigned'));
      });

      final result = await auth.assignReportToSelf('report-1');
      expect(result.id, 'report-assigned');
    });

    test('unassignReport returns parsed report', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        expect(method, 'POST');
        return (200, adminReportJson(id: 'report-unassigned'));
      });

      final result = await auth.unassignReport('report-1');
      expect(result.id, 'report-unassigned');
    });

    test('resolveReport returns parsed report', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        return (200, adminReportJson(id: 'report-resolved'));
      });

      final result = await auth.resolveReport('report-1');
      expect(result.id, 'report-resolved');
    });

    test('reopenReport returns parsed report', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        return (200, adminReportJson(id: 'report-reopened'));
      });

      final result = await auth.reopenReport('report-1');
      expect(result.id, 'report-reopened');
    });

    test('fetchAdminAccounts with query params returns parsed accounts', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        expect(url.queryParameters['origin'], 'local');
        expect(url.queryParameters['status'], 'active');
        expect(url.queryParameters['username'], 'alice');
        expect(url.queryParameters['display_name'], 'Alice');
        expect(url.queryParameters['email'], 'a@b.c');
        expect(url.queryParameters['ip'], '1.2.3.4');
        return (200, '[${adminAccountJson()}]');
      });

      final result = await auth.fetchAdminAccounts(
        origin: AdminAccountOrigin.local,
        status: AdminAccountStatus.active,
        username: 'alice',
        displayName: 'Alice',
        email: 'a@b.c',
        ip: '1.2.3.4',
      );
      expect(result.length, 1);
      expect(result.first.id, 'admin-acc-1');
    });

    test('approveAccount returns parsed account', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        return (200, adminAccountJson(id: 'approved'));
      });

      final result = await auth.approveAccount('acc-1');
      expect(result.id, 'approved');
    });

    test('rejectAccount returns parsed account', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        return (200, adminAccountJson(id: 'rejected'));
      });

      final result = await auth.rejectAccount('acc-1');
      expect(result.id, 'rejected');
    });

    test('performAccountAction with reportId and text completes', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        expect(method, 'POST');
        return (200, '{}');
      });

      await auth.performAccountAction('acc-1', type: 'silence', reportId: 'r-1', text: 'reason');
    });

    test('enableAccount returns parsed account', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        return (200, adminAccountJson(id: 'enabled'));
      });

      final result = await auth.enableAccount('acc-1');
      expect(result.id, 'enabled');
    });

    test('unsilenceAccount returns parsed account', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        return (200, adminAccountJson(id: 'unsilenced'));
      });

      final result = await auth.unsilenceAccount('acc-1');
      expect(result.id, 'unsilenced');
    });

    test('unsuspendAccount returns parsed account', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        return (200, adminAccountJson(id: 'unsuspended'));
      });

      final result = await auth.unsuspendAccount('acc-1');
      expect(result.id, 'unsuspended');
    });

    test('unsensitiveAccount returns parsed account', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        return (200, adminAccountJson(id: 'unsensitive'));
      });

      final result = await auth.unsensitiveAccount('acc-1');
      expect(result.id, 'unsensitive');
    });

    test('getAdminReport returns parsed report', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        return (200, adminReportJson(id: 'report-detail'));
      });

      final result = await auth.getAdminReport('report-detail');
      expect(result.id, 'report-detail');
    });

    test('getAdminAccount returns parsed account', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        return (200, adminAccountJson(id: 'acc-detail'));
      });

      final result = await auth.getAdminAccount('acc-detail');
      expect(result.id, 'acc-detail');
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
