// The routes.dart file defines the routes for the app.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum RoutePath {
  landing,           // The landing page of the app when user opens it.
  explorer,          // The server explorer page of the app to explore the Mastodon server.
  webview,           // The in-app webview page of the app.
  media,             // The media viewer page of the app to view the media content.
  preference,        // The preference settings page of the app.
  // The home page of the Glacial, showing the timeline, trends, notifications, and other features.
  timeline,          // The timeline page of the app.
  list,              // The list page of the app to show the pinned lists.
  listItem,          // The list item page of the app to show the list details.
  trends,            // The trends page of the app.
  notifications,     // The notifications page of the app.
  admin,             // The admin page of the app.
  search,            // The search page of the app.
  hashtag,           // The hashtag page of the app.
  profile,           // The user's profile page of the app.
  editProfile,       // The page to edit the user's profile.
  createFilterForm,  // The page to create a filter.
  editFilterForm,    // The page to edit a filter.
  status,            // The list of statuses in the context of the app.
  statusInfo,        // The status info page of the app to show the status details.
  statusHistory,     // The status history page of the app to show the status history.
  post,              // The post page of the app to create a new post.
  edit,              // The edit page of the app to edit an existing post.
  directory,         // The directory page of the app to expore the accounts in the Mastodon server.
  wip;               // The work-in-progress page of the app.

  // Get the string path for the route.
  String get path {
    switch (this) {
      case RoutePath.landing:
        return '/';
      case RoutePath.explorer:
        return '/explorer';
      case RoutePath.webview:
        return '/webview';
      case RoutePath.preference:
        return '/preference';
      case RoutePath.media:
        return '/media';
      case RoutePath.timeline:
        return '/home/timeline';
      case RoutePath.list:
        return '/home/list';
      case RoutePath.listItem:
        return '/home/list/item';
      case RoutePath.trends:
        return '/home/trends';
      case RoutePath.notifications:
        return '/home/notifications';
      case RoutePath.admin:
        return '/home/admin';
      case RoutePath.search:
        return '/home/search';
      case RoutePath.hashtag:
        return '/home/hashtag';
      case RoutePath.profile:
        return '/home/profile';
      case RoutePath.editProfile:
        return '/home/profile/edit';
      case RoutePath.createFilterForm:
        return '/home/filter/form';
      case RoutePath.editFilterForm:
        return '/home/filter/form/edit';
      case RoutePath.status:
        return '/home/status';
      case RoutePath.statusInfo:
        return '/home/status/info';
      case RoutePath.statusHistory:
        return '/home/status/history';
      case RoutePath.post:
        return '/home/post';
      case RoutePath.edit:
        return '/home/edit';
      case RoutePath.directory:
        return '/home/directory';
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
