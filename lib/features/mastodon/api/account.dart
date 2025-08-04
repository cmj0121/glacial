// The Account APIs for the mastdon server.
//
// ## Account APIs
//
//   - [ ] POST  /api/v1/accounts
//   - [+] GET   /api/v1/accounts/verify_credentials
//   - [ ] PATCH /api/v1/accounts/update_credentials
//   - [ ] GET   /api/v1/accounts/:id
//   - [ ] GET   /api/v1/accounts
//   - [ ] GET   /api/v1/accounts/:id/statuses
//   - [ ] GET   /api/v1/accounts/:id/followers
//   - [ ] GET   /api/v1/accounts/:id/following
//   - [ ] GET   /api/v1/accounts/:id/featured_tags
//   - [ ] GET   /api/v1/accounts/:id/lists
//   - [ ] POST  /api/v1/accounts/:id/follow
//   - [ ] POST  /api/v1/accounts/:id/unfollow
//   - [ ] POST  /api/v1/accounts/:id/remove_from_followers
//   - [ ] POST  /api/v1/accounts/:id/block
//   - [ ] POST  /api/v1/accounts/:id/unbloc
//   - [ ] POST  /api/v1/accounts/:id/mute
//   - [ ] POST  /api/v1/accounts/:id/unmute
//   - [ ] POST  /api/v1/accounts/:id/pin                    (deprecated in 4.4.0)
//   - [ ] POST  /api/v1/accounts/:id/unpin                  (deprecated in 4.4.0)
//   - [ ] GET   /api/v1/accounts/:id/endorsements
//   - [ ] POST  /api/v1/accounts/:id/endorse
//   - [ ] POST  /api/v1/accounts/:id/unendorse
//   - [ ] POST  /api/v1/accounts/:id/note
//   - [ ] GET   /api/v1/accounts/relationships
//   - [ ] GET   /api/v1/accounts/familiar_followers
//   - [ ] GET   /api/v1/accounts/search
//   - [ ] GET   /api/v1/accounts/lookup
//   - [ ] GET   /api/v1/accounts/:id/identity_proofs        (deprecated in 3.5.0)
//
// ref:
//   - https://docs.joinmastodon.org/methods/accounts/
import 'dart:async';
import 'dart:convert';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';

// The in-memory account cache per Mastodon server, per account ID.
final Map<String?, Map<String, AccountSchema>> _accountCache = {};

extension AccountsExtensions on AccessStatusSchema {
  // Get the account data schema from the Mastodon server by account ID, return null
  // if the account does not exist or the request fails.
  Future<AccountSchema?> getAccount(String? accountID) async {
    if (accountID == null || accountID.isEmpty) {
      return null;
    }

    // Check if the account is already cached.
    final AccountSchema? cachedAccount = lookupAccount(accountID);
    if (cachedAccount != null) {
      return cachedAccount;
    }

    final String endpoint = '/api/v1/accounts/$accountID';
    final String body = await getAPI(endpoint) ?? '{}';

    try {
      final Map<String, dynamic> json = jsonDecode(body) as Map<String, dynamic>;
      final AccountSchema account = AccountSchema.fromJson(json);

      logger.i("complete get the account from $accountID on $domain");
      cacheAccount(account);
      return account;
    } catch (e) {
      logger.d("failed to get or parse the account: $accountID, error: $e");
      return null;
    }
  }

  // Save the account data schema to the in-memory cache.
  void cacheAccount(AccountSchema account) {
    if (domain == null || domain?.isNotEmpty != true) {
      logger.w("server is not set, cannot save account: ${account.id}");
      return;
    }

    _accountCache[domain] ??= {};
    _accountCache[domain]?[account.id] = account;
  }

  // Get the account data schema from the in-memory cache by account ID.
  AccountSchema? lookupAccount(String accountID) {
    return _accountCache[domain]?[accountID];
  }

  // Get the account data schema from the access token.
  Future<AccountSchema?> getAccountByAccessToken(String? token) async {
    if (token == null || domain == null) {
      return null;
    }

    final Uri uri = UriEx.handle(domain!, "/api/v1/accounts/verify_credentials");
    final Map<String, String> headers = {"Authorization": "Bearer $token"};
    final response = await get(uri, headers: headers);
    try {
      final Map<String, dynamic> json = jsonDecode(response.body) as Map<String, dynamic>;
      final AccountSchema account = AccountSchema.fromJson(json);

      return account;
    } catch (e) {
      logger.w("failed to get account by access token: $token, error: $e");
      return null;
    }
  }

  // The raw action to interact with the account, such as follow, unfollow, block, or mute.
  Future<void> interactWithAcount(StatusSchema status) async {
    return;
  }
}

// vim: set ts=2 sw=2 sts=2 et:
