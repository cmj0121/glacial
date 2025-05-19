// The extensions implementation for the OAuth2 application.
import 'dart:async';
import 'dart:convert';

import 'package:glacial/core.dart';
import 'package:glacial/features/auth/models/oauth.dart';

final String prefsOAuthInfoKey = "mastodon_server_oauth2_info";
final String prefsAccessTokenKey = "access_token";

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
  void saveAccessToken(String domain, String token) async {
    final Map<String, dynamic> json = jsonDecode(await getString(prefsAccessTokenKey, secure: true) ?? '{}');

    json[domain] = token;
    setString(prefsAccessTokenKey, jsonEncode(json), secure: true);
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

    final Uri uri = Uri.parse("https://$domain/oauth/token");
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
