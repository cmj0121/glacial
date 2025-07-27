// The data schema for the Glacial home page.
import 'package:flutter/material.dart';

import 'package:glacial/core.dart';

// The possible actions in sidebar and used to interact with the current server.
enum SidebarButtonType {
  timeline,
  trending,
  notifications,
  admin,
  post;

  // The icon associated with the sidebar button type, returns the active or not
  IconData icon({bool active = false}) {
    switch (this) {
      case timeline:
        return active ? Icons.view_list : Icons.view_list_outlined;
      case trending:
        return active ? Icons.bar_chart : Icons.trending_up_outlined;
      case notifications:
        return active ? Icons.notifications : Icons.notifications_outlined;
      case admin:
        return active ? Icons.admin_panel_settings : Icons.admin_panel_settings_outlined;
      case post:
        return active ? Icons.post_add : Icons.post_add_outlined;
    }
  }

  // The tooltip text for the sidebar button type, localized if possible.
  String tooltip(BuildContext context) {
    switch (this) {
      case SidebarButtonType.timeline:
        return AppLocalizations.of(context)?.btn_sidebar_timelines ?? "Timelines";
      case SidebarButtonType.trending:
        return AppLocalizations.of(context)?.btn_sidebar_trendings ?? "Trendings";
      case SidebarButtonType.notifications:
        return AppLocalizations.of(context)?.btn_sidebar_notificatios ?? "Notifications";
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
      case trending:
        return RoutePath.trends;
      case notifications:
        return RoutePath.notifications;
      case admin:
        return RoutePath.admin;
      case post:
        return RoutePath.post;
    }
  }
}

// The possible actions in the drawer and used to interact with the current server.
enum DrawerButtonType {
  switchServer,
  profile,
  settings,
  logout;

  // The icon associated with the drawer button type, returns the active or not
  IconData icon() {
    switch (this) {
      case switchServer:
        return Icons.swap_horiz;
      case profile:
        return Icons.person;
      case settings:
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
      case profile:
        return AppLocalizations.of(context)?.btn_drawer_profile ?? "Profile";
      case settings:
        return AppLocalizations.of(context)?.btn_drawer_settings ?? "Settings";
      case logout:
        return AppLocalizations.of(context)?.btn_drawer_logout ?? "Logout";
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
