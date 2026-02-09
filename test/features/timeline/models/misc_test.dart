import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/features/models.dart';

void main() {
  // JSON helpers
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

  group('PostStatusSchema', () {
    test('toJson includes all non-null fields', () {
      const post = PostStatusSchema(
        status: 'Hello world',
        mediaIDs: ['att-1'],
        sensitive: true,
        spoiler: 'CW',
        visibility: VisibilityType.unlisted,
        inReplyToID: '99',
        quotedStatusID: '50',
        quoteApprovalPolicy: QuotePolicyType.followers,
      );
      final json = post.toJson();

      expect(json['status'], 'Hello world');
      expect(json['media_ids'], ['att-1']);
      expect(json['sensitive'], true);
      expect(json['spoiler_text'], 'CW');
      expect(json['visibility'], 'unlisted');
      expect(json['in_reply_to_id'], '99');
      expect(json['quoted_status_id'], '50');
      expect(json['quote_approval_policy'], 'followers');
    });

    test('toJson removes null values', () {
      const post = PostStatusSchema(
        status: 'Hello',
        mediaIDs: [],
        quoteApprovalPolicy: QuotePolicyType.public,
      );
      final json = post.toJson();

      expect(json.containsKey('in_reply_to_id'), false);
      expect(json.containsKey('scheduled_at'), false);
      expect(json.containsKey('poll'), false);
      expect(json.containsKey('quoted_status_id'), false);
    });

    test('toJson removes empty string values', () {
      const post = PostStatusSchema(
        status: 'Hello',
        mediaIDs: [],
        spoiler: '',
        quoteApprovalPolicy: QuotePolicyType.public,
      );
      final json = post.toJson();

      expect(json.containsKey('spoiler_text'), false);
    });

    test('copyWith updates specified fields', () {
      const original = PostStatusSchema(
        status: 'Original',
        mediaIDs: [],
        quoteApprovalPolicy: QuotePolicyType.public,
      );
      final updated = original.copyWith(
        status: 'Updated',
        visibility: VisibilityType.private,
        sensitive: true,
      );

      expect(updated.status, 'Updated');
      expect(updated.visibility, VisibilityType.private);
      expect(updated.sensitive, true);
      expect(updated.mediaIDs, isEmpty);
      expect(updated.quoteApprovalPolicy, QuotePolicyType.public);
    });

    test('copyWith preserves unchanged fields', () {
      const original = PostStatusSchema(
        status: 'Hello',
        mediaIDs: ['att-1'],
        sensitive: true,
        spoiler: 'CW',
        visibility: VisibilityType.unlisted,
        inReplyToID: '99',
        quoteApprovalPolicy: QuotePolicyType.followers,
      );
      final copy = original.copyWith();

      expect(copy.status, original.status);
      expect(copy.mediaIDs, original.mediaIDs);
      expect(copy.sensitive, original.sensitive);
      expect(copy.spoiler, original.spoiler);
      expect(copy.visibility, original.visibility);
      expect(copy.inReplyToID, original.inReplyToID);
      expect(copy.quoteApprovalPolicy, original.quoteApprovalPolicy);
    });
  });

  group('TranslationSchema', () {
    test('fromJson parses all fields', () {
      final json = {
        'content': '<p>Translated text</p>',
        'spoiler_text': 'Warning',
        'language': 'en',
        'detected_source_language': 'ja',
        'provider': 'DeepL',
      };
      final translation = TranslationSchema.fromJson(json);

      expect(translation.content, '<p>Translated text</p>');
      expect(translation.spoilerText, 'Warning');
      expect(translation.language, 'en');
      expect(translation.detectedSourceLanguage, 'ja');
      expect(translation.provider, 'DeepL');
    });

    test('fromJson defaults null fields to empty strings', () {
      final json = <String, dynamic>{};
      final translation = TranslationSchema.fromJson(json);

      expect(translation.content, '');
      expect(translation.spoilerText, '');
      expect(translation.language, '');
      expect(translation.detectedSourceLanguage, '');
      expect(translation.provider, '');
    });

    test('fromString round-trip', () {
      final json = {
        'content': '<p>Hello</p>',
        'spoiler_text': '',
        'language': 'de',
        'detected_source_language': 'en',
        'provider': 'Google',
      };
      final translation = TranslationSchema.fromString(jsonEncode(json));

      expect(translation.content, '<p>Hello</p>');
      expect(translation.language, 'de');
    });
  });

  group('ReportSchema', () {
    test('fromJson parses all fields', () {
      final json = {
        'id': 'report-1',
        'action_taken': true,
        'action_taken_at': '2024-06-16T12:00:00.000Z',
        'category': 'spam',
        'comment': 'Posting spam links',
        'forwarded': true,
        'created_at': '2024-06-15T12:00:00.000Z',
        'status_ids': ['100', '101'],
        'rule_ids': ['1', '2'],
        'target_account': accountJson(),
      };
      final report = ReportSchema.fromJson(json);

      expect(report.id, 'report-1');
      expect(report.actionTaken, true);
      expect(report.actionTakenAt, DateTime.utc(2024, 6, 16, 12));
      expect(report.category, ReportCategoryType.spam);
      expect(report.comment, 'Posting spam links');
      expect(report.forwarded, true);
      expect(report.createdAt, DateTime.utc(2024, 6, 15, 12));
      expect(report.statusIDs, ['100', '101']);
      expect(report.ruleIDs, ['1', '2']);
      expect(report.targetAccount.id, '1');
    });

    test('fromJson handles null optional fields', () {
      final json = {
        'id': 'report-2',
        'action_taken': false,
        'category': 'other',
        'comment': '',
        'forwarded': false,
        'created_at': '2024-06-15T12:00:00.000Z',
        'target_account': accountJson(),
      };
      final report = ReportSchema.fromJson(json);

      expect(report.actionTakenAt, isNull);
      expect(report.statusIDs, isNull);
      expect(report.ruleIDs, isNull);
    });

    test('fromJson parses all ReportCategoryType values', () {
      for (final cat in ReportCategoryType.values) {
        final json = {
          'id': '1',
          'action_taken': false,
          'category': cat.name,
          'comment': '',
          'forwarded': false,
          'created_at': '2024-01-01T00:00:00.000Z',
          'target_account': accountJson(),
        };
        final report = ReportSchema.fromJson(json);
        expect(report.category, cat);
      }
    });

    test('fromString round-trip', () {
      final json = {
        'id': 'report-3',
        'action_taken': false,
        'category': 'violation',
        'comment': 'Bad content',
        'forwarded': false,
        'created_at': '2024-06-15T12:00:00.000Z',
        'target_account': accountJson(),
      };
      final report = ReportSchema.fromString(jsonEncode(json));

      expect(report.id, 'report-3');
      expect(report.category, ReportCategoryType.violation);
    });
  });

  group('ReportFileSchema', () {
    test('toJson produces correct output', () {
      const form = ReportFileSchema(
        accountID: '123',
        statusIDs: ['100', '101'],
        comment: 'Spamming',
        forward: true,
        category: ReportCategoryType.spam,
        ruleIDs: ['1'],
      );
      final json = form.toJson();

      expect(json['account_id'], '123');
      expect(json['status_ids[]'], ['100', '101']);
      expect(json['comment'], 'Spamming');
      expect(json['forward'], true);
      expect(json['category'], 'spam');
      expect(json['rule_ids[]'], ['1']);
    });

    test('toJson with default values', () {
      const form = ReportFileSchema(
        accountID: '123',
        comment: 'Test',
        category: ReportCategoryType.other,
      );
      final json = form.toJson();

      expect(json['status_ids[]'], isEmpty);
      expect(json['forward'], false);
      expect(json['rule_ids[]'], isEmpty);
    });
  });

  group('ReportCategoryType', () {
    test('all values have icons', () {
      for (final cat in ReportCategoryType.values) {
        expect(cat.icon, isNotNull);
      }
    });
  });

  group('ReportFormTab', () {
    test('icon returns different icons for active/inactive', () {
      for (final tab in ReportFormTab.values) {
        expect(tab.icon(active: true), isNot(tab.icon(active: false)));
      }
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
