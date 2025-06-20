// The Mastodon server data schema.
import 'dart:convert';

import 'package:glacial/core.dart';

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
  static Future<ServerSchema> fetch(String domain) async {
    logger.i('search the mastodon server: $domain');

    final Uri url = UriEx.handle(domain, '/api/v2/instance');
    final response = await get(url);

    switch (response.statusCode) {
      case 200:
        return ServerSchema.fromString(response.body);
      case 404:
        final Uri url = UriEx.handle(domain, '/api/v2/instance');
        final response = await get(url);

        if (response.statusCode == 200) {
          return ServerSchema.fromString(response.body);
        }
    }

    throw Exception('Failed to load the server: $domain');
  }
}

// The Server rule to show the server info in the app.
class RuleSchema {
  final String id;
  final String text;
  final String hint;

  const RuleSchema({
    required this.id,
    required this.text,
    required this.hint,
  });

  factory RuleSchema.fromJson(Map<String, dynamic> json) {
    return RuleSchema(
      id: json['id'] as String,
      text: json['text'] as String,
      hint: json['hint'] as String,
    );
  }
}

// The server usage
class ServerUsageSchema {
  final int userActiveMonthly;

  const ServerUsageSchema({
    required this.userActiveMonthly,
  });

  factory ServerUsageSchema.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? users = json['users'] as Map<String, dynamic>?;
    return ServerUsageSchema(
      userActiveMonthly: users?['active_month'] as int? ?? 0,
    );
  }
}

// The server status configuration
class StatusConfigSchema {
  final int charReserved;
  final int maxCharacters;
  final int maxAttachments;

  const StatusConfigSchema({
    required this.charReserved,
    required this.maxCharacters,
    required this.maxAttachments,
  });

  factory StatusConfigSchema.fromJson(Map<String, dynamic> json) {
    return StatusConfigSchema(
      charReserved: json['characters_reserved_per_url'] as int? ?? 0,
      maxCharacters: json['max_characters'] as int? ?? 0,
      maxAttachments: json['max_media_attachments'] as int? ?? 0,
    );
  }
}

// The server configuration
class ServerConfigSchema {
  final StatusConfigSchema statuses;

  const ServerConfigSchema({
    required this.statuses,
  });

  factory ServerConfigSchema.fromJson(Map<String, dynamic> json) {
    return ServerConfigSchema(
      statuses: StatusConfigSchema.fromJson(json['statuses'] as Map<String, dynamic>),
    );
  }
}

// The information about registering for this website.
class RegisterConfigSchema {
  final bool enabled;
  final bool approvalRequired;

  const RegisterConfigSchema({
    required this.enabled,
    required this.approvalRequired,
  });

  factory RegisterConfigSchema.fromJson(Map<String, dynamic> json) {
    return RegisterConfigSchema(
      enabled: json['enabled'] as bool? ?? false,
      approvalRequired: json['approval_required'] as bool? ?? false,
    );
  }
}

// The hints related to contacting a representative of the website.
class ContactSchema {
  final String email;

  const ContactSchema({
    required this.email,
  });

  factory ContactSchema.fromJson(Map<String, dynamic> json) {
    return ContactSchema(
      email: json['email'] as String,
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
