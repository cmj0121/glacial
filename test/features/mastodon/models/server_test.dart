import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/features/models.dart';

void main() {
  // JSON helpers
  Map<String, dynamic> serverJson({
    String domain = 'mastodon.social',
    String title = 'Mastodon',
    String description = 'A social network',
    String version = '4.2.0',
    String thumbnailUrl = 'https://mastodon.social/thumb.png',
    int activeMonth = 1000,
    bool translationEnabled = false,
    bool registrationEnabled = true,
    bool approvalRequired = false,
  }) => {
    'domain': domain,
    'title': title,
    'description': description,
    'version': version,
    'thumbnail': {'url': thumbnailUrl},
    'usage': {
      'users': {'active_month': activeMonth},
    },
    'configuration': {
      'statuses': {
        'characters_reserved_per_url': 23,
        'max_characters': 500,
        'max_media_attachments': 4,
      },
      'polls': {
        'max_options': 4,
        'max_characters_per_option': 50,
        'min_expiration': 300,
        'max_expiration': 2592000,
      },
      'translation': {'enabled': translationEnabled},
    },
    'registrations': {
      'enabled': registrationEnabled,
      'approval_required': approvalRequired,
    },
    'contact': {'email': 'admin@$domain'},
    'languages': ['en', 'de'],
    'rules': [
      {'id': '1', 'text': 'No spam', 'hint': 'Do not spam'},
      {'id': '2', 'text': 'Be kind', 'hint': 'Treat others well'},
    ],
  };

  group('ServerUsageSchema', () {
    test('fromJson parses nested users.active_month', () {
      final json = {'users': {'active_month': 5000}};
      final usage = ServerUsageSchema.fromJson(json);

      expect(usage.userActiveMonthly, 5000);
    });

    test('fromJson defaults to 0 when users is null', () {
      final json = <String, dynamic>{};
      final usage = ServerUsageSchema.fromJson(json);

      expect(usage.userActiveMonthly, 0);
    });
  });

  group('StatusConfigSchema', () {
    test('fromJson parses all fields', () {
      final json = {
        'characters_reserved_per_url': 23,
        'max_characters': 500,
        'max_media_attachments': 4,
      };
      final config = StatusConfigSchema.fromJson(json);

      expect(config.charReserved, 23);
      expect(config.maxCharacters, 500);
      expect(config.maxAttachments, 4);
    });

    test('fromJson defaults to 0 when fields missing', () {
      final json = <String, dynamic>{};
      final config = StatusConfigSchema.fromJson(json);

      expect(config.charReserved, 0);
      expect(config.maxCharacters, 0);
      expect(config.maxAttachments, 0);
    });
  });

  group('PollConfigSchema', () {
    test('fromJson parses all fields', () {
      final json = {
        'max_options': 6,
        'max_characters_per_option': 100,
        'min_expiration': 300,
        'max_expiration': 604800,
      };
      final config = PollConfigSchema.fromJson(json);

      expect(config.maxOptions, 6);
      expect(config.maxCharacters, 100);
      expect(config.minExpiresIn, 300);
      expect(config.maxExpiresIn, 604800);
    });
  });

  group('TimelineAccessLevel', () {
    test('fromString parses public', () {
      expect(TimelineAccessLevel.fromString('public'), TimelineAccessLevel.public);
    });

    test('fromString parses authenticated', () {
      expect(TimelineAccessLevel.fromString('authenticated'), TimelineAccessLevel.authenticated);
    });

    test('fromString parses disabled', () {
      expect(TimelineAccessLevel.fromString('disabled'), TimelineAccessLevel.disabled);
    });

    test('fromString defaults unknown to disabled', () {
      expect(TimelineAccessLevel.fromString('unknown'), TimelineAccessLevel.disabled);
    });

    test('fromString defaults null to disabled', () {
      expect(TimelineAccessLevel.fromString(null), TimelineAccessLevel.disabled);
    });
  });

  group('LiveFeedsAccessSchema', () {
    test('fromJson parses all fields', () {
      final json = {
        'local': 'public',
        'remote': 'disabled',
        'bubble': 'authenticated',
      };
      final feeds = LiveFeedsAccessSchema.fromJson(json);

      expect(feeds.local, TimelineAccessLevel.public);
      expect(feeds.federated, TimelineAccessLevel.disabled);
      expect(feeds.bubble, TimelineAccessLevel.authenticated);
    });

    test('fromJson defaults to disabled when empty', () {
      final feeds = LiveFeedsAccessSchema.fromJson({});

      expect(feeds.local, TimelineAccessLevel.disabled);
      expect(feeds.federated, TimelineAccessLevel.disabled);
      expect(feeds.bubble, TimelineAccessLevel.disabled);
    });

    test('default constructor uses public', () {
      const feeds = LiveFeedsAccessSchema();

      expect(feeds.local, TimelineAccessLevel.public);
      expect(feeds.federated, TimelineAccessLevel.public);
      expect(feeds.bubble, TimelineAccessLevel.public);
    });
  });

  group('TimelinesAccessSchema', () {
    test('fromJson with null returns defaults', () {
      final access = TimelinesAccessSchema.fromJson(null);

      expect(access.home, TimelineAccessLevel.authenticated);
      expect(access.liveFeeds.local, TimelineAccessLevel.public);
      expect(access.liveFeeds.federated, TimelineAccessLevel.public);
    });

    test('fromJson parses populated data', () {
      final access = TimelinesAccessSchema.fromJson({
        'home': 'authenticated',
        'live_feeds': {
          'local': 'disabled',
          'remote': 'disabled',
        },
      });

      expect(access.home, TimelineAccessLevel.authenticated);
      expect(access.liveFeeds.local, TimelineAccessLevel.disabled);
      expect(access.liveFeeds.federated, TimelineAccessLevel.disabled);
    });

    test('fromJson with missing live_feeds defaults', () {
      final access = TimelinesAccessSchema.fromJson({
        'home': 'public',
      });

      expect(access.home, TimelineAccessLevel.public);
      expect(access.liveFeeds.local, TimelineAccessLevel.disabled);
      expect(access.liveFeeds.federated, TimelineAccessLevel.disabled);
    });

    test('fromJson with missing home key defaults to authenticated', () {
      final access = TimelinesAccessSchema.fromJson({
        'live_feeds': {'local': 'disabled', 'remote': 'disabled'},
      });

      expect(access.home, TimelineAccessLevel.authenticated);
    });

    test('hasPublicFeeds is true when local is available', () {
      final access = TimelinesAccessSchema.fromJson({
        'live_feeds': {'local': 'public', 'remote': 'disabled'},
      });
      expect(access.hasPublicFeeds, true);
    });

    test('hasPublicFeeds is true when federated is available', () {
      final access = TimelinesAccessSchema.fromJson({
        'live_feeds': {'local': 'disabled', 'remote': 'public'},
      });
      expect(access.hasPublicFeeds, true);
    });

    test('hasPublicFeeds is false when both disabled', () {
      final access = TimelinesAccessSchema.fromJson({
        'live_feeds': {'local': 'disabled', 'remote': 'disabled'},
      });
      expect(access.hasPublicFeeds, false);
    });

    test('hasPublicFeeds is true with default constructor', () {
      const access = TimelinesAccessSchema();
      expect(access.hasPublicFeeds, true);
    });
  });

  group('ServerConfigSchema', () {
    test('fromJson parses nested statuses/polls/translation', () {
      final json = {
        'statuses': {
          'characters_reserved_per_url': 23,
          'max_characters': 500,
          'max_media_attachments': 4,
        },
        'polls': {
          'max_options': 4,
          'max_characters_per_option': 50,
          'min_expiration': 300,
          'max_expiration': 2592000,
        },
        'translation': {'enabled': true},
      };
      final config = ServerConfigSchema.fromJson(json);

      expect(config.statuses.maxCharacters, 500);
      expect(config.polls.maxOptions, 4);
      expect(config.translationEnabled, true);
    });

    test('fromJson defaults translation to false when null', () {
      final json = {
        'statuses': {
          'characters_reserved_per_url': 0,
          'max_characters': 0,
          'max_media_attachments': 0,
        },
        'polls': {
          'max_options': 0,
          'max_characters_per_option': 0,
          'min_expiration': 0,
          'max_expiration': 0,
        },
      };
      final config = ServerConfigSchema.fromJson(json);

      expect(config.translationEnabled, false);
    });

    test('fromJson defaults timelinesAccess when absent', () {
      final json = {
        'statuses': {
          'characters_reserved_per_url': 0,
          'max_characters': 0,
          'max_media_attachments': 0,
        },
        'polls': {
          'max_options': 0,
          'max_characters_per_option': 0,
          'min_expiration': 0,
          'max_expiration': 0,
        },
      };
      final config = ServerConfigSchema.fromJson(json);

      expect(config.timelinesAccess.home, TimelineAccessLevel.authenticated);
      expect(config.timelinesAccess.liveFeeds.local, TimelineAccessLevel.public);
      expect(config.timelinesAccess.liveFeeds.federated, TimelineAccessLevel.public);
    });

    test('fromJson parses timelines_access when present', () {
      final json = {
        'statuses': {
          'characters_reserved_per_url': 0,
          'max_characters': 0,
          'max_media_attachments': 0,
        },
        'polls': {
          'max_options': 0,
          'max_characters_per_option': 0,
          'min_expiration': 0,
          'max_expiration': 0,
        },
        'timelines_access': {
          'home': 'authenticated',
          'live_feeds': {
            'local': 'disabled',
            'remote': 'disabled',
          },
        },
      };
      final config = ServerConfigSchema.fromJson(json);

      expect(config.timelinesAccess.liveFeeds.local, TimelineAccessLevel.disabled);
      expect(config.timelinesAccess.liveFeeds.federated, TimelineAccessLevel.disabled);
    });
  });

  group('RegisterConfigSchema', () {
    test('fromJson parses enabled and approval_required', () {
      final json = {'enabled': true, 'approval_required': true};
      final config = RegisterConfigSchema.fromJson(json);

      expect(config.enabled, true);
      expect(config.approvalRequired, true);
    });

    test('fromJson defaults to false when missing', () {
      final json = <String, dynamic>{};
      final config = RegisterConfigSchema.fromJson(json);

      expect(config.enabled, false);
      expect(config.approvalRequired, false);
    });
  });

  group('RuleSchema', () {
    test('fromJson parses all fields', () {
      final json = {'id': '1', 'text': 'No spam', 'hint': 'Do not spam'};
      final rule = RuleSchema.fromJson(json);

      expect(rule.id, '1');
      expect(rule.text, 'No spam');
      expect(rule.hint, 'Do not spam');
    });
  });

  group('ContactSchema', () {
    test('fromJson parses email', () {
      final json = {'email': 'admin@example.com'};
      final contact = ContactSchema.fromJson(json);

      expect(contact.email, 'admin@example.com');
    });
  });

  group('ServerInfoSchema', () {
    test('fromJson parses all fields', () {
      final json = {
        'domain': 'example.com',
        'thumbnail': 'https://example.com/thumb.png',
      };
      final info = ServerInfoSchema.fromJson(json);

      expect(info.domain, 'example.com');
      expect(info.thumbnail, 'https://example.com/thumb.png');
    });

    test('toJson produces correct output', () {
      const info = ServerInfoSchema(
        domain: 'example.com',
        thumbnail: 'https://example.com/thumb.png',
      );
      final json = info.toJson();

      expect(json['domain'], 'example.com');
      expect(json['thumbnail'], 'https://example.com/thumb.png');
    });

    test('fromString round-trip', () {
      const info = ServerInfoSchema(
        domain: 'example.com',
        thumbnail: 'https://example.com/thumb.png',
      );
      final str = jsonEncode(info.toJson());
      final rebuilt = ServerInfoSchema.fromString(str);

      expect(rebuilt.domain, 'example.com');
      expect(rebuilt.thumbnail, 'https://example.com/thumb.png');
    });
  });

  group('ServerSchema', () {
    test('fromJson parses all nested objects', () {
      final json = serverJson();
      final server = ServerSchema.fromJson(json);

      expect(server.domain, 'mastodon.social');
      expect(server.title, 'Mastodon');
      expect(server.desc, 'A social network');
      expect(server.version, '4.2.0');
      expect(server.thumbnail, 'https://mastodon.social/thumb.png');
      expect(server.usage.userActiveMonthly, 1000);
      expect(server.config.statuses.maxCharacters, 500);
      expect(server.config.polls.maxOptions, 4);
      expect(server.config.translationEnabled, false);
      expect(server.registration.enabled, true);
      expect(server.registration.approvalRequired, false);
      expect(server.contact.email, 'admin@mastodon.social');
      expect(server.languages, ['en', 'de']);
      expect(server.rules.length, 2);
      expect(server.rules[0].text, 'No spam');
    });

    test('fromString round-trip', () {
      final json = serverJson();
      final server = ServerSchema.fromString(jsonEncode(json));

      expect(server.domain, 'mastodon.social');
      expect(server.rules.length, 2);
    });

    test('toInfo creates ServerInfoSchema', () {
      final json = serverJson();
      final server = ServerSchema.fromJson(json);
      final info = server.toInfo();

      expect(info.domain, 'mastodon.social');
      expect(info.thumbnail, 'https://mastodon.social/thumb.png');
    });

    test('fromJson with translation enabled', () {
      final json = serverJson(translationEnabled: true);
      final server = ServerSchema.fromJson(json);

      expect(server.config.translationEnabled, true);
    });
  });

  group('ReactionSchema', () {
    test('fromJson parses all fields', () {
      final json = {
        'name': '👍',
        'count': 5,
        'me': true,
        'url': 'https://example.com/emoji.png',
        'static_url': 'https://example.com/emoji_static.png',
      };
      final reaction = ReactionSchema.fromJson(json);

      expect(reaction.name, '👍');
      expect(reaction.count, 5);
      expect(reaction.me, true);
      expect(reaction.url, 'https://example.com/emoji.png');
      expect(reaction.staticUrl, 'https://example.com/emoji_static.png');
    });

    test('fromJson handles null optional fields', () {
      final json = {'name': '🎉'};
      final reaction = ReactionSchema.fromJson(json);

      expect(reaction.name, '🎉');
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
        'content': '<p>Server maintenance tonight</p>',
        'starts_at': '2024-06-15T22:00:00.000Z',
        'ends_at': '2024-06-16T04:00:00.000Z',
        'all_day': false,
        'published_at': '2024-06-14T10:00:00.000Z',
        'updated_at': '2024-06-14T12:00:00.000Z',
        'read': true,
        'reactions': [
          {'name': '👍', 'count': 3, 'me': false},
        ],
      };
      final ann = AnnouncementSchema.fromJson(json);

      expect(ann.id, '1');
      expect(ann.content, '<p>Server maintenance tonight</p>');
      expect(ann.startsAt, '2024-06-15T22:00:00.000Z');
      expect(ann.endsAt, '2024-06-16T04:00:00.000Z');
      expect(ann.allDay, false);
      expect(ann.publishedAt, '2024-06-14T10:00:00.000Z');
      expect(ann.updatedAt, '2024-06-14T12:00:00.000Z');
      expect(ann.read, true);
      expect(ann.reactions.length, 1);
    });

    test('fromJson handles null optional fields', () {
      final json = {
        'id': '2',
        'content': '<p>Update</p>',
        'published_at': '2024-01-01T00:00:00.000Z',
      };
      final ann = AnnouncementSchema.fromJson(json);

      expect(ann.startsAt, isNull);
      expect(ann.endsAt, isNull);
      expect(ann.allDay, false);
      expect(ann.updatedAt, isNull);
      expect(ann.read, false);
      expect(ann.reactions, isEmpty);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
