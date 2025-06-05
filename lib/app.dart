// The main application and define the global variables.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/screens.dart';

final navigatorKey = GlobalKey<NavigatorState>();

// The placeholder for the app's Work-In-Progress screen
class WIP extends StatelessWidget {
  const WIP({
    super.key,
  });

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

// The main application widget that contains the router and the theme.
class GlacialApp extends StatelessWidget {
  const GlacialApp({super.key});

  @override
  Widget build(BuildContext context) {
    final info = Info().info;

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: info == null ? "Glacial" : '${info.appName} (v${info.version})',

      // The theme mode
      themeMode: ThemeMode.dark,
      theme: ThemeData(useMaterial3: true, brightness: Brightness.light),
      darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark),

      // Localizations support for the app.
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,

      // The router implementation
      routerConfig: router(),
    );
  }

  // define the router for the app and how to handle the routes
  // with the optional animation
  GoRouter router() {
    return GoRouter(
      initialLocation: RoutePath.landing.path,
      navigatorKey: navigatorKey,
      routes: <RouteBase>[
        // The landing page, show the icon and preload the necessary resources
        GoRoute(
          path: RoutePath.landing.path,
          builder: (_, _) => const LandingPage(),
        ),
        // The engineering mode to show the app's internal information and settings
        // @animation: FadeTransition
        GoRoute(
          path: RoutePath.engineer.path,
          builder: (_, _) => const EngineeringMode(),
        ),
        // The server explorer page to search and show the available servers
        // @animation: FadeTransition
        GoRoute(
          path: RoutePath.explorer.path,
          builder: (_, __) => const ServerExplorer(),
        ),

        // The core home page and show the possible operations
        homeRoutes(),
      ],
      // The fallback page, show the WIP screen if the route is not found
      errorBuilder: (BuildContext context, GoRouterState state) {
        logger.w("the route ${state.uri} does not implement yet ...");
        return const WIP();
      }
    );
  }

  // Build the home page with the sidebar and the main content
  RouteBase homeRoutes() {
    return ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return GlacialHome(child: child);
      },
      routes: [
        // The glacial timeline page to show the server timeline in the selected
        // Mastodon server
        GoRoute(
          path: RoutePath.timeline.path,
          builder: (BuildContext context, GoRouterState state) =>const WIP(),
        ),
        // The glacial trends page to show the server trends in the selected
        // Mastodon server
        GoRoute(
          path: RoutePath.trends.path,
          builder: (BuildContext context, GoRouterState state) =>const WIP(),
        ),
        // The explorer page to search and show the target accounts, links, and
        // hashtags in the selected Mastodon server
        GoRoute(
          path: RoutePath.explorer.path,
          builder: (BuildContext context, GoRouterState state) =>const WIP(),
        ),
        // The glacial notifications page to show the server notifications in the
        // selected Mastodon server
        GoRoute(
          path: RoutePath.notifications.path,
          builder: (BuildContext context, GoRouterState state) => const WIP(),
        ),
        // The glacial settings page to show the server settings in the selected
        // Mastodon server
        GoRoute(
          path: RoutePath.settings.path,
          builder: (BuildContext context, GoRouterState state) => const WIP(),
        ),
        // The admin page to show the server management page in the selected
        // Mastodon server
        GoRoute(
          path: RoutePath.admin.path,
          builder: (BuildContext context, GoRouterState state) => const WIP(),
        ),
      ],
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
