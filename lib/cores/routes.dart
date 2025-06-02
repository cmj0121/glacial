// The routes.dart file defines the routes for the app.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum RoutePath {
  landing,           // The landing page of the app when user opens it.
  wip;               // The work-in-progress page of the app.

  // Get the string path for the route.
  String get path {
    switch (this) {
      case RoutePath.landing:
        return '/';
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
