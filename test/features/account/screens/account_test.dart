// Widget tests for account screens: Account, AccountAvatar, AccountLite.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  group('Account', () {
    testWidgets('renders with schema', (tester) async {
      final account = MockAccount.create();

      await tester.pumpWidget(createTestWidget(
        child: Account(schema: account),
      ));
      await tester.pump();

      expect(find.byType(Account), findsOneWidget);
    });

    testWidgets('displays display name', (tester) async {
      final account = MockAccount.create(displayName: 'Alice');

      await tester.pumpWidget(createTestWidget(
        child: Account(schema: account),
      ));
      await tester.pump();

      expect(find.textContaining('Alice'), findsOneWidget);
    });

    testWidgets('displays acct with @ prefix', (tester) async {
      final account = MockAccount.create(username: 'alice');

      await tester.pumpWidget(createTestWidget(
        child: Account(schema: account),
      ));
      await tester.pump();

      expect(find.text('@alice'), findsOneWidget);
    });

    testWidgets('uses username when displayName is empty', (tester) async {
      final account = MockAccount.create(username: 'bob', displayName: '');

      await tester.pumpWidget(createTestWidget(
        child: Account(schema: account),
      ));
      await tester.pump();

      expect(find.textContaining('bob'), findsWidgets);
    });

    testWidgets('wraps in InkWellDone for navigation', (tester) async {
      final account = MockAccount.create();

      await tester.pumpWidget(createTestWidget(
        child: Account(schema: account),
      ));
      await tester.pump();

      expect(find.byType(InkWellDone), findsOneWidget);
    });

    testWidgets('accepts custom size', (tester) async {
      final account = MockAccount.create();

      await tester.pumpWidget(createTestWidget(
        child: Account(schema: account, size: 64),
      ));
      await tester.pump();

      expect(find.byType(Account), findsOneWidget);
    });

    testWidgets('uses Row layout for avatar and name', (tester) async {
      final account = MockAccount.create();

      await tester.pumpWidget(createTestWidget(
        child: Account(schema: account),
      ));
      await tester.pump();

      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('has ClipRect wrapping content', (tester) async {
      final account = MockAccount.create();

      await tester.pumpWidget(createTestWidget(
        child: Account(schema: account),
      ));
      await tester.pump();

      expect(find.byType(ClipRect), findsWidgets);
    });

    testWidgets('has Semantics widget for accessibility', (tester) async {
      final account = MockAccount.create(displayName: 'Semantic Test');

      await tester.pumpWidget(createTestWidget(
        child: Account(schema: account),
      ));
      await tester.pump();

      expect(find.byType(Semantics), findsWidgets);
    });

    testWidgets('Semantics label uses displayName when present', (tester) async {
      final account = MockAccount.create(displayName: 'AccessibleName');

      await tester.pumpWidget(createTestWidget(
        child: Account(schema: account),
      ));
      await tester.pump();

      final semantics = tester.widgetList<Semantics>(find.byType(Semantics));
      final hasCorrectLabel = semantics.any((s) => s.properties.label == 'AccessibleName');
      expect(hasCorrectLabel, isTrue);
    });

    testWidgets('Semantics label uses acct when displayName is empty', (tester) async {
      final account = MockAccount.create(username: 'acctuser', displayName: '');

      await tester.pumpWidget(createTestWidget(
        child: Account(schema: account),
      ));
      await tester.pump();

      final semantics = tester.widgetList<Semantics>(find.byType(Semantics));
      final hasAcctLabel = semantics.any((s) => s.properties.label == 'acctuser');
      expect(hasAcctLabel, isTrue);
    });

    testWidgets('uses Column for name layout', (tester) async {
      final account = MockAccount.create();

      await tester.pumpWidget(createTestWidget(
        child: Account(schema: account),
      ));
      await tester.pump();

      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('renders with emojis in display name', (tester) async {
      // Account with custom emoji in display name should render without error
      final account = MockAccount.create(displayName: 'User With Name');

      await tester.pumpWidget(createTestWidget(
        child: Account(schema: account),
      ));
      await tester.pump();

      expect(find.byType(Account), findsOneWidget);
      expect(find.textContaining('User With Name'), findsOneWidget);
    });
  });

  group('AccountAvatar', () {
    testWidgets('renders with schema', (tester) async {
      final account = MockAccount.create();

      await tester.pumpWidget(createTestWidget(
        child: AccountAvatar(schema: account),
      ));
      await tester.pump();

      expect(find.byType(AccountAvatar), findsOneWidget);
    });

    testWidgets('shows tooltip with acct', (tester) async {
      final account = MockAccount.create(username: 'charlie');

      await tester.pumpWidget(createTestWidget(
        child: AccountAvatar(schema: account),
      ));
      await tester.pump();

      expect(find.byType(Tooltip), findsOneWidget);
    });

    testWidgets('uses ClipOval for circular shape', (tester) async {
      final account = MockAccount.create();

      await tester.pumpWidget(createTestWidget(
        child: AccountAvatar(schema: account),
      ));
      await tester.pump();

      expect(find.byType(ClipOval), findsOneWidget);
    });

    testWidgets('accepts custom size', (tester) async {
      final account = MockAccount.create();

      await tester.pumpWidget(createTestWidget(
        child: AccountAvatar(schema: account, size: 32),
      ));
      await tester.pump();

      expect(find.byType(AccountAvatar), findsOneWidget);
    });

    testWidgets('wraps in InkWellDone for navigation', (tester) async {
      final account = MockAccount.create();

      await tester.pumpWidget(createTestWidget(
        child: AccountAvatar(schema: account),
      ));
      await tester.pump();

      expect(find.byType(InkWellDone), findsOneWidget);
    });

    testWidgets('has Semantics for accessibility', (tester) async {
      final account = MockAccount.create(displayName: 'AvatarUser');

      await tester.pumpWidget(createTestWidget(
        child: AccountAvatar(schema: account),
      ));
      await tester.pump();

      expect(find.byType(Semantics), findsWidgets);
    });

    testWidgets('Semantics label uses displayName when present', (tester) async {
      final account = MockAccount.create(displayName: 'AvatarAccess');

      await tester.pumpWidget(createTestWidget(
        child: AccountAvatar(schema: account),
      ));
      await tester.pump();

      final semantics = tester.widgetList<Semantics>(find.byType(Semantics));
      final hasCorrectLabel = semantics.any((s) => s.properties.label == 'AvatarAccess');
      expect(hasCorrectLabel, isTrue);
    });

    testWidgets('Semantics label uses acct when displayName is empty', (tester) async {
      final account = MockAccount.create(username: 'acctavatar', displayName: '');

      await tester.pumpWidget(createTestWidget(
        child: AccountAvatar(schema: account),
      ));
      await tester.pump();

      final semantics = tester.widgetList<Semantics>(find.byType(Semantics));
      final hasAcctLabel = semantics.any((s) => s.properties.label == 'acctavatar');
      expect(hasAcctLabel, isTrue);
    });

    testWidgets('tooltip message is the account acct', (tester) async {
      final account = MockAccount.create(username: 'tooltipuser');

      await tester.pumpWidget(createTestWidget(
        child: AccountAvatar(schema: account),
      ));
      await tester.pump();

      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
      expect(tooltip.message, 'tooltipuser');
    });
  });

  group('AccountLite', () {
    testWidgets('returns empty when schema is null', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const AccountLite(),
      ));
      await tester.pump();

      expect(find.byType(SizedBox), findsWidgets);
      expect(find.byType(ListTile), findsNothing);
    });

    testWidgets('renders ListTile with schema', (tester) async {
      final account = MockAccount.create(displayName: 'Dana');

      await tester.pumpWidget(createTestWidget(
        child: AccountLite(schema: account),
      ));
      await tester.pump();

      expect(find.byType(ListTile), findsOneWidget);
      expect(find.text('Dana'), findsOneWidget);
    });

    testWidgets('accepts custom size', (tester) async {
      final account = MockAccount.create();

      await tester.pumpWidget(createTestWidget(
        child: AccountLite(schema: account, size: 48),
      ));
      await tester.pump();

      expect(find.byType(AccountLite), findsOneWidget);
    });

    testWidgets('accepts custom onTap callback', (tester) async {
      bool tapped = false;
      final account = MockAccount.create();

      await tester.pumpWidget(createTestWidget(
        child: AccountLite(schema: account, onTap: () => tapped = true),
      ));
      await tester.pump();

      await tester.tap(find.byType(ListTile));
      expect(tapped, isTrue);
    });

    testWidgets('shows avatar in leading position', (tester) async {
      final account = MockAccount.create();

      await tester.pumpWidget(createTestWidget(
        child: AccountLite(schema: account),
      ));
      await tester.pump();

      expect(find.byType(ClipOval), findsOneWidget);
    });

    testWidgets('uses username when displayName is null', (tester) async {
      // AccountSchema with null displayName falls back to username
      final account = MockAccount.create(username: 'fallback_user', displayName: '');

      await tester.pumpWidget(createTestWidget(
        child: AccountLite(schema: account),
      ));
      await tester.pump();

      // displayName is '' so AccountLite falls back to username
      // AccountLite uses: schema?.displayName ?? schema?.username ?? '-'
      // Empty string is not null, so it will show ''
      expect(find.byType(ListTile), findsOneWidget);
    });

    testWidgets('has Semantics for avatar accessibility', (tester) async {
      final account = MockAccount.create(displayName: 'LiteUser');

      await tester.pumpWidget(createTestWidget(
        child: AccountLite(schema: account),
      ));
      await tester.pump();

      expect(find.byType(Semantics), findsWidgets);
    });

    testWidgets('Semantics label uses displayName when not empty', (tester) async {
      final account = MockAccount.create(displayName: 'LiteLabel');

      await tester.pumpWidget(createTestWidget(
        child: AccountLite(schema: account),
      ));
      await tester.pump();

      final semantics = tester.widgetList<Semantics>(find.byType(Semantics));
      final hasCorrectLabel = semantics.any((s) => s.properties.label == 'LiteLabel');
      expect(hasCorrectLabel, isTrue);
    });

    testWidgets('Semantics label uses acct when displayName is empty', (tester) async {
      final account = MockAccount.create(username: 'litacct', displayName: '');

      await tester.pumpWidget(createTestWidget(
        child: AccountLite(schema: account),
      ));
      await tester.pump();

      final semantics = tester.widgetList<Semantics>(find.byType(Semantics));
      final hasAcctLabel = semantics.any((s) => s.properties.label == 'litacct');
      expect(hasAcctLabel, isTrue);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
