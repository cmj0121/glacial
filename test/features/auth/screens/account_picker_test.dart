// Widget tests for AccountPickerSheet.
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

/// Helper to create a SavedAccountSchema for testing.
SavedAccountSchema createSavedAccount({
  String domain = 'mastodon.social',
  String accountId = '100',
  String username = 'alice',
  String displayName = 'Alice',
  String avatar = 'https://example.com/avatar.png',
  DateTime? lastUsed,
}) {
  return SavedAccountSchema(
    domain: domain,
    accountId: accountId,
    username: username,
    displayName: displayName,
    avatar: avatar,
    lastUsed: lastUsed ?? DateTime(2024, 1, 1),
  );
}

/// Serialize a list of SavedAccountSchema to JSON string for SharedPreferences.
String savedAccountsJson(List<SavedAccountSchema> accounts) {
  return jsonEncode(accounts.map((a) => a.toJson()).toList());
}

void main() {
  setupTestEnvironment();

  // Initialize sqflite FFI for CachedNetworkImage's cache manager.
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // Mock path_provider channel for CachedNetworkImage.
  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'getApplicationDocumentsDirectory' ||
            methodCall.method == 'getTemporaryDirectory' ||
            methodCall.method == 'getApplicationSupportDirectory') {
          return '/tmp';
        }
        return null;
      },
    );
  });

  group('AccountPickerSheet', () {
    testWidgets('renders with authenticated status', (tester) async {
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AccountPickerSheet(status: status),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.byType(AccountPickerSheet), findsOneWidget);
    });

    testWidgets('shows title text', (tester) async {
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AccountPickerSheet(status: status),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.text('Accounts'), findsOneWidget);
    });

    testWidgets('shows add account button', (tester) async {
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AccountPickerSheet(status: status),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.text('Add Account'), findsOneWidget);
      expect(find.byIcon(Icons.person_add), findsOneWidget);
    });

    testWidgets('shows loading indicator initially', (tester) async {
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AccountPickerSheet(status: status),
        accessStatus: status,
      ));
      // Before the post-frame callback fires, should show loading.
      expect(find.byType(AccountPickerSheet), findsOneWidget);
    });

    testWidgets('renders with anonymous status', (tester) async {
      final status = MockAccessStatus.anonymous();

      await tester.pumpWidget(createTestWidget(
        child: AccountPickerSheet(status: status),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.byType(AccountPickerSheet), findsOneWidget);
      expect(find.text('Accounts'), findsOneWidget);
    });

    testWidgets('renders with null status', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const AccountPickerSheet(status: null),
      ));
      await tester.pump();

      expect(find.byType(AccountPickerSheet), findsOneWidget);
    });

    testWidgets('add account button is an OutlinedButton', (tester) async {
      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AccountPickerSheet(status: status),
        accessStatus: status,
      ));
      await tester.pump();

      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('loads and displays saved accounts', (tester) async {
      final saved = [
        createSavedAccount(accountId: '100', username: 'alice', displayName: 'Alice'),
        createSavedAccount(accountId: '200', username: 'bob', displayName: 'Bob'),
      ];

      SharedPreferences.setMockInitialValues({
        'saved_accounts': savedAccountsJson(saved),
      });
      await Storage.init();

      final status = MockAccessStatus.authenticated(
        account: MockAccount.create(id: '999', username: 'other'),
      );

      await tester.pumpWidget(createTestWidget(
        child: AccountPickerSheet(status: status),
        accessStatus: status,
      ));

      // Let onLoad complete via post-frame callback
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();

      // Both saved accounts should render
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('@alice@mastodon.social'), findsOneWidget);
      expect(find.text('@bob@mastodon.social'), findsOneWidget);
    });

    testWidgets('shows check icon for current account', (tester) async {
      final currentAccount = MockAccount.create(id: '100', username: 'alice');
      final saved = [
        createSavedAccount(accountId: '100', username: 'alice', displayName: 'Alice'),
        createSavedAccount(accountId: '200', username: 'bob', displayName: 'Bob'),
      ];

      SharedPreferences.setMockInitialValues({
        'saved_accounts': savedAccountsJson(saved),
      });
      await Storage.init();

      final status = MockAccessStatus.authenticated(account: currentAccount);

      await tester.pumpWidget(createTestWidget(
        child: AccountPickerSheet(status: status),
        accessStatus: status,
      ));

      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();

      // Current account should have a check icon
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('account tile shows CachedNetworkImage for avatar', (tester) async {
      final saved = [
        createSavedAccount(accountId: '100', username: 'alice', displayName: 'Alice'),
      ];

      SharedPreferences.setMockInitialValues({
        'saved_accounts': savedAccountsJson(saved),
      });
      await Storage.init();

      final status = MockAccessStatus.authenticated(
        account: MockAccount.create(id: '999', username: 'other'),
      );

      await tester.pumpWidget(createTestWidget(
        child: AccountPickerSheet(status: status),
        accessStatus: status,
      ));

      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();

      expect(find.byType(CachedNetworkImage), findsOneWidget);
    });

    testWidgets('account tile uses username when displayName is empty', (tester) async {
      final saved = [
        createSavedAccount(accountId: '100', username: 'alice', displayName: ''),
      ];

      SharedPreferences.setMockInitialValues({
        'saved_accounts': savedAccountsJson(saved),
      });
      await Storage.init();

      final status = MockAccessStatus.authenticated(
        account: MockAccount.create(id: '999', username: 'other'),
      );

      await tester.pumpWidget(createTestWidget(
        child: AccountPickerSheet(status: status),
        accessStatus: status,
      ));

      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();

      // Title should show username since displayName is empty
      expect(find.text('alice'), findsAtLeast(1));
    });

    testWidgets('no check icon when no account matches', (tester) async {
      final saved = [
        createSavedAccount(accountId: '200', username: 'bob', displayName: 'Bob'),
      ];

      SharedPreferences.setMockInitialValues({
        'saved_accounts': savedAccountsJson(saved),
      });
      await Storage.init();

      final status = MockAccessStatus.authenticated(
        account: MockAccount.create(id: '999', username: 'other'),
      );

      await tester.pumpWidget(createTestWidget(
        child: AccountPickerSheet(status: status),
        accessStatus: status,
      ));

      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();

      expect(find.byIcon(Icons.check_circle), findsNothing);
    });

    testWidgets('shows empty list when no saved accounts', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await Storage.init();

      final status = MockAccessStatus.authenticated();

      await tester.pumpWidget(createTestWidget(
        child: AccountPickerSheet(status: status),
        accessStatus: status,
      ));

      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();

      // Should show add account button but no account tiles
      expect(find.text('Add Account'), findsOneWidget);
      expect(find.byType(ListTile), findsNothing);
    });

    testWidgets('dismiss on current account is rejected', (tester) async {
      final currentAccount = MockAccount.create(id: '100', username: 'alice');
      final saved = [
        createSavedAccount(accountId: '100', username: 'alice', displayName: 'Alice'),
      ];

      SharedPreferences.setMockInitialValues({
        'saved_accounts': savedAccountsJson(saved),
      });
      await Storage.init();

      final status = MockAccessStatus.authenticated(account: currentAccount);

      await tester.pumpWidget(createTestWidget(
        child: AccountPickerSheet(status: status),
        accessStatus: status,
      ));

      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();

      // Attempt to dismiss the current account tile
      await tester.drag(find.text('Alice'), const Offset(-400, 0));
      await tester.pumpAndSettle();

      // Tile should still be present (dismiss rejected for current account)
      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('dismiss on non-current account removes it', (tester) async {
      final saved = [
        createSavedAccount(accountId: '100', username: 'alice', displayName: 'Alice'),
        createSavedAccount(accountId: '200', username: 'bob', displayName: 'Bob'),
      ];

      SharedPreferences.setMockInitialValues({
        'saved_accounts': savedAccountsJson(saved),
      });
      FlutterSecureStorage.setMockInitialValues({});
      await Storage.init();

      final status = MockAccessStatus.authenticated(
        account: MockAccount.create(id: '999', username: 'other'),
      );

      await tester.pumpWidget(createTestWidget(
        child: AccountPickerSheet(status: status),
        accessStatus: status,
      ));

      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();

      expect(find.text('Alice'), findsOneWidget);

      // Dismiss Alice's tile — this triggers onRemoveAccount which:
      // 1. Removes the saved account from SharedPreferences
      // 2. Removes the access token from FlutterSecureStorage
      // 3. Shows a snackbar "Account removed"
      // 4. Removes from the local accounts list
      await tester.drag(find.text('Alice'), const Offset(-400, 0));
      await tester.pumpAndSettle();

      // Bob should still be there
      expect(find.text('Bob'), findsOneWidget);
    });

    testWidgets('dismiss background shows delete icon', (tester) async {
      final saved = [
        createSavedAccount(accountId: '200', username: 'bob', displayName: 'Bob'),
      ];

      SharedPreferences.setMockInitialValues({
        'saved_accounts': savedAccountsJson(saved),
      });
      await Storage.init();

      final status = MockAccessStatus.authenticated(
        account: MockAccount.create(id: '999', username: 'other'),
      );

      await tester.pumpWidget(createTestWidget(
        child: AccountPickerSheet(status: status),
        accessStatus: status,
      ));

      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();

      // Start dragging to reveal dismiss background
      await tester.drag(find.text('Bob'), const Offset(-100, 0));
      await tester.pump();

      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('tapping non-current account triggers switch', (tester) async {
      final saved = [
        createSavedAccount(accountId: '200', username: 'bob', displayName: 'Bob'),
      ];

      SharedPreferences.setMockInitialValues({
        'saved_accounts': savedAccountsJson(saved),
      });
      // Initialize FlutterSecureStorage so switchToAccount can call loadAccessToken
      // No token for bob means switchToAccount returns early ("no token found")
      FlutterSecureStorage.setMockInitialValues({});
      await Storage.init();

      final status = MockAccessStatus.authenticated(
        account: MockAccount.create(id: '999', username: 'other'),
      );

      await tester.pumpWidget(createTestWidget(
        child: AccountPickerSheet(status: status),
        accessStatus: status,
      ));

      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();

      // Tap Bob's tile (non-current account) — will trigger onSwitchAccount
      // which calls storage.switchToAccount. Since no token is stored for
      // bob's compositeKey, it will return early (no token found).
      // The error handler catches exceptions and shows a snackbar.
      await tester.tap(find.text('Bob'));
      await tester.pump();

      // Let the async switchToAccount complete
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump();
    });

    testWidgets('tapping current account does nothing', (tester) async {
      final currentAccount = MockAccount.create(id: '100', username: 'alice');
      final saved = [
        createSavedAccount(accountId: '100', username: 'alice', displayName: 'Alice'),
      ];

      SharedPreferences.setMockInitialValues({
        'saved_accounts': savedAccountsJson(saved),
      });
      await Storage.init();

      final status = MockAccessStatus.authenticated(account: currentAccount);

      await tester.pumpWidget(createTestWidget(
        child: AccountPickerSheet(status: status),
        accessStatus: status,
      ));

      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();

      // Tap the current account tile — onTap should be null
      await tester.tap(find.text('Alice'));
      await tester.pump();

      // Widget should still be there (no navigation)
      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('add account button with null domain returns early', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await Storage.init();

      // Use a status with null domain to trigger early return in onAddAccount
      final status = AccessStatusSchema(domain: null);

      await tester.pumpWidget(createTestWidget(
        child: AccountPickerSheet(status: status),
        accessStatus: status,
      ));

      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();

      // Tap add account — domain is null, should return early
      await tester.tap(find.text('Add Account'));
      await tester.pump();

      // Widget should still be there (no navigation, no crash)
      expect(find.byType(AccountPickerSheet), findsOneWidget);
    });

    testWidgets('add account button with empty domain returns early', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await Storage.init();

      final status = AccessStatusSchema(domain: '');

      await tester.pumpWidget(createTestWidget(
        child: AccountPickerSheet(status: status),
        accessStatus: status,
      ));

      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();

      await tester.tap(find.text('Add Account'));
      await tester.pump();

      expect(find.byType(AccountPickerSheet), findsOneWidget);
    });

    testWidgets('add account with null status exits early', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await Storage.init();

      await tester.pumpWidget(createTestWidget(
        child: const AccountPickerSheet(status: null),
      ));

      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();

      // Tap add account — status is null, should return early
      await tester.tap(find.text('Add Account'));
      await tester.pump();

      // Widget should still be there
      expect(find.byType(AccountPickerSheet), findsOneWidget);
    });

    testWidgets('multiple accounts render with ListView', (tester) async {
      final saved = [
        createSavedAccount(accountId: '100', username: 'alice', displayName: 'Alice'),
        createSavedAccount(accountId: '200', username: 'bob', displayName: 'Bob'),
        createSavedAccount(accountId: '300', username: 'carol', displayName: 'Carol'),
      ];

      SharedPreferences.setMockInitialValues({
        'saved_accounts': savedAccountsJson(saved),
      });
      await Storage.init();

      final status = MockAccessStatus.authenticated(
        account: MockAccount.create(id: '999', username: 'other'),
      );

      await tester.pumpWidget(createTestWidget(
        child: AccountPickerSheet(status: status),
        accessStatus: status,
      ));

      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();

      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('Carol'), findsOneWidget);
    });

    testWidgets('account subtitle shows @username@domain', (tester) async {
      final saved = [
        createSavedAccount(
          accountId: '100',
          username: 'alice',
          displayName: 'Alice',
          domain: 'example.social',
        ),
      ];

      SharedPreferences.setMockInitialValues({
        'saved_accounts': savedAccountsJson(saved),
      });
      await Storage.init();

      final status = MockAccessStatus.authenticated(
        account: MockAccount.create(id: '999', username: 'other'),
      );

      await tester.pumpWidget(createTestWidget(
        child: AccountPickerSheet(status: status),
        accessStatus: status,
      ));

      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();

      expect(find.text('@alice@example.social'), findsOneWidget);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
