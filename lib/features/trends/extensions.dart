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
      case TrendsType.links:
        return json.map((e) => LinkSchema.fromJson(e as Map<String, dynamic>)).toList();
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
