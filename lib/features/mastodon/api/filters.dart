// The Filters APIs for the mastdon server.
//
// ## Filters APIs
//
//   - [+] GET    /api/v2/filters
//   - [+] GET    /api/v2/filters/:id
//   - [+] POST   /api/v2/filters
//   - [+] PUT    /api/v2/filters/:id
//   - [+] DELETE /api/v2/filters/:id
//   - [+] GET    /api/v2/filters/:filter_id/keywords
//   - [+] POST   /api/v2/filters/:filter_id/keywords
//   - [+] GET    /api/v2/filters/keywords/:id
//   - [+] PUT    /api/v2/filters/keywords/:id
//   - [+] DELETE /api/v2/filters/keywords/:id
//   - [+] GET    /api/v2/filters/:filter_id/statuses
//   - [+] POST   /api/v2/filters/:filter_id/statuses
//   - [+] GET    /api/v2/filters/statuses/:id
//   - [+] DELETE /api/v2/filters/statuses/:id
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

  // Create a filter group with the given parameters.
  Future<FiltersSchema> createFilter({required FilterFormSchema schema}) async {
    final String endpoint = '/api/v2/filters';
    final String body = await postAPI(endpoint, body: schema.toJson()) ?? '{}';
    final Map<String, dynamic> json = jsonDecode(body) as Map<String, dynamic>;

    return FiltersSchema.fromJson(json);
  }

  // Update a filter group with the given parameters.
  Future<FiltersSchema> updateFilter({required String id, required FilterFormSchema schema}) async {
    final String endpoint = '/api/v2/filters/$id';
    final String body = await putAPI(endpoint, body: schema.toJson()) ?? '{}';
    final Map<String, dynamic> json = jsonDecode(body) as Map<String, dynamic>;

    return FiltersSchema.fromJson(json);
  }

  // Delete a filter group with the given id.
  Future<void> deleteFilter({required String id}) async {
    final String endpoint = '/api/v2/filters/$id';
    await deleteAPI(endpoint);
  }

  // Obtain a list of all status filters within this filter group.
  Future<List<FilterStatusSchema>> fetchFilterStatuses({required FiltersSchema filter}) async {
    final String endpoint = '/api/v2/filters/${filter.id}/statuses';
    final String body = await getAPI(endpoint) ?? '[]';
    final List<dynamic> json = jsonDecode(body) as List<dynamic>;

    return json.map((e) => FilterStatusSchema.fromJson(e as Map<String, dynamic>)).toList();
  }

  // Add a status filter to the current filter group.
  Future<FilterStatusSchema> addFilterStatus({required FiltersSchema filter, required StatusSchema status}) async {
    final String endpoint = '/api/v2/filters/${filter.id}/statuses';
    final String body = await postAPI(endpoint, body: {'status_id': status.id}) ?? '{}';

    return FilterStatusSchema.fromString(body);
  }

  // Remove a status filter from the current filter group.
  Future<void> removeFilterStatus({required FilterStatusSchema status}) async {
    final String endpoint = '/api/v2/filters/statuses/${status.id}';
    await deleteAPI(endpoint);
  }

  // Obtain a single filter group by its ID.
  Future<FiltersSchema?> getFilter({required String id}) async {
    final String endpoint = '/api/v2/filters/$id';
    final String? body = await getAPI(endpoint);
    if (body == null) return null;

    final Map<String, dynamic> json = jsonDecode(body) as Map<String, dynamic>;
    return FiltersSchema.fromJson(json);
  }

  // Obtain all keywords attached to a filter group.
  Future<List<FilterKeywordSchema>> fetchFilterKeywords({required String filterId}) async {
    final String endpoint = '/api/v2/filters/$filterId/keywords';
    final String body = await getAPI(endpoint) ?? '[]';
    final List<dynamic> json = jsonDecode(body) as List<dynamic>;

    return json.map((e) => FilterKeywordSchema.fromJson(e as Map<String, dynamic>)).toList();
  }

  // Add a keyword to a filter group.
  Future<FilterKeywordSchema> addFilterKeyword({
    required String filterId,
    required String keyword,
    bool wholeWord = false,
  }) async {
    final String endpoint = '/api/v2/filters/$filterId/keywords';
    final Map<String, dynamic> body = {
      'keyword': keyword,
      'whole_word': wholeWord,
    };

    final String response = await postAPI(endpoint, body: body) ?? '{}';
    final Map<String, dynamic> json = jsonDecode(response) as Map<String, dynamic>;
    return FilterKeywordSchema.fromJson(json);
  }

  // Get a single keyword by its ID.
  Future<FilterKeywordSchema?> getFilterKeyword({required String id}) async {
    final String endpoint = '/api/v2/filters/keywords/$id';
    final String? body = await getAPI(endpoint);
    if (body == null) return null;

    final Map<String, dynamic> json = jsonDecode(body) as Map<String, dynamic>;
    return FilterKeywordSchema.fromJson(json);
  }

  // Update a keyword in a filter group.
  Future<FilterKeywordSchema> updateFilterKeyword({
    required String id,
    required String keyword,
    bool wholeWord = false,
  }) async {
    final String endpoint = '/api/v2/filters/keywords/$id';
    final Map<String, dynamic> body = {
      'keyword': keyword,
      'whole_word': wholeWord,
    };

    final String response = await putAPI(endpoint, body: body) ?? '{}';
    final Map<String, dynamic> json = jsonDecode(response) as Map<String, dynamic>;
    return FilterKeywordSchema.fromJson(json);
  }

  // Delete a keyword from a filter group.
  Future<void> deleteFilterKeyword({required String id}) async {
    final String endpoint = '/api/v2/filters/keywords/$id';
    await deleteAPI(endpoint);
  }

  // Get a single status filter by its ID.
  Future<FilterStatusSchema?> getFilterStatus({required String id}) async {
    final String endpoint = '/api/v2/filters/statuses/$id';
    final String? body = await getAPI(endpoint);
    if (body == null) return null;

    final Map<String, dynamic> json = jsonDecode(body) as Map<String, dynamic>;
    return FilterStatusSchema.fromJson(json);
  }
}

// vim: set ts=2 sw=2 sts=2 et:
