// Tests for GlacialDrawer widget - conditional rendering of drawer items.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/features/glacial/screens/core.dart';

import '../../../helpers/test_helpers.dart';

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
      testWidgets('shows suggestions option', (tester) async {
        setTallViewport(tester);
        await tester.pumpWidget(createTestWidgetRaw(
          accessStatus: MockAccessStatus.authenticated(),
          child: const Scaffold(drawer: GlacialDrawer()),
        ));
        await openDrawer(tester);

        expect(find.byIcon(Icons.person_add), findsOneWidget);
      });

      testWidgets('shows endorsed accounts option', (tester) async {
        setTallViewport(tester);
        await tester.pumpWidget(createTestWidgetRaw(
          accessStatus: MockAccessStatus.authenticated(),
          child: const Scaffold(drawer: GlacialDrawer()),
        ));
        await openDrawer(tester);

        expect(find.byIcon(Icons.star), findsOneWidget);
      });

      testWidgets('shows logout option', (tester) async {
        setTallViewport(tester);
        await tester.pumpWidget(createTestWidgetRaw(
          accessStatus: MockAccessStatus.authenticated(),
          child: const Scaffold(drawer: GlacialDrawer()),
        ));
        await openDrawer(tester);

        expect(find.byIcon(Icons.logout), findsOneWidget);
      });

      testWidgets('shows all 7 drawer actions when signed in', (tester) async {
        setTallViewport(tester);
        await tester.pumpWidget(createTestWidgetRaw(
          accessStatus: MockAccessStatus.authenticated(),
          child: const Scaffold(drawer: GlacialDrawer()),
        ));
        await openDrawer(tester);

        expect(find.byIcon(Icons.swap_horiz), findsOneWidget);
        expect(find.byIcon(Icons.groups), findsOneWidget);
        expect(find.byIcon(Icons.campaign), findsOneWidget);
        expect(find.byIcon(Icons.person_add), findsOneWidget);
        expect(find.byIcon(Icons.star), findsOneWidget);
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

        // Each drawer action is a ListTile; at least 7 (one per action)
        expect(find.byType(ListTile), findsAtLeastNWidgets(7));
      });
    });

    group('anonymous user', () {
      testWidgets('hides suggestions option', (tester) async {
        setTallViewport(tester);
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(drawer: GlacialDrawer()),
        ));
        await openDrawer(tester);

        expect(find.byIcon(Icons.person_add), findsNothing);
      });

      testWidgets('hides endorsed accounts option', (tester) async {
        setTallViewport(tester);
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(drawer: GlacialDrawer()),
        ));
        await openDrawer(tester);

        expect(find.byIcon(Icons.star), findsNothing);
      });

      testWidgets('hides logout option when anonymous', (tester) async {
        setTallViewport(tester);
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(drawer: GlacialDrawer()),
        ));
        await openDrawer(tester);

        expect(find.byIcon(Icons.logout), findsNothing);
      });

      testWidgets('shows only common drawer actions when anonymous', (tester) async {
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
        // suggestions, endorsedAccounts, logout are hidden when anonymous
        expect(find.byIcon(Icons.person_add), findsNothing);
        expect(find.byIcon(Icons.star), findsNothing);
        expect(find.byIcon(Icons.logout), findsNothing);
      });
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
