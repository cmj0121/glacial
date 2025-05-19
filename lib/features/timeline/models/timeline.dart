// The Timeline related data schema.
import 'package:flutter/material.dart';

import 'package:glacial/core.dart';

// The type list for the timeline, based on the Mastodon API.
enum TimelineType implements SlideTab {
  home,          // The home timeline for the logged in user.
  local,         // The local timeline for the current server.
  federal,       // The federated timeline for the current server.
  public,        // The public timeline for the connected server.
  favourites,    // The favourite timeline for the logged in user.
  bookmarks;     // The bookmark timeline for the logged in user.

  @override
  String? tooltip(BuildContext context) {
    switch (this) {
      case TimelineType.home:
        return AppLocalizations.of(context)?.btn_home_timeline ?? 'Home';
      case TimelineType.local:
        return AppLocalizations.of(context)?.btn_local_timeline ?? 'Local';
      case TimelineType.federal:
        return AppLocalizations.of(context)?.btn_federal_timeline ?? 'Federal';
      case TimelineType.public:
        return AppLocalizations.of(context)?.btn_public_timeline ?? 'Public';
      case TimelineType.bookmarks:
        return AppLocalizations.of(context)?.btn_bookmarks_timeline ?? 'Bookmarks';
      case TimelineType.favourites:
        return AppLocalizations.of(context)?.btn_favourites_timeline ?? 'Favourites';
    }
  }

  @override
  IconData get icon {
    switch (this) {
      case home:
        return Icons.home_outlined;
      case local:
        return Icons.groups_outlined;
      case federal:
        return Icons.account_tree_outlined;
      case public:
        return Icons.public_outlined;
      case bookmarks:
        return Icons.bookmarks_outlined;
      case favourites:
        return Icons.star_outline_outlined;
    }
  }

  @override
  IconData get activeIcon {
    switch (this) {
      case home:
        return Icons.home;
      case local:
        return Icons.groups;
      case federal:
        return Icons.account_tree;
      case public:
        return Icons.public;
      case bookmarks:
        return Icons.bookmarks;
      case favourites:
        return Icons.star;
    }
  }

  bool get supportAnonymous {
    switch (this) {
      case local:
      case federal:
      case public:
        return true;
      default:
        return false;
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
