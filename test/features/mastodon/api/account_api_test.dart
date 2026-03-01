// Tests for account API extensions (no-domain and valid-domain HTTP exercise).
import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/mastodon/extensions.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  AccessStatusSchema noDomainAuth() =>
      const AccessStatusSchema(domain: '', accessToken: 'token');

  const auth = AccessStatusSchema(
    domain: 'nonexistent-server-12345.invalid',
    accessToken: 'test-token',
  );

  group('AccountsExtensions with no domain', () {
    test('getAccount throws when no domain (model parse error)', () {
      expect(() => noDomainAuth().getAccount('acc-1'), throwsA(anything));
    });

    test('getAccounts returns empty when no domain and all cached miss', () async {
      final result = await noDomainAuth().getAccounts(['acc-1', 'acc-2']);
      expect(result, isEmpty);
    });

    test('searchAccounts returns empty for non-empty query when no domain', () async {
      final result = await noDomainAuth().searchAccounts('alice');
      expect(result, isEmpty);
    });

    test('fetchAccountTimeline returns empty when no domain', () async {
      final result = await noDomainAuth().fetchAccountTimeline(
        account: MockAccount.create(),
      );
      expect(result, isEmpty);
    });

    test('lookupAccountByAcct returns null when no domain', () async {
      final result = await noDomainAuth().lookupAccountByAcct('alice@example.com');
      expect(result, isNull);
    });

    test('fetchRelationships returns empty with accounts when no domain', () async {
      final result = await noDomainAuth().fetchRelationships([MockAccount.create()]);
      expect(result, isEmpty);
    });

    test('fetchFamiliarFollowers returns empty when no domain', () async {
      final result = await noDomainAuth().fetchFamiliarFollowers(accountId: 'acc-1');
      expect(result, isEmpty);
    });

    test('fetchAccountFeaturedTags returns empty when no domain', () async {
      final result = await noDomainAuth().fetchAccountFeaturedTags(accountId: 'acc-1');
      expect(result, isEmpty);
    });
  });

  group('AccountsExtensions with valid domain exercises HTTP call lines', () {
    // GET methods catch errors via getAPI
    test('getAccount throws on network error (model parse error)', () {
      expect(() => auth.getAccount('acc-1'), throwsA(anything));
    });

    test('searchAccounts returns empty on network error', () async {
      final result = await auth.searchAccounts('alice', limit: 5);
      expect(result, isEmpty);
    });

    test('fetchAccountTimeline returns empty on network error', () async {
      final result = await auth.fetchAccountTimeline(
        account: MockAccount.create(),
        maxId: 'max-1',
        pinned: true,
      );
      expect(result, isEmpty);
    });

    test('lookupAccountByAcct returns null on network error', () async {
      final result = await auth.lookupAccountByAcct('alice@example.com');
      expect(result, isNull);
    });

    test('fetchRelationships returns empty on network error', () async {
      final result = await auth.fetchRelationships([MockAccount.create()]);
      expect(result, isEmpty);
    });

    test('fetchFamiliarFollowers returns empty on network error', () async {
      final result = await auth.fetchFamiliarFollowers(accountId: 'acc-1');
      expect(result, isEmpty);
    });

    test('fetchAccountFeaturedTags returns empty on network error', () async {
      final result = await auth.fetchAccountFeaturedTags(accountId: 'acc-1');
      expect(result, isEmpty);
    });

    // getAPIEx methods throw
    test('fetchFollowers throws on network error', () {
      expect(
        () => auth.fetchFollowers(account: MockAccount.create()),
        throwsA(anything),
      );
    });

    test('fetchFollowing throws on network error', () {
      expect(
        () => auth.fetchFollowing(account: MockAccount.create()),
        throwsA(anything),
      );
    });

    test('fetchMutedAccounts throws on network error', () {
      expect(() => auth.fetchMutedAccounts(), throwsA(anything));
    });

    test('fetchBlockedAccounts throws on network error', () {
      expect(() => auth.fetchBlockedAccounts(), throwsA(anything));
    });

    test('fetchEndorsedAccounts throws on network error', () {
      expect(() => auth.fetchEndorsedAccounts(), throwsA(anything));
    });

    test('fetchDomainBlocks throws on network error', () {
      expect(() => auth.fetchDomainBlocks(), throwsA(anything));
    });

    // POST methods throw
    test('changeRelationship throws on network error', () {
      expect(
        () => auth.changeRelationship(
          account: MockAccount.create(),
          type: RelationshipType.following,
        ),
        throwsA(anything),
      );
    });

    test('setAccountNote throws on network error', () {
      expect(
        () => auth.setAccountNote(accountId: 'acc-1', comment: 'note'),
        throwsA(anything),
      );
    });

    test('endorseAccount throws on network error', () {
      expect(() => auth.endorseAccount(accountId: 'acc-1'), throwsA(anything));
    });

    test('unendorseAccount throws on network error', () {
      expect(() => auth.unendorseAccount(accountId: 'acc-1'), throwsA(anything));
    });

    test('removeFromFollowers throws on network error', () {
      expect(() => auth.removeFromFollowers(accountId: 'acc-1'), throwsA(anything));
    });

    test('acceptFollowRequest throws on network error', () {
      expect(() => auth.acceptFollowRequest('acc-1'), throwsA(anything));
    });

    test('rejectFollowRequest throws on network error', () {
      expect(() => auth.rejectFollowRequest('acc-1'), throwsA(anything));
    });

    test('blockDomain throws on network error', () {
      expect(() => auth.blockDomain('evil.com'), throwsA(anything));
    });

    test('unblockDomain throws on network error', () {
      expect(() => auth.unblockDomain('evil.com'), throwsA(anything));
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
