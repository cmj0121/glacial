import 'dart:convert';

import 'package:glacial/core.dart';
import 'package:glacial/features/glacial/models/server.dart';
import 'package:glacial/features/timeline/models/core.dart';

// The extension to the TimelineType enum to list the statuses per timeline type.
extension StatusLoaderExtensions on ServerSchema {
  // Fetch the timeline statuss from the server.
  Future<List<StatusSchema>> fetchTimeline({required TimelineType type, String? accessToken, String? maxId}) async {
    late final Uri uri;

    switch (type) {
      case TimelineType.home:
        final Map<String, String> query = {};
        query["max_id"] = maxId ?? "";

        uri = Uri.https(domain, "/api/v1/timelines/home").replace(queryParameters: query);
        break;
      case TimelineType.local:
        final Map<String, String> query = {};

        query["max_id"] = maxId ?? "";
        query["local"] = "true";
        query["remote"] = "false";
        uri = Uri.https(domain, "/api/v1/timelines/public").replace(queryParameters: query);
        break;
      case TimelineType.federal:
        final Map<String, String> query = {};

        query["max_id"] = maxId ?? "";
        query["local"] = "false";
        query["remote"] = "true";
        uri = Uri.https(domain, "/api/v1/timelines/public").replace(queryParameters: query);
        break;
      case TimelineType.public:
        final Map<String, String> query = {};

        query["max_id"] = maxId ?? "";
        query["local"] = "false";
        query["remote"] = "false";
        uri = Uri.https(domain, "/api/v1/timelines/public").replace(queryParameters: query);
        break;
      case TimelineType.bookmarks:
        final Map<String, String> query = {};

        query["max_id"] = maxId ?? "";
        uri = Uri.https(domain, "/api/v1/bookmarks").replace(queryParameters: query);
        break;
      case TimelineType.favourites:
        final Map<String, String> query = {};

        query["max_id"] = maxId ?? "";
        uri = Uri.https(domain, "/api/v1/favourites").replace(queryParameters: query);
        break;
    }

    if (!type.supportAnonymous && accessToken == null) {
      logger.w("access token is required for $this");
      throw MissingAuth("access token is required for $this");
    }

    final Map<String, String> headers = {"Authorization": "Bearer $accessToken"};
    final response = await get(uri, headers: type.supportAnonymous ? {} : headers);
    final List<dynamic> json = jsonDecode(response.body) as List<dynamic>;

    logger.i("fetch $this from $uri");
    return json.map((e) => StatusSchema.fromJson(e)).toList();
  }

  // Get the authenticated user account.
  Future<AccountSchema?> getAuthUser(String? token) async {
    if (token == null) {
      return null;
    }

    final Uri uri = Uri.https(domain, "/api/v1/accounts/verify_credentials");
    final Map<String, String> headers = {"Authorization": "Bearer $token"};
    final response = await get(uri, headers: headers);

    if (response.statusCode != 200) {
      throw RequestError(response);
    }

    final Map<String, dynamic> json = jsonDecode(response.body) as Map<String, dynamic>;
    return AccountSchema.fromJson(json);
  }
}

// The extension to post the new status to the server.
extension PostStatusExtensions on NewStatusSchema {
  Future<StatusSchema> create({ServerSchema? schema, String? accessToken}) async {
    if (schema == null || accessToken == null) {
      logger.w("schema and access token are required");
      throw MissingAuth("schema and access token are required");
    }

    final Uri uri = Uri.https(schema.domain, "/api/v1/statuses");
    final Map<String, String> headers = {
      "Authorization": "Bearer $accessToken",
      "Content-Type": "application/json",
    };

    final Map<String, dynamic> body = toJson();
    final response = await post(uri, headers: headers, body: jsonEncode(body));

    logger.i("complete create a new status: ${response.statusCode}");
    return StatusSchema.fromString(response.body);
  }
}

// The future function to interact with the status.
typedef InteractIt = Future<StatusSchema> Function({required String domain, required String accessToken});

// The extension of the current status to update the status.
extension InteractiveStatusExtensions on StatusSchema {
  // Reblog the status to the Mastodon server
  Future<StatusSchema> reblogIt({required String domain, required String accessToken}) async {
    final Uri uri = Uri.https(domain, "/api/v1/statuses/$id/reblog");
    final Map<String, String> headers = {
      "Authorization": "Bearer $accessToken",
      "Content-Type": "application/json",
    };

    final String body = await sendPostRequest(uri, headers: headers);
    return StatusSchema.fromString(body);
  }

  // Unreblog the status to the Mastodon server
  Future<StatusSchema> unreblogIt({required String domain, required String accessToken}) async {
    final Uri uri = Uri.https(domain, "/api/v1/statuses/$id/unreblog");
    final Map<String, String> headers = {
      "Authorization": "Bearer $accessToken",
      "Content-Type": "application/json",
    };

    final String body = await sendPostRequest(uri, headers: headers);
    return StatusSchema.fromString(body);
  }

  // Favourite the status to the Mastodon server
  Future<StatusSchema> favouriteIt({required String domain, required String accessToken}) async {
    final Uri uri = Uri.https(domain, "/api/v1/statuses/$id/favourite");
    final Map<String, String> headers = {
      "Authorization": "Bearer $accessToken",
      "Content-Type": "application/json",
    };

    final String body = await sendPostRequest(uri, headers: headers);
    return StatusSchema.fromString(body);
  }

  // Unfavourite the status to the Mastodon server
  Future<StatusSchema> unfavouriteIt({required String domain, required String accessToken}) async {
    final Uri uri = Uri.https(domain, "/api/v1/statuses/$id/unfavourite");
    final Map<String, String> headers = {
      "Authorization": "Bearer $accessToken",
      "Content-Type": "application/json",
    };

    final String body = await sendPostRequest(uri, headers: headers);
    return StatusSchema.fromString(body);
  }

  // Bookmark the status to the Mastodon server
  Future<StatusSchema> bookmarkIt({required String domain, required String accessToken}) async {
    final Uri uri = Uri.https(domain, "/api/v1/statuses/$id/bookmark");
    final Map<String, String> headers = {
      "Authorization": "Bearer $accessToken",
      "Content-Type": "application/json",
    };

    final String body = await sendPostRequest(uri, headers: headers);
    return StatusSchema.fromString(body);
  }

  // Unbookmark the status to the Mastodon server
  Future<StatusSchema> unbookmarkIt({required String domain, required String accessToken}) async {
    final Uri uri = Uri.https(domain, "/api/v1/statuses/$id/unbookmark");
    final Map<String, String> headers = {
      "Authorization": "Bearer $accessToken",
      "Content-Type": "application/json",
    };

    final String body = await sendPostRequest(uri, headers: headers);
    return StatusSchema.fromString(body);
  }

  Future<String> sendPostRequest(Uri uri, {Map<String, String>? headers, Map<String, String>? body}) async {
    final response = await post(uri, headers: headers, body: jsonEncode(body));
    switch (response.statusCode) {
      case 200:
        logger.i("call status action from $uri");
        return response.body;
      default:
        logger.e("failed to unbookmark $this from $uri: ${response.statusCode}");
        throw Exception("failed to unbookmark $this from $uri: ${response.statusCode}");
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
