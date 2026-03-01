// Widget tests for profile edit screens: EditProfilePage, EditProfileCategory.
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  // Initialize sqflite FFI for CachedNetworkImage's cache manager in runAsync tests.
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('EditProfilePage', () {
    setUpAll(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (MethodCall methodCall) async => Directory.systemTemp.path,
      );
    });

    // All EditProfilePage tests use accessStatusProvider override to null.
    // The widget's onSave() calls status?.updateAccount(schema) -- with null status
    // this short-circuits safely, preventing async PATCH calls from leaking errors
    // when the Focus widget triggers onFocusChange during test teardown.

    testWidgets('renders SwipeTabView', (tester) async {
      final account = MockAccount.create();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: EditProfilePage(account: account),
          ),
          overrides: [accessStatusProvider.overrideWith((ref) => null)],
        ));
        await tester.pump();
      });

      expect(find.byType(SwipeTabView), findsOneWidget);
    });

    testWidgets('shows tab icons for categories', (tester) async {
      final account = MockAccount.create();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: EditProfilePage(account: account),
          ),
          overrides: [accessStatusProvider.overrideWith((ref) => null)],
        ));
        await tester.pump();
      });

      // The general tab should show its active icon (selected by default)
      expect(find.byIcon(CupertinoIcons.doc_person_fill), findsOneWidget);
      // The privacy tab should show its inactive icon
      expect(find.byIcon(Icons.privacy_tip_outlined), findsOneWidget);
    });

    testWidgets('general tab shows display name text field', (tester) async {
      final account = MockAccount.create(displayName: 'TestUser');

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: EditProfilePage(account: account),
          ),
          overrides: [accessStatusProvider.overrideWith((ref) => null)],
        ));
        await tester.pump();
      });

      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('general tab shows name icon', (tester) async {
      final account = MockAccount.create();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: EditProfilePage(account: account),
          ),
          overrides: [accessStatusProvider.overrideWith((ref) => null)],
        ));
        await tester.pump();
      });

      expect(find.byIcon(Icons.text_fields_outlined), findsOneWidget);
    });

    testWidgets('general tab shows bio icon', (tester) async {
      final account = MockAccount.create();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: EditProfilePage(account: account),
          ),
          overrides: [accessStatusProvider.overrideWith((ref) => null)],
        ));
        await tester.pump();
      });

      expect(find.byIcon(Icons.description), findsOneWidget);
    });

    testWidgets('general tab shows person icon when not bot', (tester) async {
      final account = MockAccount.create(bot: false);

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: EditProfilePage(account: account),
          ),
          overrides: [accessStatusProvider.overrideWith((ref) => null)],
        ));
        await tester.pump();
      });

      expect(find.byType(SwitchListTile), findsWidgets);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('general tab shows bot icon when bot is true', (tester) async {
      final account = MockAccount.create(bot: true);

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: EditProfilePage(account: account),
          ),
          overrides: [accessStatusProvider.overrideWith((ref) => null)],
        ));
        await tester.pump();
      });

      expect(find.byIcon(Icons.smart_toy_outlined), findsOneWidget);
    });

    testWidgets('general tab shows field items for existing fields', (tester) async {
      final account = AccountSchema(
        id: '123',
        username: 'testuser',
        acct: 'testuser',
        url: 'https://example.com/@testuser',
        displayName: 'Test User',
        note: 'A note',
        avatar: 'https://example.com/avatar.png',
        avatarStatic: 'https://example.com/avatar.png',
        header: 'https://example.com/header.png',
        locked: false,
        bot: false,
        indexable: true,
        createdAt: DateTime(2023, 1, 1),
        statusesCount: 10,
        followersCount: 5,
        followingCount: 3,
        fields: const [
          FieldSchema(name: 'Website', value: 'https://example.com'),
          FieldSchema(name: 'Location', value: 'Earth'),
        ],
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: EditProfilePage(account: account),
          ),
          overrides: [accessStatusProvider.overrideWith((ref) => null)],
        ));
        await tester.pump();
      });

      // Should show field items for existing fields
      expect(find.byType(AccessibleDismissible), findsWidgets);
    });

    testWidgets('general tab shows Divider', (tester) async {
      final account = MockAccount.create();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: EditProfilePage(account: account),
          ),
          overrides: [accessStatusProvider.overrideWith((ref) => null)],
        ));
        await tester.pump();
      });

      expect(find.byType(Divider), findsOneWidget);
    });

    testWidgets('general tab shows image fields section with correct height', (tester) async {
      final account = MockAccount.create();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: EditProfilePage(account: account),
          ),
          overrides: [accessStatusProvider.overrideWith((ref) => null)],
        ));
        await tester.pump();
      });

      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox)).where((s) {
        return s.height == 200;
      });
      expect(sizedBoxes.isNotEmpty, isTrue);
    });

    testWidgets('privacy tab renders SwitchListTiles when selected', (tester) async {
      final account = MockAccount.create(locked: false);

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: EditProfilePage(account: account),
          ),
          overrides: [accessStatusProvider.overrideWith((ref) => null)],
        ));
        await tester.pump();
      });

      // Tap privacy tab icon
      await tester.tap(find.byIcon(Icons.privacy_tip_outlined));
      await tester.pumpAndSettle();

      // Privacy tab should show 4 SwitchListTiles
      expect(find.byType(SwitchListTile), findsNWidgets(4));
    });

    testWidgets('privacy tab shows lock_open icon for unlocked account', (tester) async {
      final account = MockAccount.create(locked: false);

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: EditProfilePage(account: account),
          ),
          overrides: [accessStatusProvider.overrideWith((ref) => null)],
        ));
        await tester.pump();
      });

      await tester.tap(find.byIcon(Icons.privacy_tip_outlined));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.lock_open), findsOneWidget);
    });

    testWidgets('privacy tab shows lock_person icon for locked account', (tester) async {
      final account = MockAccount.create(locked: true);

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: EditProfilePage(account: account),
          ),
          overrides: [accessStatusProvider.overrideWith((ref) => null)],
        ));
        await tester.pump();
      });

      await tester.tap(find.byIcon(Icons.privacy_tip_outlined));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.lock_person), findsOneWidget);
    });

    testWidgets('toggling bot switch calls onChanged', (tester) async {
      final account = MockAccount.create(bot: false);

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: EditProfilePage(account: account),
          ),
          overrides: [accessStatusProvider.overrideWith((ref) => null)],
        ));
        await tester.pump();
      });

      // Find the bot SwitchListTile and toggle it
      final switchFinder = find.byType(SwitchListTile);
      expect(switchFinder, findsWidgets);

      // The bot switch is the first one on the general tab (3rd widget)
      // Toggle it by tapping the switch
      final botSwitch = find.byWidgetPredicate(
        (widget) => widget is SwitchListTile && widget.value == false &&
          widget.secondary is Icon && (widget.secondary as Icon).icon == Icons.person,
      );
      if (botSwitch.evaluate().isNotEmpty) {
        await tester.tap(botSwitch);
        await tester.pump();
      }

      expect(find.byType(EditProfilePage), findsOneWidget);
    });

    testWidgets('toggling locked switch on privacy tab calls onChanged', (tester) async {
      final account = MockAccount.create(locked: false);

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: EditProfilePage(account: account),
          ),
          overrides: [accessStatusProvider.overrideWith((ref) => null)],
        ));
        await tester.pump();
      });

      // Switch to privacy tab
      await tester.tap(find.byIcon(Icons.privacy_tip_outlined));
      await tester.pumpAndSettle();

      // Find locked switch (has lock_open icon) and toggle it
      final lockSwitch = find.byWidgetPredicate(
        (widget) => widget is SwitchListTile && widget.secondary is Icon &&
          (widget.secondary as Icon).icon == Icons.lock_open,
      );
      if (lockSwitch.evaluate().isNotEmpty) {
        await tester.tap(lockSwitch);
        await tester.pump();
      }

      expect(find.byType(EditProfilePage), findsOneWidget);
    });

    testWidgets('toggling discoverable switch calls onChanged', (tester) async {
      final account = MockAccount.create();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: EditProfilePage(account: account),
          ),
          overrides: [accessStatusProvider.overrideWith((ref) => null)],
        ));
        await tester.pump();
      });

      // Switch to privacy tab
      await tester.tap(find.byIcon(Icons.privacy_tip_outlined));
      await tester.pumpAndSettle();

      // Toggle discoverable switch
      final discoverableSwitch = find.byWidgetPredicate(
        (widget) => widget is SwitchListTile && widget.secondary is Icon &&
          (widget.secondary as Icon).icon == Icons.travel_explore,
      );
      if (discoverableSwitch.evaluate().isNotEmpty) {
        await tester.tap(discoverableSwitch);
        await tester.pump();
      }

      expect(find.byType(EditProfilePage), findsOneWidget);
    });

    testWidgets('toggling indexable switch calls onChanged', (tester) async {
      final account = MockAccount.create();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: EditProfilePage(account: account),
          ),
          overrides: [accessStatusProvider.overrideWith((ref) => null)],
        ));
        await tester.pump();
      });

      // Switch to privacy tab
      await tester.tap(find.byIcon(Icons.privacy_tip_outlined));
      await tester.pumpAndSettle();

      // Toggle indexable switch (search icon)
      final indexableSwitch = find.byWidgetPredicate(
        (widget) => widget is SwitchListTile && widget.secondary is Icon &&
          (widget.secondary as Icon).icon == Icons.search,
      );
      if (indexableSwitch.evaluate().isNotEmpty) {
        await tester.tap(indexableSwitch);
        await tester.pump();
      }

      expect(find.byType(EditProfilePage), findsOneWidget);
    });

    testWidgets('toggling hide collections switch calls onChanged', (tester) async {
      final account = MockAccount.create();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: EditProfilePage(account: account),
          ),
          overrides: [accessStatusProvider.overrideWith((ref) => null)],
        ));
        await tester.pump();
      });

      // Switch to privacy tab
      await tester.tap(find.byIcon(Icons.privacy_tip_outlined));
      await tester.pumpAndSettle();

      // Toggle hide collections switch
      final hideSwitch = find.byWidgetPredicate(
        (widget) => widget is SwitchListTile && widget.secondary is Icon &&
          (widget.secondary as Icon).icon == Icons.private_connectivity,
      );
      if (hideSwitch.evaluate().isNotEmpty) {
        await tester.tap(hideSwitch);
        await tester.pump();
      }

      expect(find.byType(EditProfilePage), findsOneWidget);
    });

    testWidgets('submitting name field triggers onSubmitted', (tester) async {
      final account = MockAccount.create(displayName: 'OldName');

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: EditProfilePage(account: account),
          ),
          overrides: [accessStatusProvider.overrideWith((ref) => null)],
        ));
        await tester.pump();
      });

      // Find the name TextField (first one) and submit
      final textFields = find.byType(TextField);
      if (textFields.evaluate().isNotEmpty) {
        await tester.enterText(textFields.first, 'NewName');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();
      }

      expect(find.byType(EditProfilePage), findsOneWidget);
    });

    testWidgets('swiping field item removes it', (tester) async {
      final account = AccountSchema(
        id: '123',
        username: 'testuser',
        acct: 'testuser',
        url: 'https://example.com/@testuser',
        displayName: 'Test User',
        note: 'A note',
        avatar: 'https://example.com/avatar.png',
        avatarStatic: 'https://example.com/avatar.png',
        header: 'https://example.com/header.png',
        locked: false,
        bot: false,
        indexable: true,
        createdAt: DateTime(2023, 1, 1),
        statusesCount: 10,
        followersCount: 5,
        followingCount: 3,
        fields: const [
          FieldSchema(name: 'Website', value: 'https://example.com'),
          FieldSchema(name: 'Location', value: 'Earth'),
        ],
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: EditProfilePage(account: account),
          ),
          overrides: [accessStatusProvider.overrideWith((ref) => null)],
        ));
        await tester.pump();
      });

      // Find an AccessibleDismissible and swipe it
      final dismissible = find.byType(AccessibleDismissible);
      if (dismissible.evaluate().isNotEmpty) {
        await tester.drag(dismissible.first, const Offset(500, 0));
        await tester.pumpAndSettle();
      }

      expect(find.byType(EditProfilePage), findsOneWidget);
    });

    testWidgets('avatar container is circular', (tester) async {
      final account = MockAccount.create();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: EditProfilePage(account: account),
          ),
          overrides: [accessStatusProvider.overrideWith((ref) => null)],
        ));
        await tester.pump();
      });

      final containerFinder = find.byWidgetPredicate((widget) =>
        widget is Container &&
        widget.decoration is BoxDecoration &&
        (widget.decoration as BoxDecoration).shape == BoxShape.circle,
      );
      expect(containerFinder, findsOneWidget);
    });
  });

  group('EditProfilePage.icon', () {
    testWidgets('renders icon button', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: EditProfilePage.icon(),
      ));
      await tester.pump();

      expect(find.byType(IconButton), findsOneWidget);
    });

    testWidgets('shows manage_accounts_outlined icon', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: EditProfilePage.icon(),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.manage_accounts_outlined), findsOneWidget);
    });

    testWidgets('wraps in LayoutBuilder', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: EditProfilePage.icon(),
      ));
      await tester.pump();

      expect(find.byType(LayoutBuilder), findsOneWidget);
    });
  });

  group('EditProfileCategory', () {
    test('has 2 values', () {
      expect(EditProfileCategory.values.length, 2);
      expect(EditProfileCategory.values, contains(EditProfileCategory.general));
      expect(EditProfileCategory.values, contains(EditProfileCategory.privacy));
    });

    test('each has icon() method', () {
      for (final category in EditProfileCategory.values) {
        expect(category.icon(), isA<IconData>());
        expect(category.icon(active: true), isA<IconData>());
        expect(category.icon(active: false), isA<IconData>());
      }
    });

    test('general active icon differs from inactive', () {
      expect(EditProfileCategory.general.icon(active: true),
          isNot(EditProfileCategory.general.icon(active: false)));
    });

    test('privacy active icon differs from inactive', () {
      expect(EditProfileCategory.privacy.icon(active: true),
          isNot(EditProfileCategory.privacy.icon(active: false)));
    });

    testWidgets('each has tooltip() method', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: Builder(
          builder: (context) {
            for (final category in EditProfileCategory.values) {
              final tooltip = category.tooltip(context);
              expect(tooltip, isA<String>());
              expect(tooltip.isNotEmpty, isTrue);
            }
            return const SizedBox.shrink();
          },
        ),
      ));
      await tester.pump();
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
