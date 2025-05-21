// The routes.dart file defines the routes for the app.
import 'package:flutter/material.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/engineer/screens/core.dart';
import 'package:glacial/features/explore/screens/core.dart';
import 'package:glacial/features/glacial/screens/core.dart';
import 'package:glacial/features/timeline/models/core.dart';
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

class RouteBackWrapper extends StatelessWidget {
  final Widget child;
  final String title;

  const RouteBackWrapper({
    super.key,
    required this.child,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildBackButton(context),
        const Divider(),
        Flexible(child: child),
      ],
    );
  }

  Widget buildBackButton(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        Expanded(
          child: Center(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
      ],
    );
  }
}

enum RoutePath {
  landing,           // The landing page of the app when user opens it.
  engineer,          // The engineer page of the app.
  explorer,          // The server explorer page of the app.
  webview,           // The in-app webview page of the app.
  statusContext,     // The status context page of the app.
  hashtagTimeline,   // The timeline with the specified hashtag.
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
      case RoutePath.hashtagTimeline:
        return '/hashtag';
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
          pageBuilder: (BuildContext context, GoRouterState state) {
            return CustomTransitionPage(
              key: state.pageKey,
              child: const TimelineTab(),
              transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
                return ScaleTransition(
                  scale: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  )),
                  child: child,
                );
              },
            );
          },
        ),
        GoRoute(
          path: RoutePath.homeTimeline.path,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return CustomTransitionPage(
              key: state.pageKey,
              child: const TimelineTab(),
              transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
                return ScaleTransition(
                  scale: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  )),
                  child: child,
                );
              },
            );
          },
        ),
        GoRoute(
          path: RoutePath.homeTrends.path,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return CustomTransitionPage(
              key: state.pageKey,
              child: const WIP(),
              transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
                return ScaleTransition(
                  scale: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  )),
                  child: child,
                );
              },
            );
          },
        ),
        GoRoute(
          path: RoutePath.homeExplore.path,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return CustomTransitionPage(
              key: state.pageKey,
              child: const Explorer(),
              transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
                return ScaleTransition(
                  scale: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  )),
                  child: child,
                );
              },
            );
          },
        ),
        GoRoute(
          path: RoutePath.homeNotifications.path,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return CustomTransitionPage(
              key: state.pageKey,
              child: const WIP(),
              transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
                return ScaleTransition(
                  scale: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  )),
                  child: child,
                );
              },
            );
          },
        ),
        GoRoute(
          path: RoutePath.homeSettings.path,
          pageBuilder: (BuildContext context, GoRouterState state) {
            return CustomTransitionPage(
              key: state.pageKey,
              child: const WIP(),
              transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
                return ScaleTransition(
                  scale: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  )),
                  child: child,
                );
              },
            );
          },
        ),

        GoRoute(
          path: RoutePath.statusContext.path,
          pageBuilder: (BuildContext context, GoRouterState state) {
            final StatusSchema status = state.extra as StatusSchema;
            return NoTransitionPage(
              key: state.pageKey,
              child: RouteBackWrapper(
                title: AppLocalizations.of(context)?.btn_post ?? "Post",
                child: StatusContext(schema: status),
              ),
            );
          },
        ),

        GoRoute(
          path: RoutePath.hashtagTimeline.path,
          pageBuilder: (BuildContext context, GoRouterState state) {
            final String tag = state.extra as String;
            final String text = AppLocalizations.of(context)?.btn_hashtag_timeline ?? "Hashtag";
            return NoTransitionPage(
              key: state.pageKey,
              child: RouteBackWrapper(
                title: '$text: $tag',
                child: TimelineBuilder(
                  type: TimelineType.hashtag,
                  keyword: tag,
                ),
              ),
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: RoutePath.webview.path,
      builder: (BuildContext context, GoRouterState state) {
        final Uri url = state.extra as Uri;
        logger.d("opening webview: $url");
        return WebViewPage(url: url);
      },
    ),
  ],
  observers: [
    GoRouterObserver(),
  ],
);

// vim: set ts=2 sw=2 sts=2 et:
