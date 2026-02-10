// Widget tests for AccountProfile and ProfilePage.
import 'dart:io';

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

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async => Directory.systemTemp.path,
    );
  });

  group('AccountProfile', () {
    testWidgets('returns SizedBox.shrink when no server', (tester) async {
      final account = MockAccount.create();

      await tester.pumpWidget(createTestWidget(
        accessStatus: MockAccessStatus.anonymous(),
        child: AccountProfile(schema: account),
      ));
      await tester.pump();

      expect(find.byType(SwipeTabView), findsNothing);
    });

    testWidgets('renders SwipeTabView when server exists', (tester) async {
      final account = MockAccount.create();
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          accessStatus: status,
          child: Scaffold(body: AccountProfile(schema: account)),
        ));
        await tester.pump();
      });

      expect(find.byType(SwipeTabView), findsOneWidget);
    });

    testWidgets('has Padding with left and bottom spacing', (tester) async {
      final account = MockAccount.create();
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          accessStatus: status,
          child: Scaffold(body: AccountProfile(schema: account)),
        ));
        await tester.pump();
      });

      final padding = tester.widgetList<Padding>(find.byType(Padding)).where((p) {
        return p.padding == const EdgeInsets.only(left: 16, bottom: 16);
      });

      expect(padding.isNotEmpty, isTrue);
    });

    test('widget accepts required schema parameter', () {
      final account = MockAccount.create(id: 'test-123');
      final widget = AccountProfile(schema: account);
      expect(widget.schema.id, 'test-123');
    });
  });

  group('ProfilePage', () {
    testWidgets('renders with authenticated status', (tester) async {
      final account = MockAccount.create();
      final status = MockAccessStatus.create(
        accessToken: 'token',
        account: MockAccount.create(id: 'other'),
        server: MockServer.create(),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          accessStatus: status,
          child: ProfilePage(schema: account),
        ));
        await tester.pump();
      });

      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    testWidgets('shows banner section with correct height', (tester) async {
      final account = MockAccount.create();
      final status = MockAccessStatus.create(
        accessToken: 'token',
        account: MockAccount.create(id: 'other'),
        server: MockServer.create(),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          accessStatus: status,
          child: ProfilePage(schema: account),
        ));
        await tester.pump();
      });

      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox)).where((s) {
        return s.height == 200;
      });
      expect(sizedBoxes.isNotEmpty, isTrue);
    });

    testWidgets('shows acct text with domain', (tester) async {
      final account = MockAccount.create(username: 'alice');
      final status = MockAccessStatus.create(
        accessToken: 'token',
        account: MockAccount.create(id: 'other'),
        server: MockServer.create(domain: 'mastodon.social'),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          accessStatus: status,
          child: ProfilePage(schema: account),
        ));
        await tester.pump();
      });

      expect(find.text('alice@mastodon.social'), findsOneWidget);
    });

    testWidgets('shows Relationship widget for non-self profile', (tester) async {
      final account = MockAccount.create(id: 'other-user');
      final selfAccount = MockAccount.create(id: 'self-user');
      final status = MockAccessStatus.create(
        accessToken: 'token',
        account: selfAccount,
        server: MockServer.create(),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          accessStatus: status,
          child: ProfilePage(schema: account),
        ));
        await tester.pump();
      });

      expect(find.byType(Relationship), findsOneWidget);
    });

    testWidgets('shows UserStatistics', (tester) async {
      final account = MockAccount.create(
        statusesCount: 42,
        followersCount: 100,
        followingCount: 50,
      );
      final status = MockAccessStatus.create(
        accessToken: 'token',
        account: MockAccount.create(id: 'other'),
        server: MockServer.create(),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          accessStatus: status,
          child: ProfilePage(schema: account),
        ));
        await tester.pump();
      });

      expect(find.byType(UserStatistics), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
      expect(find.text('50'), findsOneWidget);
    });

    testWidgets('shows Divider', (tester) async {
      final account = MockAccount.create();
      final status = MockAccessStatus.create(
        accessToken: 'token',
        account: MockAccount.create(id: 'other'),
        server: MockServer.create(),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          accessStatus: status,
          child: ProfilePage(schema: account),
        ));
        await tester.pump();
      });

      expect(find.byType(Divider), findsOneWidget);
    });

    testWidgets('shows bot icon when account is bot', (tester) async {
      final account = MockAccount.create(bot: true);
      final status = MockAccessStatus.create(
        accessToken: 'token',
        account: MockAccount.create(id: 'other'),
        server: MockServer.create(),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          accessStatus: status,
          child: ProfilePage(schema: account),
        ));
        await tester.pump();
      });

      expect(find.byIcon(Icons.smart_toy_outlined), findsOneWidget);
    });

    testWidgets('hides bot icon when not a bot', (tester) async {
      final account = MockAccount.create(bot: false);
      final status = MockAccessStatus.create(
        accessToken: 'token',
        account: MockAccount.create(id: 'other'),
        server: MockServer.create(),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          accessStatus: status,
          child: ProfilePage(schema: account),
        ));
        await tester.pump();
      });

      expect(find.byIcon(Icons.smart_toy_outlined), findsNothing);
    });

    testWidgets('accepts custom banner height', (tester) async {
      final account = MockAccount.create();
      final status = MockAccessStatus.create(
        accessToken: 'token',
        account: MockAccount.create(id: 'other'),
        server: MockServer.create(),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          accessStatus: status,
          child: ProfilePage(schema: account, bannerHeight: 150),
        ));
        await tester.pump();
      });

      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox)).where((s) {
        return s.height == 150;
      });
      expect(sizedBoxes.isNotEmpty, isTrue);
    });

    testWidgets('shows HtmlDone for account note', (tester) async {
      final account = MockAccount.create(note: '<p>Bio text here</p>');
      final status = MockAccessStatus.create(
        accessToken: 'token',
        account: MockAccount.create(id: 'other'),
        server: MockServer.create(),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          accessStatus: status,
          child: ProfilePage(schema: account),
        ));
        await tester.pump();
      });

      expect(find.byType(HtmlDone), findsWidgets);
    });

    test('defaults to bannerHeight 200 and avatarSize 80', () {
      final account = MockAccount.create();
      final page = ProfilePage(schema: account);
      expect(page.bannerHeight, 200);
      expect(page.avatarSize, 80);
    });

    test('accepts callback parameters', () {
      bool statusesTapped = false;
      bool followersTapped = false;
      bool followingTapped = false;

      final page = ProfilePage(
        schema: MockAccount.create(),
        onStatusesTap: () => statusesTapped = true,
        onFollowersTap: () => followersTapped = true,
        onFollowingTap: () => followingTapped = true,
      );

      page.onStatusesTap!();
      page.onFollowersTap!();
      page.onFollowingTap!();

      expect(statusesTapped, isTrue);
      expect(followersTapped, isTrue);
      expect(followingTapped, isTrue);
    });
  });

  group('AccountProfileType', () {
    test('selfProfile returns correct values', () {
      expect(AccountProfileType.profile.selfProfile, isTrue);
      expect(AccountProfileType.post.selfProfile, isTrue);
      expect(AccountProfileType.pin.selfProfile, isTrue);
      expect(AccountProfileType.followers.selfProfile, isTrue);
      expect(AccountProfileType.following.selfProfile, isTrue);
      expect(AccountProfileType.schedule.selfProfile, isFalse);
      expect(AccountProfileType.hashtag.selfProfile, isFalse);
      expect(AccountProfileType.filter.selfProfile, isFalse);
      expect(AccountProfileType.mute.selfProfile, isFalse);
      expect(AccountProfileType.block.selfProfile, isFalse);
      expect(AccountProfileType.domainBlock.selfProfile, isFalse);
    });

    test('each type has distinct active and inactive icons', () {
      for (final type in AccountProfileType.values) {
        final activeIcon = type.icon(active: true);
        final inactiveIcon = type.icon(active: false);
        expect(activeIcon != inactiveIcon, isTrue, reason: '${type.name} icons should differ');
      }
    });

    test('timelineType is valid for supported types', () {
      expect(AccountProfileType.post.timelineType, TimelineType.user);
      expect(AccountProfileType.pin.timelineType, TimelineType.pin);
      expect(AccountProfileType.schedule.timelineType, TimelineType.schedule);
      expect(AccountProfileType.hashtag.timelineType, TimelineType.hashtag);
    });

    test('timelineType throws for unsupported types', () {
      expect(() => AccountProfileType.profile.timelineType, throwsArgumentError);
      expect(() => AccountProfileType.followers.timelineType, throwsArgumentError);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
