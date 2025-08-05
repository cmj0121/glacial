// The Status for the mastdon server.
//
// ## Status APIs
//
//    - [+] POST   /api/v1/statuses
//    - [+] GET    /api/v1/statuses/:id
//    - [ ] GET    /api/v1/statuses
//    - [ ] DELETE /api/v1/statuses/:id
//    - [x] GET    /api/v1/statuses/:id/context
//    - [ ] POST   /api/v1/statuses/:id/translate
//    - [ ] GET    /api/v1/statuses/:id/reblogged_by
//	  - [ ] GET    /api/v1/statuses/:id/favourited_by
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
//    - [ ] GET    /api/v1/statuses/:id/history
//    - [ ] GET    /api/v1/statuses/:id/source
//    - [-] GET    /api/v1/statuses/:id/card            (deprecated in 3.0.0)
//
// ref:
//   - https://docs.joinmastodon.org/methods/statuses/
import 'dart:async';

import 'package:glacial/features/models.dart';

extension StatusExtensions on AccessStatusSchema {
  // Create a new status on the Mastodon server with the given content and media.
  Future<StatusSchema> createStatus({required PostStatusSchema schema, required String idempotentKey}) async {
    final String endpoint = '/api/v1/statuses';
    final Map<String, String> headers = {
      'Idempotency-Key': idempotentKey,
    };

    final String body = await postAPI(endpoint, body: schema.toJson(), headers: headers) ?? '{}';
    return StatusSchema.fromString(body);
  }

  // Get the status data schema from the Mastodon server by status ID, return null
  // if the status does not exist or the request fails.
  Future<StatusSchema?> getStatus(String? statusID) async {
    if (statusID == null || statusID.isEmpty) {
      return null;
    }

    final String endpoint = '/api/v1/statuses/$statusID';
    final String body = await getAPI(endpoint) ?? '{}';
    final StatusSchema status = StatusSchema.fromString(body);

    return status;
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
}

// vim: set ts=2 sw=2 sts=2 et:
