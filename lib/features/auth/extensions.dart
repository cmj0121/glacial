// The extensions implementation for the OAuth2 application.
import 'dart:async';
import 'dart:convert';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';

/// A cache entry with TTL support for OAuth state management.
class _StateCacheEntry {
  final String server;
  final DateTime expiresAt;

  _StateCacheEntry(this.server, {Duration ttl = const Duration(minutes: 10)})
      : expiresAt = DateTime.now().add(ttl);

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

// The OAuth sign-in in-memory state cache that hold the random state-server mapping.
final Map<String, _StateCacheEntry> _stateCache = {};

// SharedPreferences key for persisted OAuth state (mobile app restart resilience).
const String _keyPendingAuth = "pending_oauth_auth";

/// Clean up expired entries from the state cache.
void _cleanupStateCache() {
  _stateCache.removeWhere((_, entry) => entry.isExpired);
}

// Extend the Storage that can be used to access the Mastodon server by get/set servers.
extension AuthExtension on Storage {
  // Get or create the OAuth2Info from the storage based on the domain.
  Future<OAuth2Info> getOAuth2Info(String domain) async {
    late OAuth2Info? info;

    info = await loadOAuth2Info(domain);
    if (info == null) {
      info = await OAuth2Info.register(domain);
      await saveOAuth2Info(domain, info);
    }

    return info;
  }

  // Load the OAuth2Info from the storage based on the domain.
  Future<OAuth2Info?> loadOAuth2Info(String domain) async {
    final String? body = await getString(OAuth2Info.prefsOAuthInfoKey, secure: true);
    final Map<String, dynamic> json = jsonDecode(body ?? '{}');
    final Map<String, dynamic>? server = json[domain] as Map<String, dynamic>?;

    return server == null ? null : OAuth2Info.fromJson(server);
  }

  // Save the OAuth2Info to the storage based on the domain.
  Future<void> saveOAuth2Info(String domain, OAuth2Info info) async {
    final String? body = await getString(OAuth2Info.prefsOAuthInfoKey, secure: true);
    final Map<String, dynamic> json = jsonDecode(body ?? '{}');

    json[domain] = info.toJson();
    await setString(OAuth2Info.prefsOAuthInfoKey, jsonEncode(json), secure: true);
  }

  // Save the state-server mapping to in-memory cache and persistent storage.
  Future<void> saveStateServer(String state, String server) async {
    _cleanupStateCache();
    _stateCache[state] = _StateCacheEntry(server);

    // Persist for mobile app restart resilience — if the OS reclaims the app
    // during OAuth, the state can be recovered from SharedPreferences.
    await setString(_keyPendingAuth, jsonEncode({
      'state': state,
      'server': server,
      'expiresAt': DateTime.now().add(const Duration(minutes: 10)).toIso8601String(),
    }));
  }

  // Gain the access token from the redirect URI and state.
  Future<String?> gainAccessToken({String? expectedServer, required Uri uri}) async {
    final String? code = uri.queryParameters["code"];
    final String? state = uri.queryParameters["state"];

    final Storage storage = Storage();
    _cleanupStateCache();
    _StateCacheEntry? entry = state != null ? _stateCache[state] : null;

    // Fall back to persisted state if in-memory cache was lost (e.g., app
    // restarted by OS during OAuth flow on mobile).
    if (entry == null && state != null) {
      final String? body = await getString(_keyPendingAuth);
      if (body != null) {
        final Map<String, dynamic> persisted = jsonDecode(body) as Map<String, dynamic>;
        if (persisted['state'] == state) {
          final DateTime expiresAt = DateTime.parse(persisted['expiresAt'] as String);
          if (DateTime.now().isBefore(expiresAt)) {
            entry = _StateCacheEntry(persisted['server'] as String);
          }
        }
      }
    }

    final String? server = entry?.isExpired == false ? entry?.server : null;

    // Clean up used state from both caches.
    if (state != null) _stateCache.remove(state);
    await remove(_keyPendingAuth);

    if (server == null || code == null || server != expectedServer) {
      logger.w("unexpected expected: server=$server, code=$code");
      return null;
    }

    final OAuth2Info info = await storage.getOAuth2Info(server);
    final String? accessToken = await info.getAccessToken(server, code);

    // confirm the access token work.
    final Uri verifyUri = UriEx.handle(server, "/api/v1/apps/verify_credentials");
    final Map<String, String> headers = {"Authorization": "Bearer $accessToken"};
    await get(verifyUri, headers: headers);

    logger.i("gain access token and verify credentials for server: $server");
    return accessToken;
  }
}

// Extend the OAuth2Info to gain the access token from the grant code.
extension AccessTokenExtension on OAuth2Info {
  Future<String?> getAccessToken(String domain, String code) async {
    final Storage storage = Storage();
    final Map<String, dynamic> body = {
      "client_id": clientId,
      "client_secret": clientSecret,
      "code": code,
      "grant_type": "authorization_code",
      "redirect_uri": redirectUri,
    }
        ..removeWhere((key, value) => value == null);

    final Uri uri = UriEx.handle(domain, "/oauth/token");
    final response = await post(uri, body: jsonEncode(body), headers: {
      "Content-Type": "application/json",
    });

    if (response.statusCode != 200) {
      throw Exception("failed to get access token from $domain: ${response.statusCode} ${response.body}");
    }

    final Map<String, dynamic> json = jsonDecode(response.body) as Map<String, dynamic>;
    final String? accessToken = json['access_token'] as String?;

    await storage.saveAccessToken(domain, accessToken);
    return accessToken;
  }
}

// vim: set ts=2 sw=2 sts=2 et:
