// The trends records of the tags.

import 'package:glacial/features/trends/models/core.dart';

// The trends of the tags that are being used more frequently within the past week.
class HashTagSchema {
  final String name;
  final String url;
  final List<HistorySchema> history;

  const HashTagSchema({
    required this.name,
    required this.url,
    required this.history,
  });

  factory HashTagSchema.fromJson(Map<String, dynamic> json) {
    return HashTagSchema(
      name: json['name'] as String,
      url: json['url'] as String,
      history: (json['history'] as List<dynamic>).map((e) => HistorySchema.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
