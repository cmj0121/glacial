// Tests for account API extensions (no-domain and valid-domain HTTP exercise).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/mastodon/extensions.dart';

import '../../../helpers/mock_http.dart';
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

  group('AccountsExtensions with mock HTTP (success paths)', () {
    late HttpOverrides? originalOverrides;

    setUp(() {
      originalOverrides = HttpOverrides.current;
    });

    tearDown(() {
      HttpOverrides.global = originalOverrides;
    });

    test('getAccount success returns parsed account', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        return (200, accountJson(id: 'acc-99', username: 'alice'));
      });

      final mockAuth = const AccessStatusSchema(
        domain: 'example.com',
        accessToken: 'test-token',
      );
      final result = await mockAuth.getAccount('acc-99');
      expect(result, isNotNull);
      expect(result!.username, 'alice');
    });

    test('cacheAccount + lookupAccount round-trip works', () {
      final mockAuth = const AccessStatusSchema(
        domain: 'cache-test.com',
        accessToken: 'token',
      );
      final account = MockAccount.create(id: 'cached-1', username: 'cached_user');
      mockAuth.cacheAccount(account);
      final result = mockAuth.lookupAccount('cached-1');
      expect(result, isNotNull);
      expect(result!.username, 'cached_user');
    });

    test('cacheAccount with null domain logs warning and does not cache', () {
      const nullDomainAuth = AccessStatusSchema(
        domain: null,
        accessToken: 'token',
      );
      final account = MockAccount.create(id: 'null-domain-1', username: 'ghost');
      // Should not throw, just log a warning and return early.
      nullDomainAuth.cacheAccount(account);
      final result = nullDomainAuth.lookupAccount('null-domain-1');
      expect(result, isNull);
    });

    test('getAccounts returns list of accounts (cache miss + HTTP fetch)', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        return (200, '[${accountJson(id: 'a1', username: 'user1')}, ${accountJson(id: 'a2', username: 'user2')}]');
      });

      const mockAuth = AccessStatusSchema(
        domain: 'example.com',
        accessToken: 'test-token',
      );
      final result = await mockAuth.getAccounts(['a1', 'a2']);
      expect(result, hasLength(2));
      expect(result[0].username, 'user1');
      expect(result[1].username, 'user2');
    });

    test('searchAccounts returns matching accounts', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        return (200, '[${accountJson(id: 's1', username: 'alice')}]');
      });

      const mockAuth = AccessStatusSchema(
        domain: 'example.com',
        accessToken: 'test-token',
      );
      final result = await mockAuth.searchAccounts('alice');
      expect(result, hasLength(1));
      expect(result.first.username, 'alice');
    });

    test('fetchAccountTimeline returns list of statuses', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        return (200, '[${statusJson(id: 'st-1')}, ${statusJson(id: 'st-2')}]');
      });

      const mockAuth = AccessStatusSchema(
        domain: 'example.com',
        accessToken: 'test-token',
      );
      final account = MockAccount.create(id: 'timeline-acc');
      final result = await mockAuth.fetchAccountTimeline(account: account);
      expect(result, hasLength(2));
      expect(result[0].id, 'st-1');
      expect(result[1].id, 'st-2');
    });

    test('fetchFollowers returns accounts tuple', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        return (200, '[${accountJson(id: 'f1', username: 'follower1')}]');
      });

      const mockAuth = AccessStatusSchema(
        domain: 'example.com',
        accessToken: 'test-token',
      );
      final account = MockAccount.create(id: 'target-acc');
      final (accounts, nextId) = await mockAuth.fetchFollowers(account: account);
      expect(accounts, hasLength(1));
      expect(accounts.first.username, 'follower1');
      expect(nextId, isNull); // FakeHttpHeaders returns null for Link header
    });

    test('fetchFollowing returns accounts tuple', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        return (200, '[${accountJson(id: 'fw1', username: 'following1')}]');
      });

      const mockAuth = AccessStatusSchema(
        domain: 'example.com',
        accessToken: 'test-token',
      );
      final account = MockAccount.create(id: 'target-acc');
      final (accounts, nextId) = await mockAuth.fetchFollowing(account: account);
      expect(accounts, hasLength(1));
      expect(accounts.first.username, 'following1');
      expect(nextId, isNull);
    });

    test('fetchMutedAccounts returns accounts tuple', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        return (200, '[${accountJson(id: 'm1', username: 'muted1')}]');
      });

      const mockAuth = AccessStatusSchema(
        domain: 'example.com',
        accessToken: 'test-token',
      );
      final (accounts, nextId) = await mockAuth.fetchMutedAccounts();
      expect(accounts, hasLength(1));
      expect(accounts.first.username, 'muted1');
      expect(nextId, isNull);
    });

    test('fetchBlockedAccounts returns accounts tuple', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        return (200, '[${accountJson(id: 'b1', username: 'blocked1')}]');
      });

      const mockAuth = AccessStatusSchema(
        domain: 'example.com',
        accessToken: 'test-token',
      );
      final (accounts, nextId) = await mockAuth.fetchBlockedAccounts();
      expect(accounts, hasLength(1));
      expect(accounts.first.username, 'blocked1');
      expect(nextId, isNull);
    });

    test('fetchRelationships returns list of relationships', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        return (200, '[${_relationshipJson(id: 'rel-1')}]');
      });

      const mockAuth = AccessStatusSchema(
        domain: 'example.com',
        accessToken: 'test-token',
      );
      final account = MockAccount.create(id: 'rel-1');
      final result = await mockAuth.fetchRelationships([account]);
      expect(result, hasLength(1));
      expect(result.first.id, 'rel-1');
    });

    test('fetchFamiliarFollowers returns list of accounts', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        final body = jsonEncode([
          {
            'id': 'acc-1',
            'accounts': [jsonDecode(accountJson(id: 'fam-1', username: 'familiar1'))],
          }
        ]);
        return (200, body);
      });

      const mockAuth = AccessStatusSchema(
        domain: 'example.com',
        accessToken: 'test-token',
      );
      final result = await mockAuth.fetchFamiliarFollowers(accountId: 'acc-1');
      expect(result, hasLength(1));
      expect(result.first.username, 'familiar1');
    });

    test('changeRelationship (following) returns relationship', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        expect(method, 'POST');
        return (200, _relationshipJson(id: 'cr-1'));
      });

      const mockAuth = AccessStatusSchema(
        domain: 'example.com',
        accessToken: 'test-token',
      );
      final account = MockAccount.create(id: 'cr-1');
      final result = await mockAuth.changeRelationship(
        account: account,
        type: RelationshipType.following,
      );
      expect(result, isNotNull);
      expect(result!.id, 'cr-1');
    });

    test('changeRelationship (stranger/follow) returns relationship', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        expect(method, 'POST');
        return (200, _relationshipJson(id: 'cr-2'));
      });

      const mockAuth = AccessStatusSchema(
        domain: 'example.com',
        accessToken: 'test-token',
      );
      final account = MockAccount.create(id: 'cr-2');
      final result = await mockAuth.changeRelationship(
        account: account,
        type: RelationshipType.stranger,
      );
      expect(result, isNotNull);
      expect(result!.id, 'cr-2');
    });

    test('changeRelationship (mute) returns relationship', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        return (200, _relationshipJson(id: 'cr-3'));
      });

      const mockAuth = AccessStatusSchema(
        domain: 'example.com',
        accessToken: 'test-token',
      );
      final account = MockAccount.create(id: 'cr-3');
      final result = await mockAuth.changeRelationship(
        account: account,
        type: RelationshipType.mute,
      );
      expect(result, isNotNull);
    });

    test('changeRelationship (unmute) returns relationship', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        return (200, _relationshipJson(id: 'cr-4'));
      });

      const mockAuth = AccessStatusSchema(
        domain: 'example.com',
        accessToken: 'test-token',
      );
      final account = MockAccount.create(id: 'cr-4');
      final result = await mockAuth.changeRelationship(
        account: account,
        type: RelationshipType.unmute,
      );
      expect(result, isNotNull);
    });

    test('changeRelationship (block) returns relationship', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        return (200, _relationshipJson(id: 'cr-5'));
      });

      const mockAuth = AccessStatusSchema(
        domain: 'example.com',
        accessToken: 'test-token',
      );
      final account = MockAccount.create(id: 'cr-5');
      final result = await mockAuth.changeRelationship(
        account: account,
        type: RelationshipType.block,
      );
      expect(result, isNotNull);
    });

    test('changeRelationship (unblock) returns relationship', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        return (200, _relationshipJson(id: 'cr-6'));
      });

      const mockAuth = AccessStatusSchema(
        domain: 'example.com',
        accessToken: 'test-token',
      );
      final account = MockAccount.create(id: 'cr-6');
      final result = await mockAuth.changeRelationship(
        account: account,
        type: RelationshipType.unblock,
      );
      expect(result, isNotNull);
    });

    test('setAccountNote returns relationship', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        expect(method, 'POST');
        return (200, _relationshipJson(id: 'note-1'));
      });

      const mockAuth = AccessStatusSchema(
        domain: 'example.com',
        accessToken: 'test-token',
      );
      final result = await mockAuth.setAccountNote(accountId: 'note-1', comment: 'great person');
      expect(result, isNotNull);
      expect(result!.id, 'note-1');
    });

    test('endorseAccount returns relationship', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        expect(method, 'POST');
        return (200, _relationshipJson(id: 'end-1'));
      });

      const mockAuth = AccessStatusSchema(
        domain: 'example.com',
        accessToken: 'test-token',
      );
      final result = await mockAuth.endorseAccount(accountId: 'end-1');
      expect(result, isNotNull);
      expect(result!.id, 'end-1');
    });

    test('unendorseAccount returns relationship', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        expect(method, 'POST');
        return (200, _relationshipJson(id: 'unend-1'));
      });

      const mockAuth = AccessStatusSchema(
        domain: 'example.com',
        accessToken: 'test-token',
      );
      final result = await mockAuth.unendorseAccount(accountId: 'unend-1');
      expect(result, isNotNull);
      expect(result!.id, 'unend-1');
    });

    test('removeFromFollowers returns relationship', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        expect(method, 'POST');
        return (200, _relationshipJson(id: 'rem-1'));
      });

      const mockAuth = AccessStatusSchema(
        domain: 'example.com',
        accessToken: 'test-token',
      );
      final result = await mockAuth.removeFromFollowers(accountId: 'rem-1');
      expect(result, isNotNull);
      expect(result!.id, 'rem-1');
    });

    test('fetchFollowRequests returns list of accounts', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        return (200, '[${accountJson(id: 'fr-1', username: 'requester')}]');
      });

      const mockAuth = AccessStatusSchema(
        domain: 'example.com',
        accessToken: 'test-token',
      );
      final result = await mockAuth.fetchFollowRequests();
      expect(result, hasLength(1));
      expect(result.first.username, 'requester');
    });

    test('acceptFollowRequest returns relationship', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        expect(method, 'POST');
        return (200, _relationshipJson(id: 'afr-1'));
      });

      const mockAuth = AccessStatusSchema(
        domain: 'example.com',
        accessToken: 'test-token',
      );
      final result = await mockAuth.acceptFollowRequest('afr-1');
      expect(result, isNotNull);
      expect(result!.id, 'afr-1');
    });

    test('rejectFollowRequest returns relationship', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        expect(method, 'POST');
        return (200, _relationshipJson(id: 'rfr-1'));
      });

      const mockAuth = AccessStatusSchema(
        domain: 'example.com',
        accessToken: 'test-token',
      );
      final result = await mockAuth.rejectFollowRequest('rfr-1');
      expect(result, isNotNull);
      expect(result!.id, 'rfr-1');
    });

    test('fetchAccountFeaturedTags returns list of featured tags', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        return (200, '[${_featuredTagJson(id: 'ft-1', name: 'flutter')}]');
      });

      const mockAuth = AccessStatusSchema(
        domain: 'example.com',
        accessToken: 'test-token',
      );
      final result = await mockAuth.fetchAccountFeaturedTags(accountId: 'acc-1');
      expect(result, hasLength(1));
      expect(result.first.name, 'flutter');
    });

    test('lookupAccountByAcct returns account', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        return (200, accountJson(id: 'lookup-1', username: 'looked_up'));
      });

      const mockAuth = AccessStatusSchema(
        domain: 'example.com',
        accessToken: 'test-token',
      );
      final result = await mockAuth.lookupAccountByAcct('looked_up@example.com');
      expect(result, isNotNull);
      expect(result!.username, 'looked_up');
    });

    test('fetchDomainBlocks returns list of strings', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        return (200, '["evil.com", "spam.org"]');
      });

      const mockAuth = AccessStatusSchema(
        domain: 'example.com',
        accessToken: 'test-token',
      );
      final (domains, nextId) = await mockAuth.fetchDomainBlocks();
      expect(domains, hasLength(2));
      expect(domains, contains('evil.com'));
      expect(domains, contains('spam.org'));
      expect(nextId, isNull);
    });

    test('blockDomain completes successfully', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        expect(method, 'POST');
        return (200, '{}');
      });

      const mockAuth = AccessStatusSchema(
        domain: 'example.com',
        accessToken: 'test-token',
      );
      // Should complete without throwing.
      await mockAuth.blockDomain('evil.com');
    });

    test('unblockDomain completes successfully', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        expect(method, 'DELETE');
        return (200, '{}');
      });

      const mockAuth = AccessStatusSchema(
        domain: 'example.com',
        accessToken: 'test-token',
      );
      // Should complete without throwing.
      await mockAuth.unblockDomain('evil.com');
    });

    test('fetchEndorsedAccounts returns accounts tuple', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        return (200, '[${accountJson(id: 'e1', username: 'endorsed1')}]');
      });

      const mockAuth = AccessStatusSchema(
        domain: 'example.com',
        accessToken: 'test-token',
      );
      final (accounts, nextId) = await mockAuth.fetchEndorsedAccounts();
      expect(accounts, hasLength(1));
      expect(accounts.first.username, 'endorsed1');
      expect(nextId, isNull);
    });

    test('fetchAccountLists returns list of lists', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        return (200, '[${_listJson(id: 'list-1', title: 'My List')}]');
      });

      const mockAuth = AccessStatusSchema(
        domain: 'example.com',
        accessToken: 'test-token',
      );
      final result = await mockAuth.fetchAccountLists(accountId: 'acc-1');
      expect(result, hasLength(1));
      expect(result.first.title, 'My List');
    });

    test('registerAccount returns access token on success', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        expect(method, 'POST');
        return (200, jsonEncode({'access_token': 'new-token-123'}));
      });

      const mockAuth = AccessStatusSchema(
        domain: 'example.com',
        accessToken: 'test-token',
      );
      final result = await mockAuth.registerAccount(
        domain: 'example.com',
        appToken: 'app-token',
        username: 'newuser',
        email: 'new@example.com',
        password: 'secret123',
        locale: 'en',
        reason: 'I want to join!',
      );
      expect(result, 'new-token-123');
    });

    test('registerAccount throws on non-200 status', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        return (422, jsonEncode({'error': 'Username already taken'}));
      });

      const mockAuth = AccessStatusSchema(
        domain: 'example.com',
        accessToken: 'test-token',
      );
      expect(
        () => mockAuth.registerAccount(
          domain: 'example.com',
          appToken: 'app-token',
          username: 'taken',
          email: 'taken@example.com',
          password: 'secret123',
          locale: 'en',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('getAccountByAccessToken returns account', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        return (200, accountJson(id: 'verify-1', username: 'verified'));
      });

      const mockAuth = AccessStatusSchema(
        domain: 'example.com',
        accessToken: 'test-token',
      );
      final result = await mockAuth.getAccountByAccessToken('valid-token');
      expect(result, isNotNull);
      expect(result!.username, 'verified');
    });

    test('getAccountByAccessToken returns null for null token', () async {
      const mockAuth = AccessStatusSchema(
        domain: 'example.com',
        accessToken: 'test-token',
      );
      final result = await mockAuth.getAccountByAccessToken(null);
      expect(result, isNull);
    });

    test('updateAccount returns parsed account', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        expect(method, 'PATCH');
        return (200, accountJson(id: 'upd-1', username: 'updated'));
      });

      const mockAuth = AccessStatusSchema(
        domain: 'example.com',
        accessToken: 'test-token',
      );
      const schema = AccountCredentialSchema(
        displayName: 'Updated Name',
        note: 'Updated bio',
        locked: false,
        bot: false,
        discoverable: true,
        hideCollections: false,
        indexable: true,
      );
      final result = await mockAuth.updateAccount(schema);
      expect(result.username, 'updated');
    });

    test('changeRelationship (followEachOther) calls unfollow endpoint', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        expect(url.path, contains('unfollow'));
        return (200, _relationshipJson(id: 'cr-7'));
      });

      const mockAuth = AccessStatusSchema(
        domain: 'example.com',
        accessToken: 'test-token',
      );
      final account = MockAccount.create(id: 'cr-7');
      final result = await mockAuth.changeRelationship(
        account: account,
        type: RelationshipType.followEachOther,
      );
      expect(result, isNotNull);
    });

    test('changeRelationship (followRequest) calls unfollow endpoint', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        expect(url.path, contains('unfollow'));
        return (200, _relationshipJson(id: 'cr-8'));
      });

      const mockAuth = AccessStatusSchema(
        domain: 'example.com',
        accessToken: 'test-token',
      );
      final account = MockAccount.create(id: 'cr-8');
      final result = await mockAuth.changeRelationship(
        account: account,
        type: RelationshipType.followRequest,
      );
      expect(result, isNotNull);
    });

    test('changeRelationship (followedBy) calls follow endpoint', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        expect(url.path, contains('follow'));
        return (200, _relationshipJson(id: 'cr-9'));
      });

      const mockAuth = AccessStatusSchema(
        domain: 'example.com',
        accessToken: 'test-token',
      );
      final account = MockAccount.create(id: 'cr-9');
      final result = await mockAuth.changeRelationship(
        account: account,
        type: RelationshipType.followedBy,
      );
      expect(result, isNotNull);
    });
  });
}

// ---------------------------------------------------------------------------
// JSON builder helpers specific to account API tests
// ---------------------------------------------------------------------------

String _relationshipJson({String id = 'rel-1'}) => jsonEncode({
  'id': id,
  'following': false,
  'showing_reblogs': true,
  'notifying': false,
  'followed_by': false,
  'blocking': false,
  'blocked_by': false,
  'muting': false,
  'muting_notifications': false,
  'requested': false,
  'requested_by': false,
  'domain_blocking': false,
  'endorsed': false,
  'note': '',
});

String _featuredTagJson({String id = 'ft-1', String name = 'test'}) => jsonEncode({
  'id': id,
  'name': name,
  'url': 'https://example.com/tags/$name',
  'statuses_count': 5,
  'last_status_at': '2025-01-01',
});

String _listJson({String id = 'list-1', String title = 'Test List'}) => jsonEncode({
  'id': id,
  'title': title,
  'replies_policy': 'list',
  'exclusive': false,
});

// vim: set ts=2 sw=2 sts=2 et:
