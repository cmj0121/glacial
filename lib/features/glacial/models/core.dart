// The data schema for the Glacial home page.
import 'package:flutter/material.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/mastodon/models/config.dart';
import 'package:glacial/features/timeline/models/timeline.dart';

// The possible actions in sidebar and used to interact with the current server.
enum SidebarButtonType {
  timeline,
  list,
  trending,
  notifications,
  conversations,
  admin,
  post;

  // The icon associated with the sidebar button type, returns the active or not
  IconData icon({bool active = false}) {
    switch (this) {
      case timeline:
        return active ? Icons.view_timeline : Icons.view_timeline_outlined;
      case list:
        return active ? Icons.view_list : Icons.view_list_outlined;
      case trending:
        return active ? Icons.bar_chart : Icons.trending_up_outlined;
      case notifications:
        return active ? Icons.notifications : Icons.notifications_outlined;
      case conversations:
        return active ? Icons.mail : Icons.mail_outline;
      case admin:
        return active ? Icons.admin_panel_settings : Icons.admin_panel_settings_outlined;
      case post:
        return active ? Icons.chat : Icons.chat_outlined;
    }
  }

  // The tooltip text for the sidebar button type, localized if possible.
  String tooltip(BuildContext context) {
    switch (this) {
      case SidebarButtonType.timeline:
        return AppLocalizations.of(context)?.btn_sidebar_timelines ?? "Timelines";
      case SidebarButtonType.list:
        return AppLocalizations.of(context)?.btn_sidebar_lists ?? "Lists";
      case SidebarButtonType.trending:
        return AppLocalizations.of(context)?.btn_sidebar_trendings ?? "Trendings";
      case SidebarButtonType.notifications:
        return AppLocalizations.of(context)?.btn_sidebar_notifications ?? "Notifications";
      case SidebarButtonType.conversations:
        return AppLocalizations.of(context)?.btn_sidebar_conversations ?? "Conversations";
      case SidebarButtonType.admin:
        return AppLocalizations.of(context)?.btn_sidebar_management ?? "Management";
      case SidebarButtonType.post:
        return AppLocalizations.of(context)?.btn_sidebar_post ?? "Toot";
    }
  }

  RoutePath get route {
    switch (this) {
      case timeline:
        return RoutePath.timeline;
      case list:
        return RoutePath.list;
      case trending:
        return RoutePath.trends;
      case notifications:
        return RoutePath.notifications;
      case conversations:
        return RoutePath.conversations;
      case admin:
        return RoutePath.admin;
      case post:
        return RoutePath.post;
    }
  }

  bool get supportAnonymous {
    switch (this) {
      case timeline:
      case trending:
        return true;
      default:
        return false;
    }
  }

  // Check if this sidebar action is accessible given the auth state and server config.
  // For the timeline button, it checks whether any timeline tab is accessible.
  bool isAccessible({required bool isSignedIn, TimelinesAccessSchema? access}) {
    switch (this) {
      case timeline:
        return TimelineType.values
            .where((t) => t.inTimelineTab)
            .any((t) => t.isAccessible(isSignedIn: isSignedIn, access: access));
      case trending:
        return true;
      default:
        return supportAnonymous || isSignedIn;
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:

// vim: set ts=2 sw=2 sts=2 et:
