// Tests for auth API extensions.
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/mastodon/extensions.dart';

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
}

// vim: set ts=2 sw=2 sts=2 et:
