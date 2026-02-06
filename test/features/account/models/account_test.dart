import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/features/account/models/account.dart';

void main() {
  group('AccountSchema', () {
    test('fromJson parses minimal required fields', () {
      final json = {
        'id': '123',
        'username': 'testuser',
        'acct': 'testuser',
        'url': 'https://example.com/@testuser',
        'display_name': 'Test User',
        'note': '<p>Bio here</p>',
        'avatar': 'https://example.com/avatar.png',
        'avatar_static': 'https://example.com/avatar.png',
        'header': 'https://example.com/header.png',
        'locked': false,
        'bot': false,
        'indexable': true,
        'created_at': '2024-01-01T00:00:00.000Z',
        'statuses_count': 100,
        'followers_count': 50,
        'following_count': 25,
      };

      final account = AccountSchema.fromJson(json);

      expect(account.id, '123');
      expect(account.username, 'testuser');
      expect(account.acct, 'testuser');
      expect(account.url, 'https://example.com/@testuser');
      expect(account.displayName, 'Test User');
      expect(account.note, '<p>Bio here</p>');
      expect(account.avatar, 'https://example.com/avatar.png');
      expect(account.locked, false);
      expect(account.bot, false);
      expect(account.indexable, true);
      expect(account.statusesCount, 100);
      expect(account.followersCount, 50);
      expect(account.followingCount, 25);
    });

    test('fromJson parses remote user acct', () {
      final json = {
        'id': '456',
        'username': 'remoteuser',
        'acct': 'remoteuser@remote.server',
        'url': 'https://remote.server/@remoteuser',
        'display_name': 'Remote User',
        'note': '',
        'avatar': 'https://remote.server/avatar.png',
        'avatar_static': 'https://remote.server/avatar.png',
        'header': 'https://remote.server/header.png',
        'locked': true,
        'bot': true,
        'indexable': false,
        'created_at': '2023-06-15T12:30:00.000Z',
        'statuses_count': 0,
        'followers_count': 0,
        'following_count': 0,
      };

      final account = AccountSchema.fromJson(json);

      expect(account.acct, 'remoteuser@remote.server');
      expect(account.locked, true);
      expect(account.bot, true);
    });

    test('fromJson parses optional fields', () {
      final json = {
        'id': '789',
        'username': 'user',
        'acct': 'user',
        'uri': 'https://example.com/users/789',
        'url': 'https://example.com/@user',
        'display_name': 'User',
        'note': '',
        'avatar': 'https://example.com/avatar.png',
        'avatar_static': 'https://example.com/avatar.png',
        'header': 'https://example.com/header.png',
        'locked': false,
        'bot': false,
        'discoverable': true,
        'indexable': true,
        'noindex': false,
        'hide_collections': true,
        'created_at': '2024-01-01T00:00:00.000Z',
        'last_status_at': '2024-12-01T00:00:00.000Z',
        'statuses_count': 10,
        'followers_count': 5,
        'following_count': 3,
      };

      final account = AccountSchema.fromJson(json);

      expect(account.uri, 'https://example.com/users/789');
      expect(account.discoverable, true);
      expect(account.noindex, false);
      expect(account.hideCollections, true);
      expect(account.lastStatusAt, isNotNull);
    });

    test('fromJson parses fields array', () {
      final json = {
        'id': '123',
        'username': 'user',
        'acct': 'user',
        'url': 'https://example.com/@user',
        'display_name': 'User',
        'note': '',
        'avatar': 'https://example.com/avatar.png',
        'avatar_static': 'https://example.com/avatar.png',
        'header': 'https://example.com/header.png',
        'locked': false,
        'bot': false,
        'indexable': true,
        'created_at': '2024-01-01T00:00:00.000Z',
        'statuses_count': 0,
        'followers_count': 0,
        'following_count': 0,
        'fields': [
          {'name': 'Website', 'value': 'https://example.com', 'verified_at': '2024-01-01T00:00:00.000Z'},
          {'name': 'Location', 'value': 'Earth'},
        ],
      };

      final account = AccountSchema.fromJson(json);

      expect(account.fields.length, 2);
      expect(account.fields[0].name, 'Website');
      expect(account.fields[0].value, 'https://example.com');
      expect(account.fields[0].verifiedAt, isNotNull);
      expect(account.fields[1].name, 'Location');
      expect(account.fields[1].verifiedAt, isNull);
    });

    test('fromJson parses emojis array', () {
      final json = {
        'id': '123',
        'username': 'user',
        'acct': 'user',
        'url': 'https://example.com/@user',
        'display_name': 'User :custom:',
        'note': '',
        'avatar': 'https://example.com/avatar.png',
        'avatar_static': 'https://example.com/avatar.png',
        'header': 'https://example.com/header.png',
        'locked': false,
        'bot': false,
        'indexable': true,
        'created_at': '2024-01-01T00:00:00.000Z',
        'statuses_count': 0,
        'followers_count': 0,
        'following_count': 0,
        'emojis': [
          {
            'shortcode': 'custom',
            'url': 'https://example.com/emoji.png',
            'static_url': 'https://example.com/emoji.png',
            'visible_in_picker': true,
          },
        ],
      };

      final account = AccountSchema.fromJson(json);

      expect(account.emojis.length, 1);
      expect(account.emojis[0].shortcode, 'custom');
    });

    test('fromJson handles empty fields and emojis', () {
      final json = {
        'id': '123',
        'username': 'user',
        'acct': 'user',
        'url': 'https://example.com/@user',
        'display_name': 'User',
        'note': '',
        'avatar': 'https://example.com/avatar.png',
        'avatar_static': 'https://example.com/avatar.png',
        'header': 'https://example.com/header.png',
        'locked': false,
        'bot': false,
        'indexable': true,
        'created_at': '2024-01-01T00:00:00.000Z',
        'statuses_count': 0,
        'followers_count': 0,
        'following_count': 0,
        'fields': null,
        'emojis': null,
      };

      final account = AccountSchema.fromJson(json);

      expect(account.fields, isEmpty);
      expect(account.emojis, isEmpty);
    });
  });

  group('FieldSchema', () {
    test('fromJson parses all fields', () {
      final json = {
        'name': 'Website',
        'value': '<a href="https://example.com">example.com</a>',
        'verified_at': '2024-01-15T10:30:00.000Z',
      };

      final field = FieldSchema.fromJson(json);

      expect(field.name, 'Website');
      expect(field.value, '<a href="https://example.com">example.com</a>');
      expect(field.verifiedAt, '2024-01-15T10:30:00.000Z');
    });

    test('fromJson handles null verified_at', () {
      final json = {
        'name': 'Location',
        'value': 'Earth',
      };

      final field = FieldSchema.fromJson(json);

      expect(field.name, 'Location');
      expect(field.value, 'Earth');
      expect(field.verifiedAt, isNull);
    });

    test('toJson produces correct output', () {
      const field = FieldSchema(
        name: 'Website',
        value: 'https://example.com',
        verifiedAt: '2024-01-15T10:30:00.000Z',
      );

      final json = field.toJson();

      expect(json['name'], 'Website');
      expect(json['value'], 'https://example.com');
      // toJson doesn't include verified_at
      expect(json.containsKey('verified_at'), isFalse);
    });
  });

  group('AccountCredentialSchema', () {
    test('toJson produces correct output', () {
      const credentials = AccountCredentialSchema(
        displayName: 'Test User',
        note: 'My bio',
        locked: false,
        bot: false,
        discoverable: true,
        hideCollections: false,
        indexable: true,
        fields: [
          FieldSchema(name: 'Website', value: 'https://example.com'),
        ],
      );

      final json = credentials.toJson();

      expect(json['display_name'], 'Test User');
      expect(json['note'], 'My bio');
      expect(json['locked'], false);
      expect(json['bot'], false);
      expect(json['discoverable'], true);
      expect(json['hide_collections'], false);
      expect(json['indexable'], true);
      expect(json['fields_attributes'], isNotNull);
    });

    test('copyWith creates new instance with updated values', () {
      const original = AccountCredentialSchema(
        displayName: 'Original',
        note: 'Original note',
        locked: false,
        bot: false,
        discoverable: true,
        hideCollections: false,
        indexable: true,
      );

      final updated = original.copyWith(
        displayName: 'Updated',
        locked: true,
      );

      expect(updated.displayName, 'Updated');
      expect(updated.locked, true);
      // Unchanged values
      expect(updated.note, 'Original note');
      expect(updated.bot, false);
    });
  });
}
