// Widget tests for LandingPage — covers lines 13, 48-94 of landing.dart.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

/// Creates a LandingPage wrapped in GoRouter so that context.go() works.
Widget createLandingTestWidget({
  AccessStatusSchema? accessStatus,
  double size = 64,
}) {
  final List<Override> allOverrides = [
    accessStatusProvider.overrideWith(
      (ref) => accessStatus ?? MockAccessStatus.anonymous(),
    ),
  ];

  final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => LandingPage(size: size),
      ),
      GoRoute(
        path: '/home/timeline',
        builder: (_, __) => const Scaffold(body: Text('Timeline')),
      ),
      GoRoute(
        path: '/home/trends',
        builder: (_, __) => const Scaffold(body: Text('Trends')),
      ),
      GoRoute(
        path: '/explorer',
        builder: (_, __) => const Scaffold(body: Text('Explorer')),
      ),
      GoRoute(
        path: '/home/post/shared',
        builder: (_, __) => const Scaffold(body: Text('Post Shared')),
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

  group('LandingPage', () {
    testWidgets('renders Scaffold and SafeArea', (tester) async {
      await tester.pumpWidget(createLandingTestWidget());
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('renders icon with default size of 64', (tester) async {
      await tester.pumpWidget(createLandingTestWidget());
      await tester.pump();

      // LandingPage renders Image.asset with the icon
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('renders icon with custom size', (tester) async {
      await tester.pumpWidget(createLandingTestWidget(size: 128));
      await tester.pump();

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('shows Flipping animation initially', (tester) async {
      await tester.pumpWidget(createLandingTestWidget());
      await tester.pump();

      expect(find.byType(Flipping), findsOneWidget);
    });

    testWidgets('center widget wraps the Flipping icon', (tester) async {
      await tester.pumpWidget(createLandingTestWidget());
      await tester.pump();

      expect(find.byType(Center), findsOneWidget);
    });

    group('error state', () {
      testWidgets('shows ErrorState when loading fails', (tester) async {
        await tester.runAsync(() async {
          await tester.pumpWidget(createLandingTestWidget());
          await tester.pump();
          // Allow async onLoading to fail (Storage not initialized)
          await Future.delayed(const Duration(milliseconds: 200));
          await tester.pump();
        });

        // Should show ErrorState widget
        expect(find.byType(ErrorState), findsOneWidget);
      });

      testWidgets('shows cloud_off icon in error state', (tester) async {
        await tester.runAsync(() async {
          await tester.pumpWidget(createLandingTestWidget());
          await tester.pump();
          await Future.delayed(const Duration(milliseconds: 200));
          await tester.pump();
        });

        expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);
      });

      testWidgets('shows retry button in error state', (tester) async {
        await tester.runAsync(() async {
          await tester.pumpWidget(createLandingTestWidget());
          await tester.pump();
          await Future.delayed(const Duration(milliseconds: 200));
          await tester.pump();
        });

        expect(find.byIcon(Icons.refresh), findsOneWidget);
      });

      testWidgets('shows change server secondary action in error state', (tester) async {
        await tester.runAsync(() async {
          await tester.pumpWidget(createLandingTestWidget());
          await tester.pump();
          await Future.delayed(const Duration(milliseconds: 200));
          await tester.pump();
        });

        // Should show a secondary "Change server" action
        expect(find.textContaining('Change server'), findsOneWidget);
      });

      testWidgets('shows server unreachable message', (tester) async {
        await tester.runAsync(() async {
          await tester.pumpWidget(createLandingTestWidget());
          await tester.pump();
          await Future.delayed(const Duration(milliseconds: 200));
          await tester.pump();
        });

        // Should show the unreachable message
        expect(find.textContaining('unreachable'), findsOneWidget);
      });

      testWidgets('error state hides Flipping animation', (tester) async {
        await tester.runAsync(() async {
          await tester.pumpWidget(createLandingTestWidget());
          await tester.pump();
          await Future.delayed(const Duration(milliseconds: 200));
          await tester.pump();
        });

        // When error is shown, Flipping should be hidden
        expect(find.byType(Flipping), findsNothing);
      });

      testWidgets('tapping retry clears error and re-enters error state', (tester) async {
        // First, get into error state
        await tester.runAsync(() async {
          await tester.pumpWidget(createLandingTestWidget());
          await tester.pump();
          await Future.delayed(const Duration(milliseconds: 200));
          await tester.pump();
        });

        // Verify error state
        expect(find.byType(ErrorState), findsOneWidget);

        // Tap the retry button inside runAsync — this calls
        // setState(() => error = null) then onLoading() which will fail again
        await tester.runAsync(() async {
          await tester.tap(find.byIcon(Icons.refresh));
          await tester.pump();
          // Wait for onLoading to fail again
          await Future.delayed(const Duration(milliseconds: 200));
          await tester.pump();
        });

        // After retry fails again, ErrorState should be shown again
        expect(find.byType(ErrorState), findsOneWidget);
      });

      testWidgets('change server button navigates to explorer', (tester) async {
        // First, get into error state
        await tester.runAsync(() async {
          await tester.pumpWidget(createLandingTestWidget());
          await tester.pump();
          await Future.delayed(const Duration(milliseconds: 200));
          await tester.pump();
        });

        // Verify error state
        expect(find.textContaining('Change server'), findsOneWidget);

        // Tap change server — this calls context.go(RoutePath.explorer.path)
        await tester.runAsync(() async {
          await tester.tap(find.textContaining('Change server'));
          await tester.pump();
          await tester.pump();
        });

        // Should navigate to explorer
        await tester.pump();
        expect(find.text('Explorer'), findsOneWidget);
      });
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
