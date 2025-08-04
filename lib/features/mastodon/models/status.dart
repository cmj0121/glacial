// The access status of the Mastodon server.
import 'dart:convert';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';

// The access status of the Mastodon server, including the server access server and
// the list of the history of the access status.
class AccessStatusSchema {
  // The static key to access the access status schema.
  static const String key = "access_status";
  // The static key to store the access token.
  static const String keyAccessToken = "access_token";

  // The data store in the presistence storage.
  final String? server;
  final String? accessToken;
  final AccountSchema? account;
  final List<ServerInfoSchema> history;

  const AccessStatusSchema({
    this.server,
    this.accessToken,
    this.account,
    this.history = const [],
  });

  @override
  String toString() {
    return jsonEncode(toJson());
  }

  // Convert the JSON string to an AccessStatusSchema object.
  factory AccessStatusSchema.fromString(String str) {
    final Map<String, dynamic> json = jsonDecode(str);
    return AccessStatusSchema.fromJson(json);
  }

  // Convert the JSON map to an AccessStatusSchema object.
  factory AccessStatusSchema.fromJson(Map<String, dynamic> json) {
    return AccessStatusSchema(
      server: json['server'] as String?,
      history: (json['history'] as List<dynamic>).map((e) => ServerInfoSchema.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  // Create a copy of the current access status schema with new values.
  AccessStatusSchema copyWith({
    String? server,
    String? accessToken,
    AccountSchema? account,
    List<ServerInfoSchema>? history,
  }) {
    return AccessStatusSchema(
      server: server ?? this.server,
      accessToken: accessToken ?? this.accessToken,
      account: account ?? this.account,
      history: history ?? this.history,
    );
  }

  // Convert the access status schema to JSON format.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'server': server,
      'history': history.map((e) => e.toJson()).toList(),
    };
  }

  // Call the API endpoint with the GET method and return the response body as a string.
  Future<String?> getAPI(String endpoint, {Map<String, String>? queryParameters}) async {
    if (server?.isNotEmpty != true) {
      logger.w("No server selected, but it's required to fetch the API.");
      return null;
    }

    final Uri uri = UriEx.handle(server!, endpoint).replace(queryParameters: queryParameters);
    final Map<String, String> headers = {"Authorization": "Bearer $accessToken"};
    final response = await get(uri, headers: accessToken == null ? {} : headers);

    return response.body;
  }

  // Call the API endpoint with the POST method and return the response body as a string.
  Future<String?> postAPI(String endpoint, {Map<String, String>? queryParameters, Map<String, dynamic>? body}) async {
    if (server?.isNotEmpty != true) {
      logger.w("No server selected, but it's required to fetch the API.");
      return null;
    }

    final Uri uri = UriEx.handle(server!, endpoint).replace(queryParameters: queryParameters);
    final Map<String, String> headers = {"Authorization": "Bearer $accessToken"};
    final String? payload = body != null ? jsonEncode(body) : null;
    final response = await post(uri, headers: accessToken == null ? {} : headers, body: payload);

    return response.body;
  }

  // Call the API endpoint with the DELETE method and return the response body as a string.
  Future<String?> deleteAPI(String endpoint, {Map<String, String>? queryParameters}) async {
    if (server?.isNotEmpty != true) {
      logger.w("No server selected, but it's required to fetch the API.");
      return null;
    }

    final Uri uri = UriEx.handle(server!, endpoint).replace(queryParameters: queryParameters);
    final Map<String, String> headers = {"Authorization": "Bearer $accessToken"};
    final response = await delete(uri, headers: accessToken == null ? {} : headers);

    return response.body;
  }

  // Ensure the access token is set for the current server.
  void checkSignedIn() {
    if (accessToken?.isNotEmpty != true) {
      logger.w("try to access the API that should be signed in, but no access token is set.");
      throw Exception('Access token is required to access the server: $server');
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
