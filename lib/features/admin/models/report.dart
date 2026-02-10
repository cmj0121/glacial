// The admin report data schema for moderation purposes.
import 'dart:convert';

import 'package:glacial/features/models.dart';

// Admin-level information about a filed report.
class AdminReportSchema {
  final String id;                        // The ID of the report in the database.
  final bool actionTaken;                 // Whether an action was taken to resolve this report.
  final DateTime? actionTakenAt;          // When an action was taken, if applicable.
  final ReportCategoryType category;      // The category under which the report is classified.
  final String comment;                   // An optional reason for the report.
  final bool forwarded;                   // Whether a report was forwarded to a remote instance.
  final DateTime createdAt;               // The time the report was filed.
  final DateTime? updatedAt;              // The time of last action on this report.
  final AccountSchema account;            // The account which filed the report.
  final AccountSchema targetAccount;      // The account being reported.
  final AccountSchema? assignedAccount;   // The account of the moderator assigned to this report.
  final AccountSchema? actionTakenByAccount; // The account of the moderator who handled the report.
  final List<StatusSchema> statuses;      // Statuses attached to the report.
  final List<RuleSchema> rules;           // Rules attached to the report.

  const AdminReportSchema({
    required this.id,
    required this.actionTaken,
    this.actionTakenAt,
    required this.category,
    required this.comment,
    required this.forwarded,
    required this.createdAt,
    this.updatedAt,
    required this.account,
    required this.targetAccount,
    this.assignedAccount,
    this.actionTakenByAccount,
    this.statuses = const [],
    this.rules = const [],
  });

  factory AdminReportSchema.fromString(String str) {
    final Map<String, dynamic> json = jsonDecode(str);
    return AdminReportSchema.fromJson(json);
  }

  factory AdminReportSchema.fromJson(Map<String, dynamic> json) {
    return AdminReportSchema(
      id: json['id'] as String,
      actionTaken: json['action_taken'] as bool,
      actionTakenAt: json['action_taken_at'] != null ? DateTime.parse(json['action_taken_at'] as String) : null,
      category: ReportCategoryType.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => ReportCategoryType.other,
      ),
      comment: json['comment'] as String? ?? '',
      forwarded: json['forwarded'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
      account: AccountSchema.fromJson(json['account'] as Map<String, dynamic>),
      targetAccount: AccountSchema.fromJson(json['target_account'] as Map<String, dynamic>),
      assignedAccount: json['assigned_account'] != null
          ? AccountSchema.fromJson(json['assigned_account'] as Map<String, dynamic>)
          : null,
      actionTakenByAccount: json['action_taken_by_account'] != null
          ? AccountSchema.fromJson(json['action_taken_by_account'] as Map<String, dynamic>)
          : null,
      statuses: (json['statuses'] as List<dynamic>?)
          ?.map((e) => StatusSchema.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      rules: (json['rules'] as List<dynamic>?)
          ?.map((e) => RuleSchema.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
