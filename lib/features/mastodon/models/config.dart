// The Mastodon server data schema for configurations.

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
  final PollConfigSchema polls;

  const ServerConfigSchema({
    required this.statuses,
    required this.polls,
  });

  factory ServerConfigSchema.fromJson(Map<String, dynamic> json) {
    return ServerConfigSchema(
      statuses: StatusConfigSchema.fromJson(json['statuses'] as Map<String, dynamic>),
      polls: PollConfigSchema.fromJson(json['polls'] as Map<String, dynamic>),
    );
  }
}

// The poll configuration for the server.
class PollConfigSchema {
  final int maxOptions;
  final int maxCharacters;
  final int minExpiresIn;
  final int maxExpiresIn;

  const PollConfigSchema({
    required this.maxOptions,
    required this.maxCharacters,
    required this.minExpiresIn,
    required this.maxExpiresIn,
  });

  factory PollConfigSchema.fromJson(Map<String, dynamic> json) {
    return PollConfigSchema(
      maxOptions: json['max_options'] as int? ?? 0,
      maxCharacters: json['max_characters_per_option'] as int? ?? 0,
      minExpiresIn: json['min_expiration'] as int? ?? 0,
      maxExpiresIn: json['max_expiration'] as int? ?? 0,
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

// vim: set ts=2 sw=2 sts=2 et:
