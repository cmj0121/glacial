// The suggestion data model for the Mastodon server.
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';

// The reason this account is being suggested.
enum SuggestionSourceType {
  staff,             // This account was manually recommended by the administration team
  pastInteractions,  // The authenticated account has interacted with this account previously
  global;            // This account has many reblogs, favourites, and active local followers within the last 30 days

  factory SuggestionSourceType.fromString(String str) {
    switch (str) {
      case 'staff':
        return SuggestionSourceType.staff;
      case 'past_interactions':
        return SuggestionSourceType.pastInteractions;
      case 'global':
        return SuggestionSourceType.global;
      default:
        throw ArgumentError('Unknown suggestion source type: $str');
    }
  }

  // The tooltip text for the suggestion source type, localized if possible.
  String tooltip(BuildContext context) {
    switch (this) {
      case SuggestionSourceType.staff:
        return AppLocalizations.of(context)?.txt_suggestion_staff ?? "Staff Recommendation";
      case SuggestionSourceType.pastInteractions:
        return AppLocalizations.of(context)?.txt_suggestion_past_interactions ?? "Past Interactions";
      case SuggestionSourceType.global:
        return AppLocalizations.of(context)?.txt_suggestion_global ?? "Global Popularity";
    }
  }
}

// Represents a suggested account to follow and an associated reason for the suggestion.
class SuggestionSchema {
  final SuggestionSourceType source;         // The reason this account is being suggested.
  final List<String> sources;                // A list of reasons this account is being suggested. This replaces source
  final AccountSchema account;               // The account that is being suggested.

  const SuggestionSchema({
    required this.source,
    required this.sources,
    required this.account,
  });

  factory SuggestionSchema.fromString(String str) {
    final Map<String, dynamic> json = jsonDecode(str);
    return SuggestionSchema.fromJson(json);
  }

  factory SuggestionSchema.fromJson(Map<String, dynamic> json) {
    return SuggestionSchema(
      source: SuggestionSourceType.fromString(json['source'] as String),
      sources: (json['sources'] as List<dynamic>).map((e) => e as String).toList(),
      account: AccountSchema.fromJson(json['account'] as Map<String, dynamic>),
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
