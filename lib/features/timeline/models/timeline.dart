// The Timeline pre-defined type schema.
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
  bookmarks,     // The bookmark timeline for the logged in user.
  // The extra timeline types, not shown in the timeline tab.
  user,          // The statuses posted from the given user.
  pin,           // The pinned statuses for the logged in user.
  schedule,      // The scheduled statuses for the logged in user.
  hashtag;       // The hashtag timeline for the current server.

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
      case user:
        return active ? Icons.article : Icons.article_outlined;
      case pin:
        return active ? Icons.push_pin : Icons.push_pin_outlined;
      case schedule:
        return active ? Icons.schedule : Icons.schedule_outlined;
      case hashtag:
        return active ? Icons.tag : Icons.tag_outlined;
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
      case user:
        return AppLocalizations.of(context)?.btn_profile_post ?? "Posts";
      case pin:
        return AppLocalizations.of(context)?.btn_profile_pin ?? "Pinned Posts";
      case schedule:
        return AppLocalizations.of(context)?.btn_profile_scheduled ?? "Scheduled Posts";
      case hashtag:
        return AppLocalizations.of(context)?.btn_profile_hashtag ?? "Hashtags";
    }
  }

  // Check the timeline support anonymous to access.
  bool get supportAnonymous {
    switch (this) {
      case local:
      case federal:
      case public:
        return true; // Can be accessed anonymously.
      default:
        return false; // Requires authentication.
    }
  }

  // The timeline type is shown in the timeline tab.
  bool get inTimelineTab {
    switch (this) {
      case home:
      case local:
      case federal:
      case public:
      case favourites:
      case bookmarks:
        return true; // Shown in the timeline tab.
      default:
        return false; // Not shown in the timeline tab.
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
