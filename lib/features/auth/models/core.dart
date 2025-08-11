// The OAuth2 info registered in the Mastodon server
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:glacial/core.dart';

// The OAuth2 Application info that registered in the Mastodon server and shown as the application in the Status.
class OAuth2Info {
  // The static key to access the OAuth2 info.
  static String prefsOAuthInfoKey = "oauth_info";

  final String id;
  final String name;
  final String? website;
  final List<String> scopes;

  final String clientId;
  final String clientSecret;
  final String redirectUri;
  final List<String> redirectUris;

  const OAuth2Info({
    required this.id,
    required this.name,
    this.website,
    required this.scopes,
    required this.clientId,
    required this.clientSecret,
    required this.redirectUri,
    required this.redirectUris,
  });

  // Convert the OAuth2Info to a string representation.
  factory OAuth2Info.fromString(String str) {
    final Map<String, dynamic> json = jsonDecode(str);
    return OAuth2Info.fromJson(json);
  }

  // Convert the JSON map to an OAuth2Info object.
  factory OAuth2Info.fromJson(Map<String, dynamic> json) {
    return OAuth2Info(
      id: json['id'] as String,
      name: json['name'] as String,
      website: json['website'] as String?,
      scopes: (json['scopes'] as List<dynamic>).map((e) => e as String).toList(),
      clientId: json['client_id'] as String,
      clientSecret: json['client_secret'] as String,
      redirectUri: json['redirect_uri'] as String,
      redirectUris: (json['redirect_uris'] as List<dynamic>).map((e) => e as String).toList(),
    );
  }

  // Convert the OAuth2Info to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'website': website,
      'scopes': scopes,
      'client_id': clientId,
      'client_secret': clientSecret,
      'redirect_uri': redirectUri,
      'redirect_uris': redirectUris,
    };
  }

  // Register the OAuth2 application on the specified domain and return the OAuth2Info.
  static Future<OAuth2Info> register(String domain) async {
    final Map<String, dynamic> body = {
      "client_name": dotenv.env['OAUTH_CLIENT_NAME'] ?? "glacial",
      "redirect_uris": [dotenv.env['OAUTH_REDIRECT_URI'] ?? "glacial://auth"],
      "scopes": dotenv.env['OAUTH_SCOPES'],
      "website": dotenv.env['OAUTH_WEBSITE_URL'],
    };

    final Uri uri = UriEx.handle(domain, "/api/v1/apps");
    final Map<String, String> headers = {"Content-Type": "application/json"};
    final response = await post(uri, body: jsonEncode(body), headers: headers);

    if (response.statusCode != 200) {
      logger.w("failed to register application on $domain: ${response.body}");
      throw Exception("failed to register application on $domain: ${response.statusCode} ${response.body}");
    }

    logger.i("success register application on $domain");
    return OAuth2Info.fromString(response.body);
  }
}

// vim: set ts=2 sw=2 sts=2 et:
