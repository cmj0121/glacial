// The suggestions API for the mastodon server.
//
// ## Suggestions APIs
//   - [-] GET /api/v1/suggestions                  (deprecated in 3.4.0)
//   - [+] GET /api/v2/suggestions
//   - [+] DELETE /api/v1/suggestions/:account_id
//
// ref:
//   - https://docs.joinmastodon.org/methods/suggestions/
import 'dart:async';
import 'dart:convert';

import 'package:glacial/features/models.dart';

// The API extensions for the timeline endpoints in the Mastodon server.
extension SuggestionsExtensions on AccessStatusSchema {
  // Get the suggestions of accounts from the Mastodon server.
  Future<List<SuggestionSchema>> fetchSuggestion({int? limit}) async {
    checkSignedIn();

    final String endpoint = '/api/v2/suggestions';
    final Map<String, String> query = {"offset": (limit ?? 40).toString()};
    final String body = await getAPI(endpoint, queryParameters: query) ?? '[]';
    final List<dynamic> json = jsonDecode(body) as List<dynamic>;

    return json.map((e) => SuggestionSchema.fromJson(e as Map<String, dynamic>)).toList();
  }

  // Remove the suggestion account from the Mastodon server.
  Future<void> removeSuggestion(String accountID) async {
    checkSignedIn();

    final String endpoint = '/api/v1/suggestions/$accountID';
    await deleteAPI(endpoint);
    return;
  }
}

// vim: set ts=2 sw=2 sts=2 et:
