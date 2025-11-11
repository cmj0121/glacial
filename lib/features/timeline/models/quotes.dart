// Represents a quote or a quote placeholder, with the current authorization status.
import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:glacial/features/models.dart';

// The state of the quote. Unknown values should be treated as unauthorized.
enum QuoteStateType {
  pending,        // The quote has not been acknowledged by the quoted account yet,
  accepted,       // The quote has been accepted and can be displayed.
  rejected,       // The quote has been explicitly rejected by the quoted account.
  revoked,        // The quote has been previously accepted, but is now revoked, and thus cannot be displayed.
  deleted,        // The quote has been approved, but the quoted post itself has now been deleted.
  unauthorized,   // The quote has been approved, but cannot be displayed because the user is not authorized to see it.
  blockedAccount, // The quote has been approved, but should not be displayed because the user has blocked the account.
  blockedDomain,  // The quote has been approved, but should not be displayed because the user has blocked the domain.
  mutedAccount;   // The quote has been approved, but should not be displayed because the user has muted.

  factory QuoteStateType.fromString(String state) {
    return QuoteStateType.values.firstWhere(
      (e) => e.name == state,
      orElse: () => QuoteStateType.unauthorized,
    );
  }
}

// Represents a quote or a quote placeholder, with the current authorization status.
class QuoteSchema {
  final QuoteStateType state;
  final StatusSchema? quotedStatus;
  final String? quotedStatusID; // The identifier of the status being quoted.

  QuoteSchema({
    required this.state,
    this.quotedStatus,
    this.quotedStatusID,
  });

  factory QuoteSchema.fromString(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return QuoteSchema.fromJson(json);
  }

  factory QuoteSchema.fromJson(Map<String, dynamic> json) {
    return QuoteSchema(
      state: QuoteStateType.fromString(json['state'] as String),
      quotedStatus: json['quoted_status'] != null
          ? StatusSchema.fromJson(json['quoted_status'] as Map<String, dynamic>)
          : null,
      quotedStatusID: json['quoted_status_id'] as String?,
    );
  }
}

// Describes who is expected to be able to quote that status and have the quote automatically authorized.
enum QuoteApprovalType {
  public,            // Anybody is expected to be able to quote this status and have the quote be automatically accepted.
  followers,         // Followers are expected to be able to quote this status and have the quote be automatically accepted.
  following,         // People followed by the author are expected to be able to quote this status and have the quote be automatically accepted.
  unsupportedPolicy; // The underlying quote policy is not supported by Mastodon

  factory QuoteApprovalType.fromString(String type) {
    return QuoteApprovalType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => QuoteApprovalType.unsupportedPolicy,
    );
  }

  IconData get icon {
    switch (this) {
      case QuoteApprovalType.public:
        return Icons.format_quote_sharp;
      case QuoteApprovalType.followers:
        return Icons.group;
      case QuoteApprovalType.following:
        return Icons.person_add;
      case QuoteApprovalType.unsupportedPolicy:
        return Icons.help_outline;
    }
  }
}

// Describes how this status’ quote policy applies to the current user.
enum CurrentQuoteApprovalType {
  automatic,  // The requesting user is expected to be allowed to quote
  manual,     // The requesting user is expected to be allowed to quote after manual review
  denied,     // The requesting user is not expected to be allowed to quote this post.
  unknown;    // The user is not covered by the quote policies supported by Mastodon

  factory CurrentQuoteApprovalType.fromString(String type) {
    return CurrentQuoteApprovalType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => CurrentQuoteApprovalType.unknown,
    );
  }
}

// Summary of a status' quote approval policy and how it applies to the requesting user.
class QuoteApprovalSchema {
  final List<QuoteApprovalType> automatic;
  final List<QuoteApprovalType> manual;
  final CurrentQuoteApprovalType currentUser;

  QuoteApprovalSchema({
    required this.automatic,
    required this.manual,
    required this.currentUser,
  });

  factory QuoteApprovalSchema.fromString(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return QuoteApprovalSchema.fromJson(json);
  }

  factory QuoteApprovalSchema.fromJson(Map<String, dynamic> json) {
    return QuoteApprovalSchema(
      automatic: (json['automatic'] as List<dynamic>)
          .map((e) => QuoteApprovalType.fromString(e as String))
          .toList(),
      manual: (json['manual'] as List<dynamic>)
          .map((e) => QuoteApprovalType.fromString(e as String))
          .toList(),
      currentUser:
          CurrentQuoteApprovalType.fromString(json['current_user'] as String),
    );
  }
}

// Sets who is allowed to quote the status.
// Ignored if visibility is private or direct, in which case the policy will always be set to nobody.
enum QuotePolicyType {
  public,    // Anyone is allowed to quote this status and will have their quote automatically accepted, unless they are blocked.
  followers, // Only followers and the author are allowed to quote this status, and will have their quote automatically accepted.
  nobody;    // Only the author is allowed to quote the status.

  factory QuotePolicyType.fromString(String type) {
    return QuotePolicyType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => QuotePolicyType.nobody
    );
  }

  IconData get icon {
    switch (this) {
      case QuotePolicyType.public:
        return Icons.format_quote_sharp;
      case QuotePolicyType.followers:
        return Icons.group;
      case QuotePolicyType.nobody:
        return Icons.lock;
    }
  }

  String title(BuildContext context) {
    switch (this) {
      case QuotePolicyType.public:
        return "Public";
      case QuotePolicyType.followers:
        return "Followers";
      case QuotePolicyType.nobody:
        return "Nobody";
    }
  }

  String description(BuildContext context) {
    switch (this) {
      case QuotePolicyType.public:
        return "Anyone can quote this status.";
      case QuotePolicyType.followers:
        return "Only followers can quote this status.";
      case QuotePolicyType.nobody:
        return "No one can quote this status.";
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
