// The routes.dart file defines the routes for the app.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:glacial/core.dart';

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
  home;

  // Get the string path for the route.
  String get path {
    switch (this) {
      case RoutePath.home:
        return '/';
    }
  }
}

final GoRouter router = GoRouter(
  initialLocation: RoutePath.home.path,
  routes: <RouteBase>[
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
