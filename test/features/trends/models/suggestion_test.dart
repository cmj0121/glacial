import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/features/models.dart';

void main() {
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

  Map<String, dynamic> suggestionJson({
    String source = 'staff',
    List<String>? sources,
    String accountId = '1',
  }) => {
    'source': source,
    'sources': sources ?? [source],
    'account': accountJson(id: accountId),
  };

  group('SuggestionSourceType', () {
    test('fromString parses staff', () {
      expect(SuggestionSourceType.fromString('staff'), SuggestionSourceType.staff);
    });

    test('fromString parses past_interactions', () {
      expect(SuggestionSourceType.fromString('past_interactions'), SuggestionSourceType.pastInteractions);
    });

    test('fromString parses global', () {
      expect(SuggestionSourceType.fromString('global'), SuggestionSourceType.global);
    });

    test('fromString throws on unknown source', () {
      expect(
        () => SuggestionSourceType.fromString('unknown'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('all values have distinct names', () {
      final names = SuggestionSourceType.values.map((e) => e.name).toSet();
      expect(names.length, SuggestionSourceType.values.length);
    });
  });

  group('SuggestionSchema', () {
    test('fromJson parses all fields', () {
      final json = suggestionJson();
      final suggestion = SuggestionSchema.fromJson(json);

      expect(suggestion.source, SuggestionSourceType.staff);
      expect(suggestion.sources, ['staff']);
      expect(suggestion.account.id, '1');
      expect(suggestion.account.username, 'testuser');
    });

    test('fromJson parses pastInteractions source', () {
      final json = suggestionJson(source: 'past_interactions');
      final suggestion = SuggestionSchema.fromJson(json);

      expect(suggestion.source, SuggestionSourceType.pastInteractions);
    });

    test('fromJson parses global source', () {
      final json = suggestionJson(source: 'global');
      final suggestion = SuggestionSchema.fromJson(json);

      expect(suggestion.source, SuggestionSourceType.global);
    });

    test('fromJson parses multiple sources', () {
      final json = suggestionJson(
        source: 'staff',
        sources: ['staff', 'global'],
      );
      final suggestion = SuggestionSchema.fromJson(json);

      expect(suggestion.sources, ['staff', 'global']);
      expect(suggestion.sources.length, 2);
    });

    test('fromString parses JSON string', () {
      final json = suggestionJson(accountId: '42');
      final suggestion = SuggestionSchema.fromString(jsonEncode(json));

      expect(suggestion.account.id, '42');
      expect(suggestion.source, SuggestionSourceType.staff);
    });

    test('fromJson preserves account details', () {
      final json = suggestionJson(accountId: '99');
      final suggestion = SuggestionSchema.fromJson(json);

      expect(suggestion.account.displayName, 'Test User');
      expect(suggestion.account.avatar, 'https://example.com/avatar.png');
    });

    test('fromJson with empty sources list', () {
      final json = suggestionJson(sources: []);
      final suggestion = SuggestionSchema.fromJson(json);

      expect(suggestion.sources, isEmpty);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
