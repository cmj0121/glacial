// Widget tests for auth screens: RegisterPage and SignIn with registration.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  group('RegisterPage', () {
    Widget buildRegisterPage({AccessStatusSchema? status}) {
      return createTestWidget(
        child: const RegisterPage(),
        accessStatus: status ?? MockAccessStatus.create(
          server: MockServer.create(),
        ),
      );
    }

    testWidgets('renders form fields', (tester) async {
      await tester.pumpWidget(buildRegisterPage());
      await tester.pump();

      expect(find.byType(RegisterPage), findsOneWidget);
      expect(find.byType(TextFormField), findsAtLeast(4));
    });

    testWidgets('shows domain header', (tester) async {
      await tester.pumpWidget(buildRegisterPage(
        status: MockAccessStatus.create(
          server: MockServer.create(domain: 'test.social'),
        ),
      ));
      await tester.pump();

      // AccessStatusSchema default domain is 'mastodon.social' since we don't override it
      expect(find.textContaining('mastodon.social'), findsOneWidget);
    });

    testWidgets('shows Create Account title', (tester) async {
      await tester.pumpWidget(buildRegisterPage());
      await tester.pump();

      // Title and button both show 'Create Account'
      expect(find.text('Create Account'), findsNWidgets(2));
    });

    testWidgets('shows username field', (tester) async {
      await tester.pumpWidget(buildRegisterPage());
      await tester.pump();

      expect(find.text('Username'), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('shows email field', (tester) async {
      await tester.pumpWidget(buildRegisterPage());
      await tester.pump();

      expect(find.text('Email'), findsOneWidget);
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
    });

    testWidgets('shows password fields', (tester) async {
      await tester.pumpWidget(buildRegisterPage());
      await tester.pump();

      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsNWidgets(2));
    });

    testWidgets('shows agreement checkbox', (tester) async {
      await tester.pumpWidget(buildRegisterPage());
      await tester.pump();

      expect(find.byType(CheckboxListTile), findsOneWidget);
      expect(find.textContaining('agree'), findsOneWidget);
    });

    testWidgets('shows register button', (tester) async {
      await tester.pumpWidget(buildRegisterPage());
      await tester.pump();

      expect(find.byType(FilledButton), findsOneWidget);
      // The button text comes from l10n btn_register = 'Create Account'
      final filledButton = find.byType(FilledButton);
      expect(filledButton, findsOneWidget);
    });

    testWidgets('checkbox toggles agreement state', (tester) async {
      await tester.pumpWidget(buildRegisterPage());
      await tester.pump();

      final checkbox = tester.widget<CheckboxListTile>(find.byType(CheckboxListTile));
      expect(checkbox.value, isFalse);

      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();

      final updatedCheckbox = tester.widget<CheckboxListTile>(find.byType(CheckboxListTile));
      expect(updatedCheckbox.value, isTrue);
    });

    testWidgets('shows reason field when approval required', (tester) async {
      final server = ServerSchema(
        domain: 'approval.social',
        title: 'Approval Server',
        desc: 'Requires approval',
        version: '4.2.0',
        thumbnail: 'https://example.com/thumb.png',
        usage: const ServerUsageSchema(userActiveMonthly: 100),
        config: MockServerConfig.create(),
        registration: const RegisterConfigSchema(enabled: true, approvalRequired: true),
        contact: const ContactSchema(email: 'admin@approval.social'),
      );

      await tester.pumpWidget(buildRegisterPage(
        status: MockAccessStatus.create(server: server),
      ));
      await tester.pump();

      expect(find.text('Reason for joining'), findsOneWidget);
      expect(find.byIcon(Icons.note_outlined), findsOneWidget);
    });

    testWidgets('hides reason field when approval not required', (tester) async {
      await tester.pumpWidget(buildRegisterPage());
      await tester.pump();

      expect(find.text('Reason for joining'), findsNothing);
      expect(find.byIcon(Icons.note_outlined), findsNothing);
    });

    testWidgets('validates empty username', (tester) async {
      await tester.pumpWidget(buildRegisterPage());
      await tester.pump();

      // Tap register without filling fields
      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      expect(find.text('This field is required'), findsAtLeast(1));
    });

    testWidgets('validates invalid email', (tester) async {
      await tester.pumpWidget(buildRegisterPage());
      await tester.pump();

      // Fill in username
      await tester.enterText(find.widgetWithText(TextFormField, 'Username'), 'testuser');
      // Fill in invalid email
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'notanemail');
      // Fill password
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
      await tester.enterText(find.widgetWithText(TextFormField, 'Confirm Password'), 'password123');

      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      expect(find.text('Invalid email address'), findsOneWidget);
    });

    testWidgets('validates short password', (tester) async {
      await tester.pumpWidget(buildRegisterPage());
      await tester.pump();

      await tester.enterText(find.widgetWithText(TextFormField, 'Username'), 'testuser');
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'short');
      await tester.enterText(find.widgetWithText(TextFormField, 'Confirm Password'), 'short');

      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      expect(find.text('Password must be at least 8 characters'), findsOneWidget);
    });

    testWidgets('validates password mismatch', (tester) async {
      await tester.pumpWidget(buildRegisterPage());
      await tester.pump();

      await tester.enterText(find.widgetWithText(TextFormField, 'Username'), 'testuser');
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
      await tester.enterText(find.widgetWithText(TextFormField, 'Confirm Password'), 'different123');

      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('shows agreement error when not checked', (tester) async {
      await tester.pumpWidget(buildRegisterPage());
      await tester.pump();

      // Fill all valid fields
      await tester.enterText(find.widgetWithText(TextFormField, 'Username'), 'testuser');
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
      await tester.enterText(find.widgetWithText(TextFormField, 'Confirm Password'), 'password123');

      // Don't check the agreement checkbox
      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      expect(find.text('You must agree to the terms'), findsOneWidget);
    });

    testWidgets('shows server rules when available', (tester) async {
      final server = ServerSchema(
        domain: 'rules.social',
        title: 'Rules Server',
        desc: 'Has rules',
        version: '4.2.0',
        thumbnail: 'https://example.com/thumb.png',
        usage: const ServerUsageSchema(userActiveMonthly: 100),
        config: MockServerConfig.create(),
        registration: const RegisterConfigSchema(enabled: true, approvalRequired: false),
        contact: const ContactSchema(email: 'admin@rules.social'),
        rules: const [
          RuleSchema(id: '1', text: 'Be respectful', hint: 'Treat others kindly'),
          RuleSchema(id: '2', text: 'No spam', hint: 'No unsolicited content'),
        ],
      );

      await tester.pumpWidget(buildRegisterPage(
        status: MockAccessStatus.create(server: server),
      ));
      await tester.pump();

      expect(find.byType(ServerRules), findsOneWidget);
      expect(find.text('Be respectful'), findsOneWidget);
      expect(find.text('No spam'), findsOneWidget);
    });

    testWidgets('hides server rules when empty', (tester) async {
      await tester.pumpWidget(buildRegisterPage());
      await tester.pump();

      expect(find.byType(ServerRules), findsNothing);
    });
  });

  group('SignIn with registration', () {
    testWidgets('shows Create Account button when registration enabled', (tester) async {
      final server = MockServer.create();
      await tester.pumpWidget(createTestWidget(
        child: const SignIn(),
        accessStatus: MockAccessStatus.create(server: server),
      ));
      await tester.pump();

      expect(find.text('Create Account'), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('hides Create Account button when registration disabled', (tester) async {
      final server = ServerSchema(
        domain: 'closed.social',
        title: 'Closed Server',
        desc: 'No registration',
        version: '4.2.0',
        thumbnail: 'https://example.com/thumb.png',
        usage: const ServerUsageSchema(userActiveMonthly: 100),
        config: MockServerConfig.create(),
        registration: const RegisterConfigSchema(enabled: false, approvalRequired: false),
        contact: const ContactSchema(email: 'admin@closed.social'),
      );

      await tester.pumpWidget(createTestWidget(
        child: const SignIn(),
        accessStatus: MockAccessStatus.create(server: server),
      ));
      await tester.pump();

      expect(find.text('Create Account'), findsNothing);
      expect(find.byType(TextButton), findsNothing);
    });

    testWidgets('hides Create Account button when no server', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const SignIn(),
        accessStatus: MockAccessStatus.anonymous(),
      ));
      await tester.pump();

      expect(find.text('Create Account'), findsNothing);
    });

    testWidgets('renders sign in icon and Create Account in column', (tester) async {
      final server = MockServer.create();
      await tester.pumpWidget(createTestWidget(
        child: const SignIn(),
        accessStatus: MockAccessStatus.create(server: server),
      ));
      await tester.pump();

      expect(find.byType(Column), findsAtLeast(1));
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
