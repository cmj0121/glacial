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
