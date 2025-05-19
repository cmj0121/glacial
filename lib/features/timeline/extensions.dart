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

        uri = Uri.parse("https://$domain/api/v1/timelines/home").replace(queryParameters: query);
        break;
      case TimelineType.local:
        final Map<String, String> query = {};

        query["max_id"] = maxId ?? "";
        query["local"] = "true";
        query["remote"] = "false";
        uri = Uri.parse("https://$domain/api/v1/timelines/public").replace(queryParameters: query);
        break;
      case TimelineType.federal:
        final Map<String, String> query = {};

        query["max_id"] = maxId ?? "";
        query["local"] = "false";
        query["remote"] = "true";
        uri = Uri.parse("https://$domain/api/v1/timelines/public").replace(queryParameters: query);
        break;
      case TimelineType.public:
        final Map<String, String> query = {};

        query["max_id"] = maxId ?? "";
        query["local"] = "false";
        query["remote"] = "false";
        uri = Uri.parse("https://$domain/api/v1/timelines/public").replace(queryParameters: query);
        break;
      case TimelineType.bookmarks:
        final Map<String, String> query = {};

        query["max_id"] = maxId ?? "";
        uri = Uri.parse("https://$domain/api/v1/bookmarks").replace(queryParameters: query);
        break;
      case TimelineType.favourites:
        final Map<String, String> query = {};

        query["max_id"] = maxId ?? "";
        uri = Uri.parse("https://$domain/api/v1/favourites").replace(queryParameters: query);
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
}

// The extension to post the new status to the server.
extension PostStatusExtensions on NewStatusSchema {
  Future<StatusSchema> create({ServerSchema? schema, String? accessToken}) async {
    if (schema == null || accessToken == null) {
      logger.w("schema and access token are required");
      throw MissingAuth("schema and access token are required");
    }

    final Uri uri = Uri.parse("https://${schema.domain}/api/v1/statuses");
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

// vim: set ts=2 sw=2 sts=2 et:
