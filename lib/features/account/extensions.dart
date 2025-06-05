// The extensions implementation for the account schema.
import 'dart:async';
import 'dart:convert';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';

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
    return AccountSchema.fromJson(json);
  }
}

// vim: set ts=2 sw=2 sts=2 et:
