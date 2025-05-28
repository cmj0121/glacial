// The extensions implementation for the OAuth2 application.
import 'dart:async';
import 'dart:convert';

import 'package:glacial/core.dart';
import 'package:glacial/features/auth/models/oauth.dart';
import 'package:glacial/features/glacial/models/server.dart';

final String prefsOAuthInfoKey = "mastodon_server_oauth2_info";
final String prefsAccessTokenKey = "access_token";

// The OAuth sign-in in-memory cache.
Map <String, ServerSchema> stateCache = {};

// Extend the Storage that can be used to access the Mastodon server by get/set servers.
extension OAuth2Extension on Storage {
  // Get or Create the OAuth2Info from the storage based on the domain.
  Future<OAuth2Info> getOAuth2Info(String domain) async {
    late OAuth2Info? info;

    info = await loadOAuth2Info(domain);
    if (info == null) {
      info = await OAuth2Info.register(domain);
      saveOAuth2Info(domain, info);
    }

    return info;
  }

  // Load the OAuth2Info from the storage based on the domain.
  Future<OAuth2Info?> loadOAuth2Info(String domain) async {
    final Map<String, dynamic> json = jsonDecode(await getString(prefsOAuthInfoKey, secure: true) ?? '{}');
    final Map<String, dynamic>? server = json[domain] as Map<String, dynamic>?;

    return server == null ? null : OAuth2Info.fromJson(server);
  }

  // Save the OAuth2Info to the storage based on the domain.
  void saveOAuth2Info(String domain, OAuth2Info info) async {
    final Map<String, dynamic> json = jsonDecode(await getString(prefsOAuthInfoKey, secure: true) ?? '{}');

    json[domain] = info.toJson();
    setString(prefsOAuthInfoKey, jsonEncode(json), secure: true);
  }

  // Load the AccessToken from the storage based on the domain.
  Future<String?> loadAccessToken(String? domain) async {
    if (domain == null) {
      return null;
    }

    final Map<String, dynamic> json = jsonDecode(await getString(prefsAccessTokenKey, secure: true) ?? '{}');
    return json[domain] as String?;
  }

  // Save the AccessToken to the storage based on the domain.
  Future<void> saveAccessToken(String domain, String? token) async {
    final Map<String, dynamic> json = jsonDecode(await getString(prefsAccessTokenKey, secure: true) ?? '{}');

    if (token == null) {
      json.remove(domain);
    } else {
      json[domain] = token;
    }
    setString(prefsAccessTokenKey, jsonEncode(json), secure: true);
  }

  // The sign-in page is loaded, handle the sign-in process.
  Future<String?> gainAccessToken(Uri uri) async {
    final String? code = uri.queryParameters["code"];
    final String? state = uri.queryParameters["state"];

    final Storage storage = Storage();
    final ServerSchema? schema = storage.loadFromOAuthState(state);

    if (schema == null || code == null) {
      logger.w("expected: schema, code, got: $schema, $code");
      return null;
    }

    final OAuth2Info info = await storage.getOAuth2Info(schema.domain);
    final String? accessToken = await info.getAccessToken(schema.domain, code);

    // confirm the access token work.
    final Uri verifyUri = UriEx.handle(schema.domain, "/api/v1/apps/verify_credentials");
    final Map<String, String> headers = {"Authorization": "Bearer $accessToken"};
    await get(verifyUri, headers: headers);

    storage.saveAccessToken(schema.domain, accessToken);
    return accessToken;
  }

  // Save the state to the cache for the OAuth2 sign-in process.
  void saveToOAuthState(String state, ServerSchema schema) {
    stateCache[state] = schema;
  }

  // Load the state from the cache for the OAuth2 sign-in process.
  ServerSchema? loadFromOAuthState(String? state) {
    final ServerSchema? schema = stateCache[state];
    if (schema != null) {
      stateCache.remove(state);
    }
    return schema;
  }
}

// Extend the OAuth2Info to gain the access token from the grant code.
extension AccessTokenExtension on OAuth2Info {
  Future<String?> getAccessToken(String domain, String code) async {
    final Map<String, dynamic> body = {
      "client_id": clientId,
      "client_secret": clientSecret,
      "code": code,
      "grant_type": "authorization_code",
      "redirect_uri": redirectUri,
    }
        ..removeWhere((key, value) => value == null);

    final Uri uri = UriEx.handle(domain, "/oauth/token");
    final response = await post(uri, body: jsonEncode(body), headers: {
      "Content-Type": "application/json",
    });

    if (response.statusCode != 200) {
      throw RequestError(response);
    }

    final Map<String, dynamic> json = jsonDecode(response.body) as Map<String, dynamic>;
    return json['access_token'] as String?;
  }
}

// vim: set ts=2 sw=2 sts=2 et:
