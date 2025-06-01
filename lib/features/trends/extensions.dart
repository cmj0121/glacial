// The Trends data fetch extension.
import 'dart:convert';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';

extension TrendsExtension on TrendsType {
  // Fetch the trends data for the specified server, and return the list of trends.
  Future<List<dynamic>> fetch({required ServerSchema server, String? accessToken, int? offset}) async {
    final Map<String, String> queryParameters = <String, String>{};
    late final Uri uri;

    switch (this) {
      case TrendsType.statuses:
        uri = UriEx.handle(server.domain, '/api/v1/trends/statuses');
        break;
      case TrendsType.tags:
        uri = UriEx.handle(server.domain, '/api/v1/trends/tags');
        break;
      case TrendsType.links:
        uri = UriEx.handle(server.domain, '/api/v1/trends/links');
        break;
    }

    queryParameters["offset"] = offset?.toString() ?? '0';
    final Map<String, String> headers = {"Authorization": "Bearer $accessToken"};
    final response = await get(uri.replace(queryParameters: queryParameters), headers: accessToken == null ? {} : headers);
    final List<dynamic> json = jsonDecode(response.body) as List<dynamic>;

    switch (this) {
      case TrendsType.statuses:
        return json.map((e) => StatusSchema.fromJson(e as Map<String, dynamic>)).toList();
      case TrendsType.tags:
        return json.map((e) => HashTagSchema.fromJson(e as Map<String, dynamic>)).toList();
      case TrendsType.links:
        return json.map((e) => LinkSchema.fromJson(e as Map<String, dynamic>)).toList();
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
