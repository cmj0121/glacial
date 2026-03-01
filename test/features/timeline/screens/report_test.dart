// Widget tests for ReportStep, ReportCategoryType, and ReportDialog components.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  group('ReportStep', () {
    test('has 3 values', () {
      expect(ReportStep.values.length, 3);
    });

    test('values are status, rules, comment', () {
      expect(ReportStep.values, contains(ReportStep.status));
      expect(ReportStep.values, contains(ReportStep.rules));
      expect(ReportStep.values, contains(ReportStep.comment));
    });
  });

  group('ReportCategoryType', () {
    test('has 4 values', () {
      expect(ReportCategoryType.values.length, 4);
    });

    test('values are spam, legal, violation, other', () {
      expect(ReportCategoryType.values, contains(ReportCategoryType.spam));
      expect(ReportCategoryType.values, contains(ReportCategoryType.legal));
      expect(ReportCategoryType.values, contains(ReportCategoryType.violation));
      expect(ReportCategoryType.values, contains(ReportCategoryType.other));
    });

    test('each type has an icon', () {
      expect(ReportCategoryType.spam.icon, Icons.campaign);
      expect(ReportCategoryType.legal.icon, Icons.gavel);
      expect(ReportCategoryType.violation.icon, Icons.rule);
      expect(ReportCategoryType.other.icon, Icons.report_sharp);
    });

    testWidgets('each type has label()', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(createTestWidget(
        child: Builder(builder: (context) {
          capturedContext = context;
          return const SizedBox.shrink();
        }),
      ));
      await tester.pump();

      for (final type in ReportCategoryType.values) {
        expect(type.label(capturedContext), isNotEmpty);
      }
    });

    testWidgets('each type has tooltip()', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(createTestWidget(
        child: Builder(builder: (context) {
          capturedContext = context;
          return const SizedBox.shrink();
        }),
      ));
      await tester.pump();

      for (final type in ReportCategoryType.values) {
        expect(type.tooltip(capturedContext), isNotEmpty);
      }
    });
  });

  group('ReportDialog', () {
    testWidgets('renders with authenticated user', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );
      final account = MockAccount.create();
      final mockStatus = MockStatus.create();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: Builder(builder: (context) {
              return ReportDialog(
                account: account,
                status: mockStatus,
              );
            }),
          ),
          accessStatus: status,
        ));
        await tester.pump();
      });

      expect(find.byType(ReportDialog), findsOneWidget);
    });

    testWidgets('returns empty when not signed in', (tester) async {
      final account = MockAccount.create();
      final mockStatus = MockStatus.create();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: ReportDialog(
              account: account,
              status: mockStatus,
            ),
          ),
          accessStatus: MockAccessStatus.anonymous(),
        ));
        await tester.pump();
      });

      // When status is null (anonymous), returns SizedBox.shrink
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('shows category selection initially', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );
      final account = MockAccount.create();
      final mockStatus = MockStatus.create();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: ReportDialog(
              account: account,
              status: mockStatus,
            ),
          ),
          accessStatus: status,
        ));
        await tester.pump();
      });

      // Category selection shows ListTile for each category type
      expect(find.byType(ListTile), findsWidgets);
      // Category icons should be visible
      expect(find.byIcon(Icons.campaign), findsOneWidget);
      expect(find.byIcon(Icons.gavel), findsOneWidget);
      expect(find.byIcon(Icons.report_sharp), findsOneWidget);
    });

    testWidgets('hides violation category when server has no rules', (tester) async {
      // Server without rules — violation category should be hidden
      final server = MockServer.create();
      final status = MockAccessStatus.authenticated(server: server);
      final account = MockAccount.create();
      final mockStatus = MockStatus.create();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: ReportDialog(
              account: account,
              status: mockStatus,
            ),
          ),
          accessStatus: status,
        ));
        await tester.pump();
      });

      // Server has no rules, so violation category icon should not appear
      expect(find.byIcon(Icons.rule), findsNothing);
      // Other categories should still be present
      expect(find.byIcon(Icons.campaign), findsOneWidget);
      expect(find.byIcon(Icons.gavel), findsOneWidget);
      expect(find.byIcon(Icons.report_sharp), findsOneWidget);
    });

    testWidgets('shows violation category when server has rules', (tester) async {
      // Create a server with rules
      final server = ServerSchema(
        domain: 'example.com',
        title: 'Test Server',
        desc: 'A test server',
        version: '4.2.0',
        thumbnail: 'https://example.com/thumb.png',
        usage: const ServerUsageSchema(userActiveMonthly: 1000),
        config: MockServerConfig.create(),
        registration: const RegisterConfigSchema(
          enabled: true,
          approvalRequired: false,
        ),
        contact: const ContactSchema(email: 'admin@example.com'),
        rules: const [
          RuleSchema(id: 'r1', text: 'Be respectful', hint: 'Treat others well'),
        ],
      );
      final status = MockAccessStatus.authenticated(server: server);
      final account = MockAccount.create();
      final mockStatus = MockStatus.create();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: ReportDialog(
              account: account,
              status: mockStatus,
            ),
          ),
          accessStatus: status,
        ));
        await tester.pump();
      });

      // Server has rules, so violation category should appear
      expect(find.byIcon(Icons.rule), findsOneWidget);
      // All 4 categories should be visible
      expect(find.byType(ListTile), findsNWidgets(4));
    });

    testWidgets('tapping a category transitions to report form', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );
      final account = MockAccount.create();
      final mockStatus = MockStatus.create();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: ReportDialog(
              account: account,
              status: mockStatus,
            ),
          ),
          accessStatus: status,
        ));
        await tester.pump();
      });

      // Tap the spam category
      await tester.tap(find.byIcon(Icons.campaign));
      await tester.pump(const Duration(milliseconds: 400));

      // After selecting a category, the report form should appear with category label
      // The PageView should be present (part of buildReportForm)
      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('report form shows page indicator dots', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );
      final account = MockAccount.create();
      final mockStatus = MockStatus.create();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: ReportDialog(
              account: account,
              status: mockStatus,
            ),
          ),
          accessStatus: status,
        ));
        await tester.pump();
      });

      // Select a category to show the form
      await tester.tap(find.byIcon(Icons.campaign));
      await tester.pump(const Duration(milliseconds: 400));

      // Page indicator should show AnimatedContainer dots
      expect(find.byType(AnimatedContainer), findsWidgets);
    });

    testWidgets('report form has category heading text', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );
      final account = MockAccount.create();
      final mockStatus = MockStatus.create();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: ReportDialog(
              account: account,
              status: mockStatus,
            ),
          ),
          accessStatus: status,
        ));
        await tester.pump();
      });

      // Select the "other" category
      await tester.tap(find.byIcon(Icons.report_sharp));
      await tester.pump(const Duration(milliseconds: 400));

      // The heading should show the category label and tooltip (description)
      expect(find.byType(Divider), findsOneWidget);
    });

    testWidgets('report form with rules shows rules page on swipe', (tester) async {
      final server = ServerSchema(
        domain: 'example.com',
        title: 'Test Server',
        desc: 'A test server',
        version: '4.2.0',
        thumbnail: 'https://example.com/thumb.png',
        usage: const ServerUsageSchema(userActiveMonthly: 1000),
        config: MockServerConfig.create(),
        registration: const RegisterConfigSchema(
          enabled: true,
          approvalRequired: false,
        ),
        contact: const ContactSchema(email: 'admin@example.com'),
        rules: const [
          RuleSchema(id: 'r1', text: 'Be respectful', hint: 'Treat others well'),
          RuleSchema(id: 'r2', text: 'No spam', hint: 'Avoid spamming'),
        ],
      );
      final status = MockAccessStatus.authenticated(server: server);
      final account = MockAccount.create();
      final mockStatus = MockStatus.create();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: ReportDialog(
              account: account,
              status: mockStatus,
            ),
          ),
          accessStatus: status,
        ));
        await tester.pump();
      });

      // Select the violation category
      await tester.tap(find.byIcon(Icons.rule));
      await tester.pump(const Duration(milliseconds: 400));

      // Form should render with PageView
      expect(find.byType(PageView), findsOneWidget);

      // Swipe to rules page (second page)
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pump(const Duration(milliseconds: 400));

      // Rules should be displayed
      expect(find.text('Be respectful'), findsOneWidget);
      expect(find.text('No spam'), findsOneWidget);
    });

    testWidgets('report form comment page shows text field and submit button', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );
      final account = MockAccount.create();
      final mockStatus = MockStatus.create();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: ReportDialog(
              account: account,
              status: mockStatus,
            ),
          ),
          accessStatus: status,
        ));
        await tester.pump();
      });

      // Select the spam category
      await tester.tap(find.byIcon(Icons.campaign));
      await tester.pump(const Duration(milliseconds: 400));

      // Navigate to comment page via page indicator tap or swipe
      // With no rules, steps are [status, comment] — swipe to second page
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 200));

      // Comment page should show TextField and submit button
      expect(find.byType(TextField), findsOneWidget);
      expect(find.bySubtype<ButtonStyleButton>(), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets('comment text field updates state on change', (tester) async {
      final status = MockAccessStatus.authenticated(
        server: MockServer.create(),
      );
      final account = MockAccount.create();
      final mockStatus = MockStatus.create();

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(
            body: ReportDialog(
              account: account,
              status: mockStatus,
            ),
          ),
          accessStatus: status,
        ));
        await tester.pump();
      });

      // Select category and navigate to comment page
      await tester.tap(find.byIcon(Icons.campaign));
      await tester.pump(const Duration(milliseconds: 400));

      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 200));

      // Enter text in the comment field
      await tester.enterText(find.byType(TextField), 'This is a test report');
      await tester.pump();

      // Verify text was entered
      expect(find.text('This is a test report'), findsOneWidget);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
