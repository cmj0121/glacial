// The system preference settings to control the app"s behavior and features.
import "dart:convert";

import "package:flutter/material.dart";

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';

// The tab type of the system preference settings.
enum SystemPreferenceType {
  theme,    // The theme settings of the app.
  engineer, // The engineer settings of the app.
  about;    // The about info page.

  // The icon associated with the system preference type.
  IconData icon({bool active = false}) {
    switch (this) {
      case theme:
        return active ? Icons.color_lens : Icons.color_lens_outlined;
      case engineer:
        return active ? Icons.engineering : Icons.engineering_outlined;
      case about:
        return active ? Icons.info : Icons.info_outline;
    }
  }

  // The tooltip text for the system preference type, localized if possible.
  String tooltip(BuildContext context) {
    switch (this) {
      case theme:
        return AppLocalizations.of(context)?.btn_preference_theme ?? "Theme";
      case engineer:
        return AppLocalizations.of(context)?.btn_preference_engineer ?? "Engineer Settings";
      case about:
        return AppLocalizations.of(context)?.btn_preference_about ?? "About";
    }
  }
}

// The reply auto-tag behavior type.
enum ReplyTagType {
  all,    // tag all the mentions in the reply.
  poster, // tag only the poster of the post.
  none;   // tag no one in the reply.

  // The icon associated with the reply tag type.
  IconData icon() {
    switch (this) {
      case all:
        return Icons.group;
      case poster:
        return Icons.person;
      case none:
        return Icons.cancel;
    }
  }

  // The tooltip text for the reply tag type, localized if possible.
  String tooltip(BuildContext context) {
    switch (this) {
      case all:
        return AppLocalizations.of(context)?.txt_preference_reply_all ?? "Tag All";
      case poster:
        return AppLocalizations.of(context)?.txt_preference_reply_only ?? "Tag Poster";
      case none:
        return AppLocalizations.of(context)?.txt_preference_reply_none ?? "Tag None";
    }
  }

  // The description text for the reply tag type, localized if possible.
  String description(BuildContext context) {
    switch (this) {
      case all:
        return AppLocalizations.of(context)?.desc_preference_reply_all ?? "Tag all the mentions in the reply.";
      case poster:
        return AppLocalizations.of(context)?.desc_preference_reply_only ?? "Tag only the poster of the post.";
      case none:
        return AppLocalizations.of(context)?.desc_preference_reply_none ?? "Tag no one in the reply.";
    }
  }
}

// The global data schema of the system preference settings.
class SystemPreferenceSchema {
  // The static key to access the system preference settings.
  static const String key = "system_preference";

  final String? server;
  final ThemeMode theme;
  final VisibilityType visibility;
  final bool sensitive;
  final Duration refreshInterval;
  final ReplyTagType replyTag;

  const SystemPreferenceSchema({
    this.server,
    this.theme = ThemeMode.dark,
    this.visibility = VisibilityType.public,
    this.sensitive = true,
    this.refreshInterval = const Duration(seconds: 30),
    this.replyTag = ReplyTagType.all,
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
      visibility: VisibilityType.values.firstWhere(
        (v) => v.name == json["visibility"],
        orElse: () => VisibilityType.public,
      ),
      sensitive: json["sensitive"] as bool? ?? false,
      refreshInterval: Duration(
        seconds: json["refresh_interval"] as int? ?? 30,
      ),
      replyTag: ReplyTagType.values.firstWhere(
        (r) => r.name == json["reply_tag"],
        orElse: () => ReplyTagType.all,
      ),
    );
  }

  // Converts the perference settings to JSON format.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "server": server,
      "theme": theme.name,
      "visibility": visibility.name,
      "sensitive": sensitive,
      "refresh_interval": refreshInterval.inSeconds,
      "reply_tag": replyTag.name,
    };
  }

  // Copy the current preference settings with new values.
  SystemPreferenceSchema copyWith({
    String? server,
    ThemeMode? theme,
    VisibilityType? visibility,
    bool? sensitive,
    Duration? refreshInterval,
    ReplyTagType? replyTag,
  }) {
    return SystemPreferenceSchema(
      server: server ?? this.server,
      theme: theme ?? this.theme,
      visibility: visibility ?? this.visibility,
      sensitive: sensitive ?? this.sensitive,
      refreshInterval: refreshInterval ?? this.refreshInterval,
      replyTag: replyTag ?? this.replyTag,
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
