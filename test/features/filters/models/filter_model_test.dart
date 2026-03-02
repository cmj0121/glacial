// Tests for filter models: FilterContext, FilterAction, FilterKeywordSchema, etc.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/features/models.dart';

void main() {
  group('FilterContext', () {
    test('fromString parses all contexts', () {
      expect(FilterContext.fromString('home'), FilterContext.home);
      expect(FilterContext.fromString('notifications'), FilterContext.notifications);
      expect(FilterContext.fromString('public'), FilterContext.public);
      expect(FilterContext.fromString('thread'), FilterContext.thread);
      expect(FilterContext.fromString('account'), FilterContext.account);
    });

    test('all values exist', () {
      expect(FilterContext.values, hasLength(5));
    });
  });

  group('FilterAction', () {
    test('fromString parses all actions', () {
      expect(FilterAction.fromString('warn'), FilterAction.warn);
      expect(FilterAction.fromString('hide'), FilterAction.hide);
      expect(FilterAction.fromString('blur'), FilterAction.blur);
    });

    test('icon returns correct icons', () {
      expect(FilterAction.warn.icon, Icons.warning_amber_outlined);
      expect(FilterAction.hide.icon, Icons.block_outlined);
      expect(FilterAction.blur.icon, Icons.blur_on_outlined);
    });
  });

  group('FilterKeywordSchema', () {
    test('fromJson parses all fields', () {
      final json = {'id': 'kw-1', 'keyword': 'spam', 'whole_word': true};
      final keyword = FilterKeywordSchema.fromJson(json);
      expect(keyword.id, 'kw-1');
      expect(keyword.keyword, 'spam');
      expect(keyword.wholeWord, true);
    });
  });

  group('FilterStatusSchema', () {
    test('fromJson parses all fields', () {
      final json = {'id': 'fs-1', 'status_id': 'st-100'};
      final status = FilterStatusSchema.fromJson(json);
      expect(status.id, 'fs-1');
      expect(status.statusId, 'st-100');
    });

    test('fromString parses JSON string', () {
      final status = FilterStatusSchema.fromString('{"id": "fs-2", "status_id": "st-200"}');
      expect(status.id, 'fs-2');
      expect(status.statusId, 'st-200');
    });
  });

  group('FiltersSchema', () {
    test('fromJson parses all fields', () {
      final json = {
        'id': 'f-1',
        'title': 'Test Filter',
        'context': ['home', 'public'],
        'expires_at': '2025-01-01T00:00:00.000Z',
        'filter_action': 'warn',
        'keywords': [
          {'id': 'kw-1', 'keyword': 'spam', 'whole_word': true},
        ],
        'statuses': [
          {'id': 'fs-1', 'status_id': 'st-100'},
        ],
      };
      final filter = FiltersSchema.fromJson(json);
      expect(filter.id, 'f-1');
      expect(filter.title, 'Test Filter');
      expect(filter.context, hasLength(2));
      expect(filter.context.first, FilterContext.home);
      expect(filter.action, FilterAction.warn);
      expect(filter.keywords, hasLength(1));
      expect(filter.statuses, hasLength(1));
      expect(filter.expiresAt, isNotNull);
    });

    test('fromJson handles null keywords and statuses', () {
      final json = {
        'id': 'f-2',
        'title': 'Simple Filter',
        'context': ['notifications'],
        'filter_action': 'hide',
      };
      final filter = FiltersSchema.fromJson(json);
      expect(filter.keywords, isNull);
      expect(filter.statuses, isNull);
      expect(filter.expiresAt, isNull);
    });

    test('asForm converts to FilterFormSchema', () {
      final filter = FiltersSchema(
        id: 'f-1',
        title: 'Test',
        context: [FilterContext.home],
        action: FilterAction.hide,
        keywords: [const FilterKeywordSchema(id: 'kw-1', keyword: 'spam', wholeWord: true)],
      );
      final form = filter.asForm();
      expect(form.title, 'Test');
      expect(form.context, [FilterContext.home]);
      expect(form.action, FilterAction.hide);
      expect(form.keywords, hasLength(1));
    });
  });

  group('FilterKeywordFormSchema', () {
    test('empty creates empty form', () {
      final form = FilterKeywordFormSchema.empty();
      expect(form.keyword, '');
      expect(form.wholeWord, false);
      expect(form.destroy, false);
      expect(form.id, isNull);
    });

    test('copyWith updates keyword', () {
      final form = FilterKeywordFormSchema.empty();
      final updated = form.copyWith(keyword: 'test');
      expect(updated.keyword, 'test');
      expect(updated.wholeWord, false);
    });

    test('copyWith updates wholeWord', () {
      const form = FilterKeywordFormSchema(keyword: 'test', wholeWord: false);
      final updated = form.copyWith(wholeWord: true);
      expect(updated.wholeWord, true);
      expect(updated.keyword, 'test');
    });

    test('destroyed creates destroy variant', () {
      const form = FilterKeywordFormSchema(keyword: 'test', wholeWord: true);
      final destroyed = form.destroyed();
      expect(destroyed.keyword, 'test');
      expect(destroyed.wholeWord, true);
      expect(destroyed.destroy, true);
    });

    test('icon returns correct icon based on wholeWord', () {
      const whole = FilterKeywordFormSchema(keyword: 'a', wholeWord: true);
      const partial = FilterKeywordFormSchema(keyword: 'b', wholeWord: false);
      expect(whole.icon, Icons.check_box_outlined);
      expect(partial.icon, Icons.check_box_outline_blank);
    });

    test('toJson includes all fields', () {
      const form = FilterKeywordFormSchema(id: 'kw-1', keyword: 'test', wholeWord: true);
      final json = form.toJson();
      expect(json['id'], 'kw-1');
      expect(json['keyword'], 'test');
      expect(json['whole_word'], true);
      expect(json['_destroy'], false);
    });
  });

  group('FilterFormSchema', () {
    test('fromTitle creates with defaults', () {
      final form = FilterFormSchema.fromTitle('My Filter');
      expect(form.title, 'My Filter');
      expect(form.context, isEmpty);
      expect(form.action, FilterAction.hide);
      expect(form.keywords, isEmpty);
      expect(form.expiresIn, isNull);
    });

    test('toJson includes all fields', () {
      const form = FilterFormSchema(
        title: 'Test',
        context: [FilterContext.home, FilterContext.public],
        action: FilterAction.warn,
        expiresIn: 3600,
        keywords: [FilterKeywordFormSchema(keyword: 'spam', wholeWord: true)],
      );
      final json = form.toJson();
      expect(json['title'], 'Test');
      expect(json['context'], ['home', 'public']);
      expect(json['filter_action'], 'warn');
      expect(json['expires_in'], 3600);
      expect(json['keywords_attributes'], hasLength(1));
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

    test('copyWith with expiresIn 0 sets null', () {
      const form = FilterFormSchema(
        title: 'Test',
        context: [FilterContext.home],
        action: FilterAction.warn,
        expiresIn: 3600,
      );
      final updated = form.copyWith(expiresIn: 0);
      expect(updated.expiresIn, isNull);
    });

    test('copyWith preserves other values', () {
      const form = FilterFormSchema(
        title: 'Test',
        context: [FilterContext.home],
        action: FilterAction.warn,
      );
      final updated = form.copyWith(title: 'Updated');
      expect(updated.title, 'Updated');
      expect(updated.context, [FilterContext.home]);
      expect(updated.action, FilterAction.warn);
    });
  });

  group('FilterResultSchema', () {
    test('fromJson parses all fields', () {
      final json = {
        'filter': {
          'id': 'f-1',
          'title': 'Test',
          'context': ['home'],
          'filter_action': 'warn',
        },
        'keyword_matches': ['spam'],
        'status_matches': ['st-1'],
      };
      final result = FilterResultSchema.fromJson(json);
      expect(result.filter.id, 'f-1');
      expect(result.keywords, ['spam']);
      expect(result.statuses, ['st-1']);
    });

    test('fromJson handles null keywords and statuses', () {
      final json = {
        'filter': {
          'id': 'f-2',
          'title': 'Test',
          'context': ['home'],
          'filter_action': 'hide',
        },
      };
      final result = FilterResultSchema.fromJson(json);
      expect(result.keywords, isNull);
      expect(result.statuses, isNull);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
