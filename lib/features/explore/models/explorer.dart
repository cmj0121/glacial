// The data schema or represents the results of a search.
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/timeline/models/core.dart';
import 'tag.dart';

// The possible types of results that can be returned from the explorer.
enum ExplorerResultType implements SlideTab {
  account,
  status,
  hashtag;

  @override
  String? tooltip(BuildContext context) {
    return name;
  }

  @override
  IconData get icon {
    switch (this) {
      case account:
        return Icons.contact_page_outlined;
      case status:
        return Icons.message_outlined;
      case hashtag:
        return Icons.tag_outlined;
    }
  }

  @override
  IconData get activeIcon {
    switch (this) {
      case account:
        return Icons.contact_page;
      case status:
        return Icons.message;
      case hashtag:
        return Icons.tag;
    }
  }
}

// Represents the results of a search.
class SearchResultSchema {
		final List<AccountSchema> accounts;
		final List<StatusSchema> statuses;
    final List<TagSchema> hashtags;

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
      final List<TagSchema> hashtags = (json['hashtags'] as List<dynamic>)
          .map((e) => TagSchema.fromJson(e))
          .toList();

      return SearchResultSchema(
        accounts: accounts,
        statuses: statuses,
        hashtags: hashtags,
      );
    }
}

// vim: set ts=2 sw=2 sts=2 et:
