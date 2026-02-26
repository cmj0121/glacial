// Tests for auth extensions: OAuth2Info model and Storage AuthExtension.
import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/features/auth/models/core.dart';

void main() {
  group('OAuth2Info', () {
    test('fromJson parses all fields', () {
      final json = {
        'id': '123',
        'name': 'TestApp',
        'website': 'https://test.com',
        'scopes': ['read', 'write'],
        'client_id': 'cid',
        'client_secret': 'csecret',
        'redirect_uri': 'glacial://auth',
        'redirect_uris': ['glacial://auth', 'urn:ietf:wg:oauth:2.0:oob'],
      };
      final info = OAuth2Info.fromJson(json);
      expect(info.id, '123');
      expect(info.name, 'TestApp');
      expect(info.website, 'https://test.com');
      expect(info.scopes, ['read', 'write']);
      expect(info.clientId, 'cid');
      expect(info.clientSecret, 'csecret');
      expect(info.redirectUri, 'glacial://auth');
      expect(info.redirectUris, hasLength(2));
    });

    test('toJson produces correct map', () {
      const info = OAuth2Info(
        id: '1',
        name: 'App',
        scopes: ['read'],
        clientId: 'c1',
        clientSecret: 's1',
        redirectUri: 'glacial://auth',
        redirectUris: ['glacial://auth'],
      );
      final json = info.toJson();
      expect(json['id'], '1');
      expect(json['name'], 'App');
      expect(json['website'], isNull);
      expect(json['client_id'], 'c1');
      expect(json['client_secret'], 's1');
      expect(json['redirect_uri'], 'glacial://auth');
      expect(json['scopes'], ['read']);
    });

    test('fromJson and toJson round-trip', () {
      const original = OAuth2Info(
        id: '42',
        name: 'RoundTrip',
        website: 'https://example.com',
        scopes: ['read', 'write', 'follow'],
        clientId: 'client-42',
        clientSecret: 'secret-42',
        redirectUri: 'glacial://auth',
        redirectUris: ['glacial://auth'],
      );
      final restored = OAuth2Info.fromJson(original.toJson());
      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.website, original.website);
      expect(restored.scopes, original.scopes);
      expect(restored.clientId, original.clientId);
      expect(restored.clientSecret, original.clientSecret);
    });

    test('fromString parses JSON string', () {
      const jsonStr = '{"id":"1","name":"App","scopes":["read"],"client_id":"c1","client_secret":"s1","redirect_uri":"uri","redirect_uris":["uri"]}';
      final info = OAuth2Info.fromString(jsonStr);
      expect(info.id, '1');
      expect(info.name, 'App');
    });

    test('prefsOAuthInfoKey is correct', () {
      expect(OAuth2Info.prefsOAuthInfoKey, 'oauth_info');
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
