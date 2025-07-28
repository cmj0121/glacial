// The main application and define the global variables.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/screens.dart';

final navigatorKey = GlobalKey<NavigatorState>();

// The main application widget that contains the router and the theme.
class CoreApp extends ConsumerWidget {
  const CoreApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      routerConfig: router(ref),
    );
  }

  // define the router for the app and how to handle the routes
  // with the optional animation
  GoRouter router(WidgetRef ref) {
    return GoRouter(
      initialLocation: RoutePath.landing.path,
      navigatorKey: navigatorKey,
      routes: <RouteBase>[
        // The core home page and show the possible operations
        homeRoutes(ref),

        // The landing page of the app, shows the welcome message and navigation to the
        // next pages.
        GoRoute(
          path: RoutePath.landing.path,
          builder: (BuildContext context, GoRouterState state) {
            return const LandingPage();
          },
        ),
        // The mastodon server explorer page
        GoRoute(
          path: RoutePath.explorer.path,
          builder: (BuildContext context, GoRouterState state) {
            return const ServerExplorer();
          },
        ),
        // The system preference page to view or edit the app settings
        GoRoute(
          path: RoutePath.preference.path,
          builder: (BuildContext context, GoRouterState state) {
            return const SystemPreference();
          },
        ),
      ],
      // The fallback page, show the WIP screen if the route is not found
      errorBuilder: (BuildContext context, GoRouterState state) {
        logger.w("the route ${state.uri} does not implement yet ...");
        return const WIP();
      }
    );
  }

  // Build the home page with the sidebar and the main content
  RouteBase homeRoutes(WidgetRef ref) {
    final Map<RoutePath, Widget> routerMap = {
      RoutePath.timeline: const WIP(),
      RoutePath.trends: const WIP(),
      RoutePath.notifications: WIP(),
      RoutePath.admin: const WIP(),
      RoutePath.post: const WIP(),
    };

    return ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return GlacialHome(child: child);
      },
      routes: routerMap.entries.map((entry) {
        return GoRoute(
          path: entry.key.path,
          builder: (BuildContext context, GoRouterState state) {
            return entry.value;
          },
        );
      }).toList(),
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
