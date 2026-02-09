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

  Map<String, dynamic> statusJson({
    String id = '100',
    String content = '<p>Hello world</p>',
    String visibility = 'public',
    bool sensitive = false,
    String spoilerText = '',
    String? text,
    String? url,
    String? language,
    String? editedAt,
    String? inReplyToId,
    String? inReplyToAccountId,
    Map<String, dynamic>? reblog,
    Map<String, dynamic>? poll,
    Map<String, dynamic>? card,
    List<Map<String, dynamic>>? mediaAttachments,
    List<Map<String, dynamic>>? mentions,
    List<Map<String, dynamic>>? tags,
    List<Map<String, dynamic>>? emojis,
    int reblogsCount = 0,
    int favouritesCount = 0,
    int repliesCount = 0,
    bool? favourited,
    bool? reblogged,
    bool? bookmarked,
    bool? pinned,
    bool? muted,
  }) => {
    'id': id,
    'content': content,
    if (text != null) 'text': text,
    'visibility': visibility,
    'sensitive': sensitive,
    'spoiler_text': spoilerText,
    'account': accountJson(),
    'uri': 'https://example.com/statuses/$id',
    if (url != null) 'url': url,
    'media_attachments': mediaAttachments ?? [],
    'mentions': mentions ?? [],
    'tags': tags ?? [],
    'emojis': emojis ?? [],
    if (inReplyToId != null) 'in_reply_to_id': inReplyToId,
    if (inReplyToAccountId != null) 'in_reply_to_account_id': inReplyToAccountId,
    if (reblog != null) 'reblog': reblog,
    if (poll != null) 'poll': poll,
    if (card != null) 'card': card,
    'reblogs_count': reblogsCount,
    'favourites_count': favouritesCount,
    'replies_count': repliesCount,
    if (favourited != null) 'favourited': favourited,
    if (reblogged != null) 'reblogged': reblogged,
    if (bookmarked != null) 'bookmarked': bookmarked,
    if (pinned != null) 'pinned': pinned,
    if (muted != null) 'muted': muted,
    if (language != null) 'language': language,
    'created_at': '2024-06-15T12:00:00.000Z',
    if (editedAt != null) 'edited_at': editedAt,
  };

  group('StatusSchema', () {
    test('fromJson parses minimal required fields', () {
      final json = statusJson();
      final status = StatusSchema.fromJson(json);

      expect(status.id, '100');
      expect(status.content, '<p>Hello world</p>');
      expect(status.visibility, VisibilityType.public);
      expect(status.sensitive, false);
      expect(status.spoiler, '');
      expect(status.account.id, '1');
      expect(status.uri, 'https://example.com/statuses/100');
      expect(status.reblogsCount, 0);
      expect(status.favouritesCount, 0);
      expect(status.repliesCount, 0);
      expect(status.createdAt, DateTime.utc(2024, 6, 15, 12));
    });

    test('fromJson parses optional scalar fields', () {
      final json = statusJson(
        text: 'Hello world',
        url: 'https://example.com/@testuser/100',
        language: 'en',
        editedAt: '2024-06-16T08:00:00.000Z',
        inReplyToId: '99',
        inReplyToAccountId: '2',
        favourited: true,
        reblogged: false,
        bookmarked: true,
        pinned: false,
        muted: true,
      );
      final status = StatusSchema.fromJson(json);

      expect(status.text, 'Hello world');
      expect(status.url, 'https://example.com/@testuser/100');
      expect(status.language, 'en');
      expect(status.editedAt, DateTime.utc(2024, 6, 16, 8));
      expect(status.inReplyToID, '99');
      expect(status.inReplyToAccountID, '2');
      expect(status.favourited, true);
      expect(status.reblogged, false);
      expect(status.bookmarked, true);
      expect(status.pinned, false);
      expect(status.muted, true);
    });

    test('fromJson parses nested reblog', () {
      final innerJson = statusJson(id: '50', content: '<p>Original</p>');
      final outerJson = statusJson(id: '100', reblog: innerJson);
      final status = StatusSchema.fromJson(outerJson);

      expect(status.reblog, isNotNull);
      expect(status.reblog!.id, '50');
      expect(status.reblog!.content, '<p>Original</p>');
    });

    test('fromJson parses nested poll', () {
      final json = statusJson(poll: {
        'id': 'poll-1',
        'expires_at': '2024-07-01T00:00:00.000Z',
        'expired': false,
        'multiple': false,
        'votes_count': 10,
        'options': [
          {'title': 'Yes', 'votes_count': 7},
          {'title': 'No', 'votes_count': 3},
        ],
      });
      final status = StatusSchema.fromJson(json);

      expect(status.poll, isNotNull);
      expect(status.poll!.id, 'poll-1');
      expect(status.poll!.options.length, 2);
    });

    test('fromJson parses nested card', () {
      final json = statusJson(card: {
        'url': 'https://article.com',
        'title': 'Article',
        'description': 'An article',
        'type': 'link',
        'html': '',
        'width': 200,
        'height': 100,
      });
      final status = StatusSchema.fromJson(json);

      expect(status.card, isNotNull);
      expect(status.card!.title, 'Article');
      expect(status.card!.type, PreviewCardType.link);
    });

    test('fromJson parses attachments array', () {
      final json = statusJson(mediaAttachments: [
        {
          'id': 'att-1',
          'type': 'image',
          'url': 'https://example.com/image.png',
        },
        {
          'id': 'att-2',
          'type': 'video',
          'url': 'https://example.com/video.mp4',
        },
      ]);
      final status = StatusSchema.fromJson(json);

      expect(status.attachments.length, 2);
      expect(status.attachments[0].type, MediaType.image);
      expect(status.attachments[1].type, MediaType.video);
    });

    test('fromJson parses mentions array', () {
      final json = statusJson(mentions: [
        {
          'id': '2',
          'username': 'other',
          'url': 'https://example.com/@other',
          'acct': 'other',
        },
      ]);
      final status = StatusSchema.fromJson(json);

      expect(status.mentions.length, 1);
      expect(status.mentions[0].username, 'other');
    });

    test('fromJson parses tags array', () {
      final json = statusJson(tags: [
        {'name': 'flutter', 'url': 'https://example.com/tags/flutter'},
      ]);
      final status = StatusSchema.fromJson(json);

      expect(status.tags.length, 1);
      expect(status.tags[0].name, 'flutter');
    });

    test('fromJson parses emojis array', () {
      final json = statusJson(emojis: [
        {
          'shortcode': 'blobcat',
          'url': 'https://example.com/emoji/blobcat.png',
          'static_url': 'https://example.com/emoji/blobcat.png',
        },
      ]);
      final status = StatusSchema.fromJson(json);

      expect(status.emojis.length, 1);
      expect(status.emojis[0].shortcode, 'blobcat');
    });

    test('fromJson defaults optional arrays to empty', () {
      final json = statusJson();
      // Remove optional arrays to test null handling
      json.remove('media_attachments');
      json.remove('mentions');
      json.remove('tags');
      json.remove('emojis');
      final status = StatusSchema.fromJson(json);

      expect(status.attachments, isEmpty);
      expect(status.mentions, isEmpty);
      expect(status.tags, isEmpty);
      expect(status.emojis, isEmpty);
    });

    test('fromJson parses all VisibilityType values', () {
      for (final v in VisibilityType.values) {
        final json = statusJson(visibility: v.name);
        final status = StatusSchema.fromJson(json);
        expect(status.visibility, v);
      }
    });

    test('plainText strips HTML when text is null', () {
      final json = statusJson(content: '<p>Hello <strong>world</strong></p>');
      final status = StatusSchema.fromJson(json);

      expect(status.plainText, 'Hello world');
    });

    test('plainText returns text field when available', () {
      final json = statusJson(
        content: '<p>Hello world</p>',
        text: 'Hello world',
      );
      final status = StatusSchema.fromJson(json);

      expect(status.plainText, 'Hello world');
    });

    test('fromString round-trip', () {
      final json = statusJson();
      final str = jsonEncode(json);
      final status = StatusSchema.fromString(str);

      expect(status.id, '100');
      expect(status.content, '<p>Hello world</p>');
    });

    test('fromJson null optional fields default correctly', () {
      final json = statusJson();
      final status = StatusSchema.fromJson(json);

      expect(status.url, isNull);
      expect(status.text, isNull);
      expect(status.language, isNull);
      expect(status.editedAt, isNull);
      expect(status.inReplyToID, isNull);
      expect(status.inReplyToAccountID, isNull);
      expect(status.reblog, isNull);
      expect(status.poll, isNull);
      expect(status.card, isNull);
      expect(status.favourited, isNull);
      expect(status.reblogged, isNull);
      expect(status.bookmarked, isNull);
      expect(status.pinned, isNull);
      expect(status.muted, isNull);
    });

    test('fromJson parses interaction counts', () {
      final json = statusJson(
        reblogsCount: 42,
        favouritesCount: 100,
        repliesCount: 7,
      );
      final status = StatusSchema.fromJson(json);

      expect(status.reblogsCount, 42);
      expect(status.favouritesCount, 100);
      expect(status.repliesCount, 7);
    });
  });

  group('StatusSourceSchema', () {
    test('fromJson parses all fields', () {
      final json = {
        'id': '100',
        'text': 'Hello world',
        'spoiler_text': 'CW',
      };
      final source = StatusSourceSchema.fromJson(json);

      expect(source.id, '100');
      expect(source.text, 'Hello world');
      expect(source.spoilerText, 'CW');
    });

    test('fromJson handles null spoiler_text', () {
      final json = {
        'id': '100',
        'text': 'Hello',
      };
      final source = StatusSourceSchema.fromJson(json);

      expect(source.spoilerText, '');
    });

    test('fromString round-trip', () {
      final json = {'id': '100', 'text': 'test', 'spoiler_text': ''};
      final source = StatusSourceSchema.fromString(jsonEncode(json));

      expect(source.id, '100');
      expect(source.text, 'test');
    });
  });

  group('StatusContextSchema', () {
    test('fromJson parses ancestors and descendants', () {
      final json = {
        'ancestors': [statusJson(id: '1')],
        'descendants': [statusJson(id: '2'), statusJson(id: '3')],
      };
      final ctx = StatusContextSchema.fromJson(json);

      expect(ctx.ancestors.length, 1);
      expect(ctx.ancestors[0].id, '1');
      expect(ctx.descendants.length, 2);
      expect(ctx.descendants[0].id, '2');
    });

    test('fromJson handles empty arrays', () {
      final json = {
        'ancestors': <Map<String, dynamic>>[],
        'descendants': <Map<String, dynamic>>[],
      };
      final ctx = StatusContextSchema.fromJson(json);

      expect(ctx.ancestors, isEmpty);
      expect(ctx.descendants, isEmpty);
    });

    test('fromString round-trip', () {
      final json = {
        'ancestors': [statusJson(id: '1')],
        'descendants': [],
      };
      final ctx = StatusContextSchema.fromString(jsonEncode(json));

      expect(ctx.ancestors.length, 1);
    });
  });

  group('MentionSchema', () {
    test('fromJson parses all fields', () {
      final json = {
        'id': '42',
        'username': 'bob',
        'url': 'https://example.com/@bob',
        'acct': 'bob@remote.server',
      };
      final mention = MentionSchema.fromJson(json);

      expect(mention.id, '42');
      expect(mention.username, 'bob');
      expect(mention.url, 'https://example.com/@bob');
      expect(mention.acct, 'bob@remote.server');
    });
  });

  group('PreviewCardSchema', () {
    test('fromJson parses all fields', () {
      final json = {
        'url': 'https://article.com',
        'title': 'Great Article',
        'description': 'An article about testing',
        'type': 'link',
        'html': '<iframe></iframe>',
        'width': 400,
        'height': 300,
        'image': 'https://article.com/image.png',
      };
      final card = PreviewCardSchema.fromJson(json);

      expect(card.url, 'https://article.com');
      expect(card.title, 'Great Article');
      expect(card.description, 'An article about testing');
      expect(card.type, PreviewCardType.link);
      expect(card.html, '<iframe></iframe>');
      expect(card.width, 400);
      expect(card.height, 300);
      expect(card.image, 'https://article.com/image.png');
    });

    test('fromJson parses all PreviewCardType values', () {
      for (final t in PreviewCardType.values) {
        final json = {
          'url': 'https://example.com',
          'title': 'Test',
          'description': '',
          'type': t.name,
          'html': '',
          'width': 0,
          'height': 0,
        };
        final card = PreviewCardSchema.fromJson(json);
        expect(card.type, t);
      }
    });

    test('fromJson handles null image', () {
      final json = {
        'url': 'https://example.com',
        'title': 'Test',
        'description': '',
        'type': 'link',
        'html': '',
        'width': 0,
        'height': 0,
        'image': null,
      };
      final card = PreviewCardSchema.fromJson(json);
      expect(card.image, isNull);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
