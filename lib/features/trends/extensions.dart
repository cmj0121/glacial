// The Trends data fetch extension.
import 'dart:convert';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';

extension TrendsExtension on ServerSchema {
  // Fetch the trends data for the specified server, and return the list of trends.
  Future<List<dynamic>> fetchTrends(TrendsType type, {String? accessToken, int? offset}) async {
    final Map<String, String> queryParameters = <String, String>{};
    late final Uri uri;

    switch (type) {
      case TrendsType.statuses:
        uri = UriEx.handle(domain, '/api/v1/trends/statuses');
        break;
      case TrendsType.tags:
        uri = UriEx.handle(domain, '/api/v1/trends/tags');
        break;
      case TrendsType.users:
        throw UnimplementedError('Users trends are not implemented yet.');
      case TrendsType.links:
        uri = UriEx.handle(domain, '/api/v1/trends/links');
        break;
    }

    queryParameters["offset"] = offset?.toString() ?? '0';
    final Map<String, String> headers = {"Authorization": "Bearer $accessToken"};
    final response = await get(uri.replace(queryParameters: queryParameters), headers: accessToken == null ? {} : headers);
    final List<dynamic> json = jsonDecode(response.body) as List<dynamic>;

    switch (type) {
      case TrendsType.statuses:
        return json.map((e) => StatusSchema.fromJson(e as Map<String, dynamic>)).toList();
      case TrendsType.tags:
        return json.map((e) => HashtagSchema.fromJson(e as Map<String, dynamic>)).toList();
      case TrendsType.users:
        throw UnimplementedError('Users trends are not implemented yet.');
      case TrendsType.links:
        return json.map((e) => LinkSchema.fromJson(e as Map<String, dynamic>)).toList();
    }
  }

  // List the following hashtags in the server, and return the list of hashtags
  Future<(List<HashtagSchema>, String?)> followedHashtags({String? accessToken, String? maxID}) async {
    if (accessToken == null) {
      throw ArgumentError('Access token is required to fetch followed hashtags.');
    }

    final Map<String, String> queryParameters = <String, String>{};
    if (maxID != null) {
      queryParameters['max_id'] = maxID;
    }

    final Uri uri = UriEx.handle(domain, '/api/v1/followed_tags').replace(queryParameters: queryParameters);
    final Map<String, String> headers = {"Authorization": "Bearer $accessToken"};
    final response = await get(uri, headers: headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch followed hashtags: ${response.body}');
    }

    final String? nextLink = response.headers['link'];
    final List<dynamic> json = jsonDecode(response.body) as List<dynamic>;
    final List<HashtagSchema> hashtags = json.map((e) => HashtagSchema.fromJson(e as Map<String, dynamic>)).toList();
    return (hashtags, nextLink);
  }
}

// vim: set ts=2 sw=2 sts=2 et:
