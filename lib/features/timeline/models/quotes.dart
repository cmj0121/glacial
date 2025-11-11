// Represents a quote or a quote placeholder, with the current authorization status.
import 'dart:convert';

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
}

// Summary of a status' quote approval policy and how it applies to the requesting user.
class QuoteApprovalSchema {
  final List<QuoteApprovalType> automatic;
  final List<QuoteApprovalType> manual;
  final QuoteApprovalType currentUser;

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
          QuoteApprovalType.fromString(json['current_user'] as String),
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
