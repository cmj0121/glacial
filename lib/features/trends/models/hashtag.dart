// The trends records of the tags.

import 'package:glacial/features/models.dart';

// The trends of the tags that are being used more frequently within the past week.
class HashtagSchema {
  final String name;
  final String url;
  final List<HistorySchema> history;
  final bool? following;
  final bool? featuring;

  const HashtagSchema({
    required this.name,
    required this.url,
    required this.history,
    this.following,
    this.featuring,
  });

  factory HashtagSchema.fromJson(Map<String, dynamic> json) {
    return HashtagSchema(
      name: json['name'] as String,
      url: json['url'] as String,
      history: (json['history'] as List<dynamic>).map((e) => HistorySchema.fromJson(e as Map<String, dynamic>)).toList(),
      following: json['following'] as bool?,
      featuring: json['featuring'] as bool?,
    );
  }
}

// A hashtag that is featured on a user's profile.
class FeaturedTagSchema {
  final String id;
  final String name;
  final String url;
  final int statusesCount;
  final String? lastStatusAt;

  const FeaturedTagSchema({
    required this.id,
    required this.name,
    required this.url,
    this.statusesCount = 0,
    this.lastStatusAt,
  });

  factory FeaturedTagSchema.fromJson(Map<String, dynamic> json) {
    return FeaturedTagSchema(
      id: json['id'] as String,
      name: json['name'] as String,
      url: json['url'] as String? ?? '',
      statusesCount: json['statuses_count'] as int? ?? 0,
      lastStatusAt: json['last_status_at'] as String?,
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
