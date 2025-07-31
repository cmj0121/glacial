// The timeline APIs for the mastdon server.
// ref: https://docs.joinmastodon.org/methods/timelines/
import 'dart:async';
import 'dart:convert';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';

// The API extensions for the timeline endpoints in the Mastodon server.
extension TimelineExtensions on AccessStatusSchema {
  // Fetch timeline's statuses based on the timeline type.
  Future<List<StatusSchema>> fetchTimeline(TimelineType type, {String? maxId}) async {
    final String? domain = schema?.domain;
    final Map<String, String> query = {"max_id": maxId ?? ""};
    late final Uri uri;

    if (domain == null) {
      logger.w("No server selected, but it's required to fetch the timeline.");
      return [];
    }

    switch (type) {
      case TimelineType.home:
        uri = UriEx.handle(domain, "/api/v1/timelines/home").replace(queryParameters: query);
        break;
      case TimelineType.local:
        query["local"] = "true";
        query["remote"] = "false";
        uri = UriEx.handle(domain, "/api/v1/timelines/public").replace(queryParameters: query);
        break;
      case TimelineType.federal:
        query["local"] = "false";
        query["remote"] = "true";
        uri = UriEx.handle(domain, "/api/v1/timelines/public").replace(queryParameters: query);
        break;
      case TimelineType.public:
        query["local"] = "false";
        query["remote"] = "false";
        uri = UriEx.handle(domain, "/api/v1/timelines/public").replace(queryParameters: query);
        break;
      case TimelineType.bookmarks:
        uri = UriEx.handle(domain, "/api/v1/bookmarks").replace(queryParameters: query);
        break;
      case TimelineType.favourites:
        uri = UriEx.handle(domain, "/api/v1/favourites").replace(queryParameters: query);
        break;
    }

    final response = await get(uri);
    final List<dynamic> json = jsonDecode(response.body) as List<dynamic>;
    final List<StatusSchema> status = json.map((e) => StatusSchema.fromJson(e)).toList();

    logger.d("complete load the timeline of type: $type, count: ${status.length}");
    return status;
  }
}

// vim: set ts=2 sw=2 sts=2 et:
