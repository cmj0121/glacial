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

// vim: set ts=2 sw=2 sts=2 et:
