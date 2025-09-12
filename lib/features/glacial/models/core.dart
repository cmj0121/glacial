// The data schema for the Glacial home page.
import 'package:flutter/material.dart';

import 'package:glacial/core.dart';

// The possible actions in sidebar and used to interact with the current server.
enum SidebarButtonType {
  timeline,
  list,
  trending,
  notifications,
  followRequests,
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
      case followRequests:
        return active ? Icons.pending_actions : Icons.pending_actions_outlined;
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
      case SidebarButtonType.followRequests:
        return "Follow Requests";
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
      case followRequests:
        return RoutePath.followRequests;
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
}

// The possible actions in the drawer and used to interact with the current server.
enum DrawerButtonType {
  switchServer,
  directory,
  preference,
  logout;

  // The icon associated with the drawer button type, returns the active or not
  IconData icon() {
    switch (this) {
      case switchServer:
        return Icons.swap_horiz;
      case directory:
        return Icons.groups;
      case preference:
        return Icons.settings;
      case logout:
        return Icons.logout;
    }
  }

  // The tooltip text for the drawer button type, localized if possible.
  String tooltip(BuildContext context) {
    switch (this) {
      case switchServer:
        return AppLocalizations.of(context)?.btn_drawer_switch_server ?? "Switch Server";
      case directory:
        return AppLocalizations.of(context)?.btn_drawer_directory ?? "Directory";
      case preference:
        return AppLocalizations.of(context)?.btn_drawer_preference ?? "Preference";
      case logout:
        return AppLocalizations.of(context)?.btn_drawer_logout ?? "Logout";
    }
  }

  RoutePath get route {
    switch (this) {
      case switchServer:
        return RoutePath.explorer;
      case directory:
        return RoutePath.directory;
      case preference:
        return RoutePath.preference;
      case logout:
        return RoutePath.timeline; // Logout does not have a specific route, it will be handled in the app logic.
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
