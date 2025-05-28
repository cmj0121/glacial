// The routes.dart file defines the routes for the app.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum RoutePath {
  landing,           // The landing page of the app when user opens it.
  engineer,          // The engineer page of the app.
  serverExplorer,    // The server explorer page of the app.
  webview,           // The in-app webview page of the app.
  userDetail,        // The user profile page of the app, displaying user information.
  userProfile,       // The edit screen for the current user's profile.
  statusContext,     // The status context page of the app.
  hashtagTimeline,   // The timeline with the specified hashtag.
  timeline,          // The timeline page of the app.
  trends,            // The trends page of the app.
  explorer,          // The explorer page of the app for the current server.
  notifications,     // The notifications page of the app.
  settings,          // The settings page of the app.
  admin,             // The admin page of the app.
  wip;               // The work-in-progress page of the app.

  // Get the string path for the route.
  String get path {
    switch (this) {
      case RoutePath.landing:
        return '/';
      case RoutePath.engineer:
        return '/engineer';
      case RoutePath.serverExplorer:
        return '/explorer';
      case RoutePath.webview:
        return '/webview';
      case RoutePath.userDetail:
        return '/user-detail';
      case RoutePath.userProfile:
        return '/user-profile';
      case RoutePath.hashtagTimeline:
        return '/hashtag';
      case RoutePath.statusContext:
        return '/home/status/context';
      case RoutePath.timeline:
        return '/glacial/timeline';
      case RoutePath.trends:
        return '/glacial/trends';
      case RoutePath.explorer:
        return '/glacial/explorer';
      case RoutePath.notifications:
        return '/glacial/notifications';
      case RoutePath.settings:
        return '/glacial/settings';
      case RoutePath.admin:
        return '/admin';
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
