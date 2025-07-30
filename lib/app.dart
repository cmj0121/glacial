// The main application and define the global variables.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

final navigatorKey = GlobalKey<NavigatorState>();

// The main application widget that contains the router and the theme.
class CoreApp extends ConsumerStatefulWidget {
  final SystemPreferenceSchema? schema;

  const CoreApp({
    super.key,
    this.schema,
  });

  @override
  ConsumerState<CoreApp> createState() => _CoreAppState();
}

class _CoreAppState extends ConsumerState<CoreApp> {
  late SystemPreferenceSchema? schema = widget.schema;

  @override
  Widget build(BuildContext context) {
    final info = Info().info;
    final bool _ = ref.watch(reloadProvider);
    final SystemPreferenceSchema? schema = ref.read(preferenceProvider) ?? this.schema;

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: info == null ? "Glacial" : '${info.appName} (v${info.version})',

      // The theme mode
      themeMode: schema?.theme ?? ThemeMode.dark,
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
        // The core home page and show the possible operations
        homeRoutes(),

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
        // The user profile page to view the user details
        GoRoute(
          path: RoutePath.profile.path,
          builder: (BuildContext context, GoRouterState state) {
            return BackableView(
              title: RoutePath.profile.name,
              child: const WIP(),
            );
          },
        ),
        // The system preference page to view or edit the app settings
        GoRoute(
          path: RoutePath.preference.path,
          builder: (BuildContext context, GoRouterState state) {
            return BackableView(
              title: RoutePath.preference.name,
              child: SystemPreference(),
            );
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
  RouteBase homeRoutes() {
    final Map<RoutePath, Widget> routerMap = {
      RoutePath.timeline: const TimelineTab(),
      RoutePath.list: const WIP(),
      RoutePath.trends: const WIP(),
      RoutePath.notifications: WIP(),
      RoutePath.admin: const WIP(),
      RoutePath.post: const WIP(),
    };

    return ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return GlacialHome(key: ValueKey(state.uri.path), child: child);
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
