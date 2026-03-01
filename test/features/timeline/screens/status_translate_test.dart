// Widget tests for TranslateView component.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/features/timeline/screens/status_translate.dart';

import '../../../helpers/test_helpers.dart';

/// Finder for TextButton.icon widgets (which are ButtonStyleButton subtypes).
Finder findTranslateButton() => find.bySubtype<ButtonStyleButton>();

void main() {
  setUpAll(() => setupTestEnvironment());

  group('TranslateView', () {
    group('when should not show translate', () {
      testWidgets('returns empty when not signed in', (tester) async {
        final status = MockStatus.create(language: 'ja');

        await tester.pumpWidget(createTestWidget(
          child: TranslateView(
            schema: status,
            status: MockAccessStatus.anonymous(),
          ),
        ));
        await tester.pumpAndSettle();

        // Should render SizedBox.shrink (empty)
        expect(find.byType(TranslateView), findsOneWidget);
        expect(find.byIcon(Icons.translate), findsNothing);
      });

      testWidgets('returns empty when content is empty', (tester) async {
        final status = MockStatus.create(content: '', language: 'ja');
        final server = MockServer.withTranslation();

        await tester.pumpWidget(createTestWidget(
          child: TranslateView(
            schema: status,
            status: MockAccessStatus.authenticated(server: server),
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.translate), findsNothing);
      });

      testWidgets('returns empty when language is null', (tester) async {
        final status = MockStatus.create(language: null);
        final server = MockServer.withTranslation();

        await tester.pumpWidget(createTestWidget(
          child: TranslateView(
            schema: status,
            status: MockAccessStatus.authenticated(server: server),
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.translate), findsNothing);
      });

      testWidgets('returns empty when language matches user locale', (tester) async {
        // Test uses English locale by default
        final status = MockStatus.create(language: 'en');
        final server = MockServer.withTranslation();

        await tester.pumpWidget(createTestWidget(
          child: TranslateView(
            schema: status,
            status: MockAccessStatus.authenticated(server: server),
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.translate), findsNothing);
      });
    });

    group('widget construction', () {
      testWidgets('accepts all parameters', (tester) async {
        final status = MockStatus.create(language: 'ja');
        final server = MockServer.withTranslation();

        await tester.pumpWidget(createTestWidget(
          child: TranslateView(
            schema: status,
            status: MockAccessStatus.authenticated(server: server),
            emojis: const [],
            onLinkTap: (_) {},
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(TranslateView), findsOneWidget);
      });

      testWidgets('renders without crash when status is null', (tester) async {
        final status = MockStatus.create(language: 'ja');

        await tester.pumpWidget(createTestWidget(
          child: TranslateView(
            schema: status,
            status: null,
          ),
        ));
        await tester.pumpAndSettle();

        // Widget should render (as SizedBox.shrink since not signed in)
        expect(find.byType(TranslateView), findsOneWidget);
      });

      testWidgets('renders with default emojis', (tester) async {
        final status = MockStatus.create(language: 'ja');

        await tester.pumpWidget(createTestWidget(
          child: TranslateView(
            schema: status,
            status: MockAccessStatus.anonymous(),
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.byType(TranslateView), findsOneWidget);
      });
    });

    group('when should show translate', () {
      testWidgets('shows translate button when signed in with different language', (tester) async {
        final status = MockStatus.create(language: 'ja');
        final server = MockServer.withTranslation();

        await tester.pumpWidget(createTestWidget(
          child: TranslateView(
            schema: status,
            status: MockAccessStatus.authenticated(server: server),
          ),
        ));
        await tester.pumpAndSettle();

        // Should show a translate button with translate icon
        expect(find.byIcon(Icons.translate), findsOneWidget);
        expect(findTranslateButton(), findsOneWidget);
      });

      testWidgets('returns empty when language is empty string', (tester) async {
        final status = MockStatus.create(language: '');
        final server = MockServer.withTranslation();

        await tester.pumpWidget(createTestWidget(
          child: TranslateView(
            schema: status,
            status: MockAccessStatus.authenticated(server: server),
          ),
        ));
        await tester.pumpAndSettle();

        // Empty language string means no translation button
        expect(find.byIcon(Icons.translate), findsNothing);
      });

      testWidgets('translate button is disabled when translation not enabled on server', (tester) async {
        final status = MockStatus.create(language: 'ja');
        // Server without translation enabled
        final server = MockServer.create(translationEnabled: false);

        await tester.pumpWidget(createTestWidget(
          child: TranslateView(
            schema: status,
            status: MockAccessStatus.authenticated(server: server),
          ),
        ));
        await tester.pumpAndSettle();

        // Button should render but be disabled
        expect(findTranslateButton(), findsOneWidget);
        final button = tester.widget<ButtonStyleButton>(findTranslateButton());
        expect(button.onPressed, isNull);
      });

      testWidgets('translate button is disabled when server is null', (tester) async {
        final status = MockStatus.create(language: 'ja');
        // Authenticated but no server
        final accessStatus = MockAccessStatus.authenticated();

        await tester.pumpWidget(createTestWidget(
          child: TranslateView(
            schema: status,
            status: accessStatus,
          ),
        ));
        await tester.pumpAndSettle();

        // Button should render but be disabled (server?.config.translationEnabled is null)
        expect(findTranslateButton(), findsOneWidget);
        final button = tester.widget<ButtonStyleButton>(findTranslateButton());
        expect(button.onPressed, isNull);
      });
    });

    group('translation toggle', () {
      testWidgets('tapping translate button triggers loading state', (tester) async {
        final status = MockStatus.create(language: 'ja');
        final server = MockServer.withTranslation();
        final accessStatus = MockAccessStatus.authenticated(server: server);

        await tester.pumpWidget(createTestWidget(
          child: TranslateView(
            schema: status,
            status: accessStatus,
          ),
        ));
        await tester.pumpAndSettle();

        // Tap the translate button — use runAsync since it triggers HTTP
        await tester.runAsync(() async {
          await tester.tap(findTranslateButton());
          await tester.pump();
        });

        // During loading, the button should still exist
        expect(findTranslateButton(), findsOneWidget);
      });

      testWidgets('translation renders after state injection', (tester) async {
        final status = MockStatus.create(language: 'ja');
        final server = MockServer.withTranslation();
        final accessStatus = MockAccessStatus.authenticated(server: server);

        await tester.pumpWidget(createTestWidget(
          child: TranslateView(
            schema: status,
            status: accessStatus,
          ),
        ));
        await tester.pumpAndSettle();

        // Inject translation state directly
        final state = tester.state(find.byType(TranslateView));
        (state as dynamic).translation = MockTranslation.create(
          content: '<p>Translated text</p>',
          provider: 'TestProvider',
        );
        (state as dynamic).isVisible = true;
        (state as dynamic).isLoading = false;
        // Trigger rebuild
        // ignore: invalid_use_of_protected_member
        (state as dynamic).setState(() {});
        await tester.pump();

        // Translation content should be visible
        expect(find.text('TestProvider'), findsOneWidget);
      });

      testWidgets('hide button shows after translation is visible', (tester) async {
        final status = MockStatus.create(language: 'ja');
        final server = MockServer.withTranslation();
        final accessStatus = MockAccessStatus.authenticated(server: server);

        await tester.pumpWidget(createTestWidget(
          child: TranslateView(
            schema: status,
            status: accessStatus,
          ),
        ));
        await tester.pumpAndSettle();

        // Inject visible translation
        final state = tester.state(find.byType(TranslateView));
        (state as dynamic).translation = MockTranslation.create();
        (state as dynamic).isVisible = true;
        (state as dynamic).isLoading = false;
        // ignore: invalid_use_of_protected_member
        (state as dynamic).setState(() {});
        await tester.pump();

        // Button should still be present (now showing "Show original" label)
        expect(findTranslateButton(), findsOneWidget);
      });

      testWidgets('toggling visibility hides translation without re-fetching', (tester) async {
        final status = MockStatus.create(language: 'ja');
        final server = MockServer.withTranslation();
        final accessStatus = MockAccessStatus.authenticated(server: server);

        await tester.pumpWidget(createTestWidget(
          child: TranslateView(
            schema: status,
            status: accessStatus,
          ),
        ));
        await tester.pumpAndSettle();

        // Set up translated state
        final state = tester.state(find.byType(TranslateView));
        (state as dynamic).translation = MockTranslation.create(
          content: '<p>Translated</p>',
          provider: 'TestProvider',
        );
        (state as dynamic).isVisible = true;
        (state as dynamic).isLoading = false;
        // ignore: invalid_use_of_protected_member
        (state as dynamic).setState(() {});
        await tester.pump();

        // Provider text visible
        expect(find.text('TestProvider'), findsOneWidget);

        // Tap to toggle off (hide translation)
        await tester.tap(findTranslateButton());
        await tester.pump();

        // Translation should be hidden
        expect(find.text('TestProvider'), findsNothing);
      });

      testWidgets('re-toggling visible shows cached translation', (tester) async {
        final status = MockStatus.create(language: 'ja');
        final server = MockServer.withTranslation();
        final accessStatus = MockAccessStatus.authenticated(server: server);

        await tester.pumpWidget(createTestWidget(
          child: TranslateView(
            schema: status,
            status: accessStatus,
          ),
        ));
        await tester.pumpAndSettle();

        // Inject translation but hide it
        final state = tester.state(find.byType(TranslateView));
        (state as dynamic).translation = MockTranslation.create(
          content: '<p>Cached translation</p>',
          provider: 'CacheProvider',
        );
        (state as dynamic).isVisible = false;
        (state as dynamic).isLoading = false;
        // ignore: invalid_use_of_protected_member
        (state as dynamic).setState(() {});
        await tester.pump();

        // Translation should not be visible yet
        expect(find.text('CacheProvider'), findsNothing);

        // Tap to toggle on — should show cached translation, not re-fetch
        await tester.tap(findTranslateButton());
        await tester.pump();

        // Cached translation should now be visible
        expect(find.text('CacheProvider'), findsOneWidget);
      });

      testWidgets('loading state disables button', (tester) async {
        final status = MockStatus.create(language: 'ja');
        final server = MockServer.withTranslation();
        final accessStatus = MockAccessStatus.authenticated(server: server);

        await tester.pumpWidget(createTestWidget(
          child: TranslateView(
            schema: status,
            status: accessStatus,
          ),
        ));
        await tester.pumpAndSettle();

        // Inject loading state
        final state = tester.state(find.byType(TranslateView));
        (state as dynamic).isLoading = true;
        // ignore: invalid_use_of_protected_member
        (state as dynamic).setState(() {});
        await tester.pump();

        // Button should be disabled during loading
        final button = tester.widget<ButtonStyleButton>(findTranslateButton());
        expect(button.onPressed, isNull);
      });
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
