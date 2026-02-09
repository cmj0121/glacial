import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/features/models.dart';

void main() {
  // JSON helpers
  Map<String, dynamic> historyJson({
    String day = '1718409600',
    String accounts = '10',
    String uses = '25',
  }) => {
    'day': day,
    'accounts': accounts,
    'uses': uses,
  };

  Map<String, dynamic> hashtagJson({
    String name = 'flutter',
    String url = 'https://example.com/tags/flutter',
    List<Map<String, dynamic>>? history,
    bool? following,
    bool? featuring,
  }) => {
    'name': name,
    'url': url,
    'history': history ?? [historyJson()],
    if (following != null) 'following': following,
    if (featuring != null) 'featuring': featuring,
  };

  Map<String, dynamic> featuredTagJson({
    String id = 'ft-1',
    String name = 'dart',
    String url = 'https://example.com/tags/dart',
    int statusesCount = 42,
    String? lastStatusAt = '2024-06-15',
  }) => {
    'id': id,
    'name': name,
    'url': url,
    'statuses_count': statusesCount,
    if (lastStatusAt != null) 'last_status_at': lastStatusAt,
  };

  Map<String, dynamic> accountJson({String id = '1'}) => {
    'id': id,
    'username': 'testuser',
    'acct': 'testuser',
    'url': 'https://example.com/@testuser',
    'display_name': 'Test User',
    'note': '',
    'avatar': 'https://example.com/avatar.png',
    'avatar_static': 'https://example.com/avatar.png',
    'header': 'https://example.com/header.png',
    'locked': false,
    'bot': false,
    'indexable': true,
    'created_at': '2024-01-01T00:00:00.000Z',
    'statuses_count': 10,
    'followers_count': 5,
    'following_count': 3,
  };

  Map<String, dynamic> statusJson({String id = '100'}) => {
    'id': id,
    'content': '<p>Hello</p>',
    'visibility': 'public',
    'sensitive': false,
    'spoiler_text': '',
    'account': accountJson(),
    'uri': 'https://example.com/statuses/$id',
    'reblogs_count': 0,
    'favourites_count': 0,
    'replies_count': 0,
    'created_at': '2024-06-15T12:00:00.000Z',
  };

  group('HashtagSchema', () {
    test('fromJson parses all fields', () {
      final json = hashtagJson(
        following: true,
        featuring: false,
      );
      final hashtag = HashtagSchema.fromJson(json);

      expect(hashtag.name, 'flutter');
      expect(hashtag.url, 'https://example.com/tags/flutter');
      expect(hashtag.history.length, 1);
      expect(hashtag.following, true);
      expect(hashtag.featuring, false);
    });

    test('fromJson handles null optional booleans', () {
      final json = hashtagJson();
      final hashtag = HashtagSchema.fromJson(json);

      expect(hashtag.following, isNull);
      expect(hashtag.featuring, isNull);
    });

    test('fromJson parses multiple history entries', () {
      final json = hashtagJson(history: [
        historyJson(day: '1', accounts: '10', uses: '25'),
        historyJson(day: '2', accounts: '15', uses: '30'),
        historyJson(day: '3', accounts: '20', uses: '50'),
      ]);
      final hashtag = HashtagSchema.fromJson(json);

      expect(hashtag.history.length, 3);
      expect(hashtag.history[0].day, '1');
      expect(hashtag.history[2].uses, '50');
    });
  });

  group('FeaturedTagSchema', () {
    test('fromJson parses all fields', () {
      final json = featuredTagJson();
      final tag = FeaturedTagSchema.fromJson(json);

      expect(tag.id, 'ft-1');
      expect(tag.name, 'dart');
      expect(tag.url, 'https://example.com/tags/dart');
      expect(tag.statusesCount, 42);
      expect(tag.lastStatusAt, '2024-06-15');
    });

    test('fromJson defaults statusesCount to 0', () {
      final json = {'id': 'ft-2', 'name': 'test'};
      final tag = FeaturedTagSchema.fromJson(json);

      expect(tag.statusesCount, 0);
    });

    test('fromJson handles null lastStatusAt', () {
      final json = featuredTagJson(lastStatusAt: null);
      final tag = FeaturedTagSchema.fromJson(json);

      expect(tag.lastStatusAt, isNull);
    });

    test('fromJson defaults url to empty when null', () {
      final json = {'id': 'ft-3', 'name': 'test'};
      final tag = FeaturedTagSchema.fromJson(json);

      expect(tag.url, '');
    });
  });

  group('SearchResultSchema', () {
    test('fromJson parses nested accounts, statuses, hashtags', () {
      final json = {
        'accounts': [accountJson(id: '1'), accountJson(id: '2')],
        'statuses': [statusJson(id: '100')],
        'hashtags': [hashtagJson(name: 'dart')],
      };
      final result = SearchResultSchema.fromJson(json);

      expect(result.accounts.length, 2);
      expect(result.statuses.length, 1);
      expect(result.hashtags.length, 1);
      expect(result.isEmpty, false);
    });

    test('fromJson defaults to empty lists when null', () {
      final json = <String, dynamic>{};
      final result = SearchResultSchema.fromJson(json);

      expect(result.accounts, isEmpty);
      expect(result.statuses, isEmpty);
      expect(result.hashtags, isEmpty);
      expect(result.isEmpty, true);
    });

    test('fromString round-trip', () {
      final json = {
        'accounts': [accountJson()],
        'statuses': <Map<String, dynamic>>[],
        'hashtags': <Map<String, dynamic>>[],
      };
      final result = SearchResultSchema.fromString(jsonEncode(json));

      expect(result.accounts.length, 1);
      expect(result.isEmpty, false);
    });

    test('isEmpty returns true when all lists empty', () {
      const result = SearchResultSchema(
        accounts: [],
        statuses: [],
        hashtags: [],
      );

      expect(result.isEmpty, true);
    });
  });

  group('ExplorerResultType', () {
    test('icon returns different icons for active/inactive', () {
      for (final type in ExplorerResultType.values) {
        expect(type.icon(active: true), isNot(type.icon(active: false)));
      }
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
