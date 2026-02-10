// Widget tests for PostStatusForm and AutoCompleteForm components.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  group('PostStatusForm', () {
    testWidgets('renders basic form', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: PostStatusForm()),
          accessStatus: status,
        ));
        await tester.pump();
      });

      expect(find.byType(PostStatusForm), findsOneWidget);
    });

    testWidgets('shows text field area', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: PostStatusForm()),
          accessStatus: status,
        ));
        await tester.pump();
      });

      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('shows submit button with "Toot" text', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: PostStatusForm()),
          accessStatus: status,
        ));
        await tester.pump();
      });

      expect(find.text('Toot'), findsOneWidget);
    });

    testWidgets('shows visibility selector', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: PostStatusForm()),
          accessStatus: status,
        ));
        await tester.pump();
      });

      expect(find.byType(VisibilitySelector), findsOneWidget);
    });

    testWidgets('shows quote policy selector', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: PostStatusForm()),
          accessStatus: status,
        ));
        await tester.pump();
      });

      expect(find.byType(QuotePolicyTypeSelector), findsOneWidget);
    });

    testWidgets('shows media icon button', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: PostStatusForm()),
          accessStatus: status,
        ));
        await tester.pump();
      });

      expect(find.byIcon(Icons.perm_media_rounded), findsOneWidget);
    });

    testWidgets('shows poll icon button', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: PostStatusForm()),
          accessStatus: status,
        ));
        await tester.pump();
      });

      expect(find.byIcon(Icons.poll_outlined), findsOneWidget);
    });

    testWidgets('shows spoiler icon button', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: PostStatusForm()),
          accessStatus: status,
        ));
        await tester.pump();
      });

      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('shows sensitive icon button', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: PostStatusForm()),
          accessStatus: status,
        ));
        await tester.pump();
      });

      // Default is not sensitive, so visibility icon should show
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('does not show reply-to when replyTo is null', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: PostStatusForm(replyTo: null)),
          accessStatus: status,
        ));
        await tester.pump();
      });

      // No StatusLite should be shown when replyTo is null (no greyed-out reply)
      expect(find.byType(StatusLite), findsNothing);
    });

    testWidgets('does not show quote-to when quoteTo is null', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: PostStatusForm(quoteTo: null)),
          accessStatus: status,
        ));
        await tester.pump();
      });

      // No ColorFiltered with StatusLite for quote
      expect(find.byType(StatusLite), findsNothing);
    });
  });

  group('AutoCompleteForm', () {
    testWidgets('renders with builder', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: AutoCompleteForm(
            builder: (context, textEditingController, focusNode, onFieldSubmitted) {
              return TextFormField(
                controller: textEditingController,
                focusNode: focusNode,
              );
            },
          ),
          accessStatus: status,
        ));
        await tester.pump();
      });

      expect(find.byType(AutoCompleteForm), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
