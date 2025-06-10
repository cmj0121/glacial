// The extensions implementation for the timeline feature.
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';

// The in-memory AccountSchema and EmojiSchema cache
Map<String, EmojiSchema> emojiCache = {};
Map<String, StatusSchema> statusCache = {};

extension TimelineExtensions on ServerSchema {
  // Fetch timeline's statuses based on the timeline type.
  Future<List<StatusSchema>> fetchTimeline(TimelineType type, {
    String? accessToken,
    String? maxId,
    String? accountID,
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

        uri = UriEx.handle(domain, "/api/v1/accounts/${accountID ?? '-'}/statuses").replace(queryParameters: query);
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

    final Map<String, String> headers = {"Authorization": "Bearer $accessToken"};
    final response = await get(uri, headers: accessToken == null ? {} : headers);
    final List<dynamic> json = jsonDecode(response.body) as List<dynamic>;
    final List<StatusSchema> status = json.map((e) => StatusSchema.fromJson(e)).toList();

    // Save the related info to the in-memory cache.
    status.map((s) => Storage().saveAccountIntoCache(this, s.account)).toList();

    return status;
  }

  // Get the StatusSchema by its ID.
  Future<StatusSchema?> getStatus(String id, {String? accessToken}) async {
    final Storage storage = Storage();
    final StatusSchema? cachedStatus = storage.loadStatusFromCache(id);
    if (cachedStatus != null) {
      return cachedStatus;
    }

    final Uri uri = UriEx.handle(domain, "/api/v1/statuses/$id");
    final Map<String, String> headers = {"Authorization": "Bearer $accessToken"};
    final response = await get(uri, headers: accessToken != null ? headers : {});
    final StatusSchema schema = StatusSchema.fromJson(jsonDecode(response.body));

    storage.saveStatusIntoCache(schema);
    return schema;
  }

  // Get the context of the status by its ID.
  Future<StatusContextSchema> getStatusContext({required StatusSchema schema, String? accessToken}) async {
    final Map<String, String> headers = {"Authorization": "Bearer $accessToken"};
    final Uri uri = UriEx.handle(domain, "/api/v1/statuses/${schema.id}/context");
    final response = await get(uri, headers: accessToken == null ? {} : headers);
    final Map<String, dynamic> json = jsonDecode(response.body) as Map<String, dynamic>;

    return StatusContextSchema.fromJson(json);
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

// The extension of the Storage to save and load the status data.
extension StatusExtensions on Storage {
  // Save the status schema to the cache.
  void saveStatusIntoCache(StatusSchema schema) {
    statusCache[schema.id] = schema;
  }

  // Get the status schema from the cache.
  StatusSchema? loadStatusFromCache(String id) {
    return statusCache[id];
  }

  // Purge all the cached statuses.
  void purgeCachedStatuses() {
    statusCache.clear();
  }
}

// vim: set ts=2 sw=2 sts=2 et:
