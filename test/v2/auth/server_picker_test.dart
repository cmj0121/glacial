// Widget tests for V2ServerPicker.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/v2/auth/server_picker.dart';
import 'package:glacial/v2/theme.dart';

import '../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  Future<void> pumpServerPicker(WidgetTester tester) async {
    await tester.pumpWidget(createTestWidgetRaw(
      child: V2ServerPicker(initialServers: V2Theme.curatedServers),
    ));
    await tester.pumpAndSettle();
  }

  group('V2ServerPicker', () {
    testWidgets('renders search field', (tester) async {
      await pumpServerPicker(tester);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('shows Popular Servers header', (tester) async {
      await pumpServerPicker(tester);
      expect(find.text('Popular Servers'), findsOneWidget);
    });

    testWidgets('shows curated server domains', (tester) async {
      await pumpServerPicker(tester);
      for (final server in V2Theme.curatedServers) {
        expect(find.text(server.domain), findsOneWidget);
      }
    });

    testWidgets('shows server descriptions', (tester) async {
      await pumpServerPicker(tester);
      for (final server in V2Theme.curatedServers) {
        expect(find.text(server.description), findsOneWidget);
      }
    });

    testWidgets('shows user counts as badges', (tester) async {
      await pumpServerPicker(tester);
      for (final server in V2Theme.curatedServers) {
        expect(find.text('${server.users} users'), findsOneWidget);
      }
    });

    testWidgets('shows back button in app bar', (tester) async {
      await pumpServerPicker(tester);
      expect(find.byType(AppBar), findsOneWidget);
    });
  });

  group('V2ServerPicker search', () {
    testWidgets('typing keyword filters servers', (tester) async {
      await pumpServerPicker(tester);

      await tester.enterText(find.byType(TextField), 'japan');
      await tester.pumpAndSettle();

      expect(find.text('mstdn.jp'), findsOneWidget);
      expect(find.text('mastodon.social'), findsNothing);
    });

    testWidgets('typing domain filters by domain', (tester) async {
      await pumpServerPicker(tester);

      await tester.enterText(find.byType(TextField), 'fosstodon');
      await tester.pumpAndSettle();

      expect(find.text('fosstodon.org'), findsOneWidget);
      expect(find.text('mastodon.social'), findsNothing);
    });

    testWidgets('no match shows empty state', (tester) async {
      await pumpServerPicker(tester);

      await tester.enterText(find.byType(TextField), 'xyznotexist');
      await tester.pumpAndSettle();

      expect(find.text('No matching servers'), findsOneWidget);
    });

    testWidgets('no match with domain shows try button', (tester) async {
      await pumpServerPicker(tester);

      await tester.enterText(find.byType(TextField), 'custom.server');
      await tester.pumpAndSettle();

      expect(find.text('No matching servers'), findsOneWidget);
      expect(find.byIcon(Icons.travel_explore), findsOneWidget);
    });

    testWidgets('clear button resets search', (tester) async {
      await pumpServerPicker(tester);

      await tester.enterText(find.byType(TextField), 'fosstodon');
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      for (final server in V2Theme.curatedServers) {
        expect(find.text(server.domain), findsOneWidget);
      }
    });

    testWidgets('case-insensitive search', (tester) async {
      await pumpServerPicker(tester);

      await tester.enterText(find.byType(TextField), 'OPEN SOURCE');
      await tester.pumpAndSettle();

      expect(find.text('fosstodon.org'), findsOneWidget);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
