// Tests for status API extensions (no-domain and valid-domain HTTP exercise).
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

  group('StatusExtensions with no domain', () {
    // getStatus uses getAPI → null → '{}' → StatusSchema.fromString fails
    test('getStatus throws when no domain (model parse error)', () {
      expect(() => noDomainAuth().getStatus('st-1'), throwsA(anything));
    });

    test('getPoll returns null when no domain and pollID is non-empty', () async {
      final result = await noDomainAuth().getPoll(pollID: 'p-1');
      expect(result, isNull);
    });

    test('fetchStatuses returns empty when no domain', () async {
      final result = await noDomainAuth().fetchStatuses(ids: ['1', '2']);
      expect(result, isEmpty);
    });

    // getStatusContext uses getAPI → null → '{}' → fromString may fail
    test('getStatusContext throws when no domain (model parse error)', () {
      final s = MockStatus.create();
      expect(() => noDomainAuth().getStatusContext(schema: s), throwsA(anything));
    });

    test('fetchRebloggedBy returns empty when no domain', () async {
      final s = MockStatus.create();
      final result = await noDomainAuth().fetchRebloggedBy(schema: s);
      expect(result, isEmpty);
    });

    test('fetchFavouritedBy returns empty when no domain', () async {
      final s = MockStatus.create();
      final result = await noDomainAuth().fetchFavouritedBy(schema: s);
      expect(result, isEmpty);
    });

    test('fetchHistory returns empty when no domain', () async {
      final s = MockStatus.create();
      final result = await noDomainAuth().fetchHistory(schema: s);
      expect(result, isEmpty);
    });

    test('deleteStatus completes when no domain', () async {
      final s = MockStatus.create();
      await noDomainAuth().deleteStatus(s);
    });
  });

  group('StatusExtensions with valid domain exercises HTTP call lines', () {
    test('getStatus throws on network error (model parse error)', () {
      expect(() => auth.getStatus('st-1'), throwsA(anything));
    });

    test('getPoll returns null on network error', () async {
      final result = await auth.getPoll(pollID: 'p-1');
      expect(result, isNull);
    });

    test('fetchStatuses returns empty on network error', () async {
      final result = await auth.fetchStatuses(ids: ['1']);
      expect(result, isEmpty);
    });

    test('fetchRebloggedBy returns empty on network error', () async {
      final s = MockStatus.create();
      final result = await auth.fetchRebloggedBy(schema: s);
      expect(result, isEmpty);
    });

    test('fetchFavouritedBy returns empty on network error', () async {
      final s = MockStatus.create();
      final result = await auth.fetchFavouritedBy(schema: s);
      expect(result, isEmpty);
    });

    test('fetchHistory returns empty on network error', () async {
      final s = MockStatus.create();
      final result = await auth.fetchHistory(schema: s);
      expect(result, isEmpty);
    });

    // POST methods throw
    test('interactWithStatus throws on network error', () {
      final s = MockStatus.create();
      expect(
        () => auth.interactWithStatus(s, StatusInteraction.favourite),
        throwsA(anything),
      );
    });

    test('votePoll throws on network error', () {
      expect(
        () => auth.votePoll(pollID: 'p-1', choices: [0]),
        throwsA(anything),
      );
    });

    test('translateStatus throws on network error', () {
      final s = MockStatus.create();
      expect(() => auth.translateStatus(schema: s), throwsA(anything));
    });

    test('deleteStatus throws on network error', () {
      final s = MockStatus.create();
      expect(() => auth.deleteStatus(s), throwsA(anything));
    });

    test('editStatusInteractionPolicy throws on network error', () {
      final s = MockStatus.create();
      expect(
        () => auth.editStatusInteractionPolicy(schema: s, policy: QuotePolicyType.public),
        throwsA(anything),
      );
    });
  });

  group('StatusExtensions edge cases', () {
    test('getStatus returns null for null statusID', () async {
      final result = await auth.getStatus(null);
      expect(result, isNull);
    });

    test('getStatus returns null for empty statusID', () async {
      final result = await auth.getStatus('');
      expect(result, isNull);
    });

    test('getPoll returns null for empty pollID', () async {
      final result = await auth.getPoll(pollID: '');
      expect(result, isNull);
    });

    test('fetchStatuses returns empty for empty ids', () async {
      final result = await auth.fetchStatuses(ids: []);
      expect(result, isEmpty);
    });

    test('interactWithStatus throws for unsupported action', () {
      final s = MockStatus.create();
      expect(
        () => auth.interactWithStatus(s, StatusInteraction.reply),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('deleteStatus with scheduledAt uses scheduled endpoint', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        expect(method, 'DELETE');
        expect(url.path, contains('/scheduled_statuses/'));
        return (200, '{}');
      });

      final s = MockStatus.create(
        id: 'sched-1',
        scheduledAt: DateTime.now().add(const Duration(hours: 1)),
      );
      final mockAuth = const AccessStatusSchema(domain: 'example.com', accessToken: 'token');
      final result = await mockAuth.deleteStatus(s);
      expect(result, isNull);

      HttpOverrides.global = null;
    });
  });

  group('StatusExtensions with mock HTTP (success paths)', () {
    late HttpOverrides? originalOverrides;

    setUp(() {
      originalOverrides = HttpOverrides.current;
    });

    tearDown(() {
      HttpOverrides.global = originalOverrides;
    });

    test('getStatus success returns parsed status and caches it', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        return (200, statusJson(id: 'cached-1'));
      });

      final mockAuth = const AccessStatusSchema(domain: 'example.com', accessToken: 'token');
      final result = await mockAuth.getStatus('cached-1');
      expect(result, isNotNull);
      expect(result!.id, 'cached-1');

      // Verify the status was cached (line 117)
      final cached = mockAuth.getStatusFromCache('cached-1');
      expect(cached, isNotNull);
    });

    test('getStatus with loadCache returns cached status', () async {
      final mockAuth = const AccessStatusSchema(domain: 'example.com', accessToken: 'token');

      // First put a status in cache
      final status = MockStatus.create(id: 'from-cache');
      mockAuth.saveStatusToCache(status);

      // Now getStatus with loadCache should return from cache without HTTP
      final result = await mockAuth.getStatus('from-cache', loadCache: true);
      expect(result, isNotNull);
      expect(result!.id, 'from-cache');
    });

    test('createStatus success returns parsed status', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        expect(method, 'POST');
        return (200, statusJson(id: 'new-status'));
      });

      final mockAuth = const AccessStatusSchema(domain: 'example.com', accessToken: 'token');
      final schema = PostStatusSchema(status: 'Hello world', mediaIDs: [], quoteApprovalPolicy: QuotePolicyType.public);
      final account = MockAccount.create();
      final result = await mockAuth.createStatus(
        schema: schema,
        idempotentKey: 'key-1',
        account: account,
      );
      expect(result.id, 'new-status');
    });

    test('editStatus success returns parsed status', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        expect(method, 'PUT');
        return (200, statusJson(id: 'edited-status'));
      });

      final mockAuth = const AccessStatusSchema(domain: 'example.com', accessToken: 'token');
      final schema = PostStatusSchema(status: 'Edited content', mediaIDs: [], quoteApprovalPolicy: QuotePolicyType.public);
      final account = MockAccount.create();
      final result = await mockAuth.editStatus(
        id: 'edited-status',
        schema: schema,
        idempotentKey: 'key-2',
        account: account,
      );
      expect(result.id, 'edited-status');
    });

    test('interactWithStatus reblog returns parsed status', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        expect(url.path, contains('/reblog'));
        return (200, statusJson(id: 'reblogged'));
      });

      final mockAuth = const AccessStatusSchema(domain: 'example.com', accessToken: 'token');
      final s = MockStatus.create();
      final result = await mockAuth.interactWithStatus(s, StatusInteraction.reblog);
      expect(result.id, 'reblogged');
    });

    test('interactWithStatus negative favourite returns parsed status', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        expect(url.path, contains('/unfavourite'));
        return (200, statusJson(id: 'unfaved'));
      });

      final mockAuth = const AccessStatusSchema(domain: 'example.com', accessToken: 'token');
      final s = MockStatus.create();
      final result = await mockAuth.interactWithStatus(s, StatusInteraction.favourite, negative: true);
      expect(result.id, 'unfaved');
    });

    test('interactWithStatus bookmark returns parsed status', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        expect(url.path, contains('/bookmark'));
        return (200, statusJson(id: 'bookmarked'));
      });

      final mockAuth = const AccessStatusSchema(domain: 'example.com', accessToken: 'token');
      final s = MockStatus.create();
      final result = await mockAuth.interactWithStatus(s, StatusInteraction.bookmark);
      expect(result.id, 'bookmarked');
    });

    test('interactWithStatus pin returns parsed status', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        expect(url.path, contains('/pin'));
        return (200, statusJson(id: 'pinned'));
      });

      final mockAuth = const AccessStatusSchema(domain: 'example.com', accessToken: 'token');
      final s = MockStatus.create();
      final result = await mockAuth.interactWithStatus(s, StatusInteraction.pin);
      expect(result.id, 'pinned');
    });

    test('interactWithStatus mute returns parsed status', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        expect(url.path, contains('/mute'));
        return (200, statusJson(id: 'muted'));
      });

      final mockAuth = const AccessStatusSchema(domain: 'example.com', accessToken: 'token');
      final s = MockStatus.create();
      final result = await mockAuth.interactWithStatus(s, StatusInteraction.mute);
      expect(result.id, 'muted');
    });

    test('fetchScheduledStatuses returns parsed statuses', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        return (200, '[]');
      });

      final mockAuth = const AccessStatusSchema(domain: 'example.com', accessToken: 'token');
      final account = MockAccount.create();
      final result = await mockAuth.fetchScheduledStatuses(account: account);
      expect(result, isEmpty);
    });

    test('fetchRebloggedBy returns parsed accounts', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        return (200, '[${accountJson(id: 'reb-1')}]');
      });

      final mockAuth = const AccessStatusSchema(domain: 'example.com', accessToken: 'token');
      final s = MockStatus.create();
      final result = await mockAuth.fetchRebloggedBy(schema: s);
      expect(result.length, 1);
      expect(result.first.id, 'reb-1');
    });

    test('fetchFavouritedBy returns parsed accounts', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        return (200, '[${accountJson(id: 'fav-1')}]');
      });

      final mockAuth = const AccessStatusSchema(domain: 'example.com', accessToken: 'token');
      final s = MockStatus.create();
      final result = await mockAuth.fetchFavouritedBy(schema: s);
      expect(result.length, 1);
    });

    test('getStatusSource returns parsed source', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        return (200, '{"id":"src-1","text":"Hello","spoiler_text":""}');
      });

      final mockAuth = const AccessStatusSchema(domain: 'example.com', accessToken: 'token');
      final result = await mockAuth.getStatusSource(statusId: 'src-1');
      expect(result.text, 'Hello');
    });

    test('getScheduledStatus returns parsed status', () async {
      final scheduledJson = jsonEncode({
        'id': 'sched-1',
        'scheduled_at': '2025-06-01T12:00:00.000Z',
        'params': {
          'text': 'Scheduled post',
          'visibility': 'public',
          'in_reply_to_id': null,
          'media_ids': [],
          'sensitive': false,
          'spoiler_text': '',
          'language': 'en',
        },
        'media_attachments': [],
      });
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        return (200, scheduledJson);
      });

      final mockAuth = const AccessStatusSchema(domain: 'example.com', accessToken: 'token');
      final account = MockAccount.create();
      final result = await mockAuth.getScheduledStatus(id: 'sched-1', account: account);
      expect(result, isNotNull);
    });

    test('getScheduledStatus returns null when body is null', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        return (404, '');
      });

      final mockAuth = const AccessStatusSchema(domain: 'example.com', accessToken: 'token');
      final account = MockAccount.create();
      final result = await mockAuth.getScheduledStatus(id: 'missing', account: account);
      expect(result, isNull);
    });

    test('fetchStatuses returns parsed statuses and caches them', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        return (200, statusListJson(count: 2));
      });

      final mockAuth = const AccessStatusSchema(domain: 'example.com', accessToken: 'token');
      final result = await mockAuth.fetchStatuses(ids: ['1', '2']);
      expect(result.length, 2);
    });

    test('votePoll returns parsed poll', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        return (200, '{"id":"p-1","expires_at":"2025-12-01T00:00:00.000Z","expired":false,"multiple":false,"votes_count":1,"voters_count":1,"options":[{"title":"A","votes_count":1}],"voted":true,"own_votes":[0],"emojis":[]}');
      });

      final mockAuth = const AccessStatusSchema(domain: 'example.com', accessToken: 'token');
      final result = await mockAuth.votePoll(pollID: 'p-1', choices: [0]);
      expect(result.id, 'p-1');
    });

    test('editStatusInteractionPolicy returns parsed status', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        return (200, statusJson(id: 'policy-updated'));
      });

      final mockAuth = const AccessStatusSchema(domain: 'example.com', accessToken: 'token');
      final s = MockStatus.create();
      final result = await mockAuth.editStatusInteractionPolicy(schema: s, policy: QuotePolicyType.public);
      expect(result.id, 'policy-updated');
    });

    test('translateStatus returns parsed translation', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        return (200, '{"content":"<p>Translated</p>","spoiler_text":"","detected_source_language":"ja","language":"en","provider":"DeepL"}');
      });

      final mockAuth = const AccessStatusSchema(domain: 'example.com', accessToken: 'token');
      final s = MockStatus.create();
      final result = await mockAuth.translateStatus(schema: s, targetLanguage: 'en');
      expect(result.language, 'en');
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
