// The timeline APIs for the mastdon server.
//
// ref: https://docs.joinmastodon.org/methods/timelines/
import 'dart:async';
import 'dart:convert';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';

// The API extensions for the timeline endpoints in the Mastodon server.
extension TimelineExtensions on AccessStatusSchema {
  // Fetch timeline's statuses based on the timeline type.
  Future<List<StatusSchema>> fetchTimeline(TimelineType type, {String? maxId}) async {
    final Map<String, String> query = {"max_id": maxId ?? ""};
    late final String endpoint;

    switch (type) {
      case TimelineType.home:
        endpoint = "/api/v1/timelines/home";
        break;
      case TimelineType.local:
        query["local"] = "true";
        query["remote"] = "false";
        endpoint = "/api/v1/timelines/public";
        break;
      case TimelineType.federal:
        query["local"] = "false";
        query["remote"] = "true";
        endpoint = "/api/v1/timelines/public";
        break;
      case TimelineType.public:
        query["local"] = "false";
        query["remote"] = "false";
        endpoint = "/api/v1/timelines/public";
        break;
      case TimelineType.bookmarks:
        endpoint = "/api/v1/bookmarks";
        break;
      case TimelineType.favourites:
        endpoint = "/api/v1/favourites";
        break;
    }

    final String body = await getAPI(endpoint, queryParameters: query) ?? '[]';
    final List<dynamic> json = jsonDecode(body) as List<dynamic>;
    final List<StatusSchema> status = json.map((e) => StatusSchema.fromJson(e)).toList();

    logger.d("complete load the timeline of type: $type, count: ${status.length}");
    return status;
  }
}

// vim: set ts=2 sw=2 sts=2 et:
