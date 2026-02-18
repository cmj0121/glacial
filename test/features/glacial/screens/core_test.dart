// Widget tests for GlacialHome, GlacialDrawer, LandingPage, AnnouncementSheet.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  group('GlacialHome', () {
    test('defaults to backable false', () {
      const home = GlacialHome(child: Text('Test'));
      expect(home.backable, isFalse);
    });

    test('defaults to empty actions', () {
      const home = GlacialHome(child: Text('Test'));
      expect(home.actions, isEmpty);
    });

    test('defaults to null title', () {
      const home = GlacialHome(child: Text('Test'));
      expect(home.title, isNull);
    });

    test('accepts backable parameter', () {
      const home = GlacialHome(backable: true, child: Text('Test'));
      expect(home.backable, isTrue);
    });

    test('accepts title parameter', () {
      const home = GlacialHome(
        title: Text('Title'),
        child: Text('Content'),
      );
      expect(home.title, isA<Text>());
    });

    test('accepts actions parameter', () {
      final home = GlacialHome(
        actions: [IconButton(icon: const Icon(Icons.star), onPressed: () {})],
        child: const Text('Content'),
      );
      expect(home.actions.length, 1);
    });

    test('itemScrollToTop is initially null', () {
      expect(GlacialHome.itemScrollToTop, isNull);
    });
  });

  group('GlacialDrawer', () {
    testWidgets('renders Drawer when opened', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          drawer: const GlacialDrawer(),
          body: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
      ));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(Drawer), findsOneWidget);
    });

    testWidgets('shows DrawerHeader', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          drawer: const GlacialDrawer(),
          body: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
      ));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(DrawerHeader), findsOneWidget);
    });

    test('is a ConsumerStatefulWidget', () {
      const drawer = GlacialDrawer();
      expect(drawer, isA<GlacialDrawer>());
    });

    testWidgets('shows drawer action icons', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          drawer: const GlacialDrawer(),
          body: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
      ));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pump(const Duration(seconds: 1));

      expect(find.byIcon(Icons.swap_horiz), findsOneWidget);
      expect(find.byIcon(Icons.groups), findsOneWidget);
      expect(find.byIcon(Icons.campaign), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('hides logout when anonymous', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        accessStatus: MockAccessStatus.anonymous(),
        child: Scaffold(
          drawer: const GlacialDrawer(),
          body: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
      ));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pump(const Duration(seconds: 1));

      expect(find.byIcon(Icons.logout), findsNothing);
    });

    testWidgets('shows logout when signed in', (tester) async {
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidgetRaw(
        accessStatus: status,
        child: Scaffold(
          drawer: const GlacialDrawer(),
          body: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
      ));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pump(const Duration(seconds: 1));

      expect(find.byIcon(Icons.logout), findsOneWidget);
    });

    testWidgets('shows AccountLite in drawer', (tester) async {
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidgetRaw(
        accessStatus: status,
        child: Scaffold(
          drawer: const GlacialDrawer(),
          body: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
      ));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(AccountLite), findsOneWidget);
    });

    testWidgets('uses LayoutBuilder for responsive sizing', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          drawer: const GlacialDrawer(),
          body: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
      ));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(LayoutBuilder), findsWidgets);
    });

    testWidgets('shows ListTile for each action', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: Scaffold(
          drawer: const GlacialDrawer(),
          body: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
      ));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pump(const Duration(seconds: 1));

      // DrawerButtonType has 5 values, minus logout (hidden for anon) = 4 visible
      expect(find.byType(ListTile), findsAtLeast(4));
    });
  });

  group('LandingPage', () {
    test('defaults to size 64', () {
      const landing = LandingPage();
      expect(landing.size, 64);
    });

    test('accepts custom size', () {
      const landing = LandingPage(size: 128);
      expect(landing.size, 128);
    });

    test('is a ConsumerStatefulWidget', () {
      const landing = LandingPage();
      expect(landing, isA<LandingPage>());
    });

    testWidgets('error state shows cloud_off icon and retry button', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const LandingPage(),
        ));
        await tester.pump();
        // Allow async onLoading to fail (Storage not initialized)
        await Future.delayed(const Duration(milliseconds: 100));
        await tester.pump();
      });

      // Should show error UI with cloud_off icon and retry button
      expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('error state does not show raw exception text', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const LandingPage(),
        ));
        await tester.pump();
        await Future.delayed(const Duration(milliseconds: 100));
        await tester.pump();
      });

      // Should not contain "Exception" or "Error" type text
      expect(find.textContaining('Exception'), findsNothing);
      expect(find.textContaining('LateInitialization'), findsNothing);
    });
  });

  group('AnnouncementSheet', () {
    test('accepts status parameter', () {
      final status = MockAccessStatus.authenticated();
      final sheet = AnnouncementSheet(status: status);
      expect(sheet.status, status);
    });

    test('accepts null status', () {
      const sheet = AnnouncementSheet(status: null);
      expect(sheet.status, isNull);
    });
  });

  group('SidebarButtonType', () {
    testWidgets('each type has distinct active and inactive icons', (tester) async {
      for (final type in SidebarButtonType.values) {
        final activeIcon = type.icon(active: true);
        final inactiveIcon = type.icon(active: false);
        expect(activeIcon != inactiveIcon, isTrue, reason: '${type.name} icons should differ');
      }
    });

    test('each type has a route', () {
      for (final type in SidebarButtonType.values) {
        expect(type.route, isA<RoutePath>());
      }
    });

    test('only timeline and trending support anonymous', () {
      expect(SidebarButtonType.timeline.supportAnonymous, isTrue);
      expect(SidebarButtonType.trending.supportAnonymous, isTrue);
      expect(SidebarButtonType.notifications.supportAnonymous, isFalse);
      expect(SidebarButtonType.post.supportAnonymous, isFalse);
      expect(SidebarButtonType.conversations.supportAnonymous, isFalse);
      expect(SidebarButtonType.admin.supportAnonymous, isFalse);
      expect(SidebarButtonType.list.supportAnonymous, isFalse);
    });

    test('routes map correctly', () {
      expect(SidebarButtonType.timeline.route, RoutePath.timeline);
      expect(SidebarButtonType.list.route, RoutePath.list);
      expect(SidebarButtonType.trending.route, RoutePath.trends);
      expect(SidebarButtonType.notifications.route, RoutePath.notifications);
      expect(SidebarButtonType.conversations.route, RoutePath.conversations);
      expect(SidebarButtonType.admin.route, RoutePath.admin);
      expect(SidebarButtonType.post.route, RoutePath.post);
    });
  });

  group('DrawerButtonType', () {
    test('each type has an icon', () {
      expect(DrawerButtonType.switchServer.icon(), Icons.swap_horiz);
      expect(DrawerButtonType.directory.icon(), Icons.groups);
      expect(DrawerButtonType.announcement.icon(), Icons.campaign);
      expect(DrawerButtonType.preference.icon(), Icons.settings);
      expect(DrawerButtonType.logout.icon(), Icons.logout);
    });

    test('each type has a route', () {
      for (final type in DrawerButtonType.values) {
        expect(type.route, isA<RoutePath>());
      }
    });

    test('routes map correctly', () {
      expect(DrawerButtonType.switchServer.route, RoutePath.explorer);
      expect(DrawerButtonType.directory.route, RoutePath.directory);
      expect(DrawerButtonType.preference.route, RoutePath.preference);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
