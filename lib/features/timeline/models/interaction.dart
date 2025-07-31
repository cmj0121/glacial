// The possible interactions with the status
import 'package:flutter/material.dart';

import 'package:glacial/core.dart';

// The actions that can be performed on a status.
enum StatusInteraction {
  reply,
  reblog,
  favourite,
  bookmark,
  share,
  mute,
  block,
  edit,
  delete;

  // The icon associated with the interaction, based on the action type.
  IconData icon({bool active = false}) {
    switch (this) {
      case reply:
        return active ? Icons.turn_left : Icons.turn_left_outlined;
      case reblog:
        return active ? Icons.repeat : Icons.repeat_outlined;
      case favourite:
        return active ? Icons.star : Icons.star_outline_outlined;
      case bookmark:
        return active ? Icons.bookmark : Icons.bookmark_outline_outlined;
      case share:
        return active ? Icons.share : Icons.share_outlined;
      case mute:
        return active ? Icons.volume_off : Icons.volume_mute_outlined;
      case block:
        return active ? Icons.block : Icons.block_outlined;
      case edit:
        return active ? Icons.edit : Icons.edit_outlined;
      case delete:
        return active ? Icons.delete : Icons.delete_outline_outlined;
    }
  }

  // The tooltip text for the interaction, localized if possible.
  String tooltip(BuildContext context) {
    switch (this) {
      case reply:
        return AppLocalizations.of(context)?.btn_interaction_reply ?? "Reply";
      case reblog:
        return AppLocalizations.of(context)?.btn_interaction_reblog ?? "Reblog";
      case favourite:
        return AppLocalizations.of(context)?.btn_interaction_favourite ?? "Favourite";
      case bookmark:
        return AppLocalizations.of(context)?.btn_interaction_bookmark ?? "Bookmark";
      case share:
        return AppLocalizations.of(context)?.btn_interaction_share ?? "Share";
      case mute:
        return AppLocalizations.of(context)?.btn_interaction_mute ?? "Mute";
      case block:
        return AppLocalizations.of(context)?.btn_interaction_block ?? "Block";
      case edit:
        return AppLocalizations.of(context)?.btn_interaction_edit ?? "Edit";
      case delete:
        return AppLocalizations.of(context)?.btn_interaction_delete ?? "Delete";
    }
  }

  // The built-in action for the interaction, which is displayed in the UI by
  // default. It may be overridden by smaller layouts or custom widgets.
  bool get isBuiltIn {
    switch (this) {
      case reply:
      case reblog:
      case favourite:
      case bookmark:
      case share:
        return true; // Built-in actions.
      default:
        return false; // Not built-in, requires custom handling.
    }
  }

  // The self status action, for edit or delete.
  bool get isSelfAction {
    switch (this) {
      case edit:
      case delete:
        return true; // Actions that can only be performed on the user's own status.
      default:
        return false; // Not self actions.
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
