// The Account APIs for the mastdon server.
//
// ## Account APIs
//
//   - [ ] POST  /api/v1/accounts
//   - [+] GET   /api/v1/accounts/verify_credentials
//   - [ ] PATCH /api/v1/accounts/update_credentials
//   - [ ] GET   /api/v1/accounts/:id
//   - [ ] GET   /api/v1/accounts
//   - [+] GET   /api/v1/accounts/:id/statuses
//   - [ ] GET   /api/v1/accounts/:id/followers
//   - [ ] GET   /api/v1/accounts/:id/following
//   - [ ] GET   /api/v1/accounts/:id/featured_tags
//   - [ ] GET   /api/v1/accounts/:id/lists
//   - [+] POST  /api/v1/accounts/:id/follow
//   - [+] POST  /api/v1/accounts/:id/unfollow
//   - [ ] POST  /api/v1/accounts/:id/remove_from_followers
//   - [+] POST  /api/v1/accounts/:id/block
//   - [+] POST  /api/v1/accounts/:id/unbloc
//   - [+] POST  /api/v1/accounts/:id/mute
//   - [+] POST  /api/v1/accounts/:id/unmute
//   - [ ] POST  /api/v1/accounts/:id/pin                    (deprecated in 4.4.0)
//   - [ ] POST  /api/v1/accounts/:id/unpin                  (deprecated in 4.4.0)
//   - [ ] GET   /api/v1/accounts/:id/endorsements
//   - [ ] POST  /api/v1/accounts/:id/endorse
//   - [ ] POST  /api/v1/accounts/:id/unendorse
//   - [ ] POST  /api/v1/accounts/:id/note
//   - [+] GET   /api/v1/accounts/relationships
//   - [ ] GET   /api/v1/accounts/familiar_followers
//   - [ ] GET   /api/v1/accounts/search
//   - [ ] GET   /api/v1/accounts/lookup
//   - [ ] GET   /api/v1/accounts/:id/identity_proofs        (deprecated in 3.5.0)
//
// ## Mute APIs
//
//   - [ ] GET   /api/v1/mutes
//
// ## Block APIs
//
//   - [ ] GET   /api/v1/blocks
//
// ref:
//   - https://docs.joinmastodon.org/methods/accounts/
//   - https://docs.joinmastodon.org/methods/mutes/
//   - https://docs.joinmastodon.org/methods/blocks/
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
    final Map<String, dynamic> json = jsonDecode(body) as Map<String, dynamic>;
    final AccountSchema account = AccountSchema.fromJson(json);

    logger.i("complete get the account from $accountID on $domain");
    cacheAccount(account);
    return account;
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

  // Get the account timeline by account ID, return the list of statuses.
  Future<List<StatusSchema>> fetchAccountTimeline({AccountSchema? account, String? maxId, bool? pinned}) async {
    if (account == null) {
      logger.w("account is not set, cannot fetch the timeline.");
      return [];
    }

    final Map<String, String> query = {"max_id": maxId ?? "", "pinned": pinned == true ? "true" : "false"};
    final String endpoint = '/api/v1/accounts/${account.id}/statuses';

    final String body = await getAPI(endpoint, queryParameters: query) ?? '[]';
    final List<dynamic> json = jsonDecode(body) as List<dynamic>;
    final List<StatusSchema> status = json.map((e) => StatusSchema.fromJson(e)).toList();

    // save the related info to the in-memory cache.
    status.map((s) => cacheAccount(s.account)).toList();
    status.map((s) async => await getAccount(s.inReplyToAccountID)).toList();

    logger.d("complete load the account timelnie: ${status.length}");
    return status;
  }

  // Get the account be muted by account ID, return the list of accounts.
  Future<(List<AccountSchema>, String?)> fetchMutedAccounts({String? maxId}) async {
    if (isSignedIn == false) {
      throw Exception("You must be signed in to fetch muted accounts.");
    }

    final Map<String, String> query = {"max_id": maxId ?? ""};
    final String endpoint = '/api/v1/mutes';
    final (body, nextId) = await getAPIEx(endpoint, queryParameters: query);
    final List<dynamic> json = jsonDecode(body) as List<dynamic>;
    final List<AccountSchema> accounts = json.map((e) => AccountSchema.fromJson(e as Map<String, dynamic>)).toList();

    logger.d("complete load the muted accounts: ${accounts.length}");
    accounts.map((a) => cacheAccount(a)).toList();
    return (accounts, nextId);
  }

  // Get the account be blocked by account ID, return the list of accounts.
  Future<(List<AccountSchema>, String?)> fetchBlockedAccounts({String? maxId}) async {
    if (isSignedIn == false) {
      throw Exception("You must be signed in to fetch blocked accounts.");
    }

    final Map<String, String> query = {"max_id": maxId ?? ""};
    final String endpoint = '/api/v1/blocks';
    final (body, nextId) = await getAPIEx(endpoint, queryParameters: query);
    final List<dynamic> json = jsonDecode(body) as List<dynamic>;
    final List<AccountSchema> accounts = json.map((e) => AccountSchema.fromJson(e as Map<String, dynamic>)).toList();

    logger.d("complete load the muted accounts: ${accounts.length}");
    accounts.map((a) => cacheAccount(a)).toList();
    return (accounts, nextId);
  }

  // Check relationships to other accounts
  Future<List<RelationshipSchema>> fetchRelationships(List<AccountSchema> accounts) async {
    if (accounts.isEmpty) {
      return [];
    }

    final String endpoint = '/api/v1/accounts/relationships';
    final Map<String, String> query = {"id[]": accounts.map((e) => e.id).join(',')};
    final String body = await getAPI(endpoint, queryParameters: query) ?? '[]';
    final List<dynamic> json = jsonDecode(body) as List<dynamic>;
    final List<RelationshipSchema> relationships = json.map((e) => RelationshipSchema.fromJson(e as Map<String, dynamic>)).toList();

    logger.d("complete load the relationships: ${relationships.length}");
    return relationships;
  }

  // Change the relationship of the account, such as follow, unfollow, block, or mute.
  Future<RelationshipSchema?> changeRelationship({required AccountSchema account, required RelationshipType type}) async {
    late final String endpoint;

    switch (type) {
      case RelationshipType.following:
      case RelationshipType.followEachOther:
        endpoint = '/api/v1/accounts/${account.id}/unfollow';
        break;
      case RelationshipType.followedBy:
      case RelationshipType.stranger:
        endpoint = '/api/v1/accounts/${account.id}/follow';
        break;
      case RelationshipType.mute:
        endpoint = '/api/v1/accounts/${account.id}/mute';
        break;
      case RelationshipType.unmute:
        endpoint = '/api/v1/accounts/${account.id}/unmute';
        break;
      case RelationshipType.block:
        endpoint = '/api/v1/accounts/${account.id}/block';
        break;
      case RelationshipType.unblock:
        endpoint = '/api/v1/accounts/${account.id}/unblock';
        break;
      default:
        throw Exception("Unsupported relationship type: $type");
    }

    final String body = await postAPI(endpoint) ?? '{}';
    final Map<String, dynamic> json = jsonDecode(body) as Map<String, dynamic>;
    final RelationshipSchema relationship = RelationshipSchema.fromJson(json);

    logger.i("complete change the relationship to ${relationship.type} for account: ${account.id}");
    return relationship;
  }
}

// vim: set ts=2 sw=2 sts=2 et:
