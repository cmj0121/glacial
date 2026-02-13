// Unit tests for DraftSchema and NewPollSchema.fromJson.
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/features/models.dart';

void main() {
  group('DraftSchema', () {
    test('fromJson creates correct instance', () {
      final json = {
        'id': 'draft-1',
        'content': 'Hello world',
        'spoiler': null,
        'sensitive': false,
        'visibility': 'public',
        'quote_policy': 'public',
        'in_reply_to_id': null,
        'quote_to_id': null,
        'poll': null,
        'updated_at': '2025-01-15T10:00:00.000Z',
      };

      final draft = DraftSchema.fromJson(json);

      expect(draft.id, 'draft-1');
      expect(draft.content, 'Hello world');
      expect(draft.spoiler, isNull);
      expect(draft.sensitive, false);
      expect(draft.visibility, VisibilityType.public);
      expect(draft.quotePolicy, QuotePolicyType.public);
      expect(draft.inReplyToId, isNull);
      expect(draft.quoteToId, isNull);
      expect(draft.poll, isNull);
      expect(draft.updatedAt, DateTime.parse('2025-01-15T10:00:00.000Z'));
    });

    test('toJson produces correct map', () {
      final draft = DraftSchema(
        id: 'draft-2',
        content: 'Test content',
        spoiler: 'CW text',
        sensitive: true,
        visibility: VisibilityType.private,
        quotePolicy: QuotePolicyType.nobody,
        inReplyToId: 'status-1',
        quoteToId: 'status-2',
        updatedAt: DateTime.parse('2025-01-15T10:00:00.000Z'),
      );

      final json = draft.toJson();

      expect(json['id'], 'draft-2');
      expect(json['content'], 'Test content');
      expect(json['spoiler'], 'CW text');
      expect(json['sensitive'], true);
      expect(json['visibility'], 'private');
      expect(json['in_reply_to_id'], 'status-1');
      expect(json['quote_to_id'], 'status-2');
    });

    test('toJson/fromJson round-trip', () {
      final original = DraftSchema(
        id: 'draft-3',
        content: 'Round trip test',
        spoiler: 'Spoiler!',
        sensitive: true,
        visibility: VisibilityType.unlisted,
        quotePolicy: QuotePolicyType.public,
        inReplyToId: 'reply-id',
        quoteToId: 'quote-id',
        updatedAt: DateTime.parse('2025-06-01T12:30:00.000Z'),
      );

      final json = original.toJson();
      final restored = DraftSchema.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.content, original.content);
      expect(restored.spoiler, original.spoiler);
      expect(restored.sensitive, original.sensitive);
      expect(restored.visibility, original.visibility);
      expect(restored.inReplyToId, original.inReplyToId);
      expect(restored.quoteToId, original.quoteToId);
    });

    test('fromJson with null optional fields', () {
      final json = {
        'id': 'draft-4',
        'content': '',
        'updated_at': '2025-01-15T10:00:00.000Z',
      };

      final draft = DraftSchema.fromJson(json);

      expect(draft.content, '');
      expect(draft.spoiler, isNull);
      expect(draft.sensitive, false);
      expect(draft.visibility, VisibilityType.public);
      expect(draft.inReplyToId, isNull);
      expect(draft.quoteToId, isNull);
      expect(draft.poll, isNull);
    });

    test('round-trip with poll data', () {
      final original = DraftSchema(
        id: 'draft-5',
        content: 'Poll draft',
        poll: NewPollSchema(
          options: ['Option A', 'Option B', 'Option C'],
          expiresIn: 3600,
          multiple: true,
          hideTotals: false,
        ),
        updatedAt: DateTime.parse('2025-01-15T10:00:00.000Z'),
      );

      final json = original.toJson();
      final restored = DraftSchema.fromJson(json);

      expect(restored.poll, isNotNull);
      expect(restored.poll!.options, ['Option A', 'Option B', 'Option C']);
      expect(restored.poll!.expiresIn, 3600);
      expect(restored.poll!.multiple, true);
    });

    test('storageKey produces correct format', () {
      expect(DraftSchema.storageKey('mastodon.social@12345'), 'drafts_mastodon.social@12345');
      expect(DraftSchema.storageKey('fosstodon.org@99'), 'drafts_fosstodon.org@99');
    });

    test('maxDrafts is 20', () {
      expect(DraftSchema.maxDrafts, 20);
    });

    test('encode/decode round-trip for list', () {
      final drafts = [
        DraftSchema(id: 'a', content: 'First', updatedAt: DateTime.parse('2025-01-15T10:00:00.000Z')),
        DraftSchema(id: 'b', content: 'Second', updatedAt: DateTime.parse('2025-01-15T11:00:00.000Z')),
      ];

      final encoded = DraftSchema.encode(drafts);
      final decoded = DraftSchema.decode(encoded);

      expect(decoded.length, 2);
      expect(decoded[0].id, 'a');
      expect(decoded[1].id, 'b');
    });

    test('copyWith creates new instance with overrides', () {
      final original = DraftSchema(
        id: 'draft-6',
        content: 'Original',
        sensitive: false,
        updatedAt: DateTime.parse('2025-01-15T10:00:00.000Z'),
      );

      final modified = original.copyWith(content: 'Modified', sensitive: true);

      expect(modified.id, 'draft-6');
      expect(modified.content, 'Modified');
      expect(modified.sensitive, true);
      expect(original.content, 'Original');
      expect(original.sensitive, false);
    });
  });

  group('NewPollSchema.fromJson', () {
    test('creates correct instance', () {
      final json = {
        'options': ['Yes', 'No'],
        'expires_in': 7200,
        'multiple': false,
        'hide_totals': true,
      };

      final poll = NewPollSchema.fromJson(json);

      expect(poll.options, ['Yes', 'No']);
      expect(poll.expiresIn, 7200);
      expect(poll.multiple, false);
      expect(poll.hideTotals, true);
    });

    test('fromJson with null optional fields', () {
      final json = {
        'options': ['A', 'B'],
      };

      final poll = NewPollSchema.fromJson(json);

      expect(poll.options, ['A', 'B']);
      expect(poll.expiresIn, 86400);
      expect(poll.multiple, isNull);
      expect(poll.hideTotals, isNull);
    });

    test('toJson/fromJson round-trip', () {
      final original = NewPollSchema(
        options: ['Red', 'Blue', 'Green'],
        expiresIn: 1800,
        multiple: true,
        hideTotals: false,
      );

      final json = original.toJson();
      final restored = NewPollSchema.fromJson(json);

      expect(restored.options, original.options);
      expect(restored.expiresIn, original.expiresIn);
      expect(restored.multiple, original.multiple);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
