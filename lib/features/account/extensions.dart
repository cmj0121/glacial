import 'dart:convert';

import 'package:glacial/core.dart';
import 'package:glacial/features/core.dart';


// The relationship of the Account to current user.
extension AccountsExtensions on AccountSchema {
  Future<List<RelationshipSchema>> relationship({
    required String domain,
    required String accessToken,
    List<String> ids = const [],
  }) async {
    final Map<String, String> query = {'id[]': ids.isEmpty ? id : ids.join(',')};
    final Uri uri = UriEx.handle(domain, "/api/v1/accounts/relationships").replace(queryParameters: query);
    final Map<String, String> headers = {"Authorization": "Bearer $accessToken"};
    final response = await get(uri, headers: headers);

    if (response.statusCode != 200) {
      throw RequestError(response);
    }

    final List<dynamic> json = jsonDecode(response.body) as List<dynamic>;
    return json.map((e) => RelationshipSchema.fromJson(e as Map<String, dynamic>)).toList();
  }

  // Follow the account from the Mastodon server.
  Future<RelationshipSchema> follow({required String domain, required String accessToken}) async {
    final Uri uri = UriEx.handle(domain, "/api/v1/accounts/$id/follow");
    final Map<String, String> headers = {
      "Authorization": "Bearer $accessToken",
      "Content-Type": "application/json",
    };

    final response = await post(uri, headers: headers);
    if (response.statusCode != 200) {
      throw RequestError(response);
    }

    return RelationshipSchema.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  // Unfollow the account from the Mastodon server.
  Future<RelationshipSchema> unfollow({required String domain, required String accessToken}) async {
    final Uri uri = UriEx.handle(domain, "/api/v1/accounts/$id/unfollow");
    final Map<String, String> headers = {
      "Authorization": "Bearer $accessToken",
      "Content-Type": "application/json",
    };

    final response = await post(uri, headers: headers);
    if (response.statusCode != 200) {
      throw RequestError(response);
    }

    return RelationshipSchema.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  // Block the account from the Mastodon server.
  Future<RelationshipSchema> block({required String domain, required String accessToken}) async {
    final Uri uri = UriEx.handle(domain, "/api/v1/accounts/$id/block");
    final Map<String, String> headers = {
      "Authorization": "Bearer $accessToken",
      "Content-Type": "application/json",
    };

    final response = await post(uri, headers: headers);
    if (response.statusCode != 200) {
      throw RequestError(response);
    }

    return RelationshipSchema.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  // Unblock the account from the Mastodon server.
  Future<RelationshipSchema> unblock({required String domain, required String accessToken}) async {
    final Uri uri = UriEx.handle(domain, "/api/v1/accounts/$id/unblock");
    final Map<String, String> headers = {
      "Authorization": "Bearer $accessToken",
      "Content-Type": "application/json",
    };

    final response = await post(uri, headers: headers);
    if (response.statusCode != 200) {
      throw RequestError(response);
    }

    return RelationshipSchema.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  // Mute the account from the Mastodon server.
  Future<RelationshipSchema> mute({required String domain, required String accessToken}) async {
    final Uri uri = UriEx.handle(domain, "/api/v1/accounts/$id/mute");
    final Map<String, String> headers = {
      "Authorization": "Bearer $accessToken",
      "Content-Type": "application/json",
    };

    final response = await post(uri, headers: headers);
    if (response.statusCode != 200) {
      throw RequestError(response);
    }

    return RelationshipSchema.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  // Unmute the account from the Mastodon server.
  Future<RelationshipSchema> unmute({required String domain, required String accessToken}) async {
    final Uri uri = UriEx.handle(domain, "/api/v1/accounts/$id/unmute");
    final Map<String, String> headers = {
      "Authorization": "Bearer $accessToken",
      "Content-Type": "application/json",
    };

    final response = await post(uri, headers: headers);
    if (response.statusCode != 200) {
      throw RequestError(response);
    }

    return RelationshipSchema.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  // Update the account's note on the Mastodon server.
  Future<RelationshipSchema> updateNote({
    required String domain,
    required String accessToken,
    required String note,
  }) async {
    final Uri uri = UriEx.handle(domain, "/api/v1/accounts/$id/note");
    final Map<String, String> headers = {
      "Authorization": "Bearer $accessToken",
      "Content-Type": "application/json",
    };
    final Map<String, dynamic> body = {"comment": note};

    final response = await post(uri, headers: headers, body: jsonEncode(body));
    logger.i("Updated note for account $id: $note : ${response.statusCode}");
    if (response.statusCode != 200) {
      throw RequestError(response);
    }

    return RelationshipSchema.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}

// vim: set ts=2 sw=2 sts=2 et:
