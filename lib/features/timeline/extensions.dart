import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/glacial/models/server.dart';
import 'package:glacial/features/timeline/models/core.dart';

// The in-memory AccountSchema and EmojiSchema cache
Map<String, EmojiSchema> emojiCache = {};
Map<ServerSchema, Map<String, AccountSchema>> accountCache = {};

// The extension to the TimelineType enum to list the statuses per timeline type.
extension StatusLoaderExtensions on ServerSchema {
  // Fetch the timeline statuss from the server.
  Future<List<StatusSchema>> fetchTimeline({
    required TimelineType type,
    AccountSchema? account,
    String? accessToken,
    String? maxId,
    String? keyword,
  }) async {
    late final Uri uri;

    switch (type) {
      case TimelineType.home:
        final Map<String, String> query = {};
        query["max_id"] = maxId ?? "";

        uri = UriEx.handle(domain, "/api/v1/timelines/home").replace(queryParameters: query);
        break;
      case TimelineType.user:
        final Map<String, String> query = {};
        query["max_id"] = maxId ?? "";

        uri = UriEx.handle(domain, "/api/v1/accounts/${account?.id ?? '-'}/statuses").replace(queryParameters: query);
        break;
      case TimelineType.hashtag:
        final Map<String, String> query = {};

        query["max_id"] = maxId ?? "";
        query["local"] = "true";
        query["remote"] = "true";
        uri = UriEx.handle(domain, "/api/v1/timelines/tag/$keyword").replace(queryParameters: query);
        break;
      case TimelineType.local:
        final Map<String, String> query = {};

        query["max_id"] = maxId ?? "";
        query["local"] = "true";
        query["remote"] = "false";
        uri = UriEx.handle(domain, "/api/v1/timelines/public").replace(queryParameters: query);
        break;
      case TimelineType.federal:
        final Map<String, String> query = {};

        query["max_id"] = maxId ?? "";
        query["local"] = "false";
        query["remote"] = "true";
        uri = UriEx.handle(domain, "/api/v1/timelines/public").replace(queryParameters: query);
        break;
      case TimelineType.public:
        final Map<String, String> query = {};

        query["max_id"] = maxId ?? "";
        query["local"] = "false";
        query["remote"] = "false";
        uri = UriEx.handle(domain, "/api/v1/timelines/public").replace(queryParameters: query);
        break;
      case TimelineType.bookmarks:
        final Map<String, String> query = {};

        query["max_id"] = maxId ?? "";
        uri = UriEx.handle(domain, "/api/v1/bookmarks").replace(queryParameters: query);
        break;
      case TimelineType.favourites:
        final Map<String, String> query = {};

        query["max_id"] = maxId ?? "";
        uri = UriEx.handle(domain, "/api/v1/favourites").replace(queryParameters: query);
        break;
    }

    if (!type.supportAnonymous && accessToken == null) {
      logger.w("access token is required for $this");
      throw MissingAuth("access token is required for $this");
    }

    logger.i("try to fetch the timeline from $uri");
    final Map<String, String> headers = {"Authorization": "Bearer $accessToken"};
    final response = await get(uri, headers: type.supportAnonymous ? {} : headers);
    final List<dynamic> json = jsonDecode(response.body) as List<dynamic>;

    final ServerSchema server = this;
    final List<StatusSchema> schemas = json.map((e) => StatusSchema.fromJson(e)).toList();

    // Save the status to the in-memory cache.
    final List<Future<void>> saveFutures = schemas.map((s) => server.saveAccount(s.account)).toList();
    await Future.wait(saveFutures);
    return schemas;
  }

  // Get the authenticated user account.
  Future<AccountSchema?> getAuthUser(String? token) async {
    if (token == null) {
      return null;
    }

    final Uri uri = UriEx.handle(domain, "/api/v1/accounts/verify_credentials");
    final Map<String, String> headers = {"Authorization": "Bearer $token"};
    final response = await get(uri, headers: headers);

    if (response.statusCode != 200) {
      throw RequestError(response);
    }

    final Map<String, dynamic> json = jsonDecode(response.body) as Map<String, dynamic>;
    return AccountSchema.fromJson(json);
  }
}

// The in-memory account cache to store the account data.
extension AccountLoaderExtensions on ServerSchema {
  Future<AccountSchema?> loadAccount(String? accountID) async {
    return accountCache[this]?[accountID];
  }

  Future<void> saveAccount(AccountSchema? account) async {
    if (account == null) {
      return;
    }

    accountCache[this] ??= {};
    accountCache[this]![account.id] = account;
  }
}

// The extension to post the new status to the server.
extension PostStatusExtensions on NewStatusSchema {
  Future<StatusSchema> create({ServerSchema? schema, String? accessToken}) async {
    if (schema == null || accessToken == null) {
      logger.w("schema and access token are required");
      throw MissingAuth("schema and access token are required");
    }

    final Uri uri = UriEx.handle(schema.domain, "/api/v1/statuses");
    final Map<String, String> headers = {
      "Authorization": "Bearer $accessToken",
      "Content-Type": "application/json",
    };

    final Map<String, dynamic> body = toJson();
    final response = await post(uri, headers: headers, body: jsonEncode(body));

    logger.i("complete create a new status: ${response.statusCode}");
    return StatusSchema.fromString(response.body);
  }
}

// The future function to interact with the status.
typedef InteractIt = Future<StatusSchema> Function({required String domain, required String accessToken});

// The extension of the current status to update the status.
extension InteractiveStatusExtensions on StatusSchema {
  // Get statuses above and below this status in the thread.
  Future<StatusContextSchema> context({
    required String domain,
    String? accessToken,
  }) async {
    final Map<String, String> headers = {"Authorization": "Bearer $accessToken"};
    final Uri uri = UriEx.handle(domain, "/api/v1/statuses/$id/context");
    final response = await get(uri, headers: accessToken == null ? {} : headers);
    final Map<String, dynamic> json = jsonDecode(response.body) as Map<String, dynamic>;

    logger.i("fetch context for $this from $uri");
    return StatusContextSchema.fromJson(json);
  }

  // Reblog the status to the Mastodon server
  Future<StatusSchema> reblogIt({required String domain, required String accessToken}) async {
    final Uri uri = UriEx.handle(domain, "/api/v1/statuses/$id/reblog");
    final Map<String, String> headers = {
      "Authorization": "Bearer $accessToken",
      "Content-Type": "application/json",
    };

    final String body = await sendPostRequest(uri, headers: headers);
    return StatusSchema.fromString(body);
  }

  // Unreblog the status to the Mastodon server
  Future<StatusSchema> unreblogIt({required String domain, required String accessToken}) async {
    final Uri uri = UriEx.handle(domain, "/api/v1/statuses/$id/unreblog");
    final Map<String, String> headers = {
      "Authorization": "Bearer $accessToken",
      "Content-Type": "application/json",
    };

    final String body = await sendPostRequest(uri, headers: headers);
    return StatusSchema.fromString(body);
  }

  // Favourite the status to the Mastodon server
  Future<StatusSchema> favouriteIt({required String domain, required String accessToken}) async {
    final Uri uri = UriEx.handle(domain, "/api/v1/statuses/$id/favourite");
    final Map<String, String> headers = {
      "Authorization": "Bearer $accessToken",
      "Content-Type": "application/json",
    };

    final String body = await sendPostRequest(uri, headers: headers);
    return StatusSchema.fromString(body);
  }

  // Unfavourite the status to the Mastodon server
  Future<StatusSchema> unfavouriteIt({required String domain, required String accessToken}) async {
    final Uri uri = UriEx.handle(domain, "/api/v1/statuses/$id/unfavourite");
    final Map<String, String> headers = {
      "Authorization": "Bearer $accessToken",
      "Content-Type": "application/json",
    };

    final String body = await sendPostRequest(uri, headers: headers);
    return StatusSchema.fromString(body);
  }

  // Bookmark the status to the Mastodon server
  Future<StatusSchema> bookmarkIt({required String domain, required String accessToken}) async {
    final Uri uri = UriEx.handle(domain, "/api/v1/statuses/$id/bookmark");
    final Map<String, String> headers = {
      "Authorization": "Bearer $accessToken",
      "Content-Type": "application/json",
    };

    final String body = await sendPostRequest(uri, headers: headers);
    return StatusSchema.fromString(body);
  }

  // Unbookmark the status to the Mastodon server
  Future<StatusSchema> unbookmarkIt({required String domain, required String accessToken}) async {
    final Uri uri = UriEx.handle(domain, "/api/v1/statuses/$id/unbookmark");
    final Map<String, String> headers = {
      "Authorization": "Bearer $accessToken",
      "Content-Type": "application/json",
    };

    final String body = await sendPostRequest(uri, headers: headers);
    return StatusSchema.fromString(body);
  }

  // Delete the status to the Mastodon server
  Future<void> deleteIt({required String domain, required String accessToken}) async {
    final Uri uri = UriEx.handle(domain, "/api/v1/statuses/$id");
    final Map<String, String> headers = {
      "Authorization": "Bearer $accessToken",
      "Content-Type": "application/json",
    };

    await delete(uri, headers: headers);
  }

  Future<String> sendPostRequest(Uri uri, {Map<String, String>? headers, Map<String, String>? body}) async {
    final response = await post(uri, headers: headers, body: jsonEncode(body));
    switch (response.statusCode) {
      case 200:
        logger.i("call status action from $uri");
        return response.body;
      default:
        logger.e("failed to unbookmark $this from $uri: ${response.statusCode}");
        throw Exception("failed to unbookmark $this from $uri: ${response.statusCode}");
    }
  }
}

// The extension of the Storage to save and load the emoji data.
extension EmojiExtensions on Storage {
  // Save the account schema to the cache.
  void saveEmoji(String id, EmojiSchema schema) {
    emojiCache[id] = schema;
  }

  // Replace the orignal emoji shortcode into the HTML image tag.
  String replaceEmojiToHTML(String content, {List<EmojiSchema>? emojis, double size = 16}) {
    final List<String> parts = splitEmoji(content);

    if (parts.isEmpty) {
      return content;
    }

    return parts.reduce((String value, String part) {
      final String shortcode = (part.startsWith(':') && part.endsWith(':'))
          ? part.substring(1, part.length - 1)
          : part;
      final EmojiSchema? emoji = (
        emojiCache[shortcode] ??
        emojis?.cast<EmojiSchema?>().firstWhere((e) => e?.shortcode == shortcode, orElse: () => null)
      );

      if (emoji == null) {
        return "$value$part";
      }

      return "$value<img src='${emoji.url}' width='$size' height='$size' />";
    });
  }

  // Replace the orignal emoji shortcode into the Widget image tag.
  Widget replaceEmojiToWidget(String content, {List<EmojiSchema>? emojis, double size = 16}) {
    final List<String> parts = splitEmoji(content);

    if (parts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: parts.map((String part) {
        final String shortcode = (part.length > 2) ? part.substring(1, part.length - 1) : part;
        final EmojiSchema? emoji = (
          emojiCache[shortcode] ??
          emojis?.cast<EmojiSchema?>().firstWhere((e) => e?.shortcode == shortcode, orElse: () => null)
        );

        if (emoji == null) {
          return Text(part, overflow: TextOverflow.ellipsis);
        }

        return Image.network(
          emoji.url,
          width: size,
          height: size,
          fit: BoxFit.cover,
        );
      }).toList(),
    );
  }

  // Split the text into parts based on the emoji pattern.
  List<String> splitEmoji(String content) {
    final RegExp pattern = RegExp(r':[a-zA-Z0-9_+\-]+?:');
    final List<String> parts = [];

    int lastEnd = 0;
    for (final match in pattern.allMatches(content)) {
      if (match.start > lastEnd) {
        parts.add(content.substring(lastEnd, match.start));
      }

      final String emoji = content.substring(match.start, match.end);
      parts.add(emoji);
      lastEnd = match.end;
    }

    if (lastEnd < content.length) {
      parts.add(content.substring(lastEnd));
    }

    return parts;
  }

  // Purge all the cached accounts.
  void purgeCachedEmojis() {
    emojiCache.clear();
  }
}

// vim: set ts=2 sw=2 sts=2 et:
