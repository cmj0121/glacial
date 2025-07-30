// The system preference settings to control the app"s behavior and features.
import "dart:convert";

import "package:flutter/material.dart";

import 'package:glacial/core.dart';

// The tab type of the system preference settings.
enum SystemPreferenceType {
  theme,    // The theme settings of the app.
  engineer; // The engineer settings of the app.

  // The icon associated with the system preference type.
  IconData icon({bool active = false}) {
    switch (this) {
      case theme:
        return active ? Icons.color_lens : Icons.color_lens_outlined;
      case engineer:
        return active ? Icons.engineering : Icons.engineering_outlined;
    }
  }

  // The tooltip text for the system preference type, localized if possible.
  String tooltip(BuildContext context) {
    switch (this) {
      case theme:
        return AppLocalizations.of(context)?.btn_preference_theme ?? "Theme";
      case engineer:
        return AppLocalizations.of(context)?.btn_preference_engineer ?? "Engineer Settings";
    }
  }
}

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
