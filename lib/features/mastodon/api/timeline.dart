// The timeline APIs for the mastdon server.
//
// ## Timeline APIs
//     - [+] GET /api/v1/timelines/public
//     - [+] GET /api/v1/timelines/tag/:hashtag
//     - [+] GET /api/v1/timelines/home
//     - [ ] GET /api/v1/timelines/link?url=:url
//     - [+] GET /api/v1/timelines/list/:list_id
//     - [x] GET /api/v1/timelines/direct          (deprecated in 3.0.0)
//
// ## Bookmark APIs
//     - [+] GET /api/v1/bookmarks
//
// ## Favourite APIs
//     - [+] GET /api/v1/favourites
//
// ref:
//   - https://docs.joinmastodon.org/methods/timelines/
//   - https://docs.joinmastodon.org/methods/bookmarks/
//   - https://docs.joinmastodon.org/methods/favourites/
import 'dart:async';
import 'dart:convert';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';

// The API extensions for the timeline endpoints in the Mastodon server.
extension TimelineExtensions on AccessStatusSchema {
  // Fetch timeline's statuses based on the timeline type.
  Future<(List<StatusSchema>, String?)> fetchTimeline(TimelineType type, {
    String? maxId,
    String? minId,
    AccountSchema? account,
    String? tag,
    String? listId,
  }) async {
    final Map<String, String> query = {"max_id": maxId ?? "", "min_id": minId ?? ""};
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
      case TimelineType.user:
      case TimelineType.pin:
        final statuses = await fetchAccountTimeline(account: account, maxId: maxId, pinned: type == TimelineType.pin);
        return (statuses, null);
      case TimelineType.schedule:
        if (account == null) {
          throw Exception("Account must be provided for scheduled statuses.");
        }

        final statuses = await fetchScheduledStatuses(account: account, maxId: maxId);
        return (statuses, null);
      case TimelineType.hashtag:
        if (tag?.isNotEmpty != true) {
          throw Exception("Tag must be provided for hashtag timeline.");
        }

        query["max_id"] = maxId ?? "";
        query["local"] = "true";
        query["remote"] = "true";
        endpoint = "/api/v1/timelines/tag/$tag";
        break;
      case TimelineType.list:
        query["max_id"] = maxId ?? "";
        endpoint = "/api/v1/timelines/list/$listId";
        break;
    }

    final (body, nextId) = await getAPIEx(endpoint, queryParameters: query);
    final List<dynamic> json = jsonDecode(body) as List<dynamic>;
    final List<StatusSchema> status = json.map((e) => StatusSchema.fromJson(e)).where(
      // filter-out the statuses that are hidden by filters.
      (s) => s.filterAction != FilterAction.hide,
    ).toList();

    // save the related info to the in-memory cache.
    for (final s in status) {
      cacheAccount(s.account);
      saveStatusToCache(s);
      // Fire-and-forget prefetch of reply account (intentionally not awaited)
      if (s.inReplyToAccountID != null) getAccount(s.inReplyToAccountID);
    }

    logger.d("complete load the timeline of type: $type, count: ${status.length}");
    return (status, nextId);
  }
}

// vim: set ts=2 sw=2 sts=2 et:
