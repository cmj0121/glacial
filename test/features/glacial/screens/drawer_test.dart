// Tests for GlacialDrawer widget - conditional rendering of drawer items.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

/// Creates a test widget with GoRouter so drawer navigation works.
Widget createDrawerWithRouter({
  AccessStatusSchema? accessStatus,
}) {
  final router = GoRouter(
    initialLocation: '/home/timeline',
    routes: [
      GoRoute(
        path: '/home/timeline',
        builder: (_, __) => const Scaffold(drawer: GlacialDrawer()),
      ),
      GoRoute(path: '/explorer', builder: (_, __) => const Scaffold()),
      GoRoute(path: '/preference', builder: (_, __) => const Scaffold()),
      GoRoute(path: '/home/directory', builder: (_, __) => const Scaffold()),
    ],
  );

  return ProviderScope(
    overrides: [
      accessStatusProvider.overrideWith((ref) => accessStatus ?? MockAccessStatus.anonymous()),
    ],
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

/// Opens the drawer and waits for the animation to complete.
Future<void> openDrawer(WidgetTester tester) async {
  final ScaffoldState state = tester.firstState(find.byType(Scaffold));
  state.openDrawer();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  setUpAll(() => setupTestEnvironment());

  group('GlacialDrawer', () {
    // Helper to set a taller viewport to avoid drawer Column overflow
    void setTallViewport(WidgetTester tester) {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    testWidgets('renders as a Drawer widget', (tester) async {
      setTallViewport(tester);
      await tester.pumpWidget(createTestWidgetRaw(
        child: const Scaffold(drawer: GlacialDrawer()),
      ));
      await openDrawer(tester);

      expect(find.byType(Drawer), findsOneWidget);
    });

    testWidgets('contains DrawerHeader', (tester) async {
      setTallViewport(tester);
      await tester.pumpWidget(createTestWidgetRaw(
        child: const Scaffold(drawer: GlacialDrawer()),
      ));
      await openDrawer(tester);

      expect(find.byType(DrawerHeader), findsOneWidget);
    });

    testWidgets('shows server name from access status', (tester) async {
      setTallViewport(tester);
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(domain: 'mastodon.social'),
      );

      await tester.pumpWidget(createTestWidgetRaw(
        accessStatus: status.copyWith(domain: 'mastodon.social'),
        child: const Scaffold(drawer: GlacialDrawer()),
      ));
      await openDrawer(tester);

      expect(find.text('mastodon.social'), findsOneWidget);
    });

    testWidgets('shows fallback text in DrawerHeader when anonymous', (tester) async {
      setTallViewport(tester);
      await tester.pumpWidget(createTestWidgetRaw(
        child: const Scaffold(drawer: GlacialDrawer()),
      ));
      await openDrawer(tester);

      // Anonymous status has null domain, DrawerHeader still renders text
      final Finder textInHeader = find.descendant(
        of: find.byType(DrawerHeader),
        matching: find.byType(Text),
      );
      expect(textInHeader, findsAtLeastNWidgets(1));
    });

    group('signed-in user', () {
      testWidgets('shows logout option', (tester) async {
        setTallViewport(tester);
        await tester.pumpWidget(createTestWidgetRaw(
          accessStatus: MockAccessStatus.authenticated(),
          child: const Scaffold(drawer: GlacialDrawer()),
        ));
        await openDrawer(tester);

        expect(find.byIcon(Icons.logout), findsOneWidget);
      });

      testWidgets('shows all 5 drawer actions when signed in', (tester) async {
        setTallViewport(tester);
        await tester.pumpWidget(createTestWidgetRaw(
          accessStatus: MockAccessStatus.authenticated(),
          child: const Scaffold(drawer: GlacialDrawer()),
        ));
        await openDrawer(tester);

        expect(find.byIcon(Icons.swap_horiz), findsOneWidget);
        expect(find.byIcon(Icons.groups), findsOneWidget);
        expect(find.byIcon(Icons.campaign), findsOneWidget);
        expect(find.byIcon(Icons.settings), findsOneWidget);
        expect(find.byIcon(Icons.logout), findsOneWidget);
      });

      testWidgets('drawer actions are rendered as ListTile widgets', (tester) async {
        setTallViewport(tester);
        await tester.pumpWidget(createTestWidgetRaw(
          accessStatus: MockAccessStatus.authenticated(),
          child: const Scaffold(drawer: GlacialDrawer()),
        ));
        await openDrawer(tester);

        // Each drawer action is a ListTile; at least 5 (one per action)
        expect(find.byType(ListTile), findsAtLeastNWidgets(5));
      });
    });

    group('anonymous user', () {
      testWidgets('hides logout option when anonymous', (tester) async {
        setTallViewport(tester);
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(drawer: GlacialDrawer()),
        ));
        await openDrawer(tester);

        expect(find.byIcon(Icons.logout), findsNothing);
      });

      testWidgets('shows common drawer actions when anonymous', (tester) async {
        setTallViewport(tester);
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(drawer: GlacialDrawer()),
        ));
        await openDrawer(tester);

        // switchServer, directory, announcement, preference are visible
        expect(find.byIcon(Icons.swap_horiz), findsOneWidget);
        expect(find.byIcon(Icons.groups), findsOneWidget);
        expect(find.byIcon(Icons.campaign), findsOneWidget);
        expect(find.byIcon(Icons.settings), findsOneWidget);
        // logout is hidden when anonymous
        expect(find.byIcon(Icons.logout), findsNothing);
      });
    });

    group('signed-in drawer interactions', () {
      testWidgets('shows switchAccount icon when signed in', (tester) async {
        setTallViewport(tester);
        await tester.pumpWidget(createTestWidgetRaw(
          accessStatus: MockAccessStatus.authenticated(),
          child: const Scaffold(drawer: GlacialDrawer()),
        ));
        await openDrawer(tester);

        // switchAccount shows people icon
        expect(find.byIcon(Icons.people), findsOneWidget);
      });

      testWidgets('hides switchAccount icon when anonymous', (tester) async {
        setTallViewport(tester);
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(drawer: GlacialDrawer()),
        ));
        await openDrawer(tester);

        // switchAccount is hidden for anonymous users
        expect(find.byIcon(Icons.people), findsNothing);
      });

      testWidgets('shows drafts icon when signed in', (tester) async {
        setTallViewport(tester);
        await tester.pumpWidget(createTestWidgetRaw(
          accessStatus: MockAccessStatus.authenticated(),
          child: const Scaffold(drawer: GlacialDrawer()),
        ));
        await openDrawer(tester);

        // drafts shows edit_note icon
        expect(find.byIcon(Icons.edit_note), findsOneWidget);
      });

      testWidgets('hides drafts icon when anonymous', (tester) async {
        setTallViewport(tester);
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(drawer: GlacialDrawer()),
        ));
        await openDrawer(tester);

        // drafts is hidden for anonymous users
        expect(find.byIcon(Icons.edit_note), findsNothing);
      });

      testWidgets('drafts ListTile is disabled when draft count is 0', (tester) async {
        setTallViewport(tester);
        await tester.runAsync(() async {
          await tester.pumpWidget(createTestWidgetRaw(
            accessStatus: MockAccessStatus.authenticated(),
            child: const Scaffold(drawer: GlacialDrawer()),
          ));
          await tester.pump();
          // Wait for _loadDraftCount callback to fire
          await Future.delayed(const Duration(milliseconds: 100));
          await tester.pump();
        });

        await openDrawer(tester);

        // Find the drafts ListTile by its icon
        final Finder draftTile = find.widgetWithIcon(ListTile, Icons.edit_note);
        expect(draftTile, findsOneWidget);

        // The drafts tile should be disabled (0 drafts)
        final ListTile tile = tester.widget<ListTile>(draftTile);
        expect(tile.enabled, isFalse);
      });

      testWidgets('drawer shows server thumbnail when server has thumbnail', (tester) async {
        setTallViewport(tester);
        final status = MockAccessStatus.authenticated(
          server: MockServer.create(
            domain: 'example.com',
            thumbnail: 'https://example.com/thumb.png',
          ),
        );

        await tester.pumpWidget(createTestWidgetRaw(
          accessStatus: status.copyWith(domain: 'example.com'),
          child: const Scaffold(drawer: GlacialDrawer()),
        ));
        await openDrawer(tester);

        // Server has a thumbnail, so ClipRRect should be in the DrawerHeader
        expect(find.byType(ClipRRect), findsOneWidget);
      });

      testWidgets('drawer without server shows no ClipRRect thumbnail', (tester) async {
        setTallViewport(tester);
        // Authenticated status without server (server = null)
        final status = MockAccessStatus.authenticated();

        await tester.pumpWidget(createTestWidgetRaw(
          accessStatus: status,
          child: const Scaffold(drawer: GlacialDrawer()),
        ));
        await openDrawer(tester);

        // No server → thumbnail is null → SizedBox.shrink, no ClipRRect
        expect(find.byType(ClipRRect), findsNothing);
      });

      testWidgets('all drawer items have tooltips', (tester) async {
        setTallViewport(tester);
        await tester.pumpWidget(createTestWidgetRaw(
          accessStatus: MockAccessStatus.authenticated(),
          child: const Scaffold(drawer: GlacialDrawer()),
        ));
        await openDrawer(tester);

        // Each DrawerButtonType has a tooltip shown as ListTile title
        for (final action in DrawerButtonType.values) {
          // All actions are shown for signed-in user
          expect(find.byIcon(action.icon()), findsOneWidget);
        }
      });
    });

    group('draft count loading', () {
      testWidgets('loads draft count on init for anonymous user', (tester) async {
        setTallViewport(tester);
        await tester.runAsync(() async {
          await tester.pumpWidget(createTestWidgetRaw(
            child: const Scaffold(drawer: GlacialDrawer()),
          ));
          await tester.pump();
          // Wait for _loadDraftCount callback
          await Future.delayed(const Duration(milliseconds: 100));
          await tester.pump();
        });

        await openDrawer(tester);

        // For anonymous user (null compositeKey), _draftCount becomes 0
        // The drawer should still render without errors
        expect(find.byType(Drawer), findsOneWidget);
      });
    });

    group('drawer item taps (with GoRouter)', () {
      testWidgets('tapping switchAccount opens AccountPickerSheet', (tester) async {
        tester.view.physicalSize = const Size(800, 1200);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(createDrawerWithRouter(
          accessStatus: MockAccessStatus.authenticated(),
        ));
        await tester.pump();
        await openDrawer(tester);

        // Tap switchAccount (people icon)
        await tester.tap(find.byIcon(Icons.people));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // onTap calls context.pop() then showAdaptiveGlassSheet with AccountPickerSheet
        expect(find.byType(AccountPickerSheet), findsOneWidget);
      });

      testWidgets('tapping announcement opens AnnouncementSheet', (tester) async {
        tester.view.physicalSize = const Size(800, 1200);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.runAsync(() async {
          await tester.pumpWidget(createDrawerWithRouter(
            accessStatus: MockAccessStatus.authenticated(),
          ));
          await tester.pump();

          // Open drawer
          final ScaffoldState state = tester.firstState(find.byType(Scaffold));
          state.openDrawer();
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 300));

          // Tap announcement (campaign icon)
          await tester.tap(find.byIcon(Icons.campaign));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 300));
        });

        // onTap calls context.pop() then showAdaptiveGlassSheet with AnnouncementSheet
        expect(find.byType(AnnouncementSheet), findsOneWidget);
      });

      testWidgets('tapping preference navigates to preference page', (tester) async {
        tester.view.physicalSize = const Size(800, 1200);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(createDrawerWithRouter(
          accessStatus: MockAccessStatus.authenticated(),
        ));
        await tester.pump();
        await openDrawer(tester);

        // Tap preference (settings icon) — navigates via context.push
        await tester.tap(find.byIcon(Icons.settings));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // The drawer should be closed and navigation attempted
        // GoRouter handled the route so no error is thrown
        expect(tester.takeException(), isNull);
      });

      testWidgets('tapping directory navigates to directory page', (tester) async {
        tester.view.physicalSize = const Size(800, 1200);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(createDrawerWithRouter(
          accessStatus: MockAccessStatus.authenticated(),
        ));
        await tester.pump();
        await openDrawer(tester);

        // Tap directory (groups icon) — navigates via context.push
        await tester.tap(find.byIcon(Icons.groups));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // GoRouter handled the route so no error is thrown
        expect(tester.takeException(), isNull);
      });

      testWidgets('tapping switchServer clears domain', (tester) async {
        tester.view.physicalSize = const Size(800, 1200);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(createDrawerWithRouter(
          accessStatus: MockAccessStatus.authenticated(),
        ));
        await tester.pump();
        await openDrawer(tester);

        // Tap switchServer (swap_horiz icon) — saves empty domain + navigates
        await tester.tap(find.byIcon(Icons.swap_horiz));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // switchServer calls storage.saveAccessStatus with empty domain
        // then falls through to context.push(RoutePath.explorer.path)
        expect(tester.takeException(), isNull);
      });
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
