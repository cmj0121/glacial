// The Auth related APIs for the mastdon server.
//
// ## OAuth APIs
//
//    - [+] GET  /oauth/authorize
//    - [+] POST /oauth/token
//    - [+] POST /oauth/revoke
//    - [ ] GET  /oauth/userinfo
//    - [ ] GET  /.well-known/oauth-authorization-server
//
// ref:
//   - https://docs.joinmastodon.org/methods/oauth/
import 'dart:async';
import 'dart:convert';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';

extension AuthExtensions on AccessStatusSchema {
  // Displays an authorization form to the user.
  Future<Uri> authorize({required String domain, required String state}) async {
    final Storage storage = Storage();
    final OAuth2Info info = await storage.getOAuth2Info(domain);
    final Map<String, dynamic> query = {
      "client_id": info.clientId,
      "response_type": "code",
      "scope": info.scopes.join(" "),
      "redirect_uri": info.redirectUri,
      "state": state,
    }
        ..removeWhere((key, value) => value == null);

    storage.saveStateServer(state, domain);
    return UriEx.handle(domain, "/oauth/authorize", query);
  }

  // Obtain an access token, to be used during API calls that are not public.
  Future<String?> getAccessToken({required String domain, required String code}) async {
    final Storage storage = Storage();
    final OAuth2Info info = await storage.getOAuth2Info(domain);

    final Map<String, dynamic> body = {
      "client_id": info.clientId,
      "client_secret": info.clientSecret,
      "code": code,
      "grant_type": "authorization_code",
      "redirect_uri": info.redirectUri,
    }
        ..removeWhere((key, value) => value == null);

    final Uri uri = UriEx.handle(domain, "/oauth/token");
    final response = await post(uri, body: jsonEncode(body), headers: {
      "Content-Type": "application/json",
    });

    if (response.statusCode != 200) {
      throw Exception("failed to get access token from $domain: ${response.statusCode} ${response.body}");
    }

    final Map<String, dynamic> json = jsonDecode(response.body) as Map<String, dynamic>;
    final String? accessToken = json['access_token'] as String?;

    storage.saveAccessToken(domain, accessToken);
    return accessToken;
  }

  // Revoke an access token to make it no longer valid for use.
  Future<void> revokeAccessToken({required String domain, required String token}) async {
    final Storage storage = Storage();
    final OAuth2Info info = await storage.getOAuth2Info(domain);

    final Uri uri = UriEx.handle(domain, "/oauth/revoke");
    final Map<String, dynamic> body = {
      "token": token,
      "client_id": info.clientId,
      "client_secret": info.clientSecret,
    }
        ..removeWhere((key, value) => value == null);

    await post(uri, body: jsonEncode(body));
  }
}

// vim: set ts=2 sw=2 sts=2 et:
