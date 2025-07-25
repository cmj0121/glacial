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

// vim: set ts=2 sw=2 sts=2 et:
