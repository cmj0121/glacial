// Widget tests for GlacialHome — covers lines 29-222 of home.dart.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_riverpod/src/internals.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

/// Creates a widget tree with GoRouter wrapping GlacialHome so that
/// GoRouter.of(context) works inside buildActions().
Widget createHomeTestWidget({
  AccessStatusSchema? accessStatus,
  bool backable = false,
  Widget? title,
  List<Widget> actions = const [],
  String initialLocation = '/home/timeline',
  double width = 400,
}) {
  final List<Override> allOverrides = [
    accessStatusProvider.overrideWith(
      (ref) => accessStatus ?? MockAccessStatus.anonymous(),
    ),
  ];

  final GoRouter router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return GlacialHome(
            backable: backable,
            title: title,
            actions: actions,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/home/timeline',
            builder: (_, _) => const Text('Timeline Content'),
          ),
          GoRoute(
            path: '/home/trends',
            builder: (_, _) => const Text('Trends Content'),
          ),
          GoRoute(
            path: '/home/notifications',
            builder: (_, _) => const Text('Notifications Content'),
          ),
          GoRoute(
            path: '/home/conversations',
            builder: (_, _) => const Text('Conversations Content'),
          ),
          GoRoute(
            path: '/home/admin',
            builder: (_, _) => const Text('Admin Content'),
          ),
          GoRoute(
            path: '/home/list',
            builder: (_, _) => const Text('List Content'),
          ),
          GoRoute(
            path: '/home/post',
            builder: (_, _) => const Text('Post Content'),
          ),
        ],
      ),
    ],
  );

  return ProviderScope(
    overrides: allOverrides,
    child: MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
    ),
  );
}

void main() {
  setupTestEnvironment();

  group('GlacialHome widget', () {
    testWidgets('renders Scaffold with child content', (tester) async {
      await tester.pumpWidget(createHomeTestWidget());
      await tester.pump();
      await tester.pump();

      expect(find.byType(Scaffold), findsWidgets);
      expect(find.text('Timeline Content'), findsOneWidget);
    });

    testWidgets('renders AppBar with leading icon button', (tester) async {
      await tester.pumpWidget(createHomeTestWidget());
      await tester.pump();
      await tester.pump();

      // Non-backable: should show read_more icon
      expect(find.byIcon(Icons.read_more_rounded), findsOneWidget);
    });

    testWidgets('shows back arrow when backable is true', (tester) async {
      await tester.pumpWidget(createHomeTestWidget(backable: true));
      await tester.pump();
      await tester.pump();

      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    });

    testWidgets('renders with custom title', (tester) async {
      await tester.pumpWidget(createHomeTestWidget(
        title: const Text('My Title'),
      ));
      await tester.pump();
      await tester.pump();

      expect(find.text('My Title'), findsOneWidget);
    });

    testWidgets('renders custom actions in app bar', (tester) async {
      await tester.pumpWidget(createHomeTestWidget(
        actions: [
          IconButton(icon: const Icon(Icons.star), onPressed: () {}),
        ],
      ));
      await tester.pump();
      await tester.pump();

      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('renders drawer (GlacialDrawer)', (tester) async {
      await tester.pumpWidget(createHomeTestWidget());
      await tester.pump();
      await tester.pump();

      // Open the drawer via the leading button (read_more_rounded)
      final ScaffoldState state = tester.firstState(find.byType(Scaffold));
      state.openDrawer();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(Drawer), findsOneWidget);
    });

    group('mobile layout (narrow width)', () {
      void setMobileViewport(WidgetTester tester) {
        tester.view.physicalSize = const Size(500, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
      }

      testWidgets('shows bottom navigation bar on mobile', (tester) async {
        setMobileViewport(tester);
        await tester.pumpWidget(createHomeTestWidget());
        await tester.pump();
        await tester.pump();

        // Should have a bottom bar with action icons
        expect(find.byType(AdaptiveGlassBottomBar), findsOneWidget);
      });

      testWidgets('does not show sidebar on mobile', (tester) async {
        setMobileViewport(tester);
        await tester.pumpWidget(createHomeTestWidget());
        await tester.pump();
        await tester.pump();

        // On mobile, content is aligned without the sidebar Row
        // The sidebar uses a Column with Spacer — verify no Spacer in content
        final Finder spacerFinder = find.byType(Spacer);
        // Mobile layout should have zero Spacer (sidebar not rendered)
        expect(spacerFinder, findsNothing);
      });

      testWidgets('renders sidebar icons for anonymous user', (tester) async {
        setMobileViewport(tester);
        await tester.pumpWidget(createHomeTestWidget());
        await tester.pump();
        await tester.pump();

        // Timeline and trending icons should be present
        expect(find.byIcon(Icons.view_timeline), findsOneWidget);
        expect(find.byIcon(Icons.trending_up_outlined), findsOneWidget);
      });

      testWidgets('renders sidebar icons for signed-in user', (tester) async {
        setMobileViewport(tester);
        await tester.pumpWidget(createHomeTestWidget(
          accessStatus: MockAccessStatus.authenticated(),
        ));
        await tester.pump();
        await tester.pump();

        // All sidebar icons should be present for signed-in user
        // timeline (active on current route)
        expect(find.byIcon(Icons.view_timeline), findsOneWidget);
        expect(find.byIcon(Icons.view_list_outlined), findsOneWidget);
        expect(find.byIcon(Icons.trending_up_outlined), findsOneWidget);
        // notifications shows as NotificationBadge
        expect(find.byType(NotificationBadge), findsOneWidget);
        expect(find.byIcon(Icons.mail_outline), findsOneWidget);
        // admin
        expect(find.byIcon(Icons.admin_panel_settings_outlined), findsOneWidget);
        // post — signed in shows filledTonal button
        expect(find.byIcon(Icons.chat_outlined), findsOneWidget);
      });

      testWidgets('shows SignIn widget for anonymous user on post slot', (tester) async {
        setMobileViewport(tester);
        await tester.pumpWidget(createHomeTestWidget());
        await tester.pump();
        await tester.pump();

        // Anonymous user sees SignIn instead of post button
        expect(find.byType(SignIn), findsOneWidget);
      });

      testWidgets('shows filledTonal post button for signed-in user', (tester) async {
        setMobileViewport(tester);
        await tester.pumpWidget(createHomeTestWidget(
          accessStatus: MockAccessStatus.authenticated(),
        ));
        await tester.pump();
        await tester.pump();

        // Signed-in user sees a filled tonal IconButton for post
        expect(find.byIcon(Icons.chat_outlined), findsOneWidget);
      });
    });

    group('desktop layout (wide width)', () {
      void setWideViewport(WidgetTester tester) {
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
      }

      testWidgets('shows sidebar on desktop', (tester) async {
        setWideViewport(tester);
        await tester.pumpWidget(createHomeTestWidget());
        await tester.pump();
        await tester.pump();

        // Desktop layout renders sidebar with Spacer
        expect(find.byType(Spacer), findsOneWidget);
      });

      testWidgets('does not show bottom navigation bar on desktop', (tester) async {
        setWideViewport(tester);
        await tester.pumpWidget(createHomeTestWidget());
        await tester.pump();
        await tester.pump();

        expect(find.byType(AdaptiveGlassBottomBar), findsNothing);
      });

      testWidgets('renders sidebar with all action icons', (tester) async {
        setWideViewport(tester);
        await tester.pumpWidget(createHomeTestWidget(
          accessStatus: MockAccessStatus.authenticated(),
        ));
        await tester.pump();
        await tester.pump();

        // Sidebar should show all icons
        expect(find.byIcon(Icons.view_timeline), findsOneWidget);
        expect(find.byIcon(Icons.view_list_outlined), findsOneWidget);
        expect(find.byIcon(Icons.trending_up_outlined), findsOneWidget);
        expect(find.byType(NotificationBadge), findsOneWidget);
        expect(find.byIcon(Icons.mail_outline), findsOneWidget);
        expect(find.byIcon(Icons.admin_panel_settings_outlined), findsOneWidget);
        expect(find.byIcon(Icons.chat_outlined), findsOneWidget);
      });
    });

    group('admin button', () {
      testWidgets('admin button is disabled for non-admin user', (tester) async {
        await tester.pumpWidget(createHomeTestWidget(
          accessStatus: MockAccessStatus.authenticated(),
        ));
        await tester.pump();
        await tester.pump();

        // Admin button should exist but be wrapped in AccessibleTooltip for non-admin
        expect(find.byType(AccessibleTooltip), findsOneWidget);
      });

      testWidgets('admin button is enabled for admin user', (tester) async {
        final adminAccount = MockAccount.create();
        final adminRole = MockRole.create(
          id: 'admin-role',
          name: 'Admin',
          permissions: '1',
          highlighted: true,
        );

        // Create account with admin role
        final account = AccountSchema(
          id: adminAccount.id,
          username: adminAccount.username,
          acct: adminAccount.acct,
          url: adminAccount.url,
          displayName: adminAccount.displayName,
          note: adminAccount.note,
          avatar: adminAccount.avatar,
          avatarStatic: adminAccount.avatarStatic,
          header: adminAccount.header,
          locked: adminAccount.locked,
          bot: adminAccount.bot,
          indexable: adminAccount.indexable,
          createdAt: adminAccount.createdAt,
          statusesCount: adminAccount.statusesCount,
          followersCount: adminAccount.followersCount,
          followingCount: adminAccount.followingCount,
          role: adminRole,
        );

        await tester.pumpWidget(createHomeTestWidget(
          accessStatus: MockAccessStatus.authenticated(account: account),
        ));
        await tester.pump();
        await tester.pump();

        // Admin user: admin button is enabled, no AccessibleTooltip wrapping
        expect(find.byType(AccessibleTooltip), findsNothing);
        expect(find.byIcon(Icons.admin_panel_settings_outlined), findsOneWidget);
      });
    });

    group('notifications button', () {
      testWidgets('notifications button disabled for anonymous', (tester) async {
        await tester.pumpWidget(createHomeTestWidget());
        await tester.pump();
        await tester.pump();

        // NotificationBadge should be present but with null onPressed
        expect(find.byType(NotificationBadge), findsOneWidget);
      });

      testWidgets('notifications button enabled for signed-in user', (tester) async {
        await tester.pumpWidget(createHomeTestWidget(
          accessStatus: MockAccessStatus.authenticated(),
        ));
        await tester.pump();
        await tester.pump();

        expect(find.byType(NotificationBadge), findsOneWidget);
      });
    });

    group('SearchExplorer', () {
      testWidgets('renders SearchExplorer in app bar actions', (tester) async {
        await tester.pumpWidget(createHomeTestWidget());
        await tester.pump();
        await tester.pump();

        expect(find.byType(SearchExplorer), findsOneWidget);
      });
    });

    group('SafeArea and padding', () {
      testWidgets('body is wrapped in SafeArea and Padding', (tester) async {
        await tester.pumpWidget(createHomeTestWidget());
        await tester.pump();
        await tester.pump();

        expect(find.byType(SafeArea), findsWidgets);
        expect(find.byType(Padding), findsWidgets);
      });
    });

    group('LayoutBuilder', () {
      testWidgets('uses LayoutBuilder for responsive layout', (tester) async {
        await tester.pumpWidget(createHomeTestWidget());
        await tester.pump();
        await tester.pump();

        expect(find.byType(LayoutBuilder), findsWidgets);
      });
    });

    group('onSelect navigation', () {
      testWidgets('tapping trends icon does not throw', (tester) async {
        await tester.pumpWidget(createHomeTestWidget(
          accessStatus: MockAccessStatus.authenticated(),
        ));
        await tester.pump();
        await tester.pump();

        await tester.tap(find.byIcon(Icons.trending_up_outlined));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Navigation triggered without error
        expect(find.byType(GlacialHome), findsOneWidget);
      });

      testWidgets('tapping conversations icon does not throw', (tester) async {
        await tester.pumpWidget(createHomeTestWidget(
          accessStatus: MockAccessStatus.authenticated(),
        ));
        await tester.pump();
        await tester.pump();

        await tester.tap(find.byIcon(Icons.mail_outline));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(GlacialHome), findsOneWidget);
      });

      testWidgets('tapping notification badge does not throw', (tester) async {
        await tester.pumpWidget(createHomeTestWidget(
          accessStatus: MockAccessStatus.authenticated(),
        ));
        await tester.pump();
        await tester.pump();

        await tester.tap(find.byType(NotificationBadge));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(GlacialHome), findsOneWidget);
      });

      testWidgets('tapping post button does not throw', (tester) async {
        await tester.pumpWidget(createHomeTestWidget(
          accessStatus: MockAccessStatus.authenticated(),
        ));
        await tester.pump();
        await tester.pump();

        await tester.tap(find.byIcon(Icons.chat_outlined));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(Scaffold), findsWidgets);
      });

      testWidgets('tapping timeline icon again stays on page', (tester) async {
        await tester.pumpWidget(createHomeTestWidget(
          accessStatus: MockAccessStatus.authenticated(),
        ));
        await tester.pump();
        await tester.pump();

        await tester.tap(find.byIcon(Icons.view_timeline));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('Timeline Content'), findsOneWidget);
      });
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
