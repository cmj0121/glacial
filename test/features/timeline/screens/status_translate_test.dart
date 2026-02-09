// Widget tests for TranslateView component.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/features/timeline/screens/status_translate.dart';

import '../../../helpers/test_helpers.dart';

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
        expect(find.byType(TextButton), findsNothing);
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

        expect(find.byType(TextButton), findsNothing);
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

        expect(find.byType(TextButton), findsNothing);
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

        expect(find.byType(TextButton), findsNothing);
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
  });
}

// vim: set ts=2 sw=2 sts=2 et:
