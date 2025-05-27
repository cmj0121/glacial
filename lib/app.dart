// The main application and define the global variables.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/core.dart';

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

// The global animation for child that fade-out the current page and fade-in
// the new page
CustomTransitionPage fadeTransitionPage({required Widget child, required GoRouterState state}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  );
}

// The global animation for child that scale the current page and fade-in
// the new page
CustomTransitionPage scaleTransitionPage({required Widget child, required GoRouterState state}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return ScaleTransition(
        scale: Tween<double>(begin: 0.8, end: 1.0).animate(animation),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
  );
}

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
          pageBuilder: (BuildContext context, GoRouterState state) => fadeTransitionPage(
            state: state,
            child: const EngineeringMode(),
          ),
        ),
        // The server explorer page to search and show the available servers
        // @animation: FadeTransition
        GoRoute(
          path: RoutePath.serverExplorer.path,
          pageBuilder: (BuildContext context, GoRouterState state) => fadeTransitionPage(
            state: state,
            child: const ServerExplorer(),
          ),
        ),
        // The webview page to show the in-app webview with specified URL
        // @animation: FadeTransition
        GoRoute(
          path: RoutePath.webview.path,
          pageBuilder: (BuildContext context, GoRouterState state) {
            final Uri? url = state.extra as Uri?;
            final Widget child = url == null ? const SizedBox.shrink() : WebViewPage(url: url);

            if (url == null) {
              logger.w("the url is null, cannot open the webview");
              context.pop();
            }

            return fadeTransitionPage(
              state: state,
              child: child,
            );
          },
        ),

        // The core glacial page and show the possible operations
        glacialRoutes(),
      ],
      // The fallback page, show the WIP screen if the route is not found
      errorBuilder: (BuildContext context, GoRouterState state) {
        logger.w("the route ${state.uri} does not implement yet ...");
        return const WIP();
      }
    );
  }

  // Build the glacial home page with the sidebar and the main content
  RouteBase glacialRoutes() {
    return ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return GlacialHome(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(
                scale: Tween<double>(begin: 0.8, end: 1.0).animate(animation),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: KeyedSubtree(
              child: child,
            ),
          ),
        );
      },
      routes: [
        // The glacial timeline page to show the server timeline in the selected
        // Mastodon server
        GoRoute(
          path: RoutePath.timeline.path,
          builder: (BuildContext context, GoRouterState state) =>const TimelineTab(),
        ),
        // The glacial trends page to show the server trends in the selected
        // Mastodon server
        GoRoute(
          path: RoutePath.trends.path,
          builder: (BuildContext context, GoRouterState state) => const TrendsTab(),
        ),
        // The explorer page to search and show the target accounts, links, and
        // hashtags in the selected Mastodon server
        GoRoute(
          path: RoutePath.explorer.path,
          builder: (BuildContext context, GoRouterState state) {
            final String keyword = state.extra as String;
            return ExplorerTab(keyword: keyword);
          },
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
        // The sub-route to show the context of the status, including the previous
        // and next statuses related to the current status
        GoRoute(
          path: RoutePath.statusContext.path,
          builder: (BuildContext context, GoRouterState state) {
            final StatusSchema status = state.extra as StatusSchema;
            final Widget content = StatusContext(schema: status);

            return BackableView(
              title: AppLocalizations.of(context)?.btn_post ?? "Post",
              child: content,
            );
          },
        ),
        // The sub-route to show the user profile page with the specified user
        GoRoute(
          path: RoutePath.userProfile.path,
          builder: (BuildContext context, GoRouterState state) {
            final AccountSchema schema = state.extra as AccountSchema;
            final Widget content = AccountProfile(schema: schema);

            return BackableView(
              title: schema.displayName,
              child: content,
            );
          },
        ),
        // Show the timeline based on the specified hashtag
        GoRoute(
          path: RoutePath.hashtagTimeline.path,
          builder: (BuildContext context, GoRouterState state) {
            final HashTagSchema schema = state.extra as HashTagSchema;
            final Widget content = TimelineBuilder(
              type: TimelineType.hashtag,
              keyword: schema.name,
            );

            return BackableView(
              title: '#${schema.name}',
              child: content,
            );
          },
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
