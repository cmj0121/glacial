// Visibility of this status
import 'package:flutter/material.dart';

import 'package:glacial/core.dart';

enum VisibilityType {
  public,       // Visible to everyone, shown in public timelines.
  unlisted,     // Visible to public, but not included in public timelines.
  private,      // Visible to followers only, and to any mentioned users.
  direct;       // Visible only to mentioned users.

  // The icon associated with the visibility type.
  IconData icon() {
    switch (this) {
      case public:
        return Icons.public;
      case unlisted:
        return Icons.nightlight_outlined;
      case private:
        return Icons.group;
      case direct:
        return Icons.lock;
    }
  }

  // The tooltip text for the visibility type, localized if possible.
  String tooltip(BuildContext context) {
    switch (this) {
      case VisibilityType.public:
        return AppLocalizations.of(context)?.txt_visibility_public ?? 'Public';
      case VisibilityType.unlisted:
        return AppLocalizations.of(context)?.txt_visibility_unlisted ?? 'Unlisted';
      case VisibilityType.private:
        return AppLocalizations.of(context)?.txt_visibility_private ?? 'Private';
      case VisibilityType.direct:
        return AppLocalizations.of(context)?.txt_visibility_direct ?? 'Direct';
    }
  }

  // The description of the visibility type, localized if possible.
  String description(BuildContext context) {
    switch (this) {
      case VisibilityType.public:
        return AppLocalizations.of(context)?.desc_visibility_public ?? 'Public';
      case VisibilityType.unlisted:
        return AppLocalizations.of(context)?.desc_visibility_unlisted ?? 'Unlisted';
      case VisibilityType.private:
        return AppLocalizations.of(context)?.desc_visibility_private ?? 'Private';
      case VisibilityType.direct:
        return AppLocalizations.of(context)?.desc_visibility_direct ?? 'Direct';
    }
  }

}

// vim: set ts=2 sw=2 sts=2 et:
