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

// Access levels for timeline feeds (Mastodon 4.5.0+).
// ref: https://docs.joinmastodon.org/entities/Instance/#timelines_access
enum TimelineAccessLevel {
  public,        // Anyone can view.
  authenticated, // Only signed-in users.
  disabled;      // Not available at all.

  factory TimelineAccessLevel.fromString(String? value) {
    switch (value) {
      case 'public':
        return TimelineAccessLevel.public;
      case 'authenticated':
        return TimelineAccessLevel.authenticated;
      default:
        return TimelineAccessLevel.disabled;
    }
  }
}

// The live feeds access configuration from timelines_access.live_feeds.
class LiveFeedsAccessSchema {
  final TimelineAccessLevel local;
  final TimelineAccessLevel federated;
  final TimelineAccessLevel bubble;

  const LiveFeedsAccessSchema({
    this.local = TimelineAccessLevel.public,
    this.federated = TimelineAccessLevel.public,
    this.bubble = TimelineAccessLevel.public,
  });

  factory LiveFeedsAccessSchema.fromJson(Map<String, dynamic> json) {
    return LiveFeedsAccessSchema(
      local: TimelineAccessLevel.fromString(json['local'] as String?),
      federated: TimelineAccessLevel.fromString(json['remote'] as String?),
      bubble: TimelineAccessLevel.fromString(json['bubble'] as String?),
    );
  }
}

// The timelines access configuration from configuration.timelines_access.
class TimelinesAccessSchema {
  final TimelineAccessLevel home;
  final LiveFeedsAccessSchema liveFeeds;

  const TimelinesAccessSchema({
    this.home = TimelineAccessLevel.authenticated,
    this.liveFeeds = const LiveFeedsAccessSchema(),
  });

  // Whether any public feed (local or federated) is available.
  bool get hasPublicFeeds =>
    liveFeeds.local != TimelineAccessLevel.disabled ||
    liveFeeds.federated != TimelineAccessLevel.disabled;

  factory TimelinesAccessSchema.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const TimelinesAccessSchema();
    final String? home = json['home'] as String?;
    return TimelinesAccessSchema(
      home: home != null ? TimelineAccessLevel.fromString(home) : TimelineAccessLevel.authenticated,
      liveFeeds: LiveFeedsAccessSchema.fromJson(
        json['live_feeds'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

// The server configuration
class ServerConfigSchema {
  final StatusConfigSchema statuses;
  final PollConfigSchema polls;
  final bool translationEnabled;
  final TimelinesAccessSchema timelinesAccess;

  const ServerConfigSchema({
    required this.statuses,
    required this.polls,
    required this.translationEnabled,
    this.timelinesAccess = const TimelinesAccessSchema(),
  });

  factory ServerConfigSchema.fromJson(Map<String, dynamic> json) {
    return ServerConfigSchema(
      statuses: StatusConfigSchema.fromJson(json['statuses'] as Map<String, dynamic>),
      polls: PollConfigSchema.fromJson(json['polls'] as Map<String, dynamic>),
      translationEnabled: (json['translation'] as Map<String, dynamic>?)?['enabled'] as bool? ?? false,
      timelinesAccess: TimelinesAccessSchema.fromJson(
        json['timelines_access'] as Map<String, dynamic>?,
      ),
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
