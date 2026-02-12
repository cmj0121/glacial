// The extensions implementation for the glacial feature.
import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';

export 'api/account.dart';
export 'api/admin.dart';
export 'api/announcements.dart';
export 'api/conversations.dart';
export 'api/auth.dart';
export 'api/filters.dart';
export 'api/list.dart';
export 'api/marker.dart';
export 'api/media.dart';
export 'api/notifications.dart';
export 'api/report.dart';
export 'api/search.dart';
export 'api/status.dart';
export 'api/suggestions.dart';
export 'api/tags.dart';
export 'api/timeline.dart';
export 'api/trends.dart';

// The key for storing saved accounts list.
const String _keySavedAccounts = "saved_accounts";

// The key for tracking the active account composite key.
const String _keyActiveAccountKey = "active_account_key";

/// Returns `true` when [activeKey] belongs to [domain].
/// Prevents verifying tokens against the wrong server on domain switch.
@visibleForTesting
bool activeKeyMatchesDomain(String? activeKey, String? domain) {
  if (activeKey == null || domain == null) return true;
  return activeKey.startsWith('$domain@') || activeKey == domain;
}

extension AccessStatusExtension on Storage {
  // Load the access status from the storage.
  Future<AccessStatusSchema?> loadAccessStatus({WidgetRef? ref}) async {
    final String? json = await getString(AccessStatusSchema.key);
    AccessStatusSchema status = (json == null ? null : AccessStatusSchema.fromString(json)) ?? AccessStatusSchema();

    final String? domain = status.domain?.isNotEmpty == true ? status.domain : null;

    // Migrate old domain-only token keys to composite keys if needed.
    await _migrateTokenKeys(domain);

    // Load the active account key, falling back to finding a key for the domain.
    String? activeKey = await getString(_keyActiveAccountKey);
    // Skip activeKey if it belongs to a different domain — prevents
    // verifying an old token against the wrong server (which would 401
    // and destroy the old credentials).
    if (!activeKeyMatchesDomain(activeKey, domain)) {
      activeKey = null;
    }
    if (activeKey == null && domain != null) {
      activeKey = await _findActiveKeyForDomain(domain);
    }

    final String? accessToken = await loadAccessToken(activeKey);
    AccountSchema? account;
    String? validToken = accessToken;

    try {
      account = await status.getAccountByAccessToken(accessToken);
    } on HttpException catch (e) {
      if (e.isUnauthorized && activeKey != null) {
        logger.w("token revoked/expired for key: $activeKey, cleaning up credentials");
        await removeAccessToken(activeKey);
        await removeSavedAccount(activeKey);
        await remove(_keyActiveAccountKey);
        validToken = null;
      }
    }

    // After fetching account, ensure composite key is saved.
    if (account != null && domain != null && accessToken != null) {
      final String compositeKey = '$domain@${account.id}';
      if (activeKey != compositeKey) {
        await saveAccessToken(compositeKey, accessToken);
        if (activeKey != null && activeKey != compositeKey) {
          await removeAccessToken(activeKey);
        }
        activeKey = compositeKey;
      }
      await setString(_keyActiveAccountKey, compositeKey);
      await addSavedAccount(SavedAccountSchema(
        domain: domain,
        accountId: account.id,
        username: account.acct,
        displayName: account.displayName,
        avatar: account.avatar,
        lastUsed: DateTime.now(),
      ));
    }

    final ServerSchema? server = await ServerSchema.fetch(domain);
    final List<EmojiSchema> emojis = await status.fetchCustomEmojis();

    status = status.copyWith(accessToken: validToken, account: account, server: server, emojis: emojis);

    if (ref?.context.mounted ?? false) {
      ref?.read(accessStatusProvider.notifier).state = status;
    }

    return status;
  }

  // Migrate old domain-only token keys to composite format.
  Future<void> _migrateTokenKeys(String? domain) async {
    if (domain == null) return;

    final String? body = await getString(AccessStatusSchema.keyAccessToken, secure: true);
    final Map<String, dynamic> json = jsonDecode(body ?? '{}');

    // Check if domain key exists without '@' (old format).
    if (json.containsKey(domain) && !domain.contains('@')) {
      final String? token = json[domain] as String?;
      if (token != null) {
        logger.i("migrating token key from domain-only: $domain");
        // Keep old key for now — it will be replaced in loadAccessStatus
        // after account is fetched and compositeKey is known.
      }
    }
  }

  // Find an active key for the given domain from the token map.
  Future<String?> _findActiveKeyForDomain(String domain) async {
    final String? body = await getString(AccessStatusSchema.keyAccessToken, secure: true);
    final Map<String, dynamic> json = jsonDecode(body ?? '{}');

    // First try composite keys for this domain.
    for (final key in json.keys) {
      if (key.startsWith('$domain@')) return key;
    }

    // Fall back to plain domain key (pre-migration).
    if (json.containsKey(domain)) return domain;

    return null;
  }

  // Save the access status to the storage.
  Future<void> saveAccessStatus(AccessStatusSchema schema, {WidgetRef? ref}) async {
    final String json = jsonEncode(schema.toJson());
    await setString(AccessStatusSchema.key, json);

    if (ref?.context.mounted ?? false) {
      ref?.read(accessStatusProvider.notifier).state = schema;
    }
  }

  // Save the access token using the given key (composite key or domain).
  Future<void> saveAccessToken(String key, String? accessToken) async {
    final String? body = await getString(AccessStatusSchema.keyAccessToken, secure: true);
    final Map<String, dynamic> json = jsonDecode(body ?? '{}');

    if (accessToken == null || accessToken.isEmpty) {
      json.remove(key);
      logger.i("remove access token for key: $key");
    } else {
      json[key] = accessToken;
      logger.i("save access token for key: $key");
    }

    await setString(AccessStatusSchema.keyAccessToken, jsonEncode(json), secure: true);
  }

  // Load the access token for the given key from the storage.
  Future<String?> loadAccessToken(String? key) async {
    if (key == null || key.isEmpty) {
      return null;
    }

    final String? body = await getString(AccessStatusSchema.keyAccessToken, secure: true);
    final Map<String, dynamic> json = jsonDecode(body ?? '{}');

    return json[key] as String?;
  }

  // Remove the access token for the given key from the storage.
  Future<void> removeAccessToken(String? key) async {
    if (key == null || key.isEmpty) {
      return;
    }

    final String? body = await getString(AccessStatusSchema.keyAccessToken, secure: true);
    final Map<String, dynamic> json = jsonDecode(body ?? '{}');

    json.remove(key);
    await setString(AccessStatusSchema.keyAccessToken, jsonEncode(json), secure: true);
  }

  // Load all saved accounts from storage.
  Future<List<SavedAccountSchema>> loadSavedAccounts() async {
    final String? body = await getString(_keySavedAccounts);
    if (body == null || body.isEmpty) return [];

    final List<dynamic> list = jsonDecode(body) as List<dynamic>;
    return list
        .map((e) => SavedAccountSchema.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Add or update a saved account in the list (matched by compositeKey).
  Future<void> addSavedAccount(SavedAccountSchema account) async {
    final List<SavedAccountSchema> accounts = await loadSavedAccounts();
    final int index = accounts.indexWhere((a) => a.compositeKey == account.compositeKey);

    if (index >= 0) {
      accounts[index] = account;
    } else {
      accounts.add(account);
    }

    await _saveSavedAccounts(accounts);
  }

  // Remove a saved account by composite key and its associated token.
  Future<void> removeSavedAccount(String compositeKey) async {
    final List<SavedAccountSchema> accounts = await loadSavedAccounts();
    accounts.removeWhere((a) => a.compositeKey == compositeKey);
    await _saveSavedAccounts(accounts);
    await removeAccessToken(compositeKey);
  }

  // Persist the saved accounts list to storage.
  Future<void> _saveSavedAccounts(List<SavedAccountSchema> accounts) async {
    final String json = jsonEncode(accounts.map((a) => a.toJson()).toList());
    await setString(_keySavedAccounts, json);
  }

  // Switch to a previously saved account.
  Future<void> switchToAccount(SavedAccountSchema saved, {WidgetRef? ref}) async {
    final String? accessToken = await loadAccessToken(saved.compositeKey);
    if (accessToken == null) {
      logger.w("no token found for account: ${saved.compositeKey}");
      return;
    }

    // Build a temporary AccessStatusSchema to fetch account data.
    AccessStatusSchema status = AccessStatusSchema(domain: saved.domain);
    AccountSchema? account;

    try {
      account = await status.getAccountByAccessToken(accessToken);
    } on HttpException catch (e) {
      if (e.isUnauthorized) {
        logger.w("token revoked/expired for account: ${saved.compositeKey}, cleaning up");
        await removeSavedAccount(saved.compositeKey);
        return;
      }
    }

    if (account == null) {
      logger.w("failed to verify account: ${saved.compositeKey}");
      return;
    }

    final ServerSchema? server = await ServerSchema.fetch(saved.domain);
    final List<EmojiSchema> emojis = await status.fetchCustomEmojis();

    // Preserve history from current status.
    final String? currentJson = await getString(AccessStatusSchema.key);
    final AccessStatusSchema? current = currentJson != null ? AccessStatusSchema.fromString(currentJson) : null;

    status = status.copyWith(
      accessToken: accessToken,
      account: account,
      server: server,
      emojis: emojis,
      history: current?.history ?? [],
    );

    await saveAccessStatus(status, ref: ref);
    await setString(_keyActiveAccountKey, saved.compositeKey);

    // Update lastUsed timestamp.
    await addSavedAccount(saved.copyWith(lastUsed: DateTime.now()));
  }

  // Logout the current Mastodon server.
  Future<void> logout(AccessStatusSchema? schema, {WidgetRef? ref}) async {
    await schema?.revokeAccessToken(domain: schema.domain, token: schema.accessToken);

    // Remove token by composite key if available.
    final String? activeKey = await getString(_keyActiveAccountKey);
    await removeAccessToken(activeKey ?? schema?.domain);

    // Remove the saved account entry.
    if (activeKey != null) {
      await removeSavedAccount(activeKey);
    }

    // Check if another account exists on the same domain to switch to.
    final List<SavedAccountSchema> accounts = await loadSavedAccounts();
    final SavedAccountSchema? nextAccount = schema?.domain != null
        ? accounts
            .where((a) => a.domain == schema!.domain)
            .fold<SavedAccountSchema?>(null, (prev, a) =>
                prev == null || a.lastUsed.isAfter(prev.lastUsed) ? a : prev)
        : null;

    if (nextAccount != null) {
      // Switch to the most recently used account on the same domain.
      final String? nextToken = await loadAccessToken(nextAccount.compositeKey);
      if (nextToken != null) {
        await switchToAccount(nextAccount, ref: ref);
        return;
      }
    }

    // No other accounts — reset to explorer.
    final AccessStatusSchema status = AccessStatusSchema().copyWith(
      domain: schema?.domain,
      history: schema?.history ?? [],
    );

    await remove(_keyActiveAccountKey);
    await saveAccessStatus(status, ref: ref);
  }
}

// vim: set ts=2 sw=2 sts=2 et:
