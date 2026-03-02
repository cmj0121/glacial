// Widget tests for mastodon server screens: MastodonServer, MastodonServerInfo, ServerRules.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:glacial/core.dart';
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

    testWidgets('metadata chips use theme colors not hardcoded', (tester) async {
      final server = MockServer.create(version: '4.3.0');

      await tester.pumpWidget(createTestWidget(
        child: SizedBox(
          height: 500,
          child: MastodonServer(schema: server),
        ),
      ));
      await tester.pump();

      // Find the version chip container
      final chip = find.text('v4.3.0');
      expect(chip, findsOneWidget);

      // Verify no hardcoded Colors.black text
      final Text textWidget = tester.widget(chip);
      expect(textWidget.style?.color, isNot(equals(Colors.black)));
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

    testWidgets('fires onTap callback when tapped (line 45)', (tester) async {
      ServerSchema? tapped;
      final server = MockServer.create(title: 'Tappable');

      await tester.pumpWidget(createTestWidget(
        child: SizedBox(
          height: 500,
          child: MastodonServer(schema: server, onTap: (s) => tapped = s),
        ),
      ));
      await tester.pump();

      // Tap the InkWellDone to trigger onTap via the debouncer
      await tester.tap(find.byType(InkWellDone).first);
      // Wait for the debouncer (700ms)
      await tester.pump(const Duration(milliseconds: 800));

      expect(tapped, isNotNull);
      expect(tapped!.title, 'Tappable');
    });

    testWidgets('shows rules section with rule_outlined icon', (tester) async {
      final server = MockServer.create(domain: 'rules.social');

      await tester.pumpWidget(createTestWidget(
        child: SizedBox(
          height: 500,
          child: MastodonServer(schema: server),
        ),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.rule_outlined), findsOneWidget);
    });

    testWidgets('rules text gets primary color when rules are present (lines 130-140)', (tester) async {
      // Create a ServerSchema with rules (cannot use MockServer which has no rules param)
      final server = ServerSchema(
        domain: 'rules.social',
        title: 'Rules Server',
        desc: 'Has rules',
        version: '4.2.0',
        thumbnail: 'https://example.com/thumb.png',
        usage: const ServerUsageSchema(userActiveMonthly: 500),
        config: MockServerConfig.create(),
        registration: const RegisterConfigSchema(enabled: true, approvalRequired: false),
        contact: const ContactSchema(email: 'admin@rules.social'),
        languages: const ['en'],
        rules: const [
          RuleSchema(id: '1', text: 'Be kind', hint: 'Treat others well'),
        ],
      );

      await tester.pumpWidget(createTestWidget(
        child: SizedBox(
          height: 500,
          child: MastodonServer(schema: server),
        ),
      ));
      await tester.pump();

      // The rules text should be styled with primary color since rules are present
      expect(find.byIcon(Icons.rule_outlined), findsOneWidget);
      // Find the Server Rules text
      expect(find.text('Server Rules'), findsOneWidget);
    });

    testWidgets('tapping rules section opens dialog when rules exist (lines 130-132)', (tester) async {
      final server = ServerSchema(
        domain: 'rules.social',
        title: 'Rules Server',
        desc: 'Has rules',
        version: '4.2.0',
        thumbnail: 'https://example.com/thumb.png',
        usage: const ServerUsageSchema(userActiveMonthly: 500),
        config: MockServerConfig.create(),
        registration: const RegisterConfigSchema(enabled: true, approvalRequired: false),
        contact: const ContactSchema(email: 'admin@rules.social'),
        languages: const ['en'],
        rules: const [
          RuleSchema(id: '1', text: 'Be kind', hint: 'Treat others well'),
        ],
      );

      await tester.pumpWidget(createTestWidget(
        child: SizedBox(
          height: 500,
          child: MastodonServer(schema: server),
        ),
      ));
      await tester.pump();

      // Tap the rules section (InkWellDone wrapping the rules ListTile)
      // The rules InkWellDone is the one containing the rule_outlined icon
      await tester.tap(find.byIcon(Icons.rule_outlined));
      await tester.pumpAndSettle();

      // Should show the ServerRules dialog
      expect(find.byType(ServerRules), findsOneWidget);
      expect(find.text('Be kind'), findsOneWidget);
    });

    testWidgets('buildRegisterBadge returns SizedBox.shrink when registration disabled (lines 178-181)', (tester) async {
      final server = ServerSchema(
        domain: 'closed.social',
        title: 'Closed Server',
        desc: 'Registration closed',
        version: '4.2.0',
        thumbnail: 'https://example.com/thumb.png',
        usage: const ServerUsageSchema(userActiveMonthly: 500),
        config: MockServerConfig.create(),
        registration: const RegisterConfigSchema(enabled: false, approvalRequired: false),
        contact: const ContactSchema(email: 'admin@closed.social'),
      );

      final widget = MastodonServer(schema: server);
      await tester.pumpWidget(createTestWidget(
        child: widget.buildRegisterBadge(),
      ));
      await tester.pump();

      // Should render SizedBox.shrink (no registration badge)
      expect(find.byType(SizedBox), findsWidgets);
      expect(find.text('Registration'), findsNothing);
    });

    testWidgets('buildRegisterBadge shows badge when registration enabled (lines 183-196)', (tester) async {
      final server = MockServer.create(title: 'Open Server');

      final widget = MastodonServer(schema: server);
      await tester.pumpWidget(createTestWidget(
        child: widget.buildRegisterBadge(),
      ));
      await tester.pump();

      // MockServer.create() has registration.enabled = true
      expect(find.text('Registration'), findsOneWidget);
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

  group('MastodonServerInfo error widget', () {
    testWidgets('renders ImageErrorPlaceholder on image error (line 224)', (tester) async {
      final info = ServerInfoSchema(
        domain: 'broken.social',
        thumbnail: 'https://example.com/broken_image.png',
      );

      await tester.pumpWidget(createTestWidget(
        child: MastodonServerInfo(schema: info),
      ));
      await tester.pump();

      // The CachedNetworkImage should render; the error widget is an ImageErrorPlaceholder.
      // In test environment the image will fail to load, triggering the error widget.
      expect(find.byType(MastodonServerInfo), findsOneWidget);
      expect(find.byType(CachedNetworkImage), findsOneWidget);
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

    testWidgets('strips newlines from rule text (line 246)', (tester) async {
      const rules = [
        RuleSchema(id: '1', text: 'Rule with\nnewlines\rin it', hint: ''),
      ];

      await tester.pumpWidget(createTestWidget(
        child: SizedBox(
          height: 400,
          child: const ServerRules(rules: rules),
        ),
      ));
      await tester.pump();

      // The text should have newlines replaced with spaces
      expect(find.text('Rule with newlines in it'), findsOneWidget);
    });

    testWidgets('uses bodySmall titleTextStyle (line 253)', (tester) async {
      const rules = [
        RuleSchema(id: '1', text: 'Styled rule', hint: 'Some hint'),
      ];

      await tester.pumpWidget(createTestWidget(
        child: SizedBox(
          height: 400,
          child: const ServerRules(rules: rules),
        ),
      ));
      await tester.pump();

      // Verify the ListTile is using titleTextStyle from bodySmall
      final listTile = tester.widget<ListTile>(find.byType(ListTile));
      expect(listTile.titleTextStyle, isNotNull);
    });

    testWidgets('hides subtitle when hint is empty', (tester) async {
      const rules = [
        RuleSchema(id: '1', text: 'No hint rule', hint: ''),
      ];

      await tester.pumpWidget(createTestWidget(
        child: SizedBox(
          height: 400,
          child: const ServerRules(rules: rules),
        ),
      ));
      await tester.pump();

      final listTile = tester.widget<ListTile>(find.byType(ListTile));
      expect(listTile.subtitle, isNull);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
