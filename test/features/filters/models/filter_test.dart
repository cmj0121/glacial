import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/features/models.dart';

void main() {
  // JSON helpers
  Map<String, dynamic> filterKeywordJson({
    String id = 'kw-1',
    String keyword = 'test',
    bool wholeWord = true,
  }) => {
    'id': id,
    'keyword': keyword,
    'whole_word': wholeWord,
  };

  Map<String, dynamic> filterStatusJson({
    String id = 'fs-1',
    String statusId = '100',
  }) => {
    'id': id,
    'status_id': statusId,
  };

  Map<String, dynamic> filtersJson({
    String id = 'filter-1',
    String title = 'My Filter',
    List<String> context = const ['home', 'notifications'],
    String? expiresAt,
    String filterAction = 'warn',
    List<Map<String, dynamic>>? keywords,
    List<Map<String, dynamic>>? statuses,
  }) => {
    'id': id,
    'title': title,
    'context': context,
    if (expiresAt != null) 'expires_at': expiresAt,
    'filter_action': filterAction,
    if (keywords != null) 'keywords': keywords,
    if (statuses != null) 'statuses': statuses,
  };

  group('FilterKeywordSchema', () {
    test('fromJson parses all fields', () {
      final json = filterKeywordJson();
      final keyword = FilterKeywordSchema.fromJson(json);

      expect(keyword.id, 'kw-1');
      expect(keyword.keyword, 'test');
      expect(keyword.wholeWord, true);
    });

    test('fromJson parses wholeWord false', () {
      final json = filterKeywordJson(wholeWord: false);
      final keyword = FilterKeywordSchema.fromJson(json);

      expect(keyword.wholeWord, false);
    });
  });

  group('FilterStatusSchema', () {
    test('fromJson parses all fields', () {
      final json = filterStatusJson();
      final status = FilterStatusSchema.fromJson(json);

      expect(status.id, 'fs-1');
      expect(status.statusId, '100');
    });

    test('fromString round-trip', () {
      final json = filterStatusJson();
      final status = FilterStatusSchema.fromString(jsonEncode(json));

      expect(status.id, 'fs-1');
      expect(status.statusId, '100');
    });
  });

  group('FiltersSchema', () {
    test('fromJson parses all fields', () {
      final json = filtersJson(
        keywords: [filterKeywordJson()],
        statuses: [filterStatusJson()],
      );
      final filter = FiltersSchema.fromJson(json);

      expect(filter.id, 'filter-1');
      expect(filter.title, 'My Filter');
      expect(filter.context.length, 2);
      expect(filter.context[0], FilterContext.home);
      expect(filter.context[1], FilterContext.notifications);
      expect(filter.action, FilterAction.warn);
      expect(filter.keywords!.length, 1);
      expect(filter.statuses!.length, 1);
    });

    test('fromJson parses all FilterContext values', () {
      for (final ctx in FilterContext.values) {
        final json = filtersJson(context: [ctx.name]);
        final filter = FiltersSchema.fromJson(json);
        expect(filter.context[0], ctx);
      }
    });

    test('fromJson parses all FilterAction values', () {
      for (final action in FilterAction.values) {
        final json = filtersJson(filterAction: action.name);
        final filter = FiltersSchema.fromJson(json);
        expect(filter.action, action);
      }
    });

    test('fromJson handles null keywords and statuses', () {
      final json = filtersJson();
      final filter = FiltersSchema.fromJson(json);

      expect(filter.keywords, isNull);
      expect(filter.statuses, isNull);
    });

    test('fromJson handles null expires_at', () {
      final json = filtersJson();
      final filter = FiltersSchema.fromJson(json);

      expect(filter.expiresAt, isNull);
    });

    test('fromJson parses expires_at', () {
      final json = filtersJson(expiresAt: '2024-12-31T23:59:59.000Z');
      final filter = FiltersSchema.fromJson(json);

      expect(filter.expiresAt, DateTime.utc(2024, 12, 31, 23, 59, 59));
    });

    test('asForm converts to FilterFormSchema', () {
      final json = filtersJson(
        keywords: [filterKeywordJson(id: 'kw-1', keyword: 'spam', wholeWord: true)],
      );
      final filter = FiltersSchema.fromJson(json);
      final form = filter.asForm();

      expect(form.title, 'My Filter');
      expect(form.context.length, 2);
      expect(form.action, FilterAction.warn);
      expect(form.keywords.length, 1);
      expect(form.keywords[0].keyword, 'spam');
      expect(form.keywords[0].id, 'kw-1');
    });
  });

  group('FilterResultSchema', () {
    test('fromJson parses filter with keyword matches', () {
      final json = {
        'filter': filtersJson(),
        'keyword_matches': ['test', 'spam'],
        'status_matches': null,
      };
      final result = FilterResultSchema.fromJson(json);

      expect(result.filter.id, 'filter-1');
      expect(result.keywords, ['test', 'spam']);
      expect(result.statuses, isNull);
    });

    test('fromJson parses filter with status matches', () {
      final json = {
        'filter': filtersJson(),
        'keyword_matches': null,
        'status_matches': ['100', '200'],
      };
      final result = FilterResultSchema.fromJson(json);

      expect(result.keywords, isNull);
      expect(result.statuses, ['100', '200']);
    });

    test('fromJson handles null optional matches', () {
      final json = {
        'filter': filtersJson(),
      };
      final result = FilterResultSchema.fromJson(json);

      expect(result.keywords, isNull);
      expect(result.statuses, isNull);
    });
  });

  group('FilterFormSchema', () {
    test('toJson produces correct output', () {
      const form = FilterFormSchema(
        title: 'Test Filter',
        context: [FilterContext.home, FilterContext.public],
        action: FilterAction.hide,
        expiresIn: 3600,
        keywords: [
          FilterKeywordFormSchema(keyword: 'spam', wholeWord: true),
        ],
      );
      final json = form.toJson();

      expect(json['title'], 'Test Filter');
      expect(json['context'], ['home', 'public']);
      expect(json['filter_action'], 'hide');
      expect(json['expires_in'], 3600);
      expect((json['keywords_attributes'] as List).length, 1);
    });

    test('toJson omits expires_in when null', () {
      const form = FilterFormSchema(
        title: 'Test',
        context: [FilterContext.home],
        action: FilterAction.warn,
      );
      final json = form.toJson();

      expect(json.containsKey('expires_in'), false);
    });

    test('copyWith updates specified fields', () {
      const original = FilterFormSchema(
        title: 'Original',
        context: [FilterContext.home],
        action: FilterAction.warn,
        expiresIn: 3600,
      );
      final updated = original.copyWith(
        title: 'Updated',
        action: FilterAction.hide,
      );

      expect(updated.title, 'Updated');
      expect(updated.action, FilterAction.hide);
      // Unchanged
      expect(updated.context, [FilterContext.home]);
      expect(updated.expiresIn, 3600);
    });

    test('copyWith resets expiresIn to null when set to 0', () {
      const original = FilterFormSchema(
        title: 'Test',
        context: [],
        action: FilterAction.warn,
        expiresIn: 3600,
      );
      final updated = original.copyWith(expiresIn: 0);

      expect(updated.expiresIn, isNull);
    });

    test('fromTitle creates default form', () {
      final form = FilterFormSchema.fromTitle('Quick Filter');

      expect(form.title, 'Quick Filter');
      expect(form.context, isEmpty);
      expect(form.action, FilterAction.hide);
      expect(form.keywords, isEmpty);
      expect(form.expiresIn, isNull);
    });
  });

  group('FilterKeywordFormSchema', () {
    test('toJson produces correct output', () {
      const form = FilterKeywordFormSchema(
        id: 'kw-1',
        keyword: 'spam',
        wholeWord: true,
      );
      final json = form.toJson();

      expect(json['id'], 'kw-1');
      expect(json['keyword'], 'spam');
      expect(json['whole_word'], true);
      expect(json['_destroy'], false);
    });

    test('copyWith updates fields', () {
      const original = FilterKeywordFormSchema(
        id: 'kw-1',
        keyword: 'spam',
        wholeWord: true,
      );
      final updated = original.copyWith(keyword: 'advertising');

      expect(updated.keyword, 'advertising');
      expect(updated.wholeWord, true);
      expect(updated.id, 'kw-1');
    });

    test('destroyed sets destroy flag', () {
      const original = FilterKeywordFormSchema(
        id: 'kw-1',
        keyword: 'spam',
        wholeWord: true,
      );
      final destroyed = original.destroyed();

      expect(destroyed.destroy, true);
      expect(destroyed.keyword, 'spam');
      expect(destroyed.id, 'kw-1');
    });

    test('empty creates blank keyword', () {
      final empty = FilterKeywordFormSchema.empty();

      expect(empty.keyword, '');
      expect(empty.wholeWord, false);
      expect(empty.id, isNull);
    });
  });

  group('FilterContext enum', () {
    test('fromString parses all values', () {
      for (final ctx in FilterContext.values) {
        expect(FilterContext.fromString(ctx.name), ctx);
      }
    });
  });

  group('FilterAction enum', () {
    test('fromString parses all values', () {
      for (final action in FilterAction.values) {
        expect(FilterAction.fromString(action.name), action);
      }
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
