// The admin dashboard enums and types.
import 'package:flutter/material.dart';

import 'package:glacial/core.dart';

// The admin tab types for the admin dashboard.
enum AdminTabType {
  reports,   // The reports tab to manage reports.
  accounts;  // The accounts tab to manage accounts.

  // The icon associated with the admin tab type.
  IconData icon({bool active = false}) {
    switch (this) {
      case reports:
        return active ? Icons.flag : Icons.flag_outlined;
      case accounts:
        return active ? Icons.people : Icons.people_outlined;
    }
  }

  // The tooltip text for the admin tab type.
  String tooltip(BuildContext context) {
    switch (this) {
      case reports:
        return AppLocalizations.of(context)?.btn_admin_reports ?? "Reports";
      case accounts:
        return AppLocalizations.of(context)?.btn_admin_accounts ?? "Accounts";
    }
  }
}

// The admin action types for moderation actions.
enum AdminActionType {
  approve,     // Approve a pending account.
  reject,      // Reject a pending account.
  suspend,     // Suspend an account.
  silence,     // Silence (limit) an account.
  enable,      // Re-enable a disabled account.
  unsilence,   // Unsilence an account.
  unsuspend,   // Unsuspend an account.
  unsensitive, // Unmark an account as sensitive.
  assignToSelf,  // Assign a report to yourself.
  unassign,    // Unassign a report.
  resolve,     // Resolve a report.
  reopen;      // Reopen a resolved report.

  // The icon associated with the admin action type.
  IconData get icon {
    switch (this) {
      case approve:
        return Icons.check_circle;
      case reject:
        return Icons.cancel;
      case suspend:
        return Icons.block;
      case silence:
        return Icons.volume_off;
      case enable:
        return Icons.play_circle;
      case unsilence:
        return Icons.volume_up;
      case unsuspend:
        return Icons.lock_open;
      case unsensitive:
        return Icons.visibility;
      case assignToSelf:
        return Icons.person_add;
      case unassign:
        return Icons.person_remove;
      case resolve:
        return Icons.done;
      case reopen:
        return Icons.refresh;
    }
  }

  // The label for the admin action type.
  String label(BuildContext context) {
    switch (this) {
      case approve:
        return AppLocalizations.of(context)?.btn_admin_approve ?? "Approve";
      case reject:
        return AppLocalizations.of(context)?.btn_admin_reject ?? "Reject";
      case suspend:
        return AppLocalizations.of(context)?.btn_admin_suspend ?? "Suspend";
      case silence:
        return AppLocalizations.of(context)?.btn_admin_silence ?? "Silence";
      case enable:
        return AppLocalizations.of(context)?.btn_admin_enable ?? "Enable";
      case unsilence:
        return AppLocalizations.of(context)?.btn_admin_unsilence ?? "Unsilence";
      case unsuspend:
        return AppLocalizations.of(context)?.btn_admin_unsuspend ?? "Unsuspend";
      case unsensitive:
        return AppLocalizations.of(context)?.btn_admin_unsensitive ?? "Unsensitive";
      case assignToSelf:
        return AppLocalizations.of(context)?.btn_admin_assign ?? "Assign to me";
      case unassign:
        return AppLocalizations.of(context)?.btn_admin_unassign ?? "Unassign";
      case resolve:
        return AppLocalizations.of(context)?.btn_admin_resolve ?? "Resolve";
      case reopen:
        return AppLocalizations.of(context)?.btn_admin_reopen ?? "Reopen";
    }
  }

  // Check if the action is dangerous (requires confirmation).
  bool get isDangerous {
    switch (this) {
      case reject:
      case suspend:
        return true;
      default:
        return false;
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
