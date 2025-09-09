// The main application and define the global variables.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';

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
      locale: schema?.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        LocaleNamesLocalizationsDelegate(),
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
        // The system preference page to view or edit the app settings
        GoRoute(
          path: RoutePath.preference.path,
          builder: (BuildContext context, GoRouterState state) {
            return BackableView(
              title: AppLocalizations.of(context)?.btn_drawer_preference ?? "Preference",
              child: SystemPreference(),
            );
          },
        ),
        // The webview page to view the external links
        GoRoute(
          path: RoutePath.webview.path,
          builder: (BuildContext context, GoRouterState state) {
            final Uri uri = state.extra as Uri;
            return WebViewPage(url: uri);
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

  // Build the home page with the sidebar and the main content.
  RouteBase homeRoutes() {
    return ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        final RoutePath path = RoutePath.values.where((p) => p.path == state.uri.path).first;

        Widget? title;
        bool backable = false;
        List<Widget> actions = [];

        switch (path) {
          case RoutePath.post:
          case RoutePath.edit:
          case RoutePath.status:
          case RoutePath.editProfile:
          case RoutePath.statusInfo:
          case RoutePath.statusHistory:
            backable = true;
            break;
          case RoutePath.directory:
            title = Text(AppLocalizations.of(context)?.btn_drawer_directory ?? "Directory");
            backable = true;
            break;
          case RoutePath.search:
            final String keyword = state.extra as String;

            title = Text(keyword);
            backable = true;
            break;
          case RoutePath.profile:
            final AccountSchema account = state.extra as AccountSchema;

            title = EmojiSchema.replaceEmojiToWidget(account.displayName, emojis: account.emojis);
            backable = true;
            break;
          case RoutePath.hashtag:
            final String hashtag = state.extra as String;

            title = Text('#$hashtag');
            backable = true;
            actions.add(FollowedHashtagButton(hashtag: hashtag));
            break;
          case RoutePath.listItem:
            final ListSchema schema = state.extra as ListSchema;
            final String prefix = AppLocalizations.of(context)?.btn_sidebar_lists ?? "Lists";

            title = Text('$prefix: ${schema.title}');
            backable = true;
            break;
          case RoutePath.filterForm:
            title = Text(AppLocalizations.of(context)?.btn_profile_filter ?? 'Filters');
            backable = true;
            break;
          default:
            break;
        }

        return GlacialHome(
          key: UniqueKey(),
          backable: backable,
          title: title,
          actions: actions,
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: RoutePath.timeline.path,
          builder: (_, _) {
            final AccessStatusSchema? status = ref.read(accessStatusProvider);

            return TimelineTab(
              initialType: status?.isSignedIn == true ? TimelineType.home : TimelineType.local,
              key: ValueKey('timeline_tab_${status?.domain}'),
            );
          },
        ),
        GoRoute(
          path: RoutePath.list.path,
          builder: (_, _) => const ListTimelineTab(),
        ),
        GoRoute(
          path: RoutePath.trends.path,
          builder: (_, _) => const TrendsTab(),
        ),
        GoRoute(
          path: RoutePath.notifications.path,
          builder: (_, _) => const GroupNotification(),
        ),
        GoRoute(
          path: RoutePath.admin.path,
          builder: (_, _) => const AdminTab(),
        ),

        // The backable sub-routes that can be used to navigate to the and pop-back.
        GoRoute(
          path: RoutePath.post.path,
          builder: (BuildContext context, GoRouterState state) {
            final StatusSchema? schema = state.extra as StatusSchema?;
            return PostStatusForm(replyTo: schema);
          },
        ),
        GoRoute(
          path: RoutePath.edit.path,
          builder: (BuildContext context, GoRouterState state) {
            final StatusSchema schema = state.extra as StatusSchema;
            return PostStatusForm(editFrom: schema);
          },
        ),
        GoRoute(
          path: RoutePath.status.path,
          builder: (BuildContext context, GoRouterState state) {
            final StatusSchema status = state.extra as StatusSchema;
            return StatusContext(schema: status);
          },
        ),
        GoRoute(
          path: RoutePath.search.path,
          builder: (BuildContext context, GoRouterState state) {
            final String keyword = state.extra as String;
            return ExplorerTab(keyword: keyword);
          },
        ),
        GoRoute(
          path: RoutePath.profile.path,
          builder: (BuildContext context, GoRouterState state) {
            final AccountSchema acocunt = state.extra as AccountSchema;
            return AccountProfile(schema: acocunt);
          },
        ),
        GoRoute(
          path: RoutePath.editProfile.path,
          builder: (BuildContext context, GoRouterState state) {
            final AccessStatusSchema? status = ref.read(accessStatusProvider);
            final AccountSchema? account = status?.account;

            return account == null ? const SizedBox.shrink() : EditProfilePage(account: account);
          }
        ),
        GoRoute(
          path: RoutePath.hashtag.path,
          builder: (BuildContext context, GoRouterState state) {
            final AccessStatusSchema? status = ref.read(accessStatusProvider);
            final String hashtag = state.extra as String;

            if (status == null) {
              logger.w("No server selected, but it's required to show the hashtag timeline.");
              return const SizedBox.shrink();
            }

            return Timeline(
              type: TimelineType.hashtag,
              status: status,
              hashtag: hashtag,
            );
          },
        ),
        GoRoute(
          path: RoutePath.statusInfo.path,
          builder: (BuildContext context, GoRouterState state) {
            final StatusSchema status = state.extra as StatusSchema;
            return StatusInfo(schema: status);
          },
        ),
        GoRoute(
          path: RoutePath.statusHistory.path,
          builder: (BuildContext context, GoRouterState state) {
            final StatusSchema status = state.extra as StatusSchema;
            return StatusHistory(schema: status);
          },
        ),
        GoRoute(
          path: RoutePath.directory.path,
          builder: (BuildContext context, GoRouterState state) => const DirectoryAccount(),
        ),
        GoRoute(
          path: RoutePath.listItem.path,
          builder: (BuildContext context, GoRouterState state) {
            final ListSchema? schema = state.extra as ListSchema?;
            return schema == null ? const SizedBox.shrink() : LiteTimeline(schema: schema);
          },
        ),
        GoRoute(
          path: RoutePath.filterForm.path,
          builder: (BuildContext context, GoRouterState state) {
            final String title = state.extra as String;
            return FiltersForm(title: title);
          },
        ),
      ],
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
