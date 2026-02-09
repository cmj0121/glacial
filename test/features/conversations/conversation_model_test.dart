// Unit tests for ConversationSchema model.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/features/models.dart';

void main() {
  group('ConversationSchema', () {
    test('fromJson parses all fields correctly', () {
      final Map<String, dynamic> json = {
        'id': '42',
        'accounts': [
          {
            'id': '1',
            'username': 'alice',
            'acct': 'alice',
            'url': 'https://example.com/@alice',
            'display_name': 'Alice',
            'note': 'Hello',
            'avatar': 'https://example.com/avatar.png',
            'avatar_static': 'https://example.com/avatar.png',
            'header': 'https://example.com/header.png',
            'locked': false,
            'bot': false,
            'indexable': true,
            'created_at': '2023-01-01T00:00:00.000Z',
            'statuses_count': 10,
            'followers_count': 5,
            'following_count': 3,
          },
        ],
        'last_status': {
          'id': '99',
          'content': '<p>Hello there</p>',
          'visibility': 'direct',
          'sensitive': false,
          'spoiler_text': '',
          'uri': 'https://example.com/statuses/99',
          'reblogs_count': 0,
          'favourites_count': 0,
          'replies_count': 0,
          'created_at': '2024-01-15T10:30:00.000Z',
          'account': {
            'id': '1',
            'username': 'alice',
            'acct': 'alice',
            'url': 'https://example.com/@alice',
            'display_name': 'Alice',
            'note': 'Hello',
            'avatar': 'https://example.com/avatar.png',
            'avatar_static': 'https://example.com/avatar.png',
            'header': 'https://example.com/header.png',
            'locked': false,
            'bot': false,
            'indexable': true,
            'created_at': '2023-01-01T00:00:00.000Z',
            'statuses_count': 10,
            'followers_count': 5,
            'following_count': 3,
          },
        },
        'unread': true,
      };

      final ConversationSchema conversation = ConversationSchema.fromJson(json);

      expect(conversation.id, '42');
      expect(conversation.accounts.length, 1);
      expect(conversation.accounts.first.username, 'alice');
      expect(conversation.lastStatus, isNotNull);
      expect(conversation.lastStatus!.id, '99');
      expect(conversation.lastStatus!.content, '<p>Hello there</p>');
      expect(conversation.unread, true);
    });

    test('fromJson handles null last_status', () {
      final Map<String, dynamic> json = {
        'id': '43',
        'accounts': [],
        'last_status': null,
        'unread': false,
      };

      final ConversationSchema conversation = ConversationSchema.fromJson(json);

      expect(conversation.id, '43');
      expect(conversation.accounts, isEmpty);
      expect(conversation.lastStatus, isNull);
      expect(conversation.unread, false);
    });

    test('fromJson handles missing unread field', () {
      final Map<String, dynamic> json = {
        'id': '44',
        'accounts': [],
      };

      final ConversationSchema conversation = ConversationSchema.fromJson(json);

      expect(conversation.id, '44');
      expect(conversation.unread, false);
    });

    test('fromJson parses multiple accounts', () {
      final Map<String, dynamic> json = {
        'id': '45',
        'accounts': [
          {
            'id': '1', 'username': 'alice', 'acct': 'alice',
            'url': 'https://example.com/@alice', 'display_name': 'Alice',
            'note': '', 'avatar': '', 'avatar_static': '', 'header': '',
            'locked': false, 'bot': false, 'indexable': true,
            'created_at': '2023-01-01T00:00:00.000Z',
            'statuses_count': 0, 'followers_count': 0, 'following_count': 0,
          },
          {
            'id': '2', 'username': 'bob', 'acct': 'bob',
            'url': 'https://example.com/@bob', 'display_name': 'Bob',
            'note': '', 'avatar': '', 'avatar_static': '', 'header': '',
            'locked': false, 'bot': false, 'indexable': true,
            'created_at': '2023-01-01T00:00:00.000Z',
            'statuses_count': 0, 'followers_count': 0, 'following_count': 0,
          },
        ],
        'unread': false,
      };

      final ConversationSchema conversation = ConversationSchema.fromJson(json);

      expect(conversation.accounts.length, 2);
      expect(conversation.accounts[0].username, 'alice');
      expect(conversation.accounts[1].username, 'bob');
    });

    test('fromString parses JSON string correctly', () {
      final Map<String, dynamic> json = {
        'id': '46',
        'accounts': [],
        'unread': true,
      };

      final ConversationSchema conversation = ConversationSchema.fromString(jsonEncode(json));

      expect(conversation.id, '46');
      expect(conversation.unread, true);
    });

    test('const constructor creates immutable instance', () {
      final AccountSchema account = AccountSchema(
        id: '1', username: 'test', acct: 'test',
        url: '', displayName: 'Test', note: '',
        avatar: '', avatarStatic: '', header: '',
        locked: false, bot: false, indexable: true,
        createdAt: DateTime(2023),
        statusesCount: 0, followersCount: 0, followingCount: 0,
      );

      const ConversationSchema conversation = ConversationSchema(
        id: '47',
        accounts: [],
        unread: false,
      );

      expect(conversation.id, '47');
      expect(conversation.accounts, isEmpty);
      expect(conversation.lastStatus, isNull);

      final ConversationSchema withAccounts = ConversationSchema(
        id: '48',
        accounts: [account],
        unread: true,
      );

      expect(withAccounts.accounts.length, 1);
      expect(withAccounts.unread, true);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
