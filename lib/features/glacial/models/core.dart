// The data schema for the Glacial home page.
import 'package:flutter/material.dart';

import 'package:glacial/core.dart';

// The possible actions in sidebar and used to interact with the current server.
enum SidebarButtonType {
  timeline,
  trending,
  notifications,
  settings,
  admin,
  post;

  IconData icon({bool active = false}) {
    switch (this) {
      case timeline:
        return active ? Icons.view_list : Icons.view_list_outlined;
      case trending:
        return active ? Icons.bar_chart : Icons.trending_up_outlined;
      case notifications:
        return active ? Icons.notifications : Icons.notifications_outlined;
      case settings:
        return active ? Icons.settings : Icons.settings_outlined;
      case admin:
        return active ? Icons.admin_panel_settings : Icons.admin_panel_settings_outlined;
      case post:
        return active ? Icons.post_add : Icons.post_add_outlined;
    }
  }

  // The list of actions could be performed in the sidebar.
  String tooltip(BuildContext context) {
    switch (this) {
      case SidebarButtonType.timeline:
        return AppLocalizations.of(context)?.btn_timeline ?? "Timeline";
      case SidebarButtonType.trending:
        return AppLocalizations.of(context)?.btn_trending ?? "Trending";
      case SidebarButtonType.notifications:
        return AppLocalizations.of(context)?.btn_notifications ?? "Notifications";
      case SidebarButtonType.settings:
        return AppLocalizations.of(context)?.btn_settings ?? "Settings";
      case SidebarButtonType.admin:
        return AppLocalizations.of(context)?.btn_management ?? "Admin Management";
      case SidebarButtonType.post:
        return AppLocalizations.of(context)?.btn_post ?? "Post";
    }
  }

  bool get supportAnonymous {
    switch (this) {
      case timeline:
      case trending:
        return true;
      case notifications:
      case settings:
      case admin:
      case post:
        return false;
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
      case settings:
        return RoutePath.settings;
      case admin:
        return RoutePath.admin;
      case post:
        return RoutePath.post;
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
