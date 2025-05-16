// The routes.dart file defines the routes for the app.
import 'package:flutter/material.dart';

import 'package:glacial/core.dart';

class GoRouterObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    // Log the route change
    logger.i('pushed route: ${route.settings.name}');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    // Log the route change
    logger.i('popped route: ${route.settings.name}');
  }
}

// vim: set ts=2 sw=2 sts=2 et:
