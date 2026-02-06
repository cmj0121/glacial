// The translation response from the Mastodon server.
import 'dart:convert';

// The translated content of a status returned by POST /api/v1/statuses/:id/translate.
class TranslationSchema {
  final String content;                 // HTML-encoded translated content.
  final String spoilerText;             // Translated content warning.
  final String language;                // Target language code.
  final String detectedSourceLanguage;  // Auto-detected source language (ISO 639-1).
  final String provider;                // Translation service provider name.

  const TranslationSchema({
    required this.content,
    required this.spoilerText,
    required this.language,
    required this.detectedSourceLanguage,
    required this.provider,
  });

  factory TranslationSchema.fromString(String str) {
    final Map<String, dynamic> json = jsonDecode(str);
    return TranslationSchema.fromJson(json);
  }

  factory TranslationSchema.fromJson(Map<String, dynamic> json) {
    return TranslationSchema(
      content: json['content'] as String? ?? '',
      spoilerText: json['spoiler_text'] as String? ?? '',
      language: json['language'] as String? ?? '',
      detectedSourceLanguage: json['detected_source_language'] as String? ?? '',
      provider: json['provider'] as String? ?? '',
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
