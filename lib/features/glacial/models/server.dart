// The Mastodon server data schema.
import 'dart:convert';

import 'config.dart';

// The Mastodon server data schema that show the necessary info to show
// the widget in the app.
//
// ref: https://docs.joinmastodon.org/entities/Instance/
class ServerSchema {
  final String domain;
  final String title;
  final String desc;
  final String version;
  final String thumbnail;
  final ServerUsageSchema usage;
  final ServerConfigSchema config;
  final List<String> languages;
  final List<RuleSchema> rules;

  const ServerSchema({
    required this.domain,
    required this.title,
    required this.desc,
    required this.version,
    required this.thumbnail,
    required this.usage,
    required this.config,
    this.languages = const [],
    this.rules = const [],
  });

  // Create a new ServerSchema by the passed JSON string.
  factory ServerSchema.fromString(String str) {
    final Map<String, dynamic> json = jsonDecode(str);
    return ServerSchema.fromJson(json);
  }

  // Create a new ServerSchema by the passed JSON object.
  factory ServerSchema.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> thumbnail = json['thumbnail'] as Map<String, dynamic>;

    return ServerSchema(
      domain: json['domain'] as String,
      title: json['title'] as String,
      desc: json['description'] as String,
      version: json['version'] as String,
      thumbnail: thumbnail['url'] as String,
      usage: ServerUsageSchema.fromJson(json['usage'] as Map<String, dynamic>),
      config: ServerConfigSchema.fromJson(json['configuration'] as Map<String, dynamic>),
      languages: (json['languages'] as List<dynamic>).map((e) => e as String).toList(),
      rules: (json['rules'] as List<dynamic>).map((e) {
        final Map<String, dynamic> rule = e as Map<String, dynamic>;
        return RuleSchema.fromJson(rule);
      }).toList(),
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
