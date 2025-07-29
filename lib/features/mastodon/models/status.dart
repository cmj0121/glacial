// The access status of the Mastodon server.
import 'dart:convert';

import 'package:glacial/features/models.dart';

// The access status of the Mastodon server, including the server access server and
// the list of the history of the access status.
class AccessStatusSchema {
  // The static key to access the access status schema.
  static const String key = "access_status";

  final String? server;
  final List<ServerInfoSchema> history;

  const AccessStatusSchema({
    this.server,
    this.history = const [],
  });

  // Convert the JSON string to an AccessStatusSchema object.
  factory AccessStatusSchema.fromString(String str) {
    final Map<String, dynamic> json = jsonDecode(str);
    return AccessStatusSchema.fromJson(json);
  }

  // Convert the JSON map to an AccessStatusSchema object.
  factory AccessStatusSchema.fromJson(Map<String, dynamic> json) {
    return AccessStatusSchema(
      server: json['server'] as String,
      history: (json['history'] as List<dynamic>).map((e) => ServerInfoSchema.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  // Create a copy of the current access status schema with new values.
  AccessStatusSchema copyWith({String? server, List<ServerInfoSchema>? history}) {
    return AccessStatusSchema(
      server: server ?? this.server,
      history: history ?? this.history,
    );
  }

  // Convert the access status schema to JSON format.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'server': server,
      'history': history.map((e) => e.toJson()).toList(),
    };
  }
}

// vim: set ts=2 sw=2 sts=2 et:
