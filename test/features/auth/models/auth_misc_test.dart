import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/features/models.dart';

void main() {
  group('OAuth2Info', () {
    Map<String, dynamic> oauthJson({
      String? website = 'https://glacial.app',
    }) => {
      'id': 'app-123',
      'name': 'Glacial',
      'website': website,
      'scopes': ['read', 'write', 'follow', 'push'],
      'client_id': 'client_abc',
      'client_secret': 'secret_xyz',
      'redirect_uri': 'glacial://auth',
      'redirect_uris': ['glacial://auth'],
    };

    test('fromJson parses all fields', () {
      final json = oauthJson();
      final info = OAuth2Info.fromJson(json);

      expect(info.id, 'app-123');
      expect(info.name, 'Glacial');
      expect(info.website, 'https://glacial.app');
      expect(info.scopes, ['read', 'write', 'follow', 'push']);
      expect(info.clientId, 'client_abc');
      expect(info.clientSecret, 'secret_xyz');
      expect(info.redirectUri, 'glacial://auth');
      expect(info.redirectUris, ['glacial://auth']);
    });

    test('fromJson handles null website', () {
      final json = oauthJson(website: null);
      final info = OAuth2Info.fromJson(json);

      expect(info.website, isNull);
    });

    test('toJson produces correct output', () {
      final info = OAuth2Info.fromJson(oauthJson());
      final json = info.toJson();

      expect(json['id'], 'app-123');
      expect(json['name'], 'Glacial');
      expect(json['website'], 'https://glacial.app');
      expect(json['scopes'], ['read', 'write', 'follow', 'push']);
      expect(json['client_id'], 'client_abc');
      expect(json['client_secret'], 'secret_xyz');
      expect(json['redirect_uri'], 'glacial://auth');
      expect(json['redirect_uris'], ['glacial://auth']);
    });

    test('fromString round-trip', () {
      final info = OAuth2Info.fromJson(oauthJson());
      final str = jsonEncode(info.toJson());
      final rebuilt = OAuth2Info.fromString(str);

      expect(rebuilt.id, info.id);
      expect(rebuilt.name, info.name);
      expect(rebuilt.clientId, info.clientId);
      expect(rebuilt.clientSecret, info.clientSecret);
    });

    test('fromJson/toJson symmetry', () {
      final original = oauthJson();
      final info = OAuth2Info.fromJson(original);
      final json = info.toJson();

      expect(json['id'], original['id']);
      expect(json['name'], original['name']);
      expect(json['website'], original['website']);
      expect(json['client_id'], original['client_id']);
      expect(json['client_secret'], original['client_secret']);
      expect(json['redirect_uri'], original['redirect_uri']);
    });
  });

  group('AttachmentSchema', () {
    test('fromJson parses all fields', () {
      final json = {
        'id': 'att-1',
        'type': 'image',
        'url': 'https://example.com/image.png',
        'preview_url': 'https://example.com/preview.png',
        'remote_url': 'https://remote.com/image.png',
        'description': 'A picture',
        'blurhash': 'LEHV6nWB2yk8pyo0adR*.7kCMdnj',
      };
      final att = AttachmentSchema.fromJson(json);

      expect(att.id, 'att-1');
      expect(att.type, MediaType.image);
      expect(att.url, 'https://example.com/image.png');
      expect(att.previewUrl, 'https://example.com/preview.png');
      expect(att.remoteUrl, 'https://remote.com/image.png');
      expect(att.description, 'A picture');
      expect(att.blurhash, 'LEHV6nWB2yk8pyo0adR*.7kCMdnj');
    });

    test('fromJson handles null optional fields', () {
      final json = {
        'id': 'att-2',
        'type': 'video',
        'url': 'https://example.com/video.mp4',
      };
      final att = AttachmentSchema.fromJson(json);

      expect(att.previewUrl, isNull);
      expect(att.remoteUrl, isNull);
      expect(att.description, isNull);
      expect(att.blurhash, isNull);
    });

    test('fromJson parses all MediaType values', () {
      for (final t in MediaType.values) {
        final json = {
          'id': 'att-$t',
          'type': t.name,
          'url': 'https://example.com/media',
        };
        final att = AttachmentSchema.fromJson(json);
        expect(att.type, t);
      }
    });

    test('fromJson handles null url defaulting to empty string', () {
      final json = {
        'id': 'att-3',
        'type': 'image',
        'url': null,
      };
      final att = AttachmentSchema.fromJson(json);

      expect(att.url, '');
    });
  });

  group('EmojiSchema', () {
    test('fromJson parses all fields', () {
      final json = {
        'shortcode': 'blobcat',
        'url': 'https://example.com/emoji/blobcat.png',
        'static_url': 'https://example.com/emoji/blobcat_static.png',
        'visible_in_picker': true,
        'category': 'Custom',
      };
      final emoji = EmojiSchema.fromJson(json);

      expect(emoji.shortcode, 'blobcat');
      expect(emoji.url, 'https://example.com/emoji/blobcat.png');
      expect(emoji.staticUrl, 'https://example.com/emoji/blobcat_static.png');
      expect(emoji.visible, true);
      expect(emoji.category, 'Custom');
    });

    test('fromJson handles visible field', () {
      final json = {
        'shortcode': 'test',
        'url': 'https://example.com/emoji.png',
        'static_url': 'https://example.com/emoji.png',
        'visible': false,
      };
      final emoji = EmojiSchema.fromJson(json);

      expect(emoji.visible, false);
    });

    test('fromJson defaults visible to true when missing', () {
      final json = {
        'shortcode': 'test',
        'url': 'https://example.com/emoji.png',
        'static_url': 'https://example.com/emoji.png',
      };
      final emoji = EmojiSchema.fromJson(json);

      expect(emoji.visible, true);
    });

    test('fromJson handles null category', () {
      final json = {
        'shortcode': 'test',
        'url': 'https://example.com/emoji.png',
        'static_url': 'https://example.com/emoji.png',
      };
      final emoji = EmojiSchema.fromJson(json);

      expect(emoji.category, isNull);
    });
  });

  group('EmojiSchema.splitEmoji', () {
    test('splits text with emoji shortcodes', () {
      final parts = EmojiSchema.splitEmoji('Hello :blobcat: world');

      expect(parts, ['Hello ', ':blobcat:', ' world']);
    });

    test('splits text with multiple emojis', () {
      final parts = EmojiSchema.splitEmoji(':wave: Hello :blobcat:');

      expect(parts, [':wave:', ' Hello ', ':blobcat:']);
    });

    test('returns single item for text without emojis', () {
      final parts = EmojiSchema.splitEmoji('Hello world');

      expect(parts, ['Hello world']);
    });

    test('returns single emoji for emoji-only text', () {
      final parts = EmojiSchema.splitEmoji(':blobcat:');

      expect(parts, [':blobcat:']);
    });

    test('handles emoji with special characters in shortcode', () {
      final parts = EmojiSchema.splitEmoji(':blob-cat_wave+1:');

      expect(parts, [':blob-cat_wave+1:']);
    });
  });

  group('EmojiSchema.replaceEmojiToHTML', () {
    test('replaces emoji shortcode with img tag', () {
      final emojis = [
        const EmojiSchema(
          shortcode: 'blobcat',
          url: 'https://example.com/blobcat.png',
          staticUrl: 'https://example.com/blobcat.png',
        ),
      ];
      final result = EmojiSchema.replaceEmojiToHTML(
        'Hello :blobcat:',
        emojis: emojis,
      );

      expect(result, contains("<img src='https://example.com/blobcat.png'"));
      expect(result, contains('Hello'));
    });

    test('preserves text when no matching emoji', () {
      final result = EmojiSchema.replaceEmojiToHTML(
        'Hello :unknown:',
        emojis: [],
      );

      expect(result, 'Hello :unknown:');
    });

    test('returns original content when no emoji patterns found', () {
      final result = EmojiSchema.replaceEmojiToHTML('Hello world');

      expect(result, 'Hello world');
    });
  });

  group('PollSchema', () {
    test('fromJson parses all fields', () {
      final json = {
        'id': 'poll-1',
        'expires_at': '2024-07-01T00:00:00.000Z',
        'expired': false,
        'multiple': true,
        'votes_count': 42,
        'voters_count': 30,
        'options': [
          {'title': 'Option A', 'votes_count': 25},
          {'title': 'Option B', 'votes_count': 17},
        ],
        'voted': true,
        'own_votes': [0],
      };
      final poll = PollSchema.fromJson(json);

      expect(poll.id, 'poll-1');
      expect(poll.expiresAt, DateTime.utc(2024, 7, 1));
      expect(poll.expired, false);
      expect(poll.multiple, true);
      expect(poll.votesCount, 42);
      expect(poll.votersCount, 30);
      expect(poll.options.length, 2);
      expect(poll.options[0].title, 'Option A');
      expect(poll.options[0].votesCount, 25);
      expect(poll.voted, true);
      expect(poll.ownVotes, [0]);
    });

    test('fromJson handles null optional fields', () {
      final json = {
        'id': 'poll-2',
        'expired': true,
        'multiple': false,
        'votes_count': 0,
        'options': [
          {'title': 'Yes'},
          {'title': 'No'},
        ],
      };
      final poll = PollSchema.fromJson(json);

      expect(poll.expiresAt, isNull);
      expect(poll.votersCount, isNull);
      expect(poll.voted, isNull);
      expect(poll.ownVotes, isNull);
      expect(poll.options[0].votesCount, isNull);
    });

    test('fromString round-trip', () {
      final json = {
        'id': 'poll-3',
        'expired': false,
        'multiple': false,
        'votes_count': 5,
        'options': [
          {'title': 'A', 'votes_count': 3},
          {'title': 'B', 'votes_count': 2},
        ],
      };
      final poll = PollSchema.fromString(jsonEncode(json));

      expect(poll.id, 'poll-3');
      expect(poll.options.length, 2);
    });
  });

  group('NewPollSchema', () {
    test('toJson produces correct output', () {
      const poll = NewPollSchema(
        hideTotals: true,
        multiple: false,
        expiresIn: 86400,
        options: ['Option A', 'Option B'],
      );
      final json = poll.toJson();

      expect(json['hide_totals'], true);
      expect(json['multiple'], false);
      expect(json['expires_in'], 86400);
      expect(json['options'], ['Option A', 'Option B']);
    });

    test('toJson removes null values', () {
      const poll = NewPollSchema(
        options: ['A', 'B'],
      );
      final json = poll.toJson();

      expect(json.containsKey('hide_totals'), false);
      expect(json.containsKey('multiple'), false);
      expect(json['expires_in'], 86400);
    });

    test('isValid returns true for 2+ non-empty options', () {
      const valid = NewPollSchema(options: ['A', 'B']);
      expect(valid.isValid, true);

      const validThree = NewPollSchema(options: ['A', 'B', 'C']);
      expect(validThree.isValid, true);
    });

    test('isValid returns false for fewer than 2 non-empty options', () {
      const oneOption = NewPollSchema(options: ['A', '']);
      expect(oneOption.isValid, false);

      const allEmpty = NewPollSchema(options: ['', '']);
      expect(allEmpty.isValid, false);

      const empty = NewPollSchema(options: []);
      expect(empty.isValid, false);
    });

    test('copyWith updates specified fields', () {
      const original = NewPollSchema(
        hideTotals: false,
        multiple: true,
        expiresIn: 86400,
        options: ['A', 'B'],
      );
      final updated = original.copyWith(
        expiresIn: 3600,
        options: ['X', 'Y', 'Z'],
      );

      expect(updated.expiresIn, 3600);
      expect(updated.options, ['X', 'Y', 'Z']);
      // Unchanged
      expect(updated.hideTotals, false);
      expect(updated.multiple, true);
    });
  });

  group('ListSchema', () {
    test('fromJson parses all fields', () {
      final json = {
        'id': 'list-1',
        'title': 'Friends',
        'replies_policy': 'list',
        'exclusive': true,
      };
      final list = ListSchema.fromJson(json);

      expect(list.id, 'list-1');
      expect(list.title, 'Friends');
      expect(list.replyPolicy, ReplyPolicyType.list);
      expect(list.exclusive, true);
    });

    test('fromJson parses all ReplyPolicyType values', () {
      for (final policy in ReplyPolicyType.values) {
        final json = {
          'id': 'list-$policy',
          'title': 'Test',
          'replies_policy': policy.name,
          'exclusive': false,
        };
        final list = ListSchema.fromJson(json);
        expect(list.replyPolicy, policy);
      }
    });

    test('fromString round-trip', () {
      final json = {
        'id': 'list-1',
        'title': 'Test',
        'replies_policy': 'followed',
        'exclusive': false,
      };
      final list = ListSchema.fromString(jsonEncode(json));

      expect(list.id, 'list-1');
      expect(list.replyPolicy, ReplyPolicyType.followed);
    });
  });

  group('ApplicationSchema', () {
    test('fromJson parses all fields', () {
      final json = {
        'name': 'Glacial',
        'website': 'https://glacial.app',
      };
      final app = ApplicationSchema.fromJson(json);

      expect(app.name, 'Glacial');
      expect(app.website, 'https://glacial.app');
    });

    test('fromJson handles null website', () {
      final json = {
        'name': 'Glacial',
      };
      final app = ApplicationSchema.fromJson(json);

      expect(app.name, 'Glacial');
      expect(app.website, isNull);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
