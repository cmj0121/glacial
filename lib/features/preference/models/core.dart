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

// The image quality preference type.
enum ImageQualityType {
  low,      // Low quality images for bandwidth saving
  medium,   // Medium quality images (default)
  high;     // High quality original images

  // The description text for the image quality type, localized if possible.
  String description(BuildContext context) {
    switch (this) {
      case low:
        return AppLocalizations.of(context)?.txt_preference_image_low ?? "Low (saves data)";
      case medium:
        return AppLocalizations.of(context)?.txt_preference_image_medium ?? "Medium";
      case high:
        return AppLocalizations.of(context)?.txt_preference_image_high ?? "High (original)";
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
  final bool loadedTop;
  final ReplyTagType replyTag;
  final Locale? locale;
  final QuotePolicyType quotePolicy;
  // New preference options
  final double fontScale;           // Font size scale factor (0.8 - 1.4)
  final bool hideReplies;           // Hide replies in timeline
  final bool hideReblogs;           // Hide reblogs in timeline
  final bool autoPlayVideo;         // Auto-play videos in timeline
  final int timelineLimit;          // Max items to load in timeline (20-100)
  final ImageQualityType imageQuality; // Image quality preference
  final bool useOledTheme;          // Pure black OLED theme (only applies in dark mode)
  final bool hapticFeedback;        // Haptic feedback on interactions

  const SystemPreferenceSchema({
    this.server,
    this.theme = ThemeMode.dark,
    this.visibility = VisibilityType.public,
    this.sensitive = true,
    this.refreshInterval = const Duration(seconds: 30),
    this.loadedTop = false,
    this.replyTag = ReplyTagType.all,
    this.locale,
    this.quotePolicy = QuotePolicyType.public,
    this.fontScale = 1.0,
    this.hideReplies = false,
    this.hideReblogs = false,
    this.autoPlayVideo = true,
    this.timelineLimit = 40,
    this.imageQuality = ImageQualityType.medium,
    this.useOledTheme = false,
    this.hapticFeedback = true,
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
      loadedTop: json["loaded_top"] as bool? ?? false,
      replyTag: ReplyTagType.values.firstWhere(
        (r) => r.name == json["reply_tag"],
        orElse: () => ReplyTagType.all,
      ),
      locale: json["locale"] == null ? null : Locale(json["locale"] as String),
      quotePolicy: json["quote_approval_policy"] == null
          ? QuotePolicyType.public
          : QuotePolicyType.fromString(json["quote_approval_policy"] as String),
      fontScale: (json["font_scale"] as num?)?.toDouble() ?? 1.0,
      hideReplies: json["hide_replies"] as bool? ?? false,
      hideReblogs: json["hide_reblogs"] as bool? ?? false,
      autoPlayVideo: json["auto_play_video"] as bool? ?? true,
      timelineLimit: json["timeline_limit"] as int? ?? 40,
      imageQuality: ImageQualityType.values.firstWhere(
        (q) => q.name == json["image_quality"],
        orElse: () => ImageQualityType.medium,
      ),
      useOledTheme: json["use_oled_theme"] as bool? ?? false,
      hapticFeedback: json["haptic_feedback"] as bool? ?? true,
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
      "loaded_top": loadedTop,
      "reply_tag": replyTag.name,
      "locale": locale?.toLanguageTag(),
      "quote_approval_policy": quotePolicy.name,
      "font_scale": fontScale,
      "hide_replies": hideReplies,
      "hide_reblogs": hideReblogs,
      "auto_play_video": autoPlayVideo,
      "timeline_limit": timelineLimit,
      "image_quality": imageQuality.name,
      "use_oled_theme": useOledTheme,
      "haptic_feedback": hapticFeedback,
    };
  }

  // Copy the current preference settings with new values.
  SystemPreferenceSchema copyWith({
    String? server,
    ThemeMode? theme,
    VisibilityType? visibility,
    bool? sensitive,
    Duration? refreshInterval,
    bool? loadedTop,
    ReplyTagType? replyTag,
    Locale? locale,
    QuotePolicyType? quotePolicy,
    double? fontScale,
    bool? hideReplies,
    bool? hideReblogs,
    bool? autoPlayVideo,
    int? timelineLimit,
    ImageQualityType? imageQuality,
    bool? useOledTheme,
    bool? hapticFeedback,
  }) {
    return SystemPreferenceSchema(
      server: server ?? this.server,
      theme: theme ?? this.theme,
      visibility: visibility ?? this.visibility,
      sensitive: sensitive ?? this.sensitive,
      refreshInterval: refreshInterval ?? this.refreshInterval,
      loadedTop: loadedTop ?? this.loadedTop,
      replyTag: replyTag ?? this.replyTag,
      locale: locale ?? this.locale,
      quotePolicy: quotePolicy ?? this.quotePolicy,
      fontScale: fontScale ?? this.fontScale,
      hideReplies: hideReplies ?? this.hideReplies,
      hideReblogs: hideReblogs ?? this.hideReblogs,
      autoPlayVideo: autoPlayVideo ?? this.autoPlayVideo,
      timelineLimit: timelineLimit ?? this.timelineLimit,
      imageQuality: imageQuality ?? this.imageQuality,
      useOledTheme: useOledTheme ?? this.useOledTheme,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
