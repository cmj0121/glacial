// The Status for the mastdon server.
//
// ## Status APIs
//
//    - [+] POST   /api/v1/statuses
//    - [+] GET    /api/v1/statuses/:id
//    - [ ] GET    /api/v1/statuses
//    - [+] DELETE /api/v1/statuses/:id
//    - [+] GET    /api/v1/statuses/:id/context
//    - [ ] POST   /api/v1/statuses/:id/translate
//    - [+] GET    /api/v1/statuses/:id/reblogged_by
//	  - [+] GET    /api/v1/statuses/:id/favourited_by
//    - [+] POST   /api/v1/statuses/:id/favourite
//    - [+] POST   /api/v1/statuses/:id/unfavourite
//    - [+] POST   /api/v1/statuses/:id/reblog
//    - [+] POST   /api/v1/statuses/:id/unreblog
//    - [+] POST   /api/v1/statuses/:id/bookmark
//    - [+] POST   /api/v1/statuses/:id/unbookmark
//    - [ ] POST   /api/v1/statuses/:id/mute
//    - [ ] POST   /api/v1/statuses/:id/unmute
//    - [ ] POST   /api/v1/statuses/:id/pin
//    - [ ] POST   /api/v1/statuses/:id/unpin
//    - [ ] PUT    /api/v1/statuses/:id
//    - [+] GET    /api/v1/statuses/:id/history
//    - [ ] GET    /api/v1/statuses/:id/source
//    - [-] GET    /api/v1/statuses/:id/card            (deprecated in 3.0.0)
//
// ## Scheduled Status APIs
//
//    - [ ] GET    /api/v1/scheduled_statuses
//    - [ ] POST   /api/v1/scheduled_statuses
//    - [ ] GET    /api/v1/scheduled_statuses/:id
//    - [ ] DELETE /api/v1/scheduled_statuses/:id
//    - [ ] PUT    /api/v1/scheduled_statuses/:id
//
// ## Votes APIs
//
//    - [ ] GET    /api/v1/polls/:id
//    - [ ] POST   /api/v1/polls/:id/votes
//
// ref:
//   - https://docs.joinmastodon.org/methods/statuses/
//   - https://docs.joinmastodon.org/methods/scheduled_statuses/
//   - https://docs.joinmastodon.org/methods/polls/
import 'dart:async';
import 'dart:convert';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';

// The cached status in-memory per server.
final Map<String?, Map<String, StatusSchema>> statusCache = {};

extension StatusExtensions on AccessStatusSchema {
  // Load the status from the in-memory cache by the given status ID.
  StatusSchema? getStatusFromCache(String statusID) {
    return statusCache[domain]?[statusID];
  }

  // Save the status to the in-memory cache.
  void saveStatusToCache(StatusSchema status) {
    statusCache.putIfAbsent(domain, () => {});
    statusCache[domain]![status.id] = status;
  }

  // Create a new status on the Mastodon server with the given content and media.
  Future<StatusSchema> createStatus({
    required PostStatusSchema schema,
    required String idempotentKey,
    required AccountSchema account,
  }) async {
    final String endpoint = '/api/v1/statuses';
    final Map<String, String> headers = {
      'Idempotency-Key': idempotentKey,
    };

    final String body = await postAPI(endpoint, body: schema.toJson(), headers: headers) ?? '{}';
    final Map<String, dynamic> json = jsonDecode(body) as Map<String, dynamic>;
    return schema.scheduledAt == null ? StatusSchema.fromJson(json) : StatusSchema.fromScheduleJson(json, account);
  }

  // Edit the exists status on the Mastodon server with the given content and media.
  Future<StatusSchema> editStatus({
    required String id,
    required PostStatusSchema schema,
    required String idempotentKey,
    required AccountSchema account,
  }) async {
    final String endpoint = schema.scheduledAt == null ? '/api/v1/statuses/$id' : '/api/v1/scheduled_statuses/$id';
    final Map<String, String> headers = {
      'Idempotency-Key': idempotentKey,
    };

    final String body = await putAPI(endpoint, body: schema.toJson(), headers: headers) ?? '{}';
    final Map<String, dynamic> json = jsonDecode(body) as Map<String, dynamic>;
    return schema.scheduledAt == null ? StatusSchema.fromJson(json) : StatusSchema.fromScheduleJson(json, account);
  }

  // Get the status data schema from the Mastodon server by status ID, return null
  // if the status does not exist or the request fails.
  Future<StatusSchema?> getStatus(String? statusID, {bool loadCache=false}) async {
    if (statusID == null || statusID.isEmpty) {
      return null;
    }

    if (loadCache) {
      final StatusSchema? cachedStatus = getStatusFromCache(statusID);
      if (cachedStatus != null) {
        return cachedStatus;
      }
    }

    final String endpoint = '/api/v1/statuses/$statusID';
    final String body = await getAPI(endpoint) ?? '{}';
    final StatusSchema status = StatusSchema.fromString(body);

    saveStatusToCache(status);
    return status;
  }

  // Delete the status by the given status ID, return the deleted status
  // schema if the deletion was successful, or null if the status does not exist.
  Future<StatusSchema?> deleteStatus(StatusSchema schema) async {
    switch (schema.scheduledAt) {
      case null:
        final String endpoint = '/api/v1/statuses/${schema.id}';
        final String? body = await deleteAPI(endpoint);
        return body == null ? null : StatusSchema.fromString(body);
      default:
        final String endpoint = '/api/v1/scheduled_statuses/${schema.id}';
        await deleteAPI(endpoint);
        return null;
    }
  }

  // The raw action to interact with the status, such as reblog, favourite, or delete.
  Future<StatusSchema> interactWithStatus(StatusSchema status, StatusInteraction action, {bool? negative}) async {
    checkSignedIn();

    final bool isNegative = negative ?? false;
    late final String endpoint;

    switch (action) {
      case StatusInteraction.reblog:
        endpoint = isNegative ? '/api/v1/statuses/${status.id}/unreblog' : '/api/v1/statuses/${status.id}/reblog';
        break;
      case StatusInteraction.favourite:
        endpoint = isNegative ? '/api/v1/statuses/${status.id}/unfavourite' : '/api/v1/statuses/${status.id}/favourite';
        break;
      case StatusInteraction.bookmark:
        endpoint = isNegative ? '/api/v1/statuses/${status.id}/unbookmark' : '/api/v1/statuses/${status.id}/bookmark';
        break;
      default:
        throw ArgumentError('Unsupported status interaction: $action (negative: $isNegative)');
    }

    final String body = await postAPI(endpoint) ?? '{}';
    return StatusSchema.fromString(body);
  }

  // View statuses above and below this status in the thread.
  Future<StatusContextSchema> getStatusContext({required StatusSchema schema}) async {
    final String endpoint = '/api/v1/statuses/${schema.id}/context';
    final String body = await getAPI(endpoint) ?? '{}';
    return StatusContextSchema.fromString(body);
  }

  // List the scheduled statuses on the Mastodon server.
  Future<List<StatusSchema>> fetchScheduledStatuses({required AccountSchema account, String? maxId}) async {
    if (isSignedIn == false) {
      throw Exception("You must be signed in to fetch scheduled statuses.");
    }

    final Map<String, String> query = {"max_id": maxId ?? ""};
    final String endpoint = '/api/v1/scheduled_statuses';
    final String body = await getAPI(endpoint, queryParameters: query) ?? '[]';
    final List<dynamic> json = jsonDecode(body) as List<dynamic>;
    final List<StatusSchema> status = json.map((e) => StatusSchema.fromScheduleJson(e, account)).toList();

    // save the related info to the in-memory cache.
    status.map((s) => cacheAccount(s.account)).toList();
    status.map((s) async => await getAccount(s.inReplyToAccountID)).toList();

    logger.d("complete load the scheduled status timeline, count: ${status.length}");
    return status;
  }

  // List the accounts that have reblogged the given status.
  Future<List<AccountSchema>> fetchRebloggedBy({required StatusSchema schema}) async {
    final String endpoint = '/api/v1/statuses/${schema.id}/reblogged_by';
    final String body = await getAPI(endpoint) ?? '[]';
    final List<dynamic> json = jsonDecode(body) as List<dynamic>;
    final List<AccountSchema> accounts = json.map((e) => AccountSchema.fromJson(e)).toList();

    // save the related info to the in-memory cache.
    accounts.map((a) => cacheAccount(a)).toList();
    logger.d("complete load the reblogged by accounts, count: ${accounts.length}");
    return accounts;
  }

  // List the accounts that have favourited the given status.
  Future<List<AccountSchema>> fetchFavouritedBy({required StatusSchema schema}) async {
    final String endpoint = '/api/v1/statuses/${schema.id}/favourited_by';
    final String body = await getAPI(endpoint) ?? '[]';
    final List<dynamic> json = jsonDecode(body) as List<dynamic>;
    final List<AccountSchema> accounts = json.map((e) => AccountSchema.fromJson(e)).toList();

    // save the related info to the in-memory cache.
    accounts.map((a) => cacheAccount(a)).toList();
    logger.d("complete load the favourited by accounts, count: ${accounts.length}");
    return accounts;
  }

  // List the history of the given status.
  Future<List<StatusEditSchema>> fetchHistory({required StatusSchema schema}) async {
    final String endpoint = '/api/v1/statuses/${schema.id}/history';
    final String body = await getAPI(endpoint) ?? '[]';
    final List<dynamic> json = jsonDecode(body) as List<dynamic>;
    final List<StatusEditSchema> history = json.map((e) => StatusEditSchema.fromJson(e)).toList();

    logger.d("complete load the status history, count: ${history.length}");
    return history;
  }

  // View a poll attached to a status.
  Future<PollSchema?> getPoll({required String pollID}) async {
    if (pollID.isEmpty) {
      return null;
    }

    final String endpoint = '/api/v1/polls/$pollID';
    final String? body = await getAPI(endpoint);
    return body == null ? null : PollSchema.fromString(body);
  }

  // Vote on a poll attached to a status.
  Future<PollSchema> votePoll({required String pollID, required List<int> choices}) async {
    checkSignedIn();

    final String endpoint = '/api/v1/polls/$pollID/votes';
    final Map<String, dynamic> body = {'choices': choices};

    final String response = await postAPI(endpoint, body: body) ?? '{}';
    return PollSchema.fromString(response);
  }
}

// vim: set ts=2 sw=2 sts=2 et:
