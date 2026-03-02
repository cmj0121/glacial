// Tests for admin API extensions.
import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/mastodon/extensions.dart';

import '../../../helpers/test_helpers.dart';

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
}

// vim: set ts=2 sw=2 sts=2 et:
