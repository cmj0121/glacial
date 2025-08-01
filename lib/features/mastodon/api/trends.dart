// The trends APIs for the mastdon server.
//
// ref: https://docs.joinmastodon.org/methods/trends/
import 'dart:async';
import 'dart:convert';

import 'package:glacial/core.dart';
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
      default:
        throw UnimplementedError('Users trends are not implemented yet.');
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
}

// vim: set ts=2 sw=2 sts=2 et:
