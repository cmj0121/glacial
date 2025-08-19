// The access status of the Mastodon server.
import 'dart:convert';
import 'dart:io';

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
  final String? domain;
  final String? accessToken;
  final ServerSchema? server;
  final AccountSchema? account;
  final List<ServerInfoSchema> history;

  const AccessStatusSchema({
    this.domain,
    this.accessToken,
    this.server,
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
      domain: json['domain'] as String?,
      history: (json['history'] as List<dynamic>).map((e) => ServerInfoSchema.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  // Create a copy of the current access status schema with new values.
  AccessStatusSchema copyWith({
    String? domain,
    String? accessToken,
    ServerSchema? server,
    AccountSchema? account,
    List<ServerInfoSchema>? history,
  }) {
    return AccessStatusSchema(
      domain: domain ?? this.domain,
      accessToken: accessToken ?? this.accessToken,
      server: server ?? this.server,
      account: account ?? this.account,
      history: history ?? this.history,
    );
  }

  // Convert the access status schema to JSON format.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'domain': domain,
      'history': history.map((e) => e.toJson()).toList(),
    };
  }

  // Call the API endpoint with the GET method and return the response body as a string.
  Future<String?> getAPI(String endpoint, {Map<String, String>? queryParameters, Map<String, String>? headers}) async {
    if (domain?.isNotEmpty != true) {
      logger.w("No server selected, but it's required to fetch the API.");
      return null;
    }

    final Uri uri = UriEx.handle(domain!, endpoint).replace(queryParameters: queryParameters);
    try {
      final response = await get(
        uri,
        headers: {
          ...?headers,
          ...accessToken == null ? {} : {"Authorization": "Bearer $accessToken"},
        },
      );

      return response.body;
    } catch (e) {
      logger.e("failed to fetch API at [GET] $uri: $e");
      return null;
    }
  }

  // Similar to getAPI, but returns the response body and optional next link.
  Future<(String, String?)> getAPIEx(String endpoint, {Map<String, String>? queryParameters, Map<String, String>? headers}) async {
    if (domain?.isNotEmpty != true) {
      logger.w("No server selected, but it's required to fetch the API.");
      throw Exception('No server selected to fetch the API.');
    }

    final Uri uri = UriEx.handle(domain!, endpoint).replace(queryParameters: queryParameters);
    try {
      final response = await get(
        uri,
        headers: {
          ...?headers,
          ...accessToken == null ? {} : {"Authorization": "Bearer $accessToken"},
        },
      );

      final String body = response.body;
      final String? nextLink = response.headers['link'];

      return (body, getMaxIDFromNextLink(nextLink));
    } catch (e) {
      logger.e("failed to fetch API at [GET] $uri: $e");
      throw Exception('Failed to fetch API at [GET] $uri: $e');
    }
  }

  // Call the API endpoint with the POST method and return the response body as a string.
  Future<String?> postAPI(String endpoint, {
    Map<String, String>? queryParameters,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    if (domain?.isNotEmpty != true) {
      logger.w("No server selected, but it's required to fetch the API.");
      return null;
    }

    final Uri uri = UriEx.handle(domain!, endpoint).replace(queryParameters: queryParameters);
    final String? payload = body != null ? jsonEncode(body) : null;
    final response = await post(uri,
      headers: {
        ...?headers,
        ...accessToken == null ? {} : {"Authorization": "Bearer $accessToken"},
      },
      body: payload,
    );

    return response.body;
  }

  // Call the API endpoint with the PUT method and return the response body as a string.
  Future<String?> putAPI(String endpoint, {
    Map<String, String>? queryParameters,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    if (domain?.isNotEmpty != true) {
      logger.w("No server selected, but it's required to fetch the API.");
      return null;
    }

    final Uri uri = UriEx.handle(domain!, endpoint).replace(queryParameters: queryParameters);
    final String? payload = body != null ? jsonEncode(body) : null;
    final response = await put(uri,
      headers: {
        ...?headers,
        ...accessToken == null ? {} : {"Authorization": "Bearer $accessToken"},
      },
      body: payload,
    );

    return response.body;
  }

  // Call the API endpoint with the PATCH method and return the response body as a string.
  Future<String?> patchAPI(String endpoint, {
    Map<String, String>? queryParameters,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    if (domain?.isNotEmpty != true) {
      logger.w("No server selected, but it's required to fetch the API.");
      return null;
    }

    final Uri uri = UriEx.handle(domain!, endpoint).replace(queryParameters: queryParameters);
    final String? payload = body != null ? jsonEncode(body) : null;
    final response = await patch(
      uri,
      headers: {
        ...?headers,
        ...accessToken == null ? {} : {"Authorization": "Bearer $accessToken"},
      },
      body: payload,
    );

    return response.body;
  }

  // Call the API endpoint with the DELETE method and return the response body as a string.
  Future<String?> deleteAPI(String endpoint, {
    Map<String, String>? queryParameters,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    if (domain?.isNotEmpty != true) {
      logger.w("No server selected, but it's required to fetch the API.");
      return null;
    }

    final Uri uri = UriEx.handle(domain!, endpoint).replace(queryParameters: queryParameters);
    final response = await delete(
      uri,
      headers: {
        ...?headers,
        ...accessToken == null ? {} : {"Authorization": "Bearer $accessToken"},
      },
      body: body != null ? jsonEncode(body) : null,
    );

    return response.body;
  }

  // Call the API endpoint with the multipart API with customized method.
  Future<String?> multipartsAPI(String endpoint, {
    required String method,
    required Map<String, File> files,
    Map<String, String>? queryParameters,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    if (domain?.isNotEmpty != true) {
      logger.w("No server selected, but it's required to fetch the API.");
      return null;
    }

    final Uri uri = UriEx.handle(domain!, endpoint).replace(queryParameters: queryParameters);
    final response = await multiparts(
      uri,
      method: method,
      headers: {
        ...?headers,
        ...accessToken == null ? {} : {"Authorization": "Bearer $accessToken"},
      },
      json: body,
      files: files,
    );

    return response.body;
  }

  // Ensure the access token is set for the current server.
  void checkSignedIn() {
    if (!isSignedIn) {
      logger.w("try to access the API that should be signed in, but no access token is set.");
      throw Exception('Access token is required to access the server: $domain');
    }
  }

  // Extracts the max_id from the next link if it exists.
  String? getMaxIDFromNextLink(String? nextLink) {
    final links = nextLink?.split(',') ?? [];
    for (final link in links) {
      final match = RegExp(r'<([^>]+)>;\s*rel="([^"]+)"').firstMatch(link.trim());
      if (match != null && match.group(2) == 'next') {
        return Uri.parse(match.group(1) ?? '').queryParameters['max_id'];
      }
    }

    return null;
  }

  bool get isSignedIn =>  accessToken?.isNotEmpty == true;
}

// vim: set ts=2 sw=2 sts=2 et:
