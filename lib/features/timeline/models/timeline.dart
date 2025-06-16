// The Timeline related data schema.
import 'package:flutter/material.dart';

import 'package:glacial/core.dart';

// The type list for the timeline, based on the Mastodon API.
enum TimelineType {
  home,          // The home timeline for the logged in user.
  hashtag,       // The hashtag timeline for the current server.
  user,          // The statuses posted from the given user.
  local,         // The local timeline for the current server.
  federal,       // The federated timeline for the current server.
  public,        // The public timeline for the connected server.
  favourites,    // The favourite timeline for the logged in user.
  bookmarks;     // The bookmark timeline for the logged in user.

  String tooltip(BuildContext context) {
    switch (this) {
      case TimelineType.home:
        return AppLocalizations.of(context)?.btn_home ?? 'Home';
      case TimelineType.user:
        return AppLocalizations.of(context)?.btn_user ?? 'User';
      case TimelineType.hashtag:
        return AppLocalizations.of(context)?.btn_trends_tags ?? 'Hashtag';
      case TimelineType.local:
        return AppLocalizations.of(context)?.btn_local ?? 'Local';
      case TimelineType.federal:
        return AppLocalizations.of(context)?.btn_federal ?? 'Federal';
      case TimelineType.public:
        return AppLocalizations.of(context)?.btn_public ?? 'Public';
      case TimelineType.bookmarks:
        return AppLocalizations.of(context)?.btn_bookmarks ?? 'Bookmarks';
      case TimelineType.favourites:
        return AppLocalizations.of(context)?.btn_favourites ?? 'Favourites';
    }
  }

  IconData icon({bool active = false}) {
    switch (this) {
      case home:
        return active ? Icons.home : Icons.home_outlined;
      case user:
        return active ? Icons.person : Icons.person_outline;
      case hashtag:
        return active ? Icons.tag : Icons.tag_outlined;
      case local:
        return active ? Icons.groups : Icons.groups_outlined;
      case federal:
        return active ? Icons.account_tree : Icons.account_tree_outlined;
      case public:
        return active ? Icons.public : Icons.public_outlined;
      case bookmarks:
        return active ? Icons.bookmarks : Icons.bookmarks_outlined;
      case favourites:
        return active ? Icons.star : Icons.star_outline_outlined;
    }
  }

  bool get supportAnonymous {
    switch (this) {
      case local:
      case federal:
      case public:
      case user:
        return true;
      default:
        return false;
    }
  }

  bool get isPublicView {
    switch (this) {
      case hashtag:
      case user:
        return false;
      default:
        return true;
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
