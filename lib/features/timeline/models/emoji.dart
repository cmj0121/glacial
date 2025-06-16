// The custom emoji data schema.

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
}

// vim: set ts=2 sw=2 sts=2 et:
