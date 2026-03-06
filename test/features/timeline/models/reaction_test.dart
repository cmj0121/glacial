// Unit tests for ReactionSchema parsing in StatusSchema.
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/features/models.dart';

void main() {
  group('StatusSchema reactions field', () {
    test('parses empty reactions list', () {
      final json = _createStatusJson(reactions: []);
      final status = StatusSchema.fromJson(json);

      expect(status.reactions, isEmpty);
    });

    test('parses unicode emoji reactions', () {
      final json = _createStatusJson(reactions: [
        {'name': '👍', 'count': 5, 'me': true},
        {'name': '❤️', 'count': 3, 'me': false},
      ]);
      final status = StatusSchema.fromJson(json);

      expect(status.reactions.length, 2);
      expect(status.reactions[0].name, '👍');
      expect(status.reactions[0].count, 5);
      expect(status.reactions[0].me, true);
      expect(status.reactions[1].name, '❤️');
      expect(status.reactions[1].count, 3);
      expect(status.reactions[1].me, false);
    });

    test('parses custom emoji reactions with url', () {
      final json = _createStatusJson(reactions: [
        {
          'name': 'blobcat',
          'count': 2,
          'me': false,
          'url': 'https://example.com/emoji/blobcat.png',
          'static_url': 'https://example.com/emoji/blobcat_static.png',
        },
      ]);
      final status = StatusSchema.fromJson(json);

      expect(status.reactions.length, 1);
      expect(status.reactions[0].name, 'blobcat');
      expect(status.reactions[0].url, 'https://example.com/emoji/blobcat.png');
      expect(status.reactions[0].staticUrl, 'https://example.com/emoji/blobcat_static.png');
    });

    test('handles missing reactions field as empty list', () {
      final json = _createStatusJson();
      json.remove('reactions');
      final status = StatusSchema.fromJson(json);

      expect(status.reactions, isEmpty);
    });

    test('parses reactions from JSON string', () {
      final json = _createStatusJson(reactions: [
        {'name': '🎉', 'count': 1, 'me': true},
      ]);
      final status = StatusSchema.fromString(jsonEncode(json));

      expect(status.reactions.length, 1);
      expect(status.reactions[0].name, '🎉');
    });
  });
}

Map<String, dynamic> _createStatusJson({List<Map<String, dynamic>>? reactions}) {
  return {
    'id': '123',
    'content': '<p>Test</p>',
    'visibility': 'public',
    'sensitive': false,
    'spoiler_text': '',
    'account': {
      'id': '1',
      'username': 'test',
      'acct': 'test',
      'url': 'https://example.com/@test',
      'display_name': 'Test',
      'note': '',
      'avatar': 'https://example.com/avatar.png',
      'avatar_static': 'https://example.com/avatar.png',
      'header': 'https://example.com/header.png',
      'locked': false,
      'bot': false,
      'indexable': true,
      'created_at': '2023-01-01T00:00:00.000Z',
      'statuses_count': 0,
      'followers_count': 0,
      'following_count': 0,
    },
    'uri': 'https://example.com/statuses/123',
    'reblogs_count': 0,
    'favourites_count': 0,
    'replies_count': 0,
    'created_at': '2024-01-01T00:00:00.000Z',
    if (reactions != null) 'reactions': reactions,
  };
}

// vim: set ts=2 sw=2 sts=2 et:
