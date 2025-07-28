// The system preference settings to control the app's behavior and features.
import 'dart:convert';

class SystemPreferenceSchema {
  // The static key to access the system preference settings.
  static const String key = 'system_preference';

  final String? server;

  const SystemPreferenceSchema({
    this.server,
  });

  // Convert the JSON string to a SystemPreferenceSchema object.
  factory SystemPreferenceSchema.fromString(String json) {
    final Map<String, dynamic> data = jsonDecode(json);
    return SystemPreferenceSchema.fromJson(data);
  }

  // Convert the JSON map to a SystemPreferenceSchema object.
  factory SystemPreferenceSchema.fromJson(Map<String, dynamic> json) {
    return SystemPreferenceSchema(
      server: json['server'] as String?,
    );
  }

  // Converts the perference settings to JSON format.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'server': server,
    };
  }
}

// vim: set ts=2 sw=2 sts=2 et:
