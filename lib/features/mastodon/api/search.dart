// The Search APIs for the mastdon server.
//
// ## Search APIis
//
//   - [x] GET /api/v1/search     (removed in 3.0.0)
//   - [+] GET /api/v2/search
//
// ## Directory APIs
//
//   - [ ] GET /api/v1/directory/accounts

// ref:
//   - https://docs.joinmastodon.org/methods/search/
//   - https://docs.joinmastodon.org/methods/directory/
import 'dart:convert';

import 'package:glacial/features/models.dart';

extension SearchExtensions on AccessStatusSchema {
  // Perform a search for content in accounts, statuses and hashtags with the given parameters.
  Future<SearchResultSchema> search({
    required String keyword,
    String? type,
    int limit = 40,
    int offset = 0,
  }) async {
    final String endpoint = '/api/v2/search';
    final Map<String, String> params = {
      'q': keyword,
      if (type != null) 'type': type,
      'limit': limit.toString(),
      'offset': offset.toString(),
    };
    final String body = await getAPI(endpoint, queryParameters: params) ?? '{}';

    return SearchResultSchema.fromString(body);
  }

  // List accounts visible in the directory.
  Future<List<AccountSchema>> fetchDirectoryAccounts({
    int limit = 40,
    int offset = 0,
    DirectoryOrderType order = DirectoryOrderType.active,
    bool local = false,
  }) async {
    final String endpoint = '/api/v1/directory';
    final Map<String, String> params = {
      'limit': limit.toString(),
      'offset': offset.toString(),
      'order': order.name,
      'local': local.toString(),
    };
    final String body = await getAPI(endpoint, queryParameters: params) ?? '[]';
    final List<dynamic> jsonList = jsonDecode(body) as List<dynamic>;

    return jsonList.map((dynamic e) => AccountSchema.fromJson(e as Map<String, dynamic>)).toList();
  }
}

// vim: set ts=2 sw=2 sts=2 et:
