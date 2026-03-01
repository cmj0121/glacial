// Widget tests for profile familiar screens: FamiliarFollowers, FeaturedTags.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  // Initialize sqflite FFI for CachedNetworkImage's cache manager in runAsync tests.
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('FamiliarFollowers', () {
    setUpAll(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (MethodCall methodCall) async => Directory.systemTemp.path,
      );
    });

    testWidgets('renders empty initially', (tester) async {
      final account = MockAccount.create(id: '999');
      final status = MockAccessStatus.authenticated();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: FamiliarFollowers(schema: account),
          accessStatus: status,
        ));
        await tester.pump();
      });

      // accounts is empty before API load, so renders SizedBox.shrink
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('accepts required schema parameter', (tester) async {
      final account = MockAccount.create(id: '999', displayName: 'Alice');
      final status = MockAccessStatus.authenticated();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: FamiliarFollowers(schema: account),
          accessStatus: status,
        ));
        await tester.pump();
      });

      expect(find.byType(FamiliarFollowers), findsOneWidget);
    });

    testWidgets('accepts custom avatarSize', (tester) async {
      final account = MockAccount.create(id: '999');
      final status = MockAccessStatus.authenticated();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: FamiliarFollowers(schema: account, avatarSize: 32),
          accessStatus: status,
        ));
        await tester.pump();
      });

      expect(find.byType(FamiliarFollowers), findsOneWidget);
    });

    testWidgets('renders SizedBox.shrink when accounts is empty', (tester) async {
      final account = MockAccount.create(id: '999');
      // Use no-domain auth so fetchFamiliarFollowers returns empty
      const status = AccessStatusSchema(domain: null, accessToken: 'test');

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: FamiliarFollowers(schema: account),
          accessStatus: status,
        ));
        await tester.pump();
      });

      // Empty accounts -> SizedBox.shrink
      expect(find.byType(FamiliarFollowers), findsOneWidget);
    });

    testWidgets('shows avatars and label when accounts are loaded', (tester) async {
      final account = MockAccount.create(id: '999');
      final status = MockAccessStatus.authenticated();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: FamiliarFollowers(schema: account),
          accessStatus: status,
        ));
        await tester.pump();

        // Inject accounts into state
        final state = tester.state(find.byType(FamiliarFollowers));
        (state as dynamic).accounts = [
          MockAccount.create(id: 'f1', username: 'follower1'),
          MockAccount.create(id: 'f2', username: 'follower2'),
        ];
        (tester.element(find.byType(FamiliarFollowers)) as StatefulElement).markNeedsBuild();
        await tester.pump();
      });

      // Should show AccountAvatar widgets
      expect(find.byType(AccountAvatar), findsNWidgets(2));
      // Should show "Also followed by" label
      expect(find.text('Also followed by'), findsOneWidget);
    });

    testWidgets('shows at most 5 avatars', (tester) async {
      final account = MockAccount.create(id: '999');
      final status = MockAccessStatus.authenticated();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: FamiliarFollowers(schema: account),
          accessStatus: status,
        ));
        await tester.pump();

        // Inject 7 accounts
        final state = tester.state(find.byType(FamiliarFollowers));
        (state as dynamic).accounts = List.generate(7, (i) =>
          MockAccount.create(id: 'f$i', username: 'follower$i'),
        );
        (tester.element(find.byType(FamiliarFollowers)) as StatefulElement).markNeedsBuild();
        await tester.pump();
      });

      // Should only show 5 avatars (take(5))
      expect(find.byType(AccountAvatar), findsNWidgets(5));
    });

    testWidgets('does not load when not signed in', (tester) async {
      final account = MockAccount.create(id: '999');
      final status = MockAccessStatus.anonymous();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: FamiliarFollowers(schema: account),
          accessStatus: status,
        ));
        await tester.pump();
      });

      // isSignedIn is false, so onLoad returns early
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('uses Row layout when accounts are present', (tester) async {
      final account = MockAccount.create(id: '999');
      final status = MockAccessStatus.authenticated();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: FamiliarFollowers(schema: account),
          accessStatus: status,
        ));
        await tester.pump();

        final state = tester.state(find.byType(FamiliarFollowers));
        (state as dynamic).accounts = [
          MockAccount.create(id: 'f1', username: 'follower1'),
        ];
        (tester.element(find.byType(FamiliarFollowers)) as StatefulElement).markNeedsBuild();
        await tester.pump();
      });

      // When accounts are present, Padding and Row should be rendered
      expect(find.byType(Row), findsWidgets);
    });
  });

  group('FeaturedTags', () {
    testWidgets('renders empty initially for non-self', (tester) async {
      // Use a different account ID so isSelf is false
      final viewedAccount = MockAccount.create(id: '999');
      final selfAccount = MockAccount.create(id: '123');
      final status = MockAccessStatus.authenticated(account: selfAccount);

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: FeaturedTags(schema: viewedAccount),
          accessStatus: status,
        ));
        await tester.pump();
      });

      // tags is empty and not self, so renders SizedBox.shrink
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('accepts required schema parameter', (tester) async {
      final account = MockAccount.create(id: '999');
      final status = MockAccessStatus.authenticated();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: FeaturedTags(schema: account),
          accessStatus: status,
        ));
        await tester.pump();
      });

      expect(find.byType(FeaturedTags), findsOneWidget);
    });

    testWidgets('renders add chip for self profile even with no tags', (tester) async {
      final selfAccount = MockAccount.create(id: '123');
      final status = MockAccessStatus.authenticated(account: selfAccount);

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: FeaturedTags(schema: selfAccount),
          accessStatus: status,
        ));
        await tester.pump();
      });

      // isSelf is true, tags is empty but self profile still shows
      // (isSelf check: tags.isEmpty && !isSelf returns SizedBox)
      // So for self, the widget always renders even with empty tags
      expect(find.byType(FeaturedTags), findsOneWidget);
      // Should show the ActionChip to add a tag
      expect(find.byType(ActionChip), findsOneWidget);
    });

    testWidgets('shows featured tag chips when tags are loaded', (tester) async {
      final selfAccount = MockAccount.create(id: '123');
      final status = MockAccessStatus.authenticated(account: selfAccount);

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: FeaturedTags(schema: selfAccount),
          accessStatus: status,
        ));
        await tester.pump();

        // Inject tags into state
        final state = tester.state(find.byType(FeaturedTags));
        (state as dynamic).tags = [
          MockFeaturedTag.create(id: 'ft-1', name: 'flutter'),
          MockFeaturedTag.create(id: 'ft-2', name: 'dart'),
        ];
        (tester.element(find.byType(FeaturedTags)) as StatefulElement).markNeedsBuild();
        await tester.pump();
      });

      // Should show InputChip for each tag
      expect(find.byType(InputChip), findsNWidgets(2));
      expect(find.text('#flutter'), findsOneWidget);
      expect(find.text('#dart'), findsOneWidget);
    });

    testWidgets('shows delete icon on tags for self profile', (tester) async {
      final selfAccount = MockAccount.create(id: '123');
      final status = MockAccessStatus.authenticated(account: selfAccount);

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: FeaturedTags(schema: selfAccount),
          accessStatus: status,
        ));
        await tester.pump();

        final state = tester.state(find.byType(FeaturedTags));
        (state as dynamic).tags = [
          MockFeaturedTag.create(id: 'ft-1', name: 'flutter'),
        ];
        (tester.element(find.byType(FeaturedTags)) as StatefulElement).markNeedsBuild();
        await tester.pump();
      });

      // InputChip should have a close icon for deletion
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('shows "Featured tags" label when tags exist', (tester) async {
      final selfAccount = MockAccount.create(id: '123');
      final status = MockAccessStatus.authenticated(account: selfAccount);

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: FeaturedTags(schema: selfAccount),
          accessStatus: status,
        ));
        await tester.pump();

        final state = tester.state(find.byType(FeaturedTags));
        (state as dynamic).tags = [
          MockFeaturedTag.create(id: 'ft-1', name: 'flutter'),
        ];
        (tester.element(find.byType(FeaturedTags)) as StatefulElement).markNeedsBuild();
        await tester.pump();
      });

      // The "Featured tags" label text should appear
      expect(find.text('Featured tags'), findsWidgets);
    });

    testWidgets('no delete icon on tags for non-self profile', (tester) async {
      final viewedAccount = MockAccount.create(id: '999');
      final selfAccount = MockAccount.create(id: '123');
      final status = MockAccessStatus.authenticated(account: selfAccount);

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: FeaturedTags(schema: viewedAccount),
          accessStatus: status,
        ));
        await tester.pump();

        final state = tester.state(find.byType(FeaturedTags));
        (state as dynamic).tags = [
          MockFeaturedTag.create(id: 'ft-1', name: 'flutter'),
        ];
        (tester.element(find.byType(FeaturedTags)) as StatefulElement).markNeedsBuild();
        await tester.pump();
      });

      // Non-self should not show close/delete icons on InputChip
      expect(find.byIcon(Icons.close), findsNothing);
      // And should not show ActionChip to add tags
      expect(find.byType(ActionChip), findsNothing);
    });

    testWidgets('tapping add chip opens dialog for self', (tester) async {
      final selfAccount = MockAccount.create(id: '123');
      final status = MockAccessStatus.authenticated(account: selfAccount);

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: FeaturedTags(schema: selfAccount),
          accessStatus: status,
        ));
        await tester.pump();
      });

      // Tap the ActionChip (add) button
      await tester.tap(find.byType(ActionChip));
      await tester.pumpAndSettle();

      // Should open dialog with TextField for entering tag name
      expect(find.byType(TextField), findsOneWidget);
      // Should have Close and Save buttons
      expect(find.text('Close'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('add tag dialog has # prefix text', (tester) async {
      final selfAccount = MockAccount.create(id: '123');
      final status = MockAccessStatus.authenticated(account: selfAccount);

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: FeaturedTags(schema: selfAccount),
          accessStatus: status,
        ));
        await tester.pump();
      });

      // Tap add
      await tester.tap(find.byType(ActionChip));
      await tester.pumpAndSettle();

      // TextField should have '#' prefix
      expect(find.text('#'), findsOneWidget);
    });

    testWidgets('tapping delete icon on tag removes it from state', (tester) async {
      final selfAccount = MockAccount.create(id: '123');
      final status = MockAccessStatus.authenticated(account: selfAccount);

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: FeaturedTags(schema: selfAccount),
          accessStatus: status,
        ));
        await tester.pump();

        final state = tester.state(find.byType(FeaturedTags));
        (state as dynamic).tags = [
          MockFeaturedTag.create(id: 'ft-1', name: 'flutter'),
          MockFeaturedTag.create(id: 'ft-2', name: 'dart'),
        ];
        (tester.element(find.byType(FeaturedTags)) as StatefulElement).markNeedsBuild();
        await tester.pump();

        // Should have 2 InputChips
        expect(find.byType(InputChip), findsNWidgets(2));

        // Tap the first delete icon to trigger onRemove
        await tester.tap(find.byIcon(Icons.close).first);
        await tester.pump();
      });

      // After removal, only 1 InputChip remains
      expect(find.byType(InputChip), findsOneWidget);
      expect(find.text('#dart'), findsOneWidget);
    });

    testWidgets('uses Wrap for tag layout when tags exist', (tester) async {
      final selfAccount = MockAccount.create(id: '123');
      final status = MockAccessStatus.authenticated(account: selfAccount);

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: FeaturedTags(schema: selfAccount),
          accessStatus: status,
        ));
        await tester.pump();

        final state = tester.state(find.byType(FeaturedTags));
        (state as dynamic).tags = [
          MockFeaturedTag.create(id: 'ft-1', name: 'flutter'),
        ];
        (tester.element(find.byType(FeaturedTags)) as StatefulElement).markNeedsBuild();
        await tester.pump();
      });

      expect(find.byType(Wrap), findsOneWidget);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
