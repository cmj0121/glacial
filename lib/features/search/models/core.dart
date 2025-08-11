// The data schema or represents the results of a search.
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:glacial/features/models.dart';

// The possible types of results that can be returned from the explorer.
enum ExplorerResultType {
  account,
  status,
  hashtag;

  String tooltip(BuildContext context) {
    return name;
  }

  IconData icon({bool active = false}) {
    switch (this) {
      case account:
        return active ? Icons.contact_page : Icons.contact_page_outlined;
      case status:
        return active ? Icons.message : Icons.message_outlined;
      case hashtag:
        return active ? Icons.tag : Icons.tag_outlined;
    }
  }
}

// Represents the results of a search.
class SearchResultSchema {
		final List<AccountSchema> accounts;
		final List<StatusSchema> statuses;
    final List<HashtagSchema> hashtags;

    const SearchResultSchema({
      required this.accounts,
      required this.statuses,
      required this.hashtags,
    });

    factory SearchResultSchema.fromString(String jsonString) {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return SearchResultSchema.fromJson(json);
    }

    factory SearchResultSchema.fromJson(Map<String, dynamic> json) {
      final List<AccountSchema> accounts = (json['accounts'] as List<dynamic>)
          .map((e) => AccountSchema.fromJson(e))
          .toList();
      final List<StatusSchema> statuses = (json['statuses'] as List<dynamic>)
          .map((e) => StatusSchema.fromJson(e))
          .toList();
      final List<HashtagSchema> hashtags = (json['hashtags'] as List<dynamic>)
          .map((e) => HashtagSchema.fromJson(e))
          .toList();

      return SearchResultSchema(
        accounts: accounts,
        statuses: statuses,
        hashtags: hashtags,
      );
    }

    bool get isEmpty {
      return accounts.isEmpty && statuses.isEmpty && hashtags.isEmpty;
    }
}

// vim: set ts=2 sw=2 sts=2 et:
