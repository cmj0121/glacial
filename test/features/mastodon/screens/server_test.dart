// Widget tests for mastodon server screens: MastodonServer, MastodonServerInfo, ServerRules.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  group('MastodonServer', () {
    testWidgets('renders with schema', (tester) async {
      final server = MockServer.create();

      await tester.pumpWidget(createTestWidget(
        child: SizedBox(
          height: 500,
          child: MastodonServer(schema: server),
        ),
      ));
      await tester.pump();

      expect(find.byType(MastodonServer), findsOneWidget);
    });

    testWidgets('displays server title', (tester) async {
      final server = MockServer.create(title: 'My Mastodon');

      await tester.pumpWidget(createTestWidget(
        child: SizedBox(
          height: 500,
          child: MastodonServer(schema: server),
        ),
      ));
      await tester.pump();

      expect(find.text('My Mastodon'), findsOneWidget);
    });

    testWidgets('displays server description', (tester) async {
      final server = MockServer.create(desc: 'A great server');

      await tester.pumpWidget(createTestWidget(
        child: SizedBox(
          height: 500,
          child: MastodonServer(schema: server),
        ),
      ));
      await tester.pump();

      expect(find.text('A great server'), findsOneWidget);
    });

    testWidgets('shows version in metadata', (tester) async {
      final server = MockServer.create(version: '4.3.0');

      await tester.pumpWidget(createTestWidget(
        child: SizedBox(
          height: 500,
          child: MastodonServer(schema: server),
        ),
      ));
      await tester.pump();

      expect(find.text('v4.3.0'), findsOneWidget);
    });

    testWidgets('shows contact email', (tester) async {
      final server = MockServer.create(domain: 'test.social');

      await tester.pumpWidget(createTestWidget(
        child: SizedBox(
          height: 500,
          child: MastodonServer(schema: server),
        ),
      ));
      await tester.pump();

      expect(find.text('admin@test.social'), findsOneWidget);
    });

    testWidgets('shows language tags', (tester) async {
      final server = MockServer.create(languages: ['en', 'ja']);

      await tester.pumpWidget(createTestWidget(
        child: SizedBox(
          height: 500,
          child: MastodonServer(schema: server),
        ),
      ));
      await tester.pump();

      expect(find.text('en'), findsOneWidget);
      expect(find.text('ja'), findsOneWidget);
    });

    testWidgets('accepts onTap callback', (tester) async {
      ServerSchema? tapped;
      final server = MockServer.create();

      await tester.pumpWidget(createTestWidget(
        child: SizedBox(
          height: 500,
          child: MastodonServer(schema: server, onTap: (s) => tapped = s),
        ),
      ));
      await tester.pump();

      expect(tapped, isNull);
      expect(find.byType(MastodonServer), findsOneWidget);
    });

    testWidgets('renders in compact mode when height is small', (tester) async {
      final server = MockServer.create(title: 'Compact Server');

      await tester.pumpWidget(createTestWidget(
        child: SizedBox(
          height: 300,
          child: MastodonServer(schema: server),
        ),
      ));
      await tester.pump();

      expect(find.text('Compact Server'), findsOneWidget);
    });
  });

  group('MastodonServerInfo', () {
    testWidgets('renders with schema', (tester) async {
      final info = ServerInfoSchema(
        domain: 'example.com',
        thumbnail: 'https://example.com/thumb.png',
      );

      await tester.pumpWidget(createTestWidget(
        child: MastodonServerInfo(schema: info),
      ));
      await tester.pump();

      expect(find.byType(MastodonServerInfo), findsOneWidget);
    });

    testWidgets('displays domain name', (tester) async {
      final info = ServerInfoSchema(
        domain: 'mastodon.social',
        thumbnail: 'https://example.com/thumb.png',
      );

      await tester.pumpWidget(createTestWidget(
        child: MastodonServerInfo(schema: info),
      ));
      await tester.pump();

      expect(find.text('mastodon.social'), findsOneWidget);
    });

    testWidgets('accepts custom size parameter', (tester) async {
      final info = ServerInfoSchema(
        domain: 'example.com',
        thumbnail: 'https://example.com/thumb.png',
      );

      await tester.pumpWidget(createTestWidget(
        child: MastodonServerInfo(schema: info, size: 48),
      ));
      await tester.pump();

      expect(find.byType(MastodonServerInfo), findsOneWidget);
    });

    testWidgets('uses Row layout', (tester) async {
      final info = ServerInfoSchema(
        domain: 'example.com',
        thumbnail: 'https://example.com/thumb.png',
      );

      await tester.pumpWidget(createTestWidget(
        child: MastodonServerInfo(schema: info),
      ));
      await tester.pump();

      expect(find.byType(Row), findsWidgets);
    });
  });

  group('ServerRules', () {
    testWidgets('renders empty list', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: SizedBox(
          height: 400,
          child: const ServerRules(rules: []),
        ),
      ));
      await tester.pump();

      expect(find.byType(ServerRules), findsOneWidget);
    });

    testWidgets('renders rules as list tiles', (tester) async {
      const rules = [
        RuleSchema(id: '1', text: 'Be kind', hint: 'Treat others well'),
        RuleSchema(id: '2', text: 'No spam', hint: 'Do not spam'),
      ];

      await tester.pumpWidget(createTestWidget(
        child: SizedBox(
          height: 400,
          child: const ServerRules(rules: rules),
        ),
      ));
      await tester.pump();

      expect(find.text('Be kind'), findsOneWidget);
      expect(find.text('No spam'), findsOneWidget);
    });

    testWidgets('shows rule hints as subtitles', (tester) async {
      const rules = [
        RuleSchema(id: '1', text: 'Be respectful', hint: 'Dignity and respect'),
      ];

      await tester.pumpWidget(createTestWidget(
        child: SizedBox(
          height: 400,
          child: const ServerRules(rules: rules),
        ),
      ));
      await tester.pump();

      expect(find.text('Dignity and respect'), findsOneWidget);
    });

    testWidgets('shows check icon for each rule', (tester) async {
      const rules = [
        RuleSchema(id: '1', text: 'Rule 1', hint: ''),
        RuleSchema(id: '2', text: 'Rule 2', hint: ''),
      ];

      await tester.pumpWidget(createTestWidget(
        child: SizedBox(
          height: 400,
          child: const ServerRules(rules: rules),
        ),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.library_add_check), findsNWidgets(2));
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
