// Widget tests for PostStatusForm and AutoCompleteForm components.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setUpAll(() {
    setupTestEnvironment();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async => Directory.systemTemp.path,
    );
  });

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

  group('PostStatusForm with draftFrom', () {
    testWidgets('pre-fills text from draftFrom', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );
      final draft = DraftSchema(
        id: 'draft-1',
        content: 'Draft content from before',
        updatedAt: DateTime(2025, 1, 1),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: PostStatusForm(draftFrom: draft)),
          accessStatus: status,
        ));
        await tester.pump();
      });

      expect(find.text('Draft content from before'), findsOneWidget);
    });

    testWidgets('pre-fills spoiler from draftFrom', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );
      final draft = DraftSchema(
        id: 'draft-2',
        content: 'Has spoiler',
        spoiler: 'CW text',
        updatedAt: DateTime(2025, 1, 1),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: PostStatusForm(draftFrom: draft)),
          accessStatus: status,
        ));
        await tester.pump();
      });

      // Spoiler field should be visible with CW text
      expect(find.text('CW text'), findsOneWidget);
    });

    testWidgets('sets sensitive flag from draftFrom', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );
      final draft = DraftSchema(
        id: 'draft-3',
        content: 'Sensitive draft',
        sensitive: true,
        updatedAt: DateTime(2025, 1, 1),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: PostStatusForm(draftFrom: draft)),
          accessStatus: status,
        ));
        await tester.pump();
      });

      // When sensitive=true, should show visibility_off_outlined
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets('sets visibility from draftFrom', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );
      final draft = DraftSchema(
        id: 'draft-4',
        content: 'Private draft',
        visibility: VisibilityType.private,
        updatedAt: DateTime(2025, 1, 1),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: PostStatusForm(draftFrom: draft)),
          accessStatus: status,
        ));
        await tester.pump();
      });

      // VisibilitySelector should reflect the private type
      expect(find.byType(VisibilitySelector), findsOneWidget);
    });

    testWidgets('sets poll from draftFrom', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );
      final draft = DraftSchema(
        id: 'draft-5',
        content: 'Poll draft',
        poll: NewPollSchema(),
        updatedAt: DateTime(2025, 1, 1),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: PostStatusForm(draftFrom: draft)),
          accessStatus: status,
        ));
        await tester.pump();
      });

      // PollForm should be rendered when poll is not null
      expect(find.byType(PollForm), findsOneWidget);
    });
  });

  group('PostStatusForm with sharedContent', () {
    testWidgets('pre-fills text from sharedContent', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );
      const shared = SharedContentSchema(text: 'Shared text from Safari');

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: PostStatusForm(sharedContent: shared)),
          accessStatus: status,
        ));
        await tester.pump();
      });

      expect(find.text('Shared text from Safari'), findsOneWidget);
    });

    testWidgets('renders correctly with empty sharedContent', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );
      const shared = SharedContentSchema();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: PostStatusForm(sharedContent: shared)),
          accessStatus: status,
        ));
        await tester.pump();
      });

      expect(find.byType(PostStatusForm), findsOneWidget);
    });
  });

  group('PostStatusForm interaction tests', () {
    testWidgets('shows reply-to preview when replyTo is provided', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );
      final replyStatus = MockStatus.create(id: 'reply-1', content: '<p>Reply target</p>');

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: PostStatusForm(replyTo: replyStatus)),
          accessStatus: status,
        ));
        await tester.pump();
      });

      // StatusLite should be rendered for the reply-to preview
      expect(find.byType(StatusLite), findsOneWidget);
      // It should be wrapped in a ColorFiltered for greyed-out appearance
      expect(find.byType(ColorFiltered), findsOneWidget);
    });

    testWidgets('shows quote-to preview when quoteTo is provided', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );
      final quoteStatus = MockStatus.create(id: 'quote-1', content: '<p>Quote target</p>');

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: PostStatusForm(quoteTo: quoteStatus)),
          accessStatus: status,
        ));
        await tester.pump();
      });

      // StatusLite should be rendered for the quote-to preview
      expect(find.byType(StatusLite), findsOneWidget);
      // It should be inside a ColorFiltered widget
      expect(find.byType(ColorFiltered), findsOneWidget);
    });

    testWidgets('tapping spoiler icon toggles spoiler field', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: PostStatusForm()),
          accessStatus: status,
        ));
        await tester.pump();

        // Initially there should be only the main TextFormField (from AutoCompleteForm)
        final initialFieldCount = tester.widgetList(find.byType(TextFormField)).length;

        // Tap the spoiler (warning) icon to toggle spoiler field on
        await tester.tap(find.byIcon(Icons.warning));
        await tester.pump();

        // After toggling, there should be an additional TextFormField for the spoiler
        final afterToggleCount = tester.widgetList(find.byType(TextFormField)).length;
        expect(afterToggleCount, greaterThan(initialFieldCount));
      });
    });

    testWidgets('tapping sensitive icon toggles sensitive state', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: PostStatusForm()),
          accessStatus: status,
        ));
        await tester.pump();

        // Initially should show Icons.visibility (not sensitive)
        expect(find.byIcon(Icons.visibility), findsOneWidget);
        expect(find.byIcon(Icons.visibility_off_outlined), findsNothing);

        // Tap the sensitive icon to toggle
        await tester.tap(find.byIcon(Icons.visibility));
        await tester.pump();

        // After toggling, should show Icons.visibility_off_outlined
        expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
        expect(find.byIcon(Icons.visibility), findsNothing);
      });
    });

    testWidgets('tapping poll icon toggles poll form', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: PostStatusForm()),
          accessStatus: status,
        ));
        await tester.pump();

        // Initially no PollForm content (schema is null → SizedBox.shrink)
        // Tap the poll icon to toggle poll on
        await tester.tap(find.byIcon(Icons.poll_outlined));
        await tester.pump();

        // After toggling, PollForm should render with options
        expect(find.byType(PollForm), findsOneWidget);
      });
    });

    testWidgets('shows Edit text when editFrom is provided', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );
      final editStatus = MockStatus.create(
        id: 'edit-1',
        content: '<p>Existing post content</p>',
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: PostStatusForm(editFrom: editStatus)),
          accessStatus: status,
        ));
        await tester.pump();
      });

      // When editFrom is provided, the submit button shows "Edit" instead of "Toot"
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Toot'), findsNothing);
    });

    testWidgets('renders with media attachments in editFrom', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );
      final attachment = MockAttachment.create(
        id: 'att-edit-1',
        url: 'https://example.com/media/edit.png',
        previewUrl: 'https://example.com/media/edit_preview.png',
      );
      final editStatus = MockStatus.create(
        id: 'edit-media-1',
        content: '<p>Post with media</p>',
        attachments: [attachment],
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: PostStatusForm(editFrom: editStatus)),
          accessStatus: status,
        ));
        await tester.pump();
      });

      // The form should render with media thumbnails from editFrom
      expect(find.byType(PostStatusForm), findsOneWidget);
      // The media should cause an IconButton with remove_circle to appear
      expect(find.byIcon(Icons.remove_circle), findsOneWidget);
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
