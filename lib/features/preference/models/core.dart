// The system preference settings to control the app"s behavior and features.
import "dart:convert";
import "package:flutter/material.dart";

// The global data schema of the system preference settings.
class SystemPreferenceSchema {
  // The static key to access the system preference settings.
  static const String key = "system_preference";

  final String? server;
  final ThemeMode theme;

  const SystemPreferenceSchema({
    this.server,
    this.theme = ThemeMode.dark,
  });

  // Convert the JSON string to a SystemPreferenceSchema object.
  factory SystemPreferenceSchema.fromString(String json) {
    final Map<String, dynamic> data = jsonDecode(json);
    return SystemPreferenceSchema.fromJson(data);
  }

  // Convert the JSON map to a SystemPreferenceSchema object.
  factory SystemPreferenceSchema.fromJson(Map<String, dynamic> json) {
    return SystemPreferenceSchema(
      server: json["server"] as String?,
      theme:  ThemeMode.values.firstWhere((t) => t.name == json["theme"], orElse: () => ThemeMode.dark),
    );
  }

  // Converts the perference settings to JSON format.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "server": server,
      "theme": theme.name,
    };
  }

  // Copy the current preference settings with new values.
  SystemPreferenceSchema copyWith({
    String? server,
    ThemeMode? theme,
  }) {
    return SystemPreferenceSchema(
      server: server ?? this.server,
      theme: theme ?? this.theme,
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
