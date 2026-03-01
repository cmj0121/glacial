import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/cores/http.dart';
import 'package:glacial/features/mastodon/extensions.dart';
import 'package:glacial/features/models.dart';

void main() {
  group('AccessStatusSchema isSignedIn', () {
    test('returns false when accessToken is null', () {
      const status = AccessStatusSchema();

      expect(status.isSignedIn, isFalse);
    });

    test('returns false when accessToken is empty', () {
      final status = const AccessStatusSchema().copyWith(accessToken: '');

      expect(status.isSignedIn, isFalse);
    });

    test('returns true when accessToken is present', () {
      final status = const AccessStatusSchema().copyWith(accessToken: 'valid-token');

      expect(status.isSignedIn, isTrue);
    });

    test('cleared token results in anonymous state', () {
      // Simulates the 401 cleanup: status built with null token and null account.
      final status = const AccessStatusSchema(domain: 'mastodon.social').copyWith(
        server: ServerSchema.fromJson(_serverJson()),
      );

      expect(status.isSignedIn, isFalse);
      expect(status.account, isNull);
      expect(status.domain, 'mastodon.social');
      expect(status.server, isNotNull);
    });
  });

  group('getAccountByAccessToken', () {
    test('returns null when token is null', () async {
      const status = AccessStatusSchema(domain: 'mastodon.social');
      final account = await status.getAccountByAccessToken(null);

      expect(account, isNull);
    });

    test('returns null when domain is null', () async {
      const status = AccessStatusSchema(domain: null);
      final account = await status.getAccountByAccessToken('some-token');

      expect(account, isNull);
    });
  });

  group('HttpException 401 identification', () {
    test('isUnauthorized is true for 401 on verify_credentials', () {
      final exception = HttpException(
        statusCode: 401,
        message: 'Unauthorized',
        uri: Uri.parse('https://mastodon.social/api/v1/accounts/verify_credentials'),
        body: '{"error":"The access token was revoked"}',
      );

      expect(exception.isUnauthorized, isTrue);
      expect(exception.isClientError, isTrue);
      expect(exception.body, contains('revoked'));
    });

    test('isUnauthorized is false for 403 forbidden', () {
      final exception = HttpException(
        statusCode: 403,
        message: 'Forbidden',
        uri: Uri.parse('https://mastodon.social/api/v1/accounts/verify_credentials'),
      );

      expect(exception.isUnauthorized, isFalse);
    });

    test('isUnauthorized is false for 500 server error', () {
      final exception = HttpException(
        statusCode: 500,
        message: 'Internal Server Error',
        uri: Uri.parse('https://mastodon.social/api/v1/accounts/verify_credentials'),
      );

      expect(exception.isUnauthorized, isFalse);
    });
  });

  group('activeKeyMatchesDomain (domain-match guard)', () {
    test('activeKey from different domain is ignored', () {
      expect(activeKeyMatchesDomain('old.server@123', 'new.server'), isFalse);
    });

    test('composite activeKey matching current domain is used', () {
      expect(activeKeyMatchesDomain('mastodon.social@123', 'mastodon.social'), isTrue);
    });

    test('plain domain activeKey is used when matching', () {
      expect(activeKeyMatchesDomain('mastodon.social', 'mastodon.social'), isTrue);
    });

    test('returns true when activeKey is null (no guard needed)', () {
      expect(activeKeyMatchesDomain(null, 'mastodon.social'), isTrue);
    });

    test('returns true when domain is null (no guard needed)', () {
      expect(activeKeyMatchesDomain('old.server@123', null), isTrue);
    });

    test('similar domain prefix does not false-match', () {
      // 'mastodon.social.evil@456' should NOT match domain 'mastodon.social'
      expect(activeKeyMatchesDomain('mastodon.social.evil@456', 'mastodon.social'), isFalse);
    });
  });

  group('compositeKey', () {
    test('returns domain@accountId when both present', () {
      final status = const AccessStatusSchema(domain: 'mastodon.social').copyWith(
        account: AccountSchema.fromJson(_accountJson()..['id'] = '12345'),
      );

      expect(status.compositeKey, 'mastodon.social@12345');
    });

    test('returns null when domain is null', () {
      final status = const AccessStatusSchema(domain: null).copyWith(
        account: AccountSchema.fromJson(_accountJson()),
      );

      expect(status.compositeKey, isNull);
    });

    test('returns null when account is null', () {
      const status = AccessStatusSchema(domain: 'mastodon.social');

      expect(status.compositeKey, isNull);
    });

    test('returns null when both are null', () {
      const status = AccessStatusSchema(domain: null);

      expect(status.compositeKey, isNull);
    });
  });

  group('AccessStatusSchema toString', () {
    test('toString returns JSON-encoded string', () {
      const status = AccessStatusSchema(
        domain: 'mastodon.social',
        history: [],
      );
      final str = status.toString();

      expect(str, contains('"domain":"mastodon.social"'));
      expect(str, contains('"history":[]'));
    });

    test('toString round-trips with fromString', () {
      const status = AccessStatusSchema(
        domain: 'example.com',
        history: [],
      );
      final str = status.toString();
      final restored = AccessStatusSchema.fromString(str);

      expect(restored.domain, 'example.com');
      expect(restored.history, isEmpty);
    });
  });

  group('AccessStatusSchema fromString/fromJson', () {
    test('fromString parses domain and history', () {
      const jsonStr = '{"domain":"test.server","history":[{"domain":"old.server","thumbnail":"https://old.server/thumb.png"}]}';
      final status = AccessStatusSchema.fromString(jsonStr);

      expect(status.domain, 'test.server');
      expect(status.history.length, 1);
      expect(status.history.first.domain, 'old.server');
    });

    test('fromJson parses null domain', () {
      final json = <String, dynamic>{
        'domain': null,
        'history': <dynamic>[],
      };
      final status = AccessStatusSchema.fromJson(json);

      expect(status.domain, isNull);
      expect(status.history, isEmpty);
    });

    test('fromJson parses multiple history entries', () {
      final json = <String, dynamic>{
        'domain': 'current.server',
        'history': [
          {'domain': 'server1.com', 'thumbnail': 'https://server1.com/t.png'},
          {'domain': 'server2.com', 'thumbnail': 'https://server2.com/t.png'},
        ],
      };
      final status = AccessStatusSchema.fromJson(json);

      expect(status.domain, 'current.server');
      expect(status.history.length, 2);
      expect(status.history[0].domain, 'server1.com');
      expect(status.history[1].domain, 'server2.com');
    });
  });

  group('AccessStatusSchema toJson', () {
    test('toJson includes domain and history', () {
      const status = AccessStatusSchema(
        domain: 'mastodon.social',
        history: [],
      );
      final json = status.toJson();

      expect(json['domain'], 'mastodon.social');
      expect(json['history'], isEmpty);
    });

    test('toJson does not include accessToken, server, account, or emojis', () {
      final status = const AccessStatusSchema(
        domain: 'mastodon.social',
      ).copyWith(accessToken: 'secret-token');
      final json = status.toJson();

      expect(json.containsKey('accessToken'), isFalse);
      expect(json.containsKey('access_token'), isFalse);
      expect(json.containsKey('server'), isFalse);
      expect(json.containsKey('account'), isFalse);
      expect(json.containsKey('emojis'), isFalse);
    });
  });

  group('AccessStatusSchema copyWith', () {
    test('copyWith preserves all fields when none overridden', () {
      final original = const AccessStatusSchema(domain: 'test.com').copyWith(
        accessToken: 'tok',
        account: AccountSchema.fromJson(_accountJson()),
        server: ServerSchema.fromJson(_serverJson()),
      );
      final copy = original.copyWith();

      expect(copy.domain, original.domain);
      expect(copy.accessToken, original.accessToken);
      expect(copy.account?.id, original.account?.id);
      expect(copy.server?.domain, original.server?.domain);
    });

    test('copyWith overrides specific fields', () {
      const original = AccessStatusSchema(domain: 'old.com');
      final updated = original.copyWith(domain: 'new.com', accessToken: 'new-token');

      expect(updated.domain, 'new.com');
      expect(updated.accessToken, 'new-token');
    });

    test('copyWith with emojis', () {
      const original = AccessStatusSchema(domain: 'test.com');
      final updated = original.copyWith(emojis: [
        EmojiSchema(shortcode: 'blob', url: 'https://e.com/blob.png', staticUrl: 'https://e.com/blob.png', visible: true),
      ]);

      expect(updated.emojis.length, 1);
      expect(updated.emojis.first.shortcode, 'blob');
    });
  });

  group('AccessStatusSchema checkSignedIn', () {
    test('throws when not signed in', () {
      const status = AccessStatusSchema(domain: 'test.com');

      expect(() => status.checkSignedIn(), throwsException);
    });

    test('does not throw when signed in', () {
      final status = const AccessStatusSchema(domain: 'test.com').copyWith(
        accessToken: 'valid-token',
      );

      expect(() => status.checkSignedIn(), returnsNormally);
    });
  });

  group('AccessStatusSchema getMaxIDFromNextLink', () {
    test('extracts max_id from next link', () {
      const status = AccessStatusSchema();
      final maxId = status.getMaxIDFromNextLink(
        '<https://mastodon.social/api/v1/timelines/home?max_id=12345>; rel="next"',
      );

      expect(maxId, '12345');
    });

    test('returns null when no next link', () {
      const status = AccessStatusSchema();
      final maxId = status.getMaxIDFromNextLink(
        '<https://mastodon.social/api/v1/timelines/home?since_id=99999>; rel="prev"',
      );

      expect(maxId, isNull);
    });

    test('returns null when nextLink is null', () {
      const status = AccessStatusSchema();
      final maxId = status.getMaxIDFromNextLink(null);

      expect(maxId, isNull);
    });

    test('handles multiple links with prev and next', () {
      const status = AccessStatusSchema();
      final maxId = status.getMaxIDFromNextLink(
        '<https://mastodon.social/api/v1/timelines/home?since_id=99999>; rel="prev", '
        '<https://mastodon.social/api/v1/timelines/home?max_id=11111>; rel="next"',
      );

      expect(maxId, '11111');
    });

    test('returns null for empty string', () {
      const status = AccessStatusSchema();
      final maxId = status.getMaxIDFromNextLink('');

      expect(maxId, isNull);
    });
  });

  group('AccessStatusSchema getAPI domain guard', () {
    test('returns null when domain is null', () async {
      const status = AccessStatusSchema(domain: null);
      final result = await status.getAPI('/api/v1/test');

      expect(result, isNull);
    });

    test('returns null when domain is empty string', () async {
      const status = AccessStatusSchema(domain: '');
      final result = await status.getAPI('/api/v1/test');

      expect(result, isNull);
    });
  });

  group('AccessStatusSchema getAPIEx domain guard', () {
    test('throws when domain is null', () async {
      const status = AccessStatusSchema(domain: null);

      expect(
        () => status.getAPIEx('/api/v1/test'),
        throwsException,
      );
    });

    test('throws when domain is empty string', () async {
      const status = AccessStatusSchema(domain: '');

      expect(
        () => status.getAPIEx('/api/v1/test'),
        throwsException,
      );
    });
  });

  group('AccessStatusSchema postAPI domain guard', () {
    test('returns null when domain is null', () async {
      const status = AccessStatusSchema(domain: null);
      final result = await status.postAPI('/api/v1/test');

      expect(result, isNull);
    });

    test('returns null when domain is empty string', () async {
      const status = AccessStatusSchema(domain: '');
      final result = await status.postAPI('/api/v1/test');

      expect(result, isNull);
    });
  });

  group('AccessStatusSchema putAPI domain guard', () {
    test('returns null when domain is null', () async {
      const status = AccessStatusSchema(domain: null);
      final result = await status.putAPI('/api/v1/test');

      expect(result, isNull);
    });

    test('returns null when domain is empty string', () async {
      const status = AccessStatusSchema(domain: '');
      final result = await status.putAPI('/api/v1/test');

      expect(result, isNull);
    });
  });

  group('AccessStatusSchema patchAPI domain guard', () {
    test('returns null when domain is null', () async {
      const status = AccessStatusSchema(domain: null);
      final result = await status.patchAPI('/api/v1/test');

      expect(result, isNull);
    });

    test('returns null when domain is empty string', () async {
      const status = AccessStatusSchema(domain: '');
      final result = await status.patchAPI('/api/v1/test');

      expect(result, isNull);
    });
  });

  group('AccessStatusSchema deleteAPI domain guard', () {
    test('returns null when domain is null', () async {
      const status = AccessStatusSchema(domain: null);
      final result = await status.deleteAPI('/api/v1/test');

      expect(result, isNull);
    });

    test('returns null when domain is empty string', () async {
      const status = AccessStatusSchema(domain: '');
      final result = await status.deleteAPI('/api/v1/test');

      expect(result, isNull);
    });
  });

  group('AccessStatusSchema multipartsAPI domain guard', () {
    test('returns null when domain is null', () async {
      const status = AccessStatusSchema(domain: null);
      final result = await status.multipartsAPI(
        '/api/v1/test',
        method: 'POST',
        files: {},
      );

      expect(result, isNull);
    });

    test('returns null when domain is empty string', () async {
      const status = AccessStatusSchema(domain: '');
      final result = await status.multipartsAPI(
        '/api/v1/test',
        method: 'POST',
        files: {},
      );

      expect(result, isNull);
    });
  });

  group('AccessStatusSchema getAPI with valid domain catches errors', () {
    test('getAPI returns null on network error (catches generic exception)', () async {
      // Using a valid domain that will fail to connect exercises the catch block.
      final status = const AccessStatusSchema(domain: 'nonexistent-server-12345.invalid').copyWith(
        accessToken: 'test-token',
      );
      final result = await status.getAPI('/api/v1/timelines/home');

      expect(result, isNull);
    });
  });

  group('AccessStatusSchema getAPIEx with valid domain catches errors', () {
    test('getAPIEx throws on network error', () async {
      final status = const AccessStatusSchema(domain: 'nonexistent-server-12345.invalid').copyWith(
        accessToken: 'test-token',
      );

      expect(
        () => status.getAPIEx('/api/v1/timelines/home'),
        throwsException,
      );
    });
  });

  group('AccessStatusSchema getAPI with explicit headers covers header spread', () {
    test('getAPI with explicit headers returns null on network error', () async {
      // Passing explicit headers exercises the ...?headers spread (non-null branch).
      final status = const AccessStatusSchema(domain: 'nonexistent-server-12345.invalid').copyWith(
        accessToken: 'test-token',
      );
      final result = await status.getAPI(
        '/api/v1/timelines/home',
        headers: {'X-Custom': 'value'},
      );

      expect(result, isNull);
    });
  });

  group('AccessStatusSchema postAPI with valid domain exercises body', () {
    test('postAPI throws on network error when domain is valid', () async {
      final status = const AccessStatusSchema(domain: 'nonexistent-server-12345.invalid').copyWith(
        accessToken: 'test-token',
      );

      expect(
        () => status.postAPI('/api/v1/test', body: {'key': 'value'}),
        throwsA(anything),
      );
    });

    test('postAPI with explicit headers throws on network error', () async {
      final status = const AccessStatusSchema(domain: 'nonexistent-server-12345.invalid').copyWith(
        accessToken: 'test-token',
      );

      expect(
        () => status.postAPI('/api/v1/test', headers: {'X-Custom': 'header'}),
        throwsA(anything),
      );
    });
  });

  group('AccessStatusSchema putAPI with valid domain exercises body', () {
    test('putAPI throws on network error when domain is valid', () async {
      final status = const AccessStatusSchema(domain: 'nonexistent-server-12345.invalid').copyWith(
        accessToken: 'test-token',
      );

      expect(
        () => status.putAPI('/api/v1/test', body: {'key': 'value'}),
        throwsA(anything),
      );
    });

    test('putAPI without body throws on network error when domain is valid', () async {
      final status = const AccessStatusSchema(domain: 'nonexistent-server-12345.invalid').copyWith(
        accessToken: 'test-token',
      );

      expect(
        () => status.putAPI('/api/v1/test'),
        throwsA(anything),
      );
    });
  });

  group('AccessStatusSchema patchAPI with valid domain exercises body', () {
    test('patchAPI throws on network error when domain is valid', () async {
      final status = const AccessStatusSchema(domain: 'nonexistent-server-12345.invalid').copyWith(
        accessToken: 'test-token',
      );

      expect(
        () => status.patchAPI('/api/v1/test', body: {'key': 'value'}),
        throwsA(anything),
      );
    });

    test('patchAPI with explicit headers throws on network error', () async {
      final status = const AccessStatusSchema(domain: 'nonexistent-server-12345.invalid').copyWith(
        accessToken: 'test-token',
      );

      expect(
        () => status.patchAPI('/api/v1/test', headers: {'Accept': 'application/json'}),
        throwsA(anything),
      );
    });
  });

  group('AccessStatusSchema deleteAPI with valid domain exercises body', () {
    test('deleteAPI throws on network error when domain is valid', () async {
      final status = const AccessStatusSchema(domain: 'nonexistent-server-12345.invalid').copyWith(
        accessToken: 'test-token',
      );

      expect(
        () => status.deleteAPI('/api/v1/test'),
        throwsA(anything),
      );
    });

    test('deleteAPI with body throws on network error when domain is valid', () async {
      final status = const AccessStatusSchema(domain: 'nonexistent-server-12345.invalid').copyWith(
        accessToken: 'test-token',
      );

      expect(
        () => status.deleteAPI('/api/v1/test', body: {'id': '123'}),
        throwsA(anything),
      );
    });
  });

  group('AccessStatusSchema multipartsAPI with valid domain exercises body', () {
    test('multipartsAPI throws on network error when domain is valid', () async {
      final status = const AccessStatusSchema(domain: 'nonexistent-server-12345.invalid').copyWith(
        accessToken: 'test-token',
      );

      expect(
        () => status.multipartsAPI(
          '/api/v1/test',
          method: 'POST',
          files: {},
          body: {'description': 'test'},
        ),
        throwsA(anything),
      );
    });

    test('multipartsAPI with explicit headers throws on network error', () async {
      final status = const AccessStatusSchema(domain: 'nonexistent-server-12345.invalid').copyWith(
        accessToken: 'test-token',
      );

      expect(
        () => status.multipartsAPI(
          '/api/v1/test',
          method: 'PUT',
          files: {},
          headers: {'X-Custom': 'value'},
        ),
        throwsA(anything),
      );
    });
  });

  group('401 cleanup flow contract', () {
    test('anonymous status after cleanup has correct routing hints', () {
      // After 401 cleanup, status should be anonymous with server config available
      // so landing page can route to trends (when public feeds disabled).
      final status = const AccessStatusSchema(domain: 'mastodon.social').copyWith(
        server: ServerSchema.fromJson(_serverJson(timelinesAccess: {
          'home': 'authenticated',
          'live_feeds': {'local': 'disabled', 'remote': 'disabled'},
        })),
      );

      expect(status.isSignedIn, isFalse);
      expect(status.server?.config.timelinesAccess.hasPublicFeeds, isFalse);
    });

    test('anonymous status with public feeds routes to timeline', () {
      final status = const AccessStatusSchema(domain: 'fosstodon.org').copyWith(
        server: ServerSchema.fromJson(_serverJson(timelinesAccess: {
          'home': 'authenticated',
          'live_feeds': {'local': 'public', 'remote': 'public'},
        })),
      );

      expect(status.isSignedIn, isFalse);
      expect(status.server?.config.timelinesAccess.hasPublicFeeds, isTrue);
    });
  });
}

// Minimal server JSON for testing.
Map<String, dynamic> _serverJson({Map<String, dynamic>? timelinesAccess}) => {
  'domain': 'mastodon.social',
  'title': 'Mastodon',
  'version': '4.5.0',
  'description': '',
  'usage': {'users': {'active_month': 1000}},
  'thumbnail': {'url': ''},
  'languages': ['en'],
  'configuration': {
    'statuses': {
      'max_characters': 500,
      'max_media_attachments': 4,
      'characters_reserved_per_url': 23,
    },
    'polls': {
      'max_options': 4,
      'max_characters_per_option': 50,
      'min_expiration': 300,
      'max_expiration': 2629746,
    },
    'translation': {'enabled': true},
    if (timelinesAccess != null) 'timelines_access': timelinesAccess,
  },
  'registrations': {'enabled': true, 'approval_required': false},
  'contact': {
    'email': 'admin@mastodon.social',
    'account': _accountJson(),
  },
  'rules': [],
};

Map<String, dynamic> _accountJson() => {
  'id': '1',
  'username': 'admin',
  'acct': 'admin',
  'display_name': 'Admin',
  'url': 'https://mastodon.social/@admin',
  'avatar': '',
  'avatar_static': '',
  'header': '',
  'header_static': '',
  'note': '',
  'created_at': '2024-01-01T00:00:00.000Z',
  'followers_count': 0,
  'following_count': 0,
  'statuses_count': 0,
  'last_status_at': '2024-01-01',
  'locked': false,
  'bot': false,
  'indexable': false,
  'fields': [],
  'emojis': [],
};

// vim: set ts=2 sw=2 sts=2 et:
