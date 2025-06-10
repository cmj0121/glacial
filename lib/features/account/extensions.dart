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

    Storage().saveAccountIntoCache(this, account);
    return account;
  }
}

// The extension to the TimelineType enum to list the statuses per timeline type.
extension AccountCacheExtensions on Storage {
  // Try to load the account from the cache.
  AccountSchema? loadAccountFromCache(ServerSchema server, String? accountID) {
    return accountCache[server.domain]?[accountID];
  }

  // Save the account to the cache.
  void saveAccountIntoCache(ServerSchema server, AccountSchema? account) {
    if (account == null) {
      return;
    }

    accountCache[server.domain] ??= {};
    accountCache[server.domain]![account.id] = account;
  }

  // clear the account cache for the server.
  void pureAccountCache(ServerSchema server) {
    accountCache.remove(server.domain);
  }
}

// vim: set ts=2 sw=2 sts=2 et:
