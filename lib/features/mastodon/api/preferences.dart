// The Preferences API for the Mastodon server.
//
// ## Preferences APIs
//
//   - [+] GET /api/v1/preferences
//
// ref:
//  - https://docs.joinmastodon.org/methods/preferences/
import 'dart:convert';

import 'package:glacial/features/models.dart';

/// Server-side user preferences from GET /api/v1/preferences.
class MastodonPreferences {
  final VisibilityType defaultVisibility;
  final bool defaultSensitive;
  final String? defaultLanguage;
  final String expandMedia;      // "default", "show_all", "hide_all"
  final bool expandSpoilers;

  const MastodonPreferences({
    this.defaultVisibility = VisibilityType.public,
    this.defaultSensitive = false,
    this.defaultLanguage,
    this.expandMedia = 'default',
    this.expandSpoilers = false,
  });

  factory MastodonPreferences.fromJson(Map<String, dynamic> json) {
    return MastodonPreferences(
      defaultVisibility: VisibilityType.values.firstWhere(
        (v) => v.name == json['posting:default:visibility'],
        orElse: () => VisibilityType.public,
      ),
      defaultSensitive: json['posting:default:sensitive'] as bool? ?? false,
      defaultLanguage: json['posting:default:language'] as String?,
      expandMedia: json['reading:expand:media'] as String? ?? 'default',
      expandSpoilers: json['reading:expand:spoilers'] as bool? ?? false,
    );
  }
}

extension PreferencesExtensions on AccessStatusSchema {
  /// Fetch the authenticated user's server-side preferences.
  Future<MastodonPreferences?> fetchPreferences() async {
    checkSignedIn();

    final String endpoint = '/api/v1/preferences';
    final String? body = await getAPI(endpoint);
    if (body == null) return null;

    final Map<String, dynamic> json = jsonDecode(body) as Map<String, dynamic>;
    return MastodonPreferences.fromJson(json);
  }
}

// vim: set ts=2 sw=2 sts=2 et:
