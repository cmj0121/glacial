// The extensions implementation for the glacial feature.
import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';

export 'api/account.dart';
export 'api/list.dart';
export 'api/marker.dart';
export 'api/media.dart';
export 'api/notifications.dart';
export 'api/search.dart';
export 'api/status.dart';
export 'api/suggestions.dart';
export 'api/tags.dart';
export 'api/timeline.dart';
export 'api/trends.dart';

extension AccessStatusExtension on Storage {
  // Load the access status from the storage.
  Future<AccessStatusSchema?> loadAccessStatus({WidgetRef? ref}) async {
    final String? json = await getString(AccessStatusSchema.key);
    AccessStatusSchema status = (json == null ? null : AccessStatusSchema.fromString(json)) ?? AccessStatusSchema();

    final String? domain = status.domain?.isNotEmpty == true ? status.domain : null;
    final String? accessToken = await loadAccessToken(domain);
    final AccountSchema? account = await status.getAccountByAccessToken(accessToken);
    final ServerSchema? server = await ServerSchema.fetch(domain);

    status = status.copyWith(accessToken: accessToken, account: account, server: server);

    if (ref?.context.mounted ?? false) {
      ref?.read(accessStatusProvider.notifier).state = status;
    }

    return status;
  }

  // Save the access status to the storage.
  Future<void> saveAccessStatus(AccessStatusSchema schema, {WidgetRef? ref}) async {
    final String json = jsonEncode(schema.toJson());
    await setString(AccessStatusSchema.key, json);

    if (ref?.context.mounted ?? false) {
      ref?.read(accessStatusProvider.notifier).state = schema;
    }
  }

  // Save the access token per domain to the storage.
  Future<void> saveAccessToken(String domain, String? accessToken) async {
    final String? body = await getString(AccessStatusSchema.keyAccessToken, secure: true);
    final Map<String, dynamic> json = jsonDecode(body ?? '{}');

    if (accessToken == null || accessToken.isEmpty) {
      // If the access token is null or empty, remove it from the storage.
      json.remove(domain);
      logger.i("remove access token for domain: $domain");
    } else {
      // add or update the access token for the domain.
      json[domain] = accessToken;
      logger.i("save access token for domain: $domain");
    }

    setString(AccessStatusSchema.keyAccessToken, jsonEncode(json), secure: true);
  }

  // Load the access token per domain from the storage.
  Future<String?> loadAccessToken(String? domain) async {
    if (domain == null || domain.isEmpty) {
      return null;
    }

    final String? body = await getString(AccessStatusSchema.keyAccessToken, secure: true);
    final Map<String, dynamic> json = jsonDecode(body ?? '{}');

    return json[domain] as String?;
  }

  // Remove the access token for the given domain from the storage.
  Future<void> removeAccessToken(String? domain) async {
    if (domain == null || domain.isEmpty) {
      return;
    }

    final String? body = await getString(AccessStatusSchema.keyAccessToken, secure: true);
    final Map<String, dynamic> json = jsonDecode(body ?? '{}');

    json.remove(domain);
    await setString(AccessStatusSchema.keyAccessToken, jsonEncode(json), secure: true);
  }


  // Logout the current Mastodon server.
  Future<void> logout(AccessStatusSchema? schema, {WidgetRef? ref}) async {
    final AccessStatusSchema status = AccessStatusSchema().copyWith(
      domain: schema?.domain,
      history: schema?.history ?? [],
    );

    await removeAccessToken(schema?.domain);

    if (ref?.context.mounted ?? false) {
      ref?.read(accessStatusProvider.notifier).state = status;
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
