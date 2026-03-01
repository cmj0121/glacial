// Tests for status API extensions (no-domain and valid-domain HTTP exercise).
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
}

// vim: set ts=2 sw=2 sts=2 et:
