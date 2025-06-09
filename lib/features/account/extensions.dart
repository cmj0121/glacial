// The extensions implementation for the account schema.
import 'dart:async';
import 'dart:convert';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';

// The in-memory cache
Map<String, Map<String, AccountSchema>> accountCache = {};

// The extension to the TimelineType enum to list the statuses per timeline type.
extension AccountExtensions on ServerSchema {
  // Get the authenticated user account.
  Future<AccountSchema?> getUserByAccessToken(String? token) async {
    if (token == null) {
      return null;
    }

    final Uri uri = UriEx.handle(domain, "/api/v1/accounts/verify_credentials");
    final Map<String, String> headers = {"Authorization": "Bearer $token"};
    final response = await get(uri, headers: headers);

    if (response.statusCode != 200) {
      throw RequestError(response);
    }

    final Map<String, dynamic> json = jsonDecode(response.body) as Map<String, dynamic>;
    final AccountSchema account = AccountSchema.fromJson(json);

    await saveAccount(account);
    return account;
  }

  Future<AccountSchema?> loadAccount(String? accountID) async {
    return Storage().loadAccountFromCache(this, accountID);
  }

  Future<void> saveAccount(AccountSchema? account) async {
    if (account == null) {
      return;
    }

    await Storage().saveAccountIntoCache(this, account);
  }
}

// The extension to the TimelineType enum to list the statuses per timeline type.
extension AccountCacheExtensions on Storage {
  // Try to load the account from the cache.
  Future<AccountSchema?> loadAccountFromCache(ServerSchema server, String? accountID) async {
    return accountCache[server.domain]?[accountID];
  }

  // Save the account to the cache.
  Future<void> saveAccountIntoCache(ServerSchema server, AccountSchema? account) async {
    if (account == null) {
      return;
    }

    accountCache[server.domain] ??= {};
    accountCache[server.domain]![account.id] = account;
  }
}

// vim: set ts=2 sw=2 sts=2 et:
