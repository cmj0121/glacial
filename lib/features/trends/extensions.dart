// The Trends data fetch extension.
import 'dart:convert';

import 'package:glacial/core.dart';
import 'package:glacial/features/glacial/models/server.dart';
import 'package:glacial/features/explore/models/core.dart';
import 'package:glacial/features/timeline/models/core.dart';
import 'package:glacial/features/trends/models/core.dart';

extension TrendsExtension on TrendsType {
  // Fetch the trends data for the specified server, and return the list of trends.
  Future<List<dynamic>> fetch({required ServerSchema server, int? offset}) async {
    final Map<String, String> queryParameters = <String, String>{};
    late final Uri uri;

    switch (this) {
      case TrendsType.statuses:
        uri = Uri.https(server.domain, '/api/v1/trends/statuses');
        break;
      case TrendsType.tags:
        uri = Uri.https(server.domain, '/api/v1/trends/tags');
        break;
      case TrendsType.links:
        uri = Uri.https(server.domain, '/api/v1/trends/links');
        break;
    }

    queryParameters["offset"] = offset?.toString() ?? '0';
    final response = await get(uri.replace(queryParameters: queryParameters));
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
