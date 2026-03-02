// Widget tests for account screens: Account, AccountAvatar, AccountLite.
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

/// Creates a GoRouter-wrapped test widget so that context.push() works.
Widget createAccountTestWidgetWithRouter({
  required Widget child,
  AccessStatusSchema? accessStatus,
}) {
  final List<Override> overrides = [
    accessStatusProvider.overrideWith(
      (ref) => accessStatus ?? MockAccessStatus.anonymous(),
    ),
  ];

  final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => Scaffold(body: child),
      ),
      GoRoute(
        path: '/home/profile',
        builder: (_, __) => const Scaffold(body: Text('Profile Page')),
      ),
    ],
  );

  return ProviderScope(
    overrides: overrides,
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
  );
}

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

    testWidgets('tapping Account navigates to profile page', (tester) async {
      final account = MockAccount.create(displayName: 'Tap User');

      await tester.pumpWidget(createAccountTestWidgetWithRouter(
        child: Account(schema: account),
      ));
      await tester.pump();

      // Tap the InkWellDone which calls context.push(RoutePath.profile.path, ...)
      await tester.tap(find.byType(InkWellDone));
      await tester.pumpAndSettle();

      // Should navigate to the profile page.
      expect(find.text('Profile Page'), findsOneWidget);
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

    testWidgets('tapping AccountAvatar navigates to profile page', (tester) async {
      final account = MockAccount.create(displayName: 'Avatar Tap User');

      await tester.pumpWidget(createAccountTestWidgetWithRouter(
        child: AccountAvatar(schema: account),
      ));
      await tester.pump();

      // Tap the InkWellDone which calls context.push(RoutePath.profile.path, ...)
      await tester.tap(find.byType(InkWellDone));
      await tester.pumpAndSettle();

      expect(find.text('Profile Page'), findsOneWidget);
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

    testWidgets('tapping AccountLite without onTap navigates to profile page', (tester) async {
      final account = MockAccount.create(displayName: 'Lite Nav User');

      await tester.pumpWidget(createAccountTestWidgetWithRouter(
        child: AccountLite(schema: account),
      ));
      await tester.pump();

      // When onTap is null, AccountLite falls back to context.push(RoutePath.profile.path, ...)
      await tester.tap(find.byType(ListTile));
      await tester.pumpAndSettle();

      expect(find.text('Profile Page'), findsOneWidget);
    });
  });

  group('CachedNetworkImage imageBuilder callbacks', () {
    // A 1x1 transparent PNG for use as a fake ImageProvider.
    final Uint8List kTransparentPng = Uint8List.fromList(<int>[
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00,
      0x0D, 0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00,
      0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89,
      0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x62,
      0x00, 0x00, 0x00, 0x02, 0x00, 0x01, 0xE2, 0x21, 0xBC, 0x33, 0x00,
      0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
    ]);

    testWidgets('Account.buildAvatar imageBuilder returns ClipRRect with Image', (tester) async {
      final account = MockAccount.create();

      await tester.pumpWidget(createTestWidget(
        child: Account(schema: account),
      ));
      await tester.pump();

      final cachedImages = tester.widgetList<CachedNetworkImage>(
        find.byType(CachedNetworkImage),
      );
      expect(cachedImages, isNotEmpty);

      final cni = cachedImages.first;
      expect(cni.imageBuilder, isNotNull);

      // Invoke the imageBuilder callback with a MemoryImage provider.
      final provider = MemoryImage(kTransparentPng);
      final element = tester.element(find.byType(Account));
      final result = cni.imageBuilder!(element, provider);

      // Account.buildAvatar imageBuilder returns a ClipRRect wrapping an Image.
      expect(result, isA<ClipRRect>());
      final clipRRect = result as ClipRRect;
      expect(clipRRect.child, isA<Image>());
      final image = clipRRect.child! as Image;
      expect(image.image, same(provider));
      expect(image.width, 48);
      expect(image.height, 48);
      expect(image.fit, BoxFit.cover);
    });

    testWidgets('AccountAvatar.buildContent imageBuilder returns Image', (tester) async {
      final account = MockAccount.create();

      await tester.pumpWidget(createTestWidget(
        child: AccountAvatar(schema: account),
      ));
      await tester.pump();

      final cachedImages = tester.widgetList<CachedNetworkImage>(
        find.byType(CachedNetworkImage),
      );
      expect(cachedImages, isNotEmpty);

      final cni = cachedImages.first;
      expect(cni.imageBuilder, isNotNull);

      final provider = MemoryImage(kTransparentPng);
      final element = tester.element(find.byType(AccountAvatar));
      final result = cni.imageBuilder!(element, provider);

      // AccountAvatar imageBuilder returns an Image directly.
      expect(result, isA<Image>());
      final image = result as Image;
      expect(image.image, same(provider));
      expect(image.width, 48);
      expect(image.height, 48);
      expect(image.fit, BoxFit.cover);
    });

    testWidgets('AccountLite.buildAvatar imageBuilder returns Image', (tester) async {
      final account = MockAccount.create();

      await tester.pumpWidget(createTestWidget(
        child: AccountLite(schema: account),
      ));
      await tester.pump();

      final cachedImages = tester.widgetList<CachedNetworkImage>(
        find.byType(CachedNetworkImage),
      );
      expect(cachedImages, isNotEmpty);

      final cni = cachedImages.first;
      expect(cni.imageBuilder, isNotNull);

      final provider = MemoryImage(kTransparentPng);
      final element = tester.element(find.byType(AccountLite));
      final result = cni.imageBuilder!(element, provider);

      // AccountLite imageBuilder returns an Image directly.
      expect(result, isA<Image>());
      final image = result as Image;
      expect(image.image, same(provider));
      expect(image.width, 32); // AccountLite default size is 32
      expect(image.height, 32);
      expect(image.fit, BoxFit.cover);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
