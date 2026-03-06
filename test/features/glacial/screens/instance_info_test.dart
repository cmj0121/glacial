// Widget tests for the InstanceInfoSheet.
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/features/glacial/screens/instance_info.dart';
import 'package:glacial/features/models.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  group('InstanceInfoSheet', () {
    testWidgets('shows server title and domain', (tester) async {
      final server = MockServer.create(title: 'My Server', domain: 'mastodon.social');
      final status = MockAccessStatus.authenticated(server: server);

      await tester.pumpWidget(createTestWidget(
        child: InstanceInfoSheet(status: status),
      ));
      await tester.pump();

      expect(find.text('My Server'), findsOneWidget);
      expect(find.text('mastodon.social'), findsOneWidget);
    });

    testWidgets('shows server description', (tester) async {
      final server = MockServer.create(desc: 'A friendly server for everyone.');
      final status = MockAccessStatus.authenticated(server: server);

      await tester.pumpWidget(createTestWidget(
        child: InstanceInfoSheet(status: status),
      ));
      await tester.pump();

      expect(find.text('A friendly server for everyone.'), findsOneWidget);
    });

    testWidgets('shows version info', (tester) async {
      final server = MockServer.create(version: '4.3.1');
      final status = MockAccessStatus.authenticated(server: server);

      await tester.pumpWidget(createTestWidget(
        child: InstanceInfoSheet(status: status),
      ));
      await tester.pump();

      expect(find.text('v4.3.1'), findsOneWidget);
    });

    testWidgets('shows active user count', (tester) async {
      final server = MockServer.create();
      final status = MockAccessStatus.authenticated(server: server);

      await tester.pumpWidget(createTestWidget(
        child: InstanceInfoSheet(status: status),
      ));
      await tester.pump();

      // MockServer creates usage with 1000 active monthly users
      expect(find.text('1000'), findsOneWidget);
    });

    testWidgets('shows contact email', (tester) async {
      final server = MockServer.create(domain: 'test.social');
      final status = MockAccessStatus.authenticated(server: server);

      await tester.pumpWidget(createTestWidget(
        child: InstanceInfoSheet(status: status),
      ));
      await tester.pump();

      expect(find.text('admin@test.social'), findsOneWidget);
    });

    testWidgets('shows languages', (tester) async {
      final server = MockServer.create(languages: ['en', 'ja', 'de']);
      final status = MockAccessStatus.authenticated(server: server);

      await tester.pumpWidget(createTestWidget(
        child: InstanceInfoSheet(status: status),
      ));
      await tester.pump();

      expect(find.text('en, ja, de'), findsOneWidget);
    });

    testWidgets('shows registration status open', (tester) async {
      final server = MockServer.create();
      final status = MockAccessStatus.authenticated(server: server);

      await tester.pumpWidget(createTestWidget(
        child: InstanceInfoSheet(status: status),
      ));
      await tester.pump();

      expect(find.text('Open'), findsOneWidget);
    });

    testWidgets('shows no result when server is null', (tester) async {
      final status = MockAccessStatus.anonymous();

      await tester.pumpWidget(createTestWidget(
        child: InstanceInfoSheet(status: status),
      ));
      await tester.pump();

      // Should show the NoResult widget
      expect(find.byType(InstanceInfoSheet), findsOneWidget);
    });

    testWidgets('shows rules tile when server has rules', (tester) async {
      final server = ServerSchema(
        domain: 'rules.social',
        title: 'Rules Server',
        desc: 'Server with rules',
        version: '4.2.0',
        thumbnail: 'https://example.com/thumb.png',
        usage: const ServerUsageSchema(userActiveMonthly: 500),
        config: MockServerConfig.create(),
        registration: const RegisterConfigSchema(enabled: true, approvalRequired: false),
        contact: const ContactSchema(email: 'admin@rules.social'),
        languages: const ['en'],
        rules: const [
          RuleSchema(id: '1', text: 'Be kind', hint: 'Treat others with respect'),
          RuleSchema(id: '2', text: 'No spam', hint: 'No unsolicited advertising'),
        ],
      );
      final status = MockAccessStatus.authenticated(server: server);

      await tester.pumpWidget(createTestWidget(
        child: InstanceInfoSheet(status: status),
      ));
      await tester.pump();

      // Should show the rules count
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('shows about this server title', (tester) async {
      final server = MockServer.create();
      final status = MockAccessStatus.authenticated(server: server);

      await tester.pumpWidget(createTestWidget(
        child: InstanceInfoSheet(status: status),
      ));
      await tester.pump();

      expect(find.text('About This Server'), findsOneWidget);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
