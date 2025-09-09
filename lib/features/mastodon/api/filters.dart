// The Filters APIs for the mastdon server.
//
// ## Filters APIs
//
//   - [ ] GET    /api/v2/filters
//   - [ ] GET    /api/v2/filters/:id
//   - [ ] POST   /api/v2/filters
//   - [ ] PUT    /api/v2/filters/:id
//   - [ ] DELETE /api/v2/filters/:id
//   - [ ] GET    /api/v2/filters/:filter_id/keywords
//   - [ ] POST   /api/v2/filters/:filter_id/keywords
//   - [ ] GET    /api/v2/filters/keywords/:id
//   - [ ] PUT    /api/v2/filters/keywords/:id
//   - [ ] DELETE /api/v2/filters/keywords/:id
//   - [ ] GET    /api/v2/filters/:filter_id/statuses
//   - [ ] POST   /api/v2/filters/:filter_id/statuses
//   - [ ] GET    /api/v2/filters/statuses/:id
//   - [ ] DELETE /api/v2/filters/statuses/:id
//
// ref:
//   - https://docs.joinmastodon.org/methods/filters/
import 'dart:async';
import 'dart:convert';

import 'package:glacial/features/models.dart';

extension FiltersExtensions on AccessStatusSchema {
  // Obtain a list of all filter groups for the current user.
  Future<List<FiltersSchema>> fetchFilters() async {
    final String endpoint = '/api/v2/filters';
    final String body = await getAPI(endpoint) ?? '[]';
    final List<dynamic> json = jsonDecode(body) as List<dynamic>;

    return json.map((e) => FiltersSchema.fromJson(e as Map<String, dynamic>)).toList();
  }
}


// vim: set ts=2 sw=2 sts=2 et:
