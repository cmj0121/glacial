// Tests for auth API extensions.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/mastodon/extensions.dart';

import '../../../helpers/mock_http.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  setUpAll(() async {
    setupTestEnvironment();
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
    await Storage.init();
  });

  const auth = AccessStatusSchema(
    domain: 'nonexistent-server-12345.invalid',
    accessToken: 'test-token',
  );

  group('AuthExtensions revokeAccessToken', () {
    test('revokeAccessToken completes when domain is null', () async {
      await auth.revokeAccessToken(domain: null, token: 'token');
    });

    test('revokeAccessToken completes when domain is empty', () async {
      await auth.revokeAccessToken(domain: '', token: 'token');
    });

    test('revokeAccessToken throws on network error with valid domain', () {
      expect(
        () => auth.revokeAccessToken(
          domain: 'nonexistent-server-12345.invalid',
          token: 'token',
        ),
        throwsA(anything),
      );
    });
  });

  group('AuthExtensions getAccessToken', () {
    test('getAccessToken throws on network error', () {
      expect(
        () => auth.getAccessToken(
          domain: 'nonexistent-server-12345.invalid',
          code: 'test-code',
        ),
        throwsA(anything),
      );
    });
  });

  group('AuthExtensions getAppToken', () {
    test('getAppToken throws on network error', () {
      expect(
        () => auth.getAppToken(domain: 'nonexistent-server-12345.invalid'),
        throwsA(anything),
      );
    });
  });

  group('AuthExtensions with mock HTTP (success paths)', () {
    late HttpOverrides? originalOverrides;

    setUp(() async {
      originalOverrides = HttpOverrides.current;
      // Pre-populate OAuth2Info in secure storage
      FlutterSecureStorage.setMockInitialValues({
        'oauth_info': jsonEncode({
          'mock-server.com': {
            'id': 'app-1',
            'name': 'Glacial',
            'scopes': ['read', 'write'],
            'client_id': 'test-client-id',
            'client_secret': 'test-client-secret',
            'redirect_uri': 'glacial://auth',
            'redirect_uris': ['glacial://auth'],
          },
        }),
      });
      SharedPreferences.setMockInitialValues({});
      await Storage.init();
    });

    tearDown(() {
      HttpOverrides.global = originalOverrides;
    });

    test('getAccessToken success returns access token', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        return (200, '{"access_token":"new_token_abc"}');
      });

      final result = await auth.getAccessToken(domain: 'mock-server.com', code: 'test-code');
      expect(result, 'new_token_abc');
    });

    test('getAccessToken throws on 400 error', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        return (400, '{"error":"invalid_grant"}');
      });

      expect(
        () => auth.getAccessToken(domain: 'mock-server.com', code: 'bad-code'),
        throwsException,
      );
    });

    test('getAppToken success returns app token', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        return (200, '{"access_token":"app_token_xyz"}');
      });

      final result = await auth.getAppToken(domain: 'mock-server.com');
      expect(result, 'app_token_xyz');
    });

    test('getAppToken returns null on 500 error', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        return (500, '{"error":"server error"}');
      });

      final result = await auth.getAppToken(domain: 'mock-server.com');
      expect(result, isNull);
    });

    test('authorize constructs correct URI', () async {
      final uri = await auth.authorize(domain: 'mock-server.com', state: 'test-state');
      expect(uri.host, 'mock-server.com');
      expect(uri.path, '/oauth/authorize');
      expect(uri.queryParameters['client_id'], 'test-client-id');
      expect(uri.queryParameters['response_type'], 'code');
      expect(uri.queryParameters['state'], 'test-state');
    });

    test('revokeAccessToken completes via POST to /oauth/revoke', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        expect(method, 'POST');
        expect(url.path, '/oauth/revoke');
        return (200, '{}');
      });

      await auth.revokeAccessToken(
        domain: 'mock-server.com',
        token: 'token-to-revoke',
      );
    });

    test('getAppToken returns null on non-200 response', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        return (403, '{"error":"forbidden"}');
      });

      final result = await auth.getAppToken(domain: 'mock-server.com');
      expect(result, isNull);
    });

    test('getAccessToken response without access_token returns null', () async {
      HttpOverrides.global = MockHttpOverrides(handler: (method, url) {
        return (200, '{"token_type":"bearer"}');
      });

      final result = await auth.getAccessToken(domain: 'mock-server.com', code: 'code');
      expect(result, isNull);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
