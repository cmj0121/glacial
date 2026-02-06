// View information about or follow/unfollow hashtags.
//
// ## Hashtags APIs
//
//   - [+] GET    /api/v1/tags/:name
//   - [+] POST   /api/v1/tags/:name/follow
//   - [+] POST   /api/v1/tags/:name/unfollow
//
// ## Featured Tags APIs
//
//   - [+] GET    /api/v1/featured_tags
//   - [+] POST   /api/v1/featured_tags
//   - [+] DELETE /api/v1/featured_tags/:id
//
// ref:
//   - https://docs.joinmastodon.org/methods/tags/
//   - https://docs.joinmastodon.org/methods/featured_tags/
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

  // List all hashtags featured on your profile.
  Future<List<FeaturedTagSchema>> fetchFeaturedTags() async {
    checkSignedIn();

    final String body = await getAPI('/api/v1/featured_tags') ?? '[]';
    final List<dynamic> json = jsonDecode(body) as List<dynamic>;

    return json.map((e) => FeaturedTagSchema.fromJson(e as Map<String, dynamic>)).toList();
  }

  // Promote a hashtag on your profile.
  Future<FeaturedTagSchema> featureTag(String name) async {
    checkSignedIn();

    final Map<String, dynamic> body = {'name': name};
    final String response = await postAPI('/api/v1/featured_tags', body: body) ?? '{}';
    final Map<String, dynamic> json = jsonDecode(response) as Map<String, dynamic>;

    return FeaturedTagSchema.fromJson(json);
  }

  // Stop promoting a hashtag on your profile.
  Future<void> unfeatureTag(String id) async {
    checkSignedIn();

    await deleteAPI('/api/v1/featured_tags/$id');
  }
}

// vim: set ts=2 sw=2 sts=2 et:
