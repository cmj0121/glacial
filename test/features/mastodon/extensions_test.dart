// Tests for mastodon extensions: activeKeyMatchesDomain, token CRUD, saved accounts.
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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

  group('Storage token CRUD with FlutterSecureStorage', () {
    setUp(() async {
      FlutterSecureStorage.setMockInitialValues({});
      SharedPreferences.setMockInitialValues({});
      await Storage.init();
    });

    test('saveAccessToken and loadAccessToken round-trip', () async {
      final storage = Storage();
      await storage.saveAccessToken('example.com@42', 'my-secret-token');
      final loaded = await storage.loadAccessToken('example.com@42');
      expect(loaded, 'my-secret-token');
    });

    test('saveAccessToken overwrites existing token', () async {
      final storage = Storage();
      await storage.saveAccessToken('example.com@42', 'old-token');
      await storage.saveAccessToken('example.com@42', 'new-token');
      final loaded = await storage.loadAccessToken('example.com@42');
      expect(loaded, 'new-token');
    });

    test('saveAccessToken with null removes the key', () async {
      final storage = Storage();
      await storage.saveAccessToken('example.com@42', 'my-token');
      await storage.saveAccessToken('example.com@42', null);
      final loaded = await storage.loadAccessToken('example.com@42');
      expect(loaded, isNull);
    });

    test('saveAccessToken with empty string removes the key', () async {
      final storage = Storage();
      await storage.saveAccessToken('example.com@42', 'my-token');
      await storage.saveAccessToken('example.com@42', '');
      final loaded = await storage.loadAccessToken('example.com@42');
      expect(loaded, isNull);
    });

    test('loadAccessToken returns null for unknown key', () async {
      final storage = Storage();
      final loaded = await storage.loadAccessToken('unknown.com@99');
      expect(loaded, isNull);
    });

    test('removeAccessToken removes the token', () async {
      final storage = Storage();
      await storage.saveAccessToken('example.com@42', 'my-token');
      await storage.removeAccessToken('example.com@42');
      final loaded = await storage.loadAccessToken('example.com@42');
      expect(loaded, isNull);
    });

    test('multiple tokens stored independently', () async {
      final storage = Storage();
      await storage.saveAccessToken('a.com@1', 'token-a');
      await storage.saveAccessToken('b.com@2', 'token-b');
      expect(await storage.loadAccessToken('a.com@1'), 'token-a');
      expect(await storage.loadAccessToken('b.com@2'), 'token-b');
    });

    test('removeAccessToken only removes the specified key', () async {
      final storage = Storage();
      await storage.saveAccessToken('a.com@1', 'token-a');
      await storage.saveAccessToken('b.com@2', 'token-b');
      await storage.removeAccessToken('a.com@1');
      expect(await storage.loadAccessToken('a.com@1'), isNull);
      expect(await storage.loadAccessToken('b.com@2'), 'token-b');
    });

    test('removeSavedAccount removes account and its token', () async {
      final storage = Storage();
      await storage.saveAccessToken('example.com@42', 'my-token');
      await storage.addSavedAccount(SavedAccountSchema(
        domain: 'example.com',
        accountId: '42',
        username: 'user',
        displayName: 'User',
        avatar: 'https://example.com/avatar.png',
        lastUsed: DateTime(2024, 1, 1),
      ));
      await storage.removeSavedAccount('example.com@42');
      final accounts = await storage.loadSavedAccounts();
      expect(accounts, isEmpty);
      final token = await storage.loadAccessToken('example.com@42');
      expect(token, isNull);
    });

    test('saveAccessStatus persists schema JSON', () async {
      final storage = Storage();
      final schema = const AccessStatusSchema(
        domain: 'example.com',
        accessToken: 'test-token',
      );
      await storage.saveAccessStatus(schema);
      final String? raw = await storage.getString(AccessStatusSchema.key);
      expect(raw, isNotNull);
      expect(raw!, contains('example.com'));
    });

    test('logout with null schema completes without error', () async {
      final storage = Storage();
      await storage.logout(null);
    });

    test('logout with empty domain schema resets to explorer', () async {
      final storage = Storage();
      final schema = const AccessStatusSchema(domain: '');
      await storage.logout(schema);
      final String? raw = await storage.getString(AccessStatusSchema.key);
      expect(raw, isNotNull);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
