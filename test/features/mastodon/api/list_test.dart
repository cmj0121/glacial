// Tests for list API extensions.
import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/mastodon/extensions.dart';

void main() {
  AccessStatusSchema noDomainAuth() =>
      const AccessStatusSchema(domain: '', accessToken: 'token');

  const auth = AccessStatusSchema(
    domain: 'nonexistent-server-12345.invalid',
    accessToken: 'test-token',
  );

  group('ListsExtensions with no domain', () {
    test('getLists completes when no domain', () async {
      final result = await noDomainAuth().getLists();
      expect(result, isA<List<ListSchema>>());
    });

    test('getList returns null when no domain', () async {
      final result = await noDomainAuth().getList('list-1');
      expect(result, isNull);
    });

    test('createList throws when no domain (model parse error)', () {
      expect(() => noDomainAuth().createList(title: 'Test List'), throwsA(anything));
    });

    test('updateList throws when no domain (model parse error)', () {
      expect(() => noDomainAuth().updateList(id: 'l-1', title: 'Updated'), throwsA(anything));
    });

    test('deleteList completes when no domain', () async {
      await noDomainAuth().deleteList('l-1');
    });

    test('getListAccounts completes when no domain', () async {
      final result = await noDomainAuth().getListAccounts('l-1');
      expect(result, isA<List<AccountSchema>>());
    });

    test('addAccountsToList completes when no domain', () async {
      await noDomainAuth().addAccountsToList('l-1', ['acc-1', 'acc-2']);
    });

    test('removeAccountsFromList completes when no domain', () async {
      await noDomainAuth().removeAccountsFromList('l-1', ['acc-1']);
    });
  });

  group('ListsExtensions with valid domain exercises HTTP call lines', () {
    // GET methods catch errors (getAPI swallows exceptions)
    test('getLists completes with empty list on network error', () async {
      final result = await auth.getLists();
      expect(result, isEmpty);
    });

    test('getList returns null on network error', () async {
      final result = await auth.getList('list-1');
      expect(result, isNull);
    });

    test('getListAccounts completes with empty list on network error', () async {
      final result = await auth.getListAccounts('l-1');
      expect(result, isEmpty);
    });

    // POST/PUT/DELETE methods throw on network error
    test('createList throws on network error', () {
      expect(
        () => auth.createList(title: 'Test', replyPolicy: ReplyPolicyType.followed, exclusive: true),
        throwsA(anything),
      );
    });

    test('updateList throws on network error', () {
      expect(
        () => auth.updateList(id: 'l-1', title: 'Updated', replyPolicy: ReplyPolicyType.none, exclusive: false),
        throwsA(anything),
      );
    });

    test('deleteList throws on network error', () {
      expect(() => auth.deleteList('l-1'), throwsA(anything));
    });

    test('addAccountsToList throws on network error', () {
      expect(
        () => auth.addAccountsToList('l-1', ['acc-1']),
        throwsA(anything),
      );
    });

    test('removeAccountsFromList throws on network error', () {
      expect(
        () => auth.removeAccountsFromList('l-1', ['acc-1']),
        throwsA(anything),
      );
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
