// The main application and define the global variables.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';
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
class GlacialApp extends ConsumerWidget {
  const GlacialApp({super.key});

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
        // The landing page, show the icon and preload the necessary resources
        GoRoute(
          path: RoutePath.landing.path,
          builder: (_, _) => const LandingPage(),
        ),
        // The engineering mode to show the app's internal information and settings
        GoRoute(
          path: RoutePath.engineer.path,
          builder: (_, _) => const EngineeringMode(),
        ),
        // The server explorer page to search and show the available servers
        GoRoute(
          path: RoutePath.explorer.path,
          builder: (_, __) => const ServerExplorer(),
        ),
        // The webview page to show the in-app webview with specified URL
        GoRoute(
          path: RoutePath.webview.path,
          builder: (BuildContext context, GoRouterState state) {
            final Uri? url = state.extra as Uri?;

            if (url == null) {
              logger.w("the url is null, cannot open the webview");
              context.pop();
              return const SizedBox.shrink();
            }

            return WebViewPage(url: url);
          },
        ),

        // The core home page and show the possible operations
        homeRoutes(ref),
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
    return ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        late final ServerSchema? server = ref.watch(serverProvider);

        if (server == null) {
          logger.w("No server selected, cannot build the home page.");
          return const WIP();
        }

        return GlacialHome(server: server, child: child);
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
          builder: (BuildContext context, GoRouterState state) =>const TrendsTab(),
        ),
        // The explorer page to search and show the target accounts, links, and
        // hashtags in the selected Mastodon server
        GoRoute(
          path: RoutePath.search.path,
          builder: (BuildContext context, GoRouterState state) {
            final String keyword = state.extra as String;
            return ExplorerTab(keyword: keyword);
          },
        ),
        // The glacial notifications page to show the server notifications in the
        // selected Mastodon server
        GoRoute(
          path: RoutePath.notifications.path,
          builder: (BuildContext context, GoRouterState state) => const GroupNotification(),
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
        // Show the timeline based on the specified hashtag
        GoRoute(
          path: RoutePath.hashtag.path,
          builder: (BuildContext context, GoRouterState state) {
            final ServerSchema? server = ref.read(serverProvider);
            final String hashtag = state.extra as String;

            if (server == null) {
              logger.w("No server selected, cannot show the hashtag timeline.");
              return const SizedBox.shrink();
            }

            final Widget timeline = Timeline(
              schema: server,
              type: TimelineType.hashtag,
              keyword: hashtag,
            );

            return BackableView(
              title: '#$hashtag',
              child: timeline,
            );
          },
        ),
        // The user's profile page to show the user account details and the
        // user timeline in the selected Mastodon server
        GoRoute(
          path: RoutePath.profile.path,
          builder: (BuildContext context, GoRouterState state) {
            final AccountSchema account = state.extra as AccountSchema;
            final Widget content = AccountProfile(schema: account);

            return BackableView(
              title: account.displayName,
              child: content,
            );
          },
        ),
        // The sub-route to show the context of the status, including the previous
        // and next statuses related to the current status
        GoRoute(
          path: RoutePath.status.path,
          builder: (BuildContext context, GoRouterState state) {
            final StatusSchema status = state.extra as StatusSchema;

            return BackableView(
              title: AppLocalizations.of(context)?.btn_trends_statuses ?? "Post",
              child: StatusContext(schema: status),
            );
          },
        ),
        // The post page to create a new post in the selected Mastodon server
        GoRoute(
          path: RoutePath.post.path,
          builder: (BuildContext context, GoRouterState state) {
            final StatusSchema? schema = state.extra as StatusSchema?;
            return BackableView(
              child: StatusForm(replyTo: schema),
            );
          },
        ),
      ],
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
