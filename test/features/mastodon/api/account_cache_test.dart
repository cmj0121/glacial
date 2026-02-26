// Tests for account cache and guard behaviors in account.dart API.
import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/features/mastodon/extensions.dart';
import 'package:glacial/features/models.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  group('Account cache', () {
    test('cacheAccount and lookupAccount round-trip', () {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(domain: 'cache.test'),
      );
      final account = MockAccount.create(id: 'acc1');
      status.cacheAccount(account);
      expect(status.lookupAccount('acc1')?.id, 'acc1');
    });

    test('lookupAccount returns null for unknown id', () {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(domain: 'cache2.test'),
      );
      expect(status.lookupAccount('unknown'), isNull);
    });

    test('cacheAccount does nothing when domain is empty', () {
      final status = AccessStatusSchema(domain: '');
      final account = MockAccount.create(id: 'cache_empty_domain_test');
      status.cacheAccount(account);
      // domain is empty, so cacheAccount should skip (guard: domain?.isEmpty ?? true).
      // Verify by looking up from same empty-domain status:
      expect(status.lookupAccount('cache_empty_domain_test'), isNull);
    });
  });

  group('getAccount guards', () {
    test('returns null for null accountID', () async {
      final status = MockAccessStatus.anonymous();
      final result = await status.getAccount(null);
      expect(result, isNull);
    });

    test('returns null for empty accountID', () async {
      final status = MockAccessStatus.anonymous();
      final result = await status.getAccount('');
      expect(result, isNull);
    });
  });

  group('getAccounts guards', () {
    test('returns empty list for empty ids', () async {
      final status = MockAccessStatus.anonymous();
      final result = await status.getAccounts([]);
      expect(result, isEmpty);
    });
  });

  group('searchAccounts guards', () {
    test('returns empty list for empty query', () async {
      final status = MockAccessStatus.anonymous();
      final result = await status.searchAccounts('');
      expect(result, isEmpty);
    });
  });

  group('getAccountByAccessToken guards', () {
    test('returns null for null token', () async {
      final status = MockAccessStatus.anonymous();
      final result = await status.getAccountByAccessToken(null);
      expect(result, isNull);
    });

    test('returns null when domain is null', () async {
      final status = AccessStatusSchema(domain: null);
      final result = await status.getAccountByAccessToken('some_token');
      expect(result, isNull);
    });
  });

  group('fetchAccountTimeline guards', () {
    test('returns empty list when account is null', () async {
      final status = MockAccessStatus.anonymous();
      final result = await status.fetchAccountTimeline(account: null);
      expect(result, isEmpty);
    });
  });

  group('lookupAccountByAcct guards', () {
    test('returns null for empty acct', () async {
      final status = MockAccessStatus.anonymous();
      final result = await status.lookupAccountByAcct('');
      expect(result, isNull);
    });
  });

  group('fetchRelationships guards', () {
    test('returns empty list for empty accounts', () async {
      final status = MockAccessStatus.anonymous();
      final result = await status.fetchRelationships([]);
      expect(result, isEmpty);
    });
  });

  group('signed-in guards (isSignedIn check)', () {
    test('fetchMutedAccounts throws when not signed in', () async {
      final status = MockAccessStatus.anonymous();
      expect(() => status.fetchMutedAccounts(), throwsException);
    });

    test('fetchBlockedAccounts throws when not signed in', () async {
      final status = MockAccessStatus.anonymous();
      expect(() => status.fetchBlockedAccounts(), throwsException);
    });

    test('fetchFollowRequests throws when not signed in', () async {
      final status = MockAccessStatus.anonymous();
      expect(() => status.fetchFollowRequests(), throwsException);
    });

    test('acceptFollowRequest throws when not signed in', () async {
      final status = MockAccessStatus.anonymous();
      expect(() => status.acceptFollowRequest('123'), throwsException);
    });

    test('rejectFollowRequest throws when not signed in', () async {
      final status = MockAccessStatus.anonymous();
      expect(() => status.rejectFollowRequest('123'), throwsException);
    });
  });

  group('checkSignedIn guards', () {
    test('setAccountNote throws when not signed in', () {
      final status = MockAccessStatus.anonymous();
      expect(() => status.setAccountNote(accountId: '1', comment: 'hi'), throwsException);
    });

    test('endorseAccount throws when not signed in', () {
      final status = MockAccessStatus.anonymous();
      expect(() => status.endorseAccount(accountId: '1'), throwsException);
    });

    test('unendorseAccount throws when not signed in', () {
      final status = MockAccessStatus.anonymous();
      expect(() => status.unendorseAccount(accountId: '1'), throwsException);
    });

    test('removeFromFollowers throws when not signed in', () {
      final status = MockAccessStatus.anonymous();
      expect(() => status.removeFromFollowers(accountId: '1'), throwsException);
    });

    test('fetchDomainBlocks throws when not signed in', () {
      final status = MockAccessStatus.anonymous();
      expect(() => status.fetchDomainBlocks(), throwsException);
    });

    test('blockDomain throws when not signed in', () {
      final status = MockAccessStatus.anonymous();
      expect(() => status.blockDomain('evil.com'), throwsException);
    });

    test('unblockDomain throws when not signed in', () {
      final status = MockAccessStatus.anonymous();
      expect(() => status.unblockDomain('evil.com'), throwsException);
    });

    test('fetchEndorsedAccounts throws when not signed in', () {
      final status = MockAccessStatus.anonymous();
      expect(() => status.fetchEndorsedAccounts(), throwsException);
    });

    test('fetchAccountLists throws when not signed in', () {
      final status = MockAccessStatus.anonymous();
      expect(() => status.fetchAccountLists(accountId: '1'), throwsException);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
