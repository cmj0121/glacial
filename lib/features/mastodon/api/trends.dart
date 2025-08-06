// The trends APIs for the mastdon server.
//
// ## Trends APIs
//   - [+] GET /api/v1/trends/tags
//   - [+] GET /api/v1/trends/statuses
//   - [+] GET /api/v1/trends/links
//
// ## Following Hashtag APIs
//
//  - [+] GET /api/v1/followed_tags
//
// ref:
//   - https://docs.joinmastodon.org/methods/trends/
//   - https://docs.joinmastodon.org/methods/followed_tags/
import 'dart:async';
import 'dart:convert';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';

// The API extensions for the timeline endpoints in the Mastodon server.
extension TrendsExtensions on AccessStatusSchema {
  // Fetch the trends data for the specified server, and return the list of trends.
  Future<List<dynamic>> fetchTrends(TrendsType type, {int? offset}) async {
    late final String endpoint;

    switch (type) {
      case TrendsType.statuses:
        endpoint = '/api/v1/trends/statuses';
        break;
      case TrendsType.tags:
        endpoint ='/api/v1/trends/tags';
        break;
      case TrendsType.links:
        endpoint = '/api/v1/trends/links';
        break;
      case TrendsType.users:
        return (offset ?? 0) == 0 ? fetchSuggestion() : <dynamic>[];
    }

    final Map<String, String> query = {"offset": offset?.toString() ?? "0"};
    final String body = await getAPI(endpoint, queryParameters: query) ?? '[]';
    final List<dynamic> json = jsonDecode(body) as List<dynamic>;

    logger.d("complete load the trends of type: $type, count: ${json.length}");
    switch (type) {
      case TrendsType.statuses:
        return json.map((e) => StatusSchema.fromJson(e as Map<String, dynamic>)).toList();
      case TrendsType.tags:
        return json.map((e) => HashtagSchema.fromJson(e as Map<String, dynamic>)).toList();
      case TrendsType.links:
        return json.map((e) => LinkSchema.fromJson(e as Map<String, dynamic>)).toList();
      default:
        throw UnimplementedError('trends $type are not implemented yet.');
    }
  }

  // Fetch the following hashtags for the current user, and return the list of hashtags and next page offset.
  Future<(List<HashtagSchema>, String?)> fetchFollowedHashtags({String? maxId}) async {
    if (isSignedIn == false) {
      throw Exception("You must be signed in to fetch scheduled statuses.");
    }

    final Map<String, String> query = {"max_id": maxId ?? ""};
    final String endpoint = '/api/v1/followed_tags';
    final (body, nextId) = await getAPIEx(endpoint, queryParameters: query);

    final List<dynamic> json = jsonDecode(body) as List<dynamic>;
    final List<HashtagSchema> hashtags = json.map((e) => HashtagSchema.fromJson(e as Map<String, dynamic>)).toList();

    return (hashtags, nextId);
  }
}

// vim: set ts=2 sw=2 sts=2 et:
