// The Mastodon server data schema.
import 'dart:convert';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';

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
  final RegisterConfigSchema registration;
  final ContactSchema contact;
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
    required this.registration,
    required this.contact,
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
      registration: RegisterConfigSchema.fromJson(json['registrations'] as Map<String, dynamic>),
      contact: ContactSchema.fromJson(json['contact'] as Map<String, dynamic>),
      languages: (json['languages'] as List<dynamic>).map((e) => e as String).toList(),
      rules: (json['rules'] as List<dynamic>).map((e) {
        final Map<String, dynamic> rule = e as Map<String, dynamic>;
        return RuleSchema.fromJson(rule);
      }).toList(),
    );
  }

  // fetch the server information from the specified domain.
  static Future<ServerSchema?> fetch(String? domain) async {
    if (domain == null || domain.isNotEmpty != true) {
      return null;
    }

    logger.i('search the mastodon server: $domain');
    final Uri url = UriEx.handle(domain, '/api/v2/instance');
    final response = await get(url);

    switch (response.statusCode) {
      case 200:
        return ServerSchema.fromString(response.body);
      case 404:
        final Uri url = UriEx.handle(domain, '/api/v1/instance');
        final response = await get(url);

        if (response.statusCode == 200) {
          return ServerSchema.fromString(response.body);
        }
    }

    throw Exception('Failed to load the server: $domain');
  }

  // Create the brief server information schema from the current server schema.
  ServerInfoSchema toInfo() {
    return ServerInfoSchema(
      domain: domain,
      thumbnail: thumbnail,
    );
  }
}

// The brief server information schema that only contains the necessary info
class ServerInfoSchema {
  final String domain;
  final String thumbnail;

  const ServerInfoSchema({
    required this.domain,
    required this.thumbnail,
  });

  // Convert the JSON string to a ServerInfoSchema object.
  factory ServerInfoSchema.fromString(String str) {
    final Map<String, dynamic> json = jsonDecode(str);
    return ServerInfoSchema.fromJson(json);
  }

  // Convert the JSON map to a ServerInfoSchema object.
  factory ServerInfoSchema.fromJson(Map<String, dynamic> json) {
    return ServerInfoSchema(
      domain: json['domain'] as String,
      thumbnail: json['thumbnail'] as String,
    );
  }

  // Converts the server info to JSON format.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'domain': domain,
      'thumbnail': thumbnail,
    };
  }
}

// The type of the directory order.
enum DirectoryOrderType {
  active,  // sort by most recently posted statuses.
  latest;  // ort by most recently created profiles.
}


// vim: set ts=2 sw=2 sts=2 et:
