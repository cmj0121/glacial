// The extensions implementation for the glacial feature.
import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';

export 'api/account.dart';
export 'api/status.dart';
export 'api/suggestions.dart';
export 'api/timeline.dart';
export 'api/trends.dart';

extension AccessStatusExtension on Storage {
  // Load the access status from the storage.
  Future<AccessStatusSchema?> loadAccessStatus({WidgetRef? ref}) async {
    final String? json = await getString(AccessStatusSchema.key);
    AccessStatusSchema status = (json == null ? null : AccessStatusSchema.fromString(json)) ?? AccessStatusSchema();

    final String? domain = status.server?.isNotEmpty == true ? status.server : null;
    final String? accessToken = await loadAccessToken(domain);
    final AccountSchema? account = await status.getAccountByAccessToken(accessToken);

    status = status.copyWith(accessToken: accessToken, account: account);
    ref?.read(accessStatusProvider.notifier).state = status;

    logger.d("load access status: ${status.server}");
    return status;
  }

  // Save the access status to the storage.
  Future<void> saveAccessStatus(AccessStatusSchema schema, {WidgetRef? ref}) async {
    final String json = jsonEncode(schema.toJson());
    await setString(AccessStatusSchema.key, json);

    ref?.read(accessStatusProvider.notifier).state = schema;
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
}

// vim: set ts=2 sw=2 sts=2 et:
