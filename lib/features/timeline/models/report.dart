// Report problematic users to your moderators.
import 'package:flutter/material.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';

// The form tab of the report dialog.
enum ReportFormTab {
  statuses, // The statuses of the account, to help you decide which statuses are being reported.
  rules;    // The rules of the instance, to help you decide which rules are being violated.

  // The icon associated with the tab.
  IconData icon({bool active = false}) {
    switch (this) {
      case statuses:
        return active ? Icons.article : Icons.article_outlined;
      case rules:
        return active ? Icons.rule : Icons.rule_outlined;
    }
  }

  // The tooltip text for the tab, with localization support, if possible.
  String tooltip(BuildContext context) {
    switch (this) {
      case statuses:
        return AppLocalizations.of(context)?.btn_report_statuses ?? "Statuses";
      case rules:
        return AppLocalizations.of(context)?.btn_report_rules ?? "Rules";
    }
  }
}

// Specify if the report is
enum ReportCategoryType {
  spam,            // The account is posting unsolicited advertisements.
  legal,           // The account is posting illegal content or requesting illegal actions.
  violation,      // The account is posting content that violates the rules of the instance.
  other;

  // The icon associated with the report category.
  IconData get icon {
    switch (this) {
      case spam:
        return Icons.campaign;
      case legal:
        return Icons.gavel;
      case violation:
        return Icons.rule;
      case other:
        return Icons.report_sharp;
    }
  }

  // The name of the report category, in a human-readable format.
  String name(BuildContext content) {
    switch (this) {
      case spam:
        return AppLocalizations.of(content)?.txt_report_spam ?? "Spam";
      case legal:
        return AppLocalizations.of(content)?.txt_report_legal ?? "Legal";
      case violation:
        return AppLocalizations.of(content)?.txt_report_violation ?? "Violation";
      case other:
        return AppLocalizations.of(content)?.txt_report_other ?? "Other";
    }
  }

  // The tooltip text for the report category with localization support, if possible.
  String tooltip(BuildContext context) {
    switch (this) {
      case spam:
        return AppLocalizations.of(context)?.desc_report_spam ?? "Spam";
      case legal:
        return AppLocalizations.of(context)?.desc_report_legal ?? "Legal";
      case violation:
        return AppLocalizations.of(context)?.desc_report_violation ?? "Violation";
      case other:
        return AppLocalizations.of(context)?.desc_report_other ?? "Other";
    }
  }
}

// Reports filed against users and/or statuses, to be taken action on by moderators.
class ReportSchema {
  final String id;                   // The ID of the report in the database.
  final bool actionTaken;            // Whether an action was taken yet.
  final DateTime? actionTakenAt;     // When an action was taken against the report.
  final ReportCategoryType category; // The generic reason for the report.
  final String comment;              // The reason for the report.
  final bool forwarded;              // Whether the report was forwarded to a remote domain.
  final DateTime createdAt;          // When the report was created.
  final List<String>? statusIDs;     // IDs of statuses that have been attached to this report for additional context.
  final List<String>? ruleIDs;       // IDs of the rules that have been cited as a violation by this report.
  final AccountSchema targetAccount; // The account that was reported.

  const ReportSchema({
    required this.id,
    required this.actionTaken,
    this.actionTakenAt,
    required this.category,
    required this.comment,
    required this.forwarded,
    required this.createdAt,
    this.statusIDs,
    this.ruleIDs,
    required this.targetAccount,
  });

  factory ReportSchema.fromJson(Map<String, dynamic> json) {
    return ReportSchema(
      id: json['id'],
      actionTaken: json['action_taken'],
      actionTakenAt: json['action_taken_at'] != null ? DateTime.parse(json['action_taken_at']) : null,
      category: ReportCategoryType.values.firstWhere((e) => e.name == json['category']),
      comment: json['comment'],
      forwarded: json['forwarded'],
      createdAt: DateTime.parse(json['created_at']),
      statusIDs: json['status_ids'] != null ? List<String>.from(json['status_ids']) : null,
      ruleIDs: json['rule_ids'] != null ? List<String>.from(json['rule_ids']) : null,
      targetAccount: AccountSchema.fromJson(json['target_account']),
    );
  }
}

// Report problematic accounts and contents to your moderators.
class ReportFileSchema {
  final String accountID;            // ID of the account to report.
  final List<String> statusIDs;      // You can attach statuses to the report to provide additional context.
  final String comment;              // The reason for the report. Default maximum of 1000 characters.
  final bool forward;                // If the account is remote, should the report be forwarded to the remote admin?
  final ReportCategoryType category; // The category of the report.
  final List<String> ruleIDs;        // The IDs of the rules that the account is violating, if any.

  const ReportFileSchema({
    required this.accountID,
    this.statusIDs = const [],
    required this.comment,
    this.forward = false,
    required this.category,
    this.ruleIDs = const [],
  });
}

// vim: set ts=2 sw=2 sts=2 et:
