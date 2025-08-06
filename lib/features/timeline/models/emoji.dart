// The custom emoji data schema.
import 'package:flutter/material.dart';

class EmojiSchema {
  final String shortcode; // The name of the custom emoji.
  final String url;       // A link to the custom emoji.
  final String staticUrl; // A link to a static copy of the custom emoji.
  final bool visible;     // Whether this Emoji should be visible in the picker or unlisted.
  final String? category; // Used for sorting custom emoji in the picker.

  const EmojiSchema({
    required this.shortcode,
    required this.url,
    required this.staticUrl,
    this.visible = true,
    this.category,
  });

  factory EmojiSchema.fromJson(Map<String, dynamic> json) {
    return EmojiSchema(
      shortcode: json['shortcode'] as String,
      url: json['url'] as String,
      staticUrl: json['static_url'] as String,
      visible: json['visible'] as bool? ?? true,
      category: json['category'] as String?,
    );
  }

  // Convert the string including the emoji shortcode into a list of strings,
  static List<String> splitEmoji(String content) {
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

  // Convert the string including the emoji shortcode into a HTML string.
  static String replaceEmojiToHTML(String content, {List<EmojiSchema>? emojis, double size = 16}) {
    final List<String> parts = splitEmoji(content);

    if (parts.isEmpty) {
      return content;
    }

    return parts.reduce((String value, String part) {
      final String shortcode = (part.startsWith(':') && part.endsWith(':')) ? part.substring(1, part.length - 1) : part;
      final EmojiSchema? emoji = emojis?.cast<EmojiSchema?>().firstWhere((e) => e?.shortcode == shortcode, orElse: () => null);

      if (emoji == null) {
        return "$value$part";
      }

      return "$value<img src='${emoji.url}' width='$size' height='$size' />";
    });
  }

  // Convert the string including the emoji shortcode into a Widget image tag.
  static Widget replaceEmojiToWidget(String content, {List<EmojiSchema>? emojis, double size = 16}) {
    final List<String> parts = splitEmoji(content);

    if (parts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: parts.map((String part) {
        final String shortcode = (part.startsWith(':') && part.endsWith(':')) ? part.substring(1, part.length - 1) : part;
        final EmojiSchema? emoji = emojis?.cast<EmojiSchema?>().firstWhere((e) => e?.shortcode == shortcode, orElse: () => null);

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
}

// vim: set ts=2 sw=2 sts=2 et:
