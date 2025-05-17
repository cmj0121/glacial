// The routes.dart file defines the routes for the app.
import 'package:flutter/material.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/glacial/screens/core.dart';

class WIP extends StatelessWidget {
  const WIP({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
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
  landing,    // The landing page of the app when user opens it.
  explorer,   // The server explorer page of the app.
  home;       // The home page of the app to show the server explorer.

  // Get the string path for the route.
  String get path {
    switch (this) {
      case RoutePath.landing:
        return '/';
      case RoutePath.explorer:
        return '/explorer';
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
      path: RoutePath.explorer.path,
      builder: (BuildContext context, GoRouterState state) => const ServerExplorer(),
    ),
    GoRoute(
      path: RoutePath.home.path,
      builder: (BuildContext context, GoRouterState state) => const WIP(),
    ),
  ],
  observers: [
    GoRouterObserver(),
  ],
);

// vim: set ts=2 sw=2 sts=2 et:
