// The routes.dart file defines the routes for the app.
import 'package:flutter/material.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/engineer/screens/core.dart';
import 'package:glacial/features/glacial/screens/core.dart';
import 'package:glacial/features/timeline/screens/core.dart';
import 'package:glacial/features/webview/screens/core.dart';

class WIP extends StatelessWidget {
  final bool allowBack;

  const WIP({
    super.key,
    this.allowBack = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: allowBack ? AppBar() : null,
      body: SafeArea(
        child: Center(
          child: Text(
            "Work in Progress",
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ),
      ),
    );
  }
}

enum RoutePath {
  landing,           // The landing page of the app when user opens it.
  engineer,          // The engineer page of the app.
  explorer,          // The server explorer page of the app.
  webview,           // The in-app webview page of the app.
  statusContext,     // The status context page of the app.
  homeTimeline,      // The timeline page of the app.
  homeTrends,        // The trends page of the app.
  homeExplore,       // The explore page of the app.
  homeNotifications, // The notifications page of the app.
  homeSettings,      // The settings page of the app.
  home;              // The home page of the app to show the server explorer.

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
      case RoutePath.statusContext:
        return '/home/status/context';
      case RoutePath.homeTimeline:
        return '/home/timeline';
      case RoutePath.homeTrends:
        return '/home/trends';
      case RoutePath.homeExplore:
        return '/home/explore';
      case RoutePath.homeNotifications:
        return '/home/notifications';
      case RoutePath.homeSettings:
        return '/home/settings';
      case RoutePath.home:
        return '/home';
    }
  }
}

final GoRouter router = GoRouter(
  initialLocation: RoutePath.landing.path,
  routes: <RouteBase>[
    GoRoute(
      path: RoutePath.landing.path,
      builder: (BuildContext context, GoRouterState state) => const LandingPage(),
    ),
    GoRoute(
      path: RoutePath.engineer.path,
      builder: (BuildContext context, GoRouterState state) => const EnginnerMode(),
    ),
    GoRoute(
      path: RoutePath.explorer.path,
      builder: (BuildContext context, GoRouterState state) => const ServerExplorer(),
    ),
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        final SidebarButtonType? active = state.extra is SidebarButtonType ? state.extra as SidebarButtonType? : null;

        return GlacialHome(active: active, child: child);
      },
      routes: [
        GoRoute(
          path: RoutePath.home.path,
          builder: (BuildContext context, GoRouterState state) => const TimelineTab(),
        ),
        GoRoute(
          path: RoutePath.homeTimeline.path,
          builder: (BuildContext context, GoRouterState state) => const TimelineTab(),
        ),
        GoRoute(
          path: RoutePath.homeTrends.path,
          builder: (BuildContext context, GoRouterState state) => const WIP(),
        ),
        GoRoute(
          path: RoutePath.homeExplore.path,
          builder: (BuildContext context, GoRouterState state) => const WIP(),
        ),
        GoRoute(
          path: RoutePath.homeNotifications.path,
          builder: (BuildContext context, GoRouterState state) => const WIP(),
        ),
        GoRoute(
          path: RoutePath.homeSettings.path,
          builder: (BuildContext context, GoRouterState state) => const WIP(),
        ),
        GoRoute(
          path: RoutePath.statusContext.path,
          builder: (BuildContext context, GoRouterState state) => const WIP(allowBack: true),
        ),
      ],
    ),
    GoRoute(
      path: RoutePath.webview.path,
      builder: (BuildContext context, GoRouterState state) {
        final Uri url = state.extra as Uri;
        return WebViewPage(url: url);
      },
    ),
  ],
  observers: [
    GoRouterObserver(),
  ],
);

// vim: set ts=2 sw=2 sts=2 et:
