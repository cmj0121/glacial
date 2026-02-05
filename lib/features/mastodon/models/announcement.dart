// The Mastodon server announcement data schema.

// A reaction to an announcement.
class ReactionSchema {
  final String name;
  final int count;
  final bool me;
  final String? url;
  final String? staticUrl;

  const ReactionSchema({
    required this.name,
    this.count = 0,
    this.me = false,
    this.url,
    this.staticUrl,
  });

  factory ReactionSchema.fromJson(Map<String, dynamic> json) {
    return ReactionSchema(
      name: json['name'] as String,
      count: json['count'] as int? ?? 0,
      me: json['me'] as bool? ?? false,
      url: json['url'] as String?,
      staticUrl: json['static_url'] as String?,
    );
  }
}

// An announcement published by the server administrator.
class AnnouncementSchema {
  final String id;
  final String content;
  final String? startsAt;
  final String? endsAt;
  final bool allDay;
  final String publishedAt;
  final String? updatedAt;
  final bool read;
  final List<ReactionSchema> reactions;

  const AnnouncementSchema({
    required this.id,
    required this.content,
    this.startsAt,
    this.endsAt,
    this.allDay = false,
    required this.publishedAt,
    this.updatedAt,
    this.read = false,
    this.reactions = const [],
  });

  factory AnnouncementSchema.fromJson(Map<String, dynamic> json) {
    return AnnouncementSchema(
      id: json['id'] as String,
      content: json['content'] as String? ?? '',
      startsAt: json['starts_at'] as String?,
      endsAt: json['ends_at'] as String?,
      allDay: json['all_day'] as bool? ?? false,
      publishedAt: json['published_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String?,
      read: json['read'] as bool? ?? false,
      reactions: (json['reactions'] as List<dynamic>?)
          ?.map((e) => ReactionSchema.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
