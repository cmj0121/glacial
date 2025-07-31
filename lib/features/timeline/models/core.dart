// The Timeline related data schema.
import 'package:flutter/material.dart';

import 'package:glacial/core.dart';

// The type list for the timeline, based on the Mastodon API.
enum TimelineType {
  // The general timeline types, show in the timeline tab.
  home,          // The home timeline for the logged in user.
  local,         // The local timeline for the current server.
  federal,       // The federated timeline for the current server.
  public,        // The public timeline for the connected server.
  favourites,    // The favourite timeline for the logged in user.
  bookmarks;     // The bookmark timeline for the logged in user.

  // The icon associated with the timeline type.
  IconData icon({bool active = false}) {
    switch (this) {
      case home:
        return active ? Icons.home : Icons.home_outlined;
      case local:
        return active ? Icons.groups : Icons.groups_outlined;
      case federal:
        return active ? Icons.account_tree : Icons.account_tree_outlined;
      case public:
        return active ? Icons.public : Icons.public_outlined;
      case favourites:
        return active ? Icons.star : Icons.star_outline_outlined;
      case bookmarks:
        return active ? Icons.bookmarks : Icons.bookmarks_outlined;
    }
  }

  // The tooltip text for the timeline type, localized if possible.
  String tooltip(BuildContext context) {
    switch (this) {
      case home:
        return AppLocalizations.of(context)?.btn_timeline_home ?? "Home";
      case local:
        return AppLocalizations.of(context)?.btn_timeline_local ?? "Local";
      case federal:
        return AppLocalizations.of(context)?.btn_timeline_federal ?? "Federal";
      case public:
        return AppLocalizations.of(context)?.btn_timeline_public ?? "Public";
      case favourites:
        return AppLocalizations.of(context)?.btn_timeline_favourites ?? "Favourites";
      case bookmarks:
        return AppLocalizations.of(context)?.btn_timeline_bookmarks ?? "Bookmarks";
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
