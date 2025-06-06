// The extensions implementation for the explore feature.
import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';

extension ExploreExtensions on ServerSchema {
  // Fetch and find the data for the explore feature.
  Future<SearchResultSchema> search({required String keyword, String? accessToken}) async {
    final Map<String, String> headers = {"Authorization": "Bearer $accessToken"};
    final Uri url = UriEx.handle(domain, '/api/v2/search').replace(
      queryParameters: {
        'q': keyword,
      },
    );
    final response = await get(url, headers: accessToken == null ? {} : headers);

    return SearchResultSchema.fromString(response.body);
  }
}

// vim: set ts=2 sw=2 sts=2 et:
