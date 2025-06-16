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

  // Get the account by ID from the Mastodon server.
  Future<List<AccountSchema>> getAccounts(List<String> ids, {String? accessToken}) async {
    if (ids.isEmpty) {
      return [];
    }

    final Map<String, String> query = {'id[]': ids.join(',')};
    final Uri uri = UriEx.handle(domain, "/api/v1/accounts").replace(queryParameters: query);
    final Map<String, String> headers = {"Authorization": "Bearer $accessToken"};
    final response = await get(uri, headers: headers);

    if (response.statusCode != 200) {
      throw RequestError(response);
    }

    final List<dynamic> json = jsonDecode(response.body) as List<dynamic>;
    return json.map((e) => AccountSchema.fromJson(e as Map<String, dynamic>)).toList();
  }

  // Get the relationships of the accounts with the current user.
  Future<List<RelationshipSchema>> relationship({
    required String accessToken,
    required List<AccountSchema> accounts,
  }) async {
    final Map<String, String> query = {'id[]': accounts.map((e) => e.id).join(',')};
    final Uri uri = UriEx.handle(domain, "/api/v1/accounts/relationships").replace(queryParameters: query);
    final Map<String, String> headers = {"Authorization": "Bearer $accessToken"};
    final response = await get(uri, headers: headers);

    if (response.statusCode != 200) {
      throw RequestError(response);
    }

    final List<dynamic> json = jsonDecode(response.body) as List<dynamic>;
    return json.map((e) => RelationshipSchema.fromJson(e as Map<String, dynamic>)).toList();
  }

  // Follow the account from the Mastodon server.
  Future<RelationshipSchema> follow({required AccountSchema account, required String accessToken}) async {
    final Uri uri = UriEx.handle(domain, "/api/v1/accounts/${account.id}/follow");
    final Map<String, String> headers = {
      "Authorization": "Bearer $accessToken",
      "Content-Type": "application/json",
    };

    final response = await post(uri, headers: headers);
    if (response.statusCode != 200) {
      throw RequestError(response);
    }

    return RelationshipSchema.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  // Unfollow the account from the Mastodon server.
  Future<RelationshipSchema> unfollow({required AccountSchema account, required String accessToken}) async {
    final Uri uri = UriEx.handle(domain, "/api/v1/accounts/${account.id}/unfollow");
    final Map<String, String> headers = {
      "Authorization": "Bearer $accessToken",
      "Content-Type": "application/json",
    };

    final response = await post(uri, headers: headers);
    if (response.statusCode != 200) {
      throw RequestError(response);
    }

    return RelationshipSchema.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  // Block the account from the Mastodon server.
  Future<RelationshipSchema> block({required AccountSchema account, required String accessToken}) async {
    final Uri uri = UriEx.handle(domain, "/api/v1/accounts/${account.id}/block");
    final Map<String, String> headers = {
      "Authorization": "Bearer $accessToken",
      "Content-Type": "application/json",
    };

    final response = await post(uri, headers: headers);
    if (response.statusCode != 200) {
      throw RequestError(response);
    }

    return RelationshipSchema.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  // Unblock the account from the Mastodon server.
  Future<RelationshipSchema> unblock({required AccountSchema account, required String accessToken}) async {
    final Uri uri = UriEx.handle(domain, "/api/v1/accounts/${account.id}/unblock");
    final Map<String, String> headers = {
      "Authorization": "Bearer $accessToken",
      "Content-Type": "application/json",
    };

    final response = await post(uri, headers: headers);
    if (response.statusCode != 200) {
      throw RequestError(response);
    }

    return RelationshipSchema.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  // Mute the account from the Mastodon server.
  Future<RelationshipSchema> mute({required AccountSchema account, required String accessToken}) async {
    final Uri uri = UriEx.handle(domain, "/api/v1/accounts/${account.id}/mute");
    final Map<String, String> headers = {
      "Authorization": "Bearer $accessToken",
      "Content-Type": "application/json",
    };

    final response = await post(uri, headers: headers);
    if (response.statusCode != 200) {
      throw RequestError(response);
    }

    return RelationshipSchema.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  // Unmute the account from the Mastodon server.
  Future<RelationshipSchema> unmute({required AccountSchema account, required String accessToken}) async {
    final Uri uri = UriEx.handle(domain, "/api/v1/accounts/${account.id}/unmute");
    final Map<String, String> headers = {
      "Authorization": "Bearer $accessToken",
      "Content-Type": "application/json",
    };

    final response = await post(uri, headers: headers);
    if (response.statusCode != 200) {
      throw RequestError(response);
    }

    return RelationshipSchema.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
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
