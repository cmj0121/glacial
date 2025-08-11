// View information about or follow/unfollow hashtags.
//
// ## Hashtags APIs
//
//   - [+] GET  /api/v1/tags/:name
//   - [+] POST /api/v1/tags/:name/follow
//   - [+] POST /api/v1/tags/:name/unfollow
//   - [ ] POST /api/v1/tags/:id/feature
//   - [ ] POST /api/v1/tags/:id/unfeature
//
// ref:
//   - https://docs.joinmastodon.org/methods/tags/
import 'dart:async';
import 'dart:convert';

import 'package:glacial/features/models.dart';

extension HashtagsExtensions on AccessStatusSchema {
  // Show a hashtag and its associated information
  Future<HashtagSchema> getHashtag(String name) async {
    final String endpoint = '/api/v1/tags/$name';
    final String body = await getAPI(endpoint) ?? '{}';
    final Map<String, dynamic> json = jsonDecode(body) as Map<String, dynamic>;

    return HashtagSchema.fromJson(json);
  }

  // Follow a hashtag. Posts containing a followed hashtag will be inserted into your home timeline.
  Future<HashtagSchema> followHashtag(String name) async {
    final String endpoint = '/api/v1/tags/$name/follow';
    final String body = await postAPI(endpoint) ?? '{}';
    final Map<String, dynamic> json = jsonDecode(body) as Map<String, dynamic>;

    return HashtagSchema.fromJson(json);
  }

  // Unfollow a hashtag. Posts containing this hashtag will no longer be inserted into your home timeline.
  Future<HashtagSchema> unfollowHashtag(String name) async {
    final String endpoint = '/api/v1/tags/$name/unfollow';
    final String body = await postAPI(endpoint) ?? '{}';
    final Map<String, dynamic> json = jsonDecode(body) as Map<String, dynamic>;

    return HashtagSchema.fromJson(json);
  }
}

// vim: set ts=2 sw=2 sts=2 et:
