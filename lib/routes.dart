// The routes.dart file defines the routes for the app.
import 'package:flutter/material.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/glacial/screens/core.dart';

class WIP extends StatelessWidget {
  const WIP({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
  landing,
  home;

  // Get the string path for the route.
  String get path {
    switch (this) {
      case RoutePath.landing:
        return '/';
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
      path: RoutePath.home.path,
      builder: (BuildContext context, GoRouterState state) => const ServerExplorer(),
    ),
  ],
  observers: [
    GoRouterObserver(),
  ],
);

// vim: set ts=2 sw=2 sts=2 et:
