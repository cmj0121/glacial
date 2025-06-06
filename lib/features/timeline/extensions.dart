// The extensions implementation for the timeline feature.
import 'dart:async';
import 'dart:convert';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';

extension TimelineExtensions on ServerSchema {
  // Fetch timeline's statuses based on the timeline type.
  Future<List<StatusSchema>> fetchTimeline(TimelineType type, {
    String? accessToken,
    String? maxId,
    String? accountID,
    String? keyword,
  }) async {
    late final Uri uri;

    switch (type) {
      case TimelineType.home:
        final Map<String, String> query = {};
        query["max_id"] = maxId ?? "";

        uri = UriEx.handle(domain, "/api/v1/timelines/home").replace(queryParameters: query);
        break;
      case TimelineType.user:
        final Map<String, String> query = {};
        query["max_id"] = maxId ?? "";

        uri = UriEx.handle(domain, "/api/v1/accounts/${accountID ?? '-'}/statuses").replace(queryParameters: query);
        break;
      case TimelineType.hashtag:
        final Map<String, String> query = {};

        query["max_id"] = maxId ?? "";
        query["local"] = "true";
        query["remote"] = "true";
        uri = UriEx.handle(domain, "/api/v1/timelines/tag/$keyword").replace(queryParameters: query);
        break;
      case TimelineType.local:
        final Map<String, String> query = {};

        query["max_id"] = maxId ?? "";
        query["local"] = "true";
        query["remote"] = "false";
        uri = UriEx.handle(domain, "/api/v1/timelines/public").replace(queryParameters: query);
        break;
      case TimelineType.federal:
        final Map<String, String> query = {};

        query["max_id"] = maxId ?? "";
        query["local"] = "false";
        query["remote"] = "true";
        uri = UriEx.handle(domain, "/api/v1/timelines/public").replace(queryParameters: query);
        break;
      case TimelineType.public:
        final Map<String, String> query = {};

        query["max_id"] = maxId ?? "";
        query["local"] = "false";
        query["remote"] = "false";
        uri = UriEx.handle(domain, "/api/v1/timelines/public").replace(queryParameters: query);
        break;
      case TimelineType.bookmarks:
        final Map<String, String> query = {};

        query["max_id"] = maxId ?? "";
        uri = UriEx.handle(domain, "/api/v1/bookmarks").replace(queryParameters: query);
        break;
      case TimelineType.favourites:
        final Map<String, String> query = {};

        query["max_id"] = maxId ?? "";
        uri = UriEx.handle(domain, "/api/v1/favourites").replace(queryParameters: query);
        break;
    }

    final Map<String, String> headers = {"Authorization": "Bearer $accessToken"};
    final response = await get(uri, headers: accessToken == null ? {} : headers);
    final List<dynamic> json = jsonDecode(response.body) as List<dynamic>;

    return json.map((e) => StatusSchema.fromJson(e)).toList();
  }
}

// vim: set ts=2 sw=2 sts=2 et:
