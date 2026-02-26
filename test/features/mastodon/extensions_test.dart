// Tests for mastodon extensions: activeKeyMatchesDomain, token CRUD, saved accounts.
import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/features/mastodon/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:glacial/core.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('activeKeyMatchesDomain', () {
    test('returns true when activeKey is null', () {
      expect(activeKeyMatchesDomain(null, 'example.com'), true);
    });

    test('returns true when domain is null', () {
      expect(activeKeyMatchesDomain('example.com@123', null), true);
    });

    test('returns true when both are null', () {
      expect(activeKeyMatchesDomain(null, null), true);
    });

    test('returns true for matching composite key', () {
      expect(activeKeyMatchesDomain('example.com@123', 'example.com'), true);
    });

    test('returns true for matching plain domain key', () {
      expect(activeKeyMatchesDomain('example.com', 'example.com'), true);
    });

    test('returns false for non-matching domain', () {
      expect(activeKeyMatchesDomain('other.com@123', 'example.com'), false);
    });

    test('returns false when key domain prefix does not match', () {
      expect(activeKeyMatchesDomain('notexample.com@123', 'example.com'), false);
    });
  });

  group('SavedAccountSchema', () {
    test('compositeKey format', () {
      final saved = SavedAccountSchema(
        domain: 'mastodon.social',
        accountId: '42',
        username: 'user',
        displayName: 'User',
        avatar: 'https://example.com/avatar.png',
        lastUsed: DateTime(2024, 1, 1),
      );
      expect(saved.compositeKey, 'mastodon.social@42');
    });

    test('toJson and fromJson round-trip', () {
      final saved = SavedAccountSchema(
        domain: 'example.com',
        accountId: '99',
        username: 'testuser',
        displayName: 'Test User',
        avatar: 'https://example.com/avatar.png',
        lastUsed: DateTime(2024, 6, 15),
      );
      final json = saved.toJson();
      final restored = SavedAccountSchema.fromJson(json);
      expect(restored.domain, 'example.com');
      expect(restored.accountId, '99');
      expect(restored.username, 'testuser');
      expect(restored.compositeKey, 'example.com@99');
    });

    test('copyWith updates lastUsed', () {
      final saved = SavedAccountSchema(
        domain: 'example.com',
        accountId: '1',
        username: 'user',
        displayName: 'User',
        avatar: 'https://example.com/avatar.png',
        lastUsed: DateTime(2024, 1, 1),
      );
      final updated = saved.copyWith(lastUsed: DateTime(2024, 6, 15));
      expect(updated.lastUsed, DateTime(2024, 6, 15));
      expect(updated.domain, 'example.com');
    });
  });

  group('Storage token operations', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await Storage.init();
    });

    test('loadAccessToken returns null for null key', () async {
      final storage = Storage();
      final result = await storage.loadAccessToken(null);
      expect(result, isNull);
    });

    test('loadAccessToken returns null for empty key', () async {
      final storage = Storage();
      final result = await storage.loadAccessToken('');
      expect(result, isNull);
    });

    test('removeAccessToken does nothing for null key', () async {
      final storage = Storage();
      await storage.removeAccessToken(null);
    });

    test('removeAccessToken does nothing for empty key', () async {
      final storage = Storage();
      await storage.removeAccessToken('');
    });

    test('loadSavedAccounts returns empty list when no data', () async {
      final storage = Storage();
      final result = await storage.loadSavedAccounts();
      expect(result, isEmpty);
    });

    test('addSavedAccount and loadSavedAccounts round-trip', () async {
      final storage = Storage();
      final saved = SavedAccountSchema(
        domain: 'example.com',
        accountId: '1',
        username: 'user',
        displayName: 'User',
        avatar: 'https://example.com/avatar.png',
        lastUsed: DateTime(2024, 1, 1),
      );
      await storage.addSavedAccount(saved);
      final accounts = await storage.loadSavedAccounts();
      expect(accounts, hasLength(1));
      expect(accounts.first.compositeKey, 'example.com@1');
    });

    test('addSavedAccount updates existing account', () async {
      final storage = Storage();
      final saved1 = SavedAccountSchema(
        domain: 'example.com',
        accountId: '1',
        username: 'user',
        displayName: 'Old Name',
        avatar: 'https://example.com/avatar.png',
        lastUsed: DateTime(2024, 1, 1),
      );
      final saved2 = SavedAccountSchema(
        domain: 'example.com',
        accountId: '1',
        username: 'user',
        displayName: 'New Name',
        avatar: 'https://example.com/avatar.png',
        lastUsed: DateTime(2024, 6, 15),
      );
      await storage.addSavedAccount(saved1);
      await storage.addSavedAccount(saved2);
      final accounts = await storage.loadSavedAccounts();
      expect(accounts, hasLength(1));
      expect(accounts.first.displayName, 'New Name');
    });

    test('addSavedAccount preserves multiple accounts', () async {
      final storage = Storage();
      for (int i = 1; i <= 3; i++) {
        await storage.addSavedAccount(SavedAccountSchema(
          domain: 'example.com',
          accountId: '$i',
          username: 'user$i',
          displayName: 'User $i',
          avatar: 'https://example.com/avatar$i.png',
          lastUsed: DateTime(2024, 1, i),
        ));
      }
      final accounts = await storage.loadSavedAccounts();
      expect(accounts, hasLength(3));
    });

    // Note: removeSavedAccount uses FlutterSecureStorage (removeAccessToken)
    // which is not available in unit tests. Tested via widget/integration tests.
  });
}

// vim: set ts=2 sw=2 sts=2 et:
