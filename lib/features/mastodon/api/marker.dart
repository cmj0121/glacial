// Save and restore your position in timelines.
//
// ## Marker APIs
//
//   - [+] GET  /api/v1/markers
//   - [ ] POST /api/v1/markers
//
// ref:
//   - https://docs.joinmastodon.org/methods/markers/
import 'dart:async';

import 'package:glacial/features/models.dart';

extension MarkerExtensions on AccessStatusSchema {
  // Get current positions in timelines.
  Future<MarkersSchema?> getMarker({required TimelineMarkerType type}) async {
    final String endpoint = '/api/v1/markers';
    final Map<String, String> queryParameters = {"type": type.name};
    final String body = await getAPI(endpoint, queryParameters: queryParameters) ?? '{}';

    return MarkersSchema.fromString(body);
  }

  // Save current position in timeline.
  Future<MarkersSchema?> setMarker({required String id, required TimelineMarkerType type}) async {
    final String endpoint = '/api/v1/markers';
    final Map<String, dynamic> body = {type.name: {"last_read_id": id}};
    final String response = await postAPI(endpoint, body: body) ?? '{}';

    return MarkersSchema.fromString(response);
  }
}

// vim: set ts=2 sw=2 sts=2 et:
