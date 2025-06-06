// The trends records of the tags.

import 'package:glacial/features/models.dart';

// The trends of the tags that are being used more frequently within the past week.
class HashtagSchema {
  final String name;
  final String url;
  final List<HistorySchema> history;

  const HashtagSchema({
    required this.name,
    required this.url,
    required this.history,
  });

  factory HashtagSchema.fromJson(Map<String, dynamic> json) {
    return HashtagSchema(
      name: json['name'] as String,
      url: json['url'] as String,
      history: (json['history'] as List<dynamic>).map((e) => HistorySchema.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
