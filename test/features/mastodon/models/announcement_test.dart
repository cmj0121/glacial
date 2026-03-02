// Tests for AnnouncementSchema and ReactionSchema fromJson.
import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/features/models.dart';

void main() {
  group('ReactionSchema', () {
    test('fromJson parses all fields', () {
      final json = {
        'name': '🎉',
        'count': 5,
        'me': true,
        'url': 'https://example.com/emoji.png',
        'static_url': 'https://example.com/emoji_static.png',
      };
      final reaction = ReactionSchema.fromJson(json);
      expect(reaction.name, '🎉');
      expect(reaction.count, 5);
      expect(reaction.me, true);
      expect(reaction.url, 'https://example.com/emoji.png');
      expect(reaction.staticUrl, 'https://example.com/emoji_static.png');
    });

    test('fromJson uses defaults for missing fields', () {
      final json = {'name': '❤️'};
      final reaction = ReactionSchema.fromJson(json);
      expect(reaction.count, 0);
      expect(reaction.me, false);
      expect(reaction.url, isNull);
      expect(reaction.staticUrl, isNull);
    });
  });

  group('AnnouncementSchema', () {
    test('fromJson parses all fields', () {
      final json = {
        'id': '1',
        'content': '<p>Maintenance tonight</p>',
        'starts_at': '2024-01-15T20:00:00.000Z',
        'ends_at': '2024-01-15T22:00:00.000Z',
        'all_day': true,
        'published_at': '2024-01-14T10:00:00.000Z',
        'updated_at': '2024-01-14T12:00:00.000Z',
        'read': true,
        'reactions': [
          {'name': '👍', 'count': 3, 'me': false},
        ],
      };
      final ann = AnnouncementSchema.fromJson(json);
      expect(ann.id, '1');
      expect(ann.content, '<p>Maintenance tonight</p>');
      expect(ann.startsAt, '2024-01-15T20:00:00.000Z');
      expect(ann.endsAt, '2024-01-15T22:00:00.000Z');
      expect(ann.allDay, true);
      expect(ann.read, true);
      expect(ann.reactions, hasLength(1));
      expect(ann.reactions.first.name, '👍');
    });

    test('fromJson uses defaults for missing optional fields', () {
      final json = {
        'id': '2',
        'published_at': '2024-01-15T10:00:00.000Z',
      };
      final ann = AnnouncementSchema.fromJson(json);
      expect(ann.content, '');
      expect(ann.startsAt, isNull);
      expect(ann.endsAt, isNull);
      expect(ann.allDay, false);
      expect(ann.updatedAt, isNull);
      expect(ann.read, false);
      expect(ann.reactions, isEmpty);
    });

    test('fromJson parses multiple reactions', () {
      final json = {
        'id': '3',
        'published_at': '2024-01-15T10:00:00.000Z',
        'reactions': [
          {'name': '👍', 'count': 3},
          {'name': '❤️', 'count': 1, 'me': true},
          {'name': 'blobcat', 'count': 2, 'url': 'https://example.com/blobcat.png', 'static_url': 'https://example.com/blobcat_static.png'},
        ],
      };
      final ann = AnnouncementSchema.fromJson(json);
      expect(ann.reactions, hasLength(3));
      expect(ann.reactions[2].url, 'https://example.com/blobcat.png');
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
