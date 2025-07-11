// The routes.dart file defines the routes for the app.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum RoutePath {
  landing,           // The landing page of the app when user opens it.
  engineer,          // The engineer page of the app.
  explorer,          // The server explorer page of the app to explore the Mastodon server.
  webview,           // The in-app webview page of the app.
  media,             // The media viewer page of the app to view the media content.
  // The home page of the Glacial, showing the timeline, trends, notifications, and other features.
  timeline,          // The timeline page of the app.
  trends,            // The trends page of the app.
  notifications,     // The notifications page of the app.
  settings,          // The settings page of the app.
  admin,             // The admin page of the app.
  search,            // The search page of the app.
  hashtag,           // The hashtag page of the app.
  profile,           // The user's profile page of the app.
  status,            // The list of statuses in the context of the app.
  statusInfo,        // The status info page of the app to show the status details.
  post,              // The post page of the app to create a new post.
  wip;               // The work-in-progress page of the app.

  // Get the string path for the route.
  String get path {
    switch (this) {
      case RoutePath.landing:
        return '/';
      case RoutePath.engineer:
        return '/engineer';
      case RoutePath.explorer:
        return '/explorer';
      case RoutePath.webview:
        return '/webview';
      case RoutePath.media:
        return '/media';
      case RoutePath.timeline:
        return '/home/timeline';
      case RoutePath.trends:
        return '/home/trends';
      case RoutePath.notifications:
        return '/home/notifications';
      case RoutePath.settings:
        return '/home/settings';
      case RoutePath.admin:
        return '/home/admin';
      case RoutePath.search:
        return '/home/search';
      case RoutePath.hashtag:
        return '/home/hashtag';
      case RoutePath.profile:
        return '/home/profile';
      case RoutePath.status:
        return '/home/status';
      case RoutePath.statusInfo:
        return '/home/status/info';
      case RoutePath.post:
        return '/home/post';
      case RoutePath.wip:
        return '/wip';
    }
  }
}

// The extension and convert from the GoRouter to the RoutePath.
extension RoutePathExtension on GoRouter {
  RoutePath? routePath(BuildContext context) {
    final String path = ModalRoute.of(context)?.settings.name ?? '';

    return RoutePath.values.cast<RoutePath?>().firstWhere(
      (RoutePath? route) => route?.path == path,
      orElse: () => null,
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
