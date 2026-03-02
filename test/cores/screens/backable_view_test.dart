// Widget tests for BackableView component.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/core.dart';

import '../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  group('BackableView', () {
    testWidgets('renders Scaffold with child content', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: const BackableView(child: Text('Test Content')),
      ));
      await tester.pump();

      expect(find.byType(Scaffold), findsWidgets);
      expect(find.text('Test Content'), findsOneWidget);
    });

    testWidgets('shows back arrow icon in AppBar', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: const BackableView(child: Text('Content')),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    });

    testWidgets('shows title in AppBar when provided', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: const BackableView(
          title: 'My Title',
          child: Text('Content'),
        ),
      ));
      await tester.pump();

      expect(find.text('My Title'), findsOneWidget);
    });

    testWidgets('no title text when title is null', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: const BackableView(child: Text('Content')),
      ));
      await tester.pump();

      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('has SafeArea wrapper', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: const BackableView(child: Text('Content')),
      ));
      await tester.pump();

      expect(find.byType(SafeArea), findsWidgets);
    });

    testWidgets('has AccessibleDismissible wrapper', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: const BackableView(child: Text('Content')),
      ));
      await tester.pump();

      expect(find.byType(AccessibleDismissible), findsOneWidget);
    });

    testWidgets('tapping back button triggers pop', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: const BackableView(child: Text('Content')),
      ));
      await tester.pump();

      // Tap the back arrow icon
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pump();

      // context.pop() throws without GoRouter — consume the expected error
      final exception = tester.takeException();
      expect(exception, isNotNull);
    });

    testWidgets('AccessibleDismissible direction is startToEnd', (tester) async {
      await tester.pumpWidget(createTestWidgetRaw(
        child: const BackableView(child: Text('Content')),
      ));
      await tester.pump();

      // Verify the Dismissible is configured for startToEnd swipe
      final dismissible = tester.widget<Dismissible>(find.byType(Dismissible));
      expect(dismissible.direction, DismissDirection.startToEnd);
    });

    testWidgets('swipe triggers confirmDismiss and sets isDisposed', (tester) async {
      // Provide GoRouter so context.pop() works without throwing.
      final router = GoRouter(
        initialLocation: '/detail',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, __) => const Scaffold(body: Text('Home')),
            routes: [
              GoRoute(
                path: 'detail',
                builder: (_, __) => const BackableView(child: Text('Swipe Content')),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(ProviderScope(
        overrides: [
          accessStatusProvider.overrideWith((ref) => MockAccessStatus.anonymous()),
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
      ));
      await tester.pumpAndSettle();

      // Verify BackableView content is shown before swipe
      expect(find.text('Swipe Content'), findsOneWidget);

      // Perform a horizontal swipe (startToEnd) to trigger confirmDismiss
      await tester.drag(find.byType(Dismissible), const Offset(500, 0));
      await tester.pumpAndSettle();

      // confirmDismiss sets isDisposed=true and calls context.pop(),
      // which navigates back to the parent route '/'
      expect(find.text('Home'), findsOneWidget);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
