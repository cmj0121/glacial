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

  // Get the hashtag by its name from the server, and return the hashtag schema.
  Future<HashtagSchema> getHashtag(String tag, {String? accessToken}) async {
    final Uri uri = UriEx.handle(domain, '/api/v1/tags/$tag');
    final Map<String, String> headers = {"Authorization": "Bearer $accessToken"};
    final response = await get(uri, headers: accessToken == null ? {} : headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch hashtag: ${response.body}');
    }

    final Map<String, dynamic> json = jsonDecode(response.body) as Map<String, dynamic>;
    return HashtagSchema.fromJson(json);
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

  // Follow a hashtag in the server, and return the updated hashtag.
  Future<HashtagSchema> followHashtag(String tag, {String? accessToken}) async {
    if (accessToken == null) {
      throw ArgumentError('Access token is required to follow a hashtag.');
    }

    final Uri uri = UriEx.handle(domain, '/api/v1/tags/$tag/follow');
    final Map<String, String> headers = {"Authorization": "Bearer $accessToken"};
    final response = await post(uri, headers: headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to follow hashtag: ${response.body}');
    }

    final Map<String, dynamic> json = jsonDecode(response.body) as Map<String, dynamic>;
    return HashtagSchema.fromJson(json);
  }

  // Unfollow a hashtag in the server, and return the updated hashtag.
  Future<HashtagSchema> unfollowHashtag(String tag, {String? accessToken}) async {
    if (accessToken == null) {
      throw ArgumentError('Access token is required to unfollow a hashtag.');
    }

    final Uri uri = UriEx.handle(domain, '/api/v1/tags/$tag/unfollow');
    final Map<String, String> headers = {"Authorization": "Bearer $accessToken"};
    final response = await post(uri, headers: headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to unfollow hashtag: ${response.body}');
    }

    final Map<String, dynamic> json = jsonDecode(response.body) as Map<String, dynamic>;
    return HashtagSchema.fromJson(json);
  }
}

// vim: set ts=2 sw=2 sts=2 et:
