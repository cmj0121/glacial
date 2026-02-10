// The admin account data schema for moderation purposes.
import 'dart:convert';

import 'package:glacial/features/models.dart';

// The origin of the admin account registration.
enum AdminAccountOrigin {
  local,   // The account was registered locally.
  remote;  // The account is from a remote instance.
}

// The moderation status of the admin account.
enum AdminAccountStatus {
  active,    // The account is active.
  pending,   // The account is pending approval.
  disabled,  // The account is disabled.
  silenced,  // The account is silenced (limited).
  suspended; // The account is suspended.
}

// Admin-level information about a given account.
class AdminAccountSchema {
  final String id;                    // The ID of the account in the database.
  final String username;              // The username of the account.
  final String? domain;               // The domain of the account (null for local).
  final DateTime createdAt;           // When the account was first discovered.
  final String email;                 // The email address associated with the account.
  final String? ip;                   // The IP address last used to login to this account.
  final String? locale;               // The locale of the account set during sign up.
  final String? inviteRequest;        // The reason given when requesting an invite.
  final RoleSchema? role;             // The current role of the account.
  final bool confirmed;               // Whether the account has confirmed their email address.
  final bool approved;                // Whether the account is currently approved.
  final bool disabled;                // Whether the account is currently disabled.
  final bool silenced;                // Whether the account is currently silenced.
  final bool suspended;               // Whether the account is currently suspended.
  final AccountSchema account;        // The user-level account information.
  final AdminAccountSchema? createdByApplication; // The application that created the account (if applicable).
  final AdminAccountSchema? invitedByAccount;     // The account that invited this account (if applicable).
  final List<AdminIpSchema> ips;      // The IP addresses used by this account.

  const AdminAccountSchema({
    required this.id,
    required this.username,
    this.domain,
    required this.createdAt,
    this.email = '',
    this.ip,
    this.locale,
    this.inviteRequest,
    this.role,
    required this.confirmed,
    required this.approved,
    required this.disabled,
    required this.silenced,
    required this.suspended,
    required this.account,
    this.createdByApplication,
    this.invitedByAccount,
    this.ips = const [],
  });

  factory AdminAccountSchema.fromString(String str) {
    final Map<String, dynamic> json = jsonDecode(str);
    return AdminAccountSchema.fromJson(json);
  }

  factory AdminAccountSchema.fromJson(Map<String, dynamic> json) {
    return AdminAccountSchema(
      id: json['id'] as String,
      username: json['username'] as String,
      domain: json['domain'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      email: json['email'] as String? ?? '',
      ip: json['ip'] as String?,
      locale: json['locale'] as String?,
      inviteRequest: json['invite_request'] as String?,
      role: json['role'] != null ? RoleSchema.fromJson(json['role'] as Map<String, dynamic>) : null,
      confirmed: json['confirmed'] as bool? ?? false,
      approved: json['approved'] as bool? ?? false,
      disabled: json['disabled'] as bool? ?? false,
      silenced: json['silenced'] as bool? ?? false,
      suspended: json['suspended'] as bool? ?? false,
      account: AccountSchema.fromJson(json['account'] as Map<String, dynamic>),
      ips: (json['ips'] as List<dynamic>?)
          ?.map((e) => AdminIpSchema.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  // Get the current moderation status of the account.
  AdminAccountStatus get status {
    if (suspended) return AdminAccountStatus.suspended;
    if (silenced) return AdminAccountStatus.silenced;
    if (disabled) return AdminAccountStatus.disabled;
    if (!approved) return AdminAccountStatus.pending;
    return AdminAccountStatus.active;
  }

  // Check if the account is local or remote.
  bool get isLocal => domain == null;
}

// IP address information for admin accounts.
class AdminIpSchema {
  final String ip;          // The IP address.
  final DateTime usedAt;    // The timestamp of when the IP was last used.

  const AdminIpSchema({
    required this.ip,
    required this.usedAt,
  });

  factory AdminIpSchema.fromJson(Map<String, dynamic> json) {
    return AdminIpSchema(
      ip: json['ip'] as String,
      usedAt: DateTime.parse(json['used_at'] as String),
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
