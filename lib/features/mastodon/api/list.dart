// The List APIs for the mastdon server.
//
// ## List APIs
//	 - [+] GET    /api/v1/lists
//	 - [+] GET    /api/v1/lists/:id
//   - [+] GET    /api/v1/lists/:id/accounts
//   - [+] POST   /api/v1/lists/:id/accounts
//   - [+] DELETE /api/v1/lists/:id/accounts
//	 - [+] POST   /api/v1/lists
//   - [+] PUT    /api/v1/lists/:id
//   - [+] DELETE /api/v1/lists/:id
//
// ref:
//   - https://docs.joinmastodon.org/methods/lists/
import 'dart:async';
import 'dart:convert';

import 'package:glacial/features/models.dart';

extension ListsExtensions on AccessStatusSchema {
  // Fetch all lists that the user owns.
  Future<List<ListSchema>> getLists() async {
    final String endpoint = '/api/v1/lists';
    final String body = await getAPI(endpoint) ?? '[]';
    final List<dynamic> json = jsonDecode(body) as List<dynamic>;

    return json.map((item) => ListSchema.fromJson(item as Map<String, dynamic>)).toList();
  }

  // Fetch the list with the given ID.
  Future<ListSchema?> getList(String id) async {
    final String endpoint = '/api/v1/lists/$id';
    final String? body = await getAPI(endpoint);
    if (body == null) return null;

    final Map<String, dynamic> json = jsonDecode(body) as Map<String, dynamic>;
    return ListSchema.fromJson(json);
  }

  // Create a new list.
  Future<ListSchema> createList({
    required String title,
    ReplyPolicyType replyPolicy = ReplyPolicyType.list,
    bool exclusive = false,
  }) async {
    final String endpoint = '/api/v1/lists';
    final Map<String, dynamic> body = {
      'title': title,
      'reply_policy': replyPolicy.name,
      'exclusive': exclusive,
    };
    final String response = await postAPI(endpoint, body: body) ?? '{}';
    final Map<String, dynamic> json = jsonDecode(response) as Map<String, dynamic>;

    return ListSchema.fromJson(json);
  }

  // Change the properties of a list.
  Future<ListSchema> updateList({
    required String id,
    required String title,
    ReplyPolicyType? replyPolicy,
    bool? exclusive,
  }) async {
    final String endpoint = '/api/v1/lists/$id';
    final Map<String, dynamic> body = <String, dynamic>{
      'title': title,
      if (replyPolicy != null) 'replies_policy': replyPolicy.name,
      if (exclusive != null) 'exclusive': exclusive,
    };

    final String response = await putAPI(endpoint, body: body) ?? '{}';
    final Map<String, dynamic> json = jsonDecode(response) as Map<String, dynamic>;

    return ListSchema.fromJson(json);
  }

  // Delete a list.
  Future<void> deleteList(String id) async {
    final String endpoint = '/api/v1/lists/$id';
    await deleteAPI(endpoint);
  }

  // View accounts in a list.
  Future<List<AccountSchema>> getListAccounts(String id) async {
    final String endpoint = '/api/v1/lists/$id/accounts';
    final String body = await getAPI(endpoint) ?? '[]';
    final List<dynamic> json = jsonDecode(body) as List<dynamic>;

    return json.map((item) => AccountSchema.fromJson(item as Map<String, dynamic>)).toList();
  }

  // Add accounts to the given list. Note that the user must be following these accounts.
  Future<void> addAccountsToList(String id, List<String> accountIds) async {
    final String endpoint = '/api/v1/lists/$id/accounts';
    final Map<String, dynamic> body = {'account_ids': accountIds};

    await postAPI(endpoint, body: body);
  }

  // Remove accounts from the given list.
  Future<void> removeAccountsFromList(String id, List<String> accountIds) async {
    final String endpoint = '/api/v1/lists/$id/accounts';
    final Map<String, dynamic> body = {'account_ids': accountIds};
    await deleteAPI(endpoint, body: body);
  }
}

// vim: set ts=2 sw=2 sts=2 et:
