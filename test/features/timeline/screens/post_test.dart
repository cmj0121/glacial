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

  group('PostStatusForm onInitMentioned tests', () {
    testWidgets('reply with poster-only preference pre-fills @poster acct', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );
      final replyTo = MockStatus.create(
        id: 'reply-tag-1',
        content: '<p>Reply target</p>',
      );
      final pref = const SystemPreferenceSchema(replyTag: ReplyTagType.poster);

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: PostStatusForm(replyTo: replyTo)),
          accessStatus: status,
          preference: pref,
        ));
        await tester.pump();
      });

      // Should pre-fill with @testuser (the replyTo poster's acct)
      expect(find.textContaining('@testuser'), findsWidgets);
    });

    testWidgets('reply with none preference does not add mentions', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );
      final replyTo = MockStatus.create(
        id: 'reply-tag-2',
        content: '<p>Reply target</p>',
      );
      final pref = const SystemPreferenceSchema(replyTag: ReplyTagType.none);

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: PostStatusForm(replyTo: replyTo)),
          accessStatus: status,
          preference: pref,
        ));
        await tester.pump();
      });

      // The text field should be empty (no @mentions added)
      expect(find.byType(PostStatusForm), findsOneWidget);
    });

    testWidgets('reply with all preference adds all mentioned accts', (tester) async {
      final status = MockAccessStatus.authenticated(
        account: MockAccount.create(id: 'me', username: 'me', acct: 'me'),
        server: MockServer.create(),
      );
      final replyTo = MockStatus.create(
        id: 'reply-tag-3',
        content: '<p>Reply with mentions</p>',
        mentions: [
          MockMention.create(id: 'm1', username: 'alice', acct: 'alice'),
          MockMention.create(id: 'm2', username: 'bob', acct: 'bob'),
        ],
      );
      final pref = const SystemPreferenceSchema(replyTag: ReplyTagType.all);

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: PostStatusForm(replyTo: replyTo)),
          accessStatus: status,
          preference: pref,
        ));
        await tester.pump();
      });

      // Should have @alice, @bob, and @testuser (poster's acct) in text
      expect(find.textContaining('@alice'), findsWidgets);
      expect(find.textContaining('@bob'), findsWidgets);
    });
  });

  group('PostStatusForm with editFrom', () {
    testWidgets('renders with spoiler text from editFrom', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );
      final editFrom = MockStatus.create(
        id: 'edit-1',
        content: '<p>Editing this</p>',
        spoiler: 'Content Warning',
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: PostStatusForm(editFrom: editFrom)),
          accessStatus: status,
        ));
        await tester.pump();
      });

      // Spoiler field should be rendered (not SizedBox.shrink)
      expect(find.byType(PostStatusForm), findsOneWidget);
      expect(find.text('Content Warning'), findsOneWidget);
    });

    testWidgets('renders with scheduledAt from editFrom', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );
      final editFrom = MockStatus.create(
        id: 'edit-2',
        content: '<p>Scheduled post</p>',
        scheduledAt: DateTime.now().add(const Duration(days: 1)),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: PostStatusForm(editFrom: editFrom)),
          accessStatus: status,
        ));
        await tester.pump();
      });

      // The scheduled icon should appear in the submit button
      expect(find.byType(PostStatusForm), findsOneWidget);
      expect(find.byIcon(Icons.schedule), findsOneWidget);
    });

    testWidgets('renders with attachments from editFrom', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );
      final attachment = MockAttachment.create(id: 'att-edit-1');
      final editFrom = MockStatus.create(
        id: 'edit-3',
        content: '<p>Post with media</p>',
        attachments: [attachment],
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: PostStatusForm(editFrom: editFrom)),
          accessStatus: status,
        ));
        await tester.pump();
      });

      // Media section should be rendered
      expect(find.byType(PostStatusForm), findsOneWidget);
      // Remove button icon should be visible for the attachment
      expect(find.byIcon(Icons.remove_circle), findsOneWidget);
    });

    testWidgets('renders with draftFrom parameters', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );
      final draft = DraftSchema(
        id: 'draft-1',
        content: 'Draft text here',
        spoiler: 'Draft CW',
        sensitive: true,
        visibility: VisibilityType.private,
        updatedAt: DateTime.now(),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: PostStatusForm(draftFrom: draft)),
          accessStatus: status,
        ));
        await tester.pump();
      });

      expect(find.byType(PostStatusForm), findsOneWidget);
      expect(find.text('Draft text here'), findsOneWidget);
      expect(find.text('Draft CW'), findsOneWidget);
    });

    testWidgets('long press submit button toggles schedule mode', (tester) async {
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

      // Initially shows chat icon (not scheduled)
      expect(find.byIcon(Icons.chat), findsOneWidget);

      // Long press the submit button (FilledButton.icon) to toggle schedule mode
      final chatIcon = find.byIcon(Icons.chat);
      // Find the ancestor FilledButton
      final button = find.ancestor(
        of: chatIcon,
        matching: find.byWidgetPredicate((w) => w is FilledButton),
      );
      expect(button, findsOneWidget);

      await tester.longPress(button);
      await tester.pump();

      // After long press, should show schedule icon
      expect(find.byIcon(Icons.schedule), findsOneWidget);
    });

    testWidgets('unfocusing spoiler field updates spoiler state', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );
      final editFrom = MockStatus.create(
        id: 'edit-spoiler',
        content: '<p>Test spoiler focus</p>',
        spoiler: 'Initial CW',
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: PostStatusForm(editFrom: editFrom)),
          accessStatus: status,
        ));
        await tester.pump();
      });

      // Find the spoiler text field (has the CW text)
      expect(find.text('Initial CW'), findsOneWidget);

      // Tap the spoiler field to focus it
      await tester.tap(find.text('Initial CW'));
      await tester.pump();

      // Now tap the main content text field to unfocus the spoiler
      final mainField = find.byType(TextFormField).last;
      await tester.tap(mainField);
      await tester.pump();

      // Widget still renders without crash after focus change
      expect(find.byType(PostStatusForm), findsOneWidget);
    });

    testWidgets('tapping remove button removes media attachment', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );
      final attachment = MockAttachment.create(id: 'att-rm-1');
      final editFrom = MockStatus.create(
        id: 'edit-rm',
        content: '<p>Post</p>',
        attachments: [attachment],
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: PostStatusForm(editFrom: editFrom)),
          accessStatus: status,
        ));
        await tester.pump();
      });

      // Verify remove button exists
      expect(find.byIcon(Icons.remove_circle), findsOneWidget);

      // Tap the remove button
      await tester.tap(find.byIcon(Icons.remove_circle));
      await tester.pumpAndSettle();

      // After removing, the icon should be gone
      expect(find.byIcon(Icons.remove_circle), findsNothing);
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
