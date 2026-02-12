import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/features/models.dart';

void main() {
  group('SavedAccountSchema', () {
    Map<String, dynamic> accountJson({
      String domain = 'mastodon.social',
      String accountId = '12345',
      String username = 'testuser',
      String displayName = 'Test User',
      String avatar = 'https://example.com/avatar.png',
      String lastUsed = '2024-01-15T10:30:00.000Z',
    }) => {
      'domain': domain,
      'account_id': accountId,
      'username': username,
      'display_name': displayName,
      'avatar': avatar,
      'last_used': lastUsed,
    };

    test('fromJson parses all fields', () {
      final json = accountJson();
      final account = SavedAccountSchema.fromJson(json);

      expect(account.domain, 'mastodon.social');
      expect(account.accountId, '12345');
      expect(account.username, 'testuser');
      expect(account.displayName, 'Test User');
      expect(account.avatar, 'https://example.com/avatar.png');
      expect(account.lastUsed, DateTime.utc(2024, 1, 15, 10, 30));
    });

    test('toJson produces correct output', () {
      final account = SavedAccountSchema.fromJson(accountJson());
      final json = account.toJson();

      expect(json['domain'], 'mastodon.social');
      expect(json['account_id'], '12345');
      expect(json['username'], 'testuser');
      expect(json['display_name'], 'Test User');
      expect(json['avatar'], 'https://example.com/avatar.png');
      expect(json['last_used'], isNotNull);
    });

    test('fromJson/toJson symmetry', () {
      final original = accountJson();
      final account = SavedAccountSchema.fromJson(original);
      final json = account.toJson();

      expect(json['domain'], original['domain']);
      expect(json['account_id'], original['account_id']);
      expect(json['username'], original['username']);
      expect(json['display_name'], original['display_name']);
      expect(json['avatar'], original['avatar']);
    });

    test('fromJson round-trip via JSON string', () {
      final account = SavedAccountSchema.fromJson(accountJson());
      final str = jsonEncode(account.toJson());
      final rebuilt = SavedAccountSchema.fromJson(jsonDecode(str));

      expect(rebuilt.domain, account.domain);
      expect(rebuilt.accountId, account.accountId);
      expect(rebuilt.username, account.username);
      expect(rebuilt.displayName, account.displayName);
    });

    test('compositeKey format is domain@accountId', () {
      final account = SavedAccountSchema.fromJson(accountJson());

      expect(account.compositeKey, 'mastodon.social@12345');
    });

    test('compositeKey with different domain and id', () {
      final account = SavedAccountSchema.fromJson(accountJson(
        domain: 'fosstodon.org',
        accountId: '99999',
      ));

      expect(account.compositeKey, 'fosstodon.org@99999');
    });

    test('copyWith updates specified fields', () {
      final original = SavedAccountSchema.fromJson(accountJson());
      final updated = original.copyWith(
        displayName: 'New Name',
        avatar: 'https://example.com/new-avatar.png',
      );

      expect(updated.displayName, 'New Name');
      expect(updated.avatar, 'https://example.com/new-avatar.png');
      // Unchanged fields
      expect(updated.domain, original.domain);
      expect(updated.accountId, original.accountId);
      expect(updated.username, original.username);
      expect(updated.lastUsed, original.lastUsed);
    });

    test('copyWith with no changes returns equivalent object', () {
      final original = SavedAccountSchema.fromJson(accountJson());
      final copy = original.copyWith();

      expect(copy.domain, original.domain);
      expect(copy.accountId, original.accountId);
      expect(copy.username, original.username);
      expect(copy.displayName, original.displayName);
      expect(copy.avatar, original.avatar);
      expect(copy.compositeKey, original.compositeKey);
    });

    test('copyWith lastUsed updates timestamp', () {
      final original = SavedAccountSchema.fromJson(accountJson());
      final newTime = DateTime(2025, 6, 1);
      final updated = original.copyWith(lastUsed: newTime);

      expect(updated.lastUsed, newTime);
      expect(original.lastUsed, isNot(newTime));
    });

    test('list serialization round-trip', () {
      final accounts = [
        SavedAccountSchema.fromJson(accountJson()),
        SavedAccountSchema.fromJson(accountJson(
          domain: 'fosstodon.org',
          accountId: '67890',
          username: 'otheruser',
        )),
      ];

      final json = jsonEncode(accounts.map((a) => a.toJson()).toList());
      final parsed = (jsonDecode(json) as List<dynamic>)
          .map((e) => SavedAccountSchema.fromJson(e as Map<String, dynamic>))
          .toList();

      expect(parsed.length, 2);
      expect(parsed[0].compositeKey, 'mastodon.social@12345');
      expect(parsed[1].compositeKey, 'fosstodon.org@67890');
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
