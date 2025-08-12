// The integration test for the app to switch Mastodon servers.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:integration_test/integration_test.dart';

import 'package:glacial/app.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

Future<void> selectMastodonServer(WidgetTester tester, String serverUrl) async {
  // Find the server explorer text field and enter a server URL.
  final Finder serverTextField = find.byType(TextField);
  expect(serverTextField, findsOneWidget, reason: 'Server text field should be present');
  await tester.enterText(serverTextField, serverUrl);
  await tester.pump();

  // Find and tap the search button to initiate the server search.
  final Finder searchButton = find.byIcon(Icons.search);
  expect(searchButton, findsOneWidget, reason: 'Search button should be present');
  await tester.tap(searchButton);
  await tester.pump(const Duration(seconds: 1));

  // Expect the server explorer to show the search result in the screen and tap on it.
  final Finder serverExplorer = find.byType(MastodonServer);
  expect(serverExplorer, findsOneWidget, reason: 'Server explorer should be present');
  await tester.tap(serverExplorer);
  await tester.pump(const Duration(milliseconds: 500));

  // Check the local timeline tab is selected and loaded.
  final Timeline timeline = tester.widget<Timeline>(find.byType(Timeline));
  expect(timeline.type, TimelineType.local, reason: 'Local timeline should be selected');
    await tester.pump();
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('[E2E] switch between Mastodon servers', (WidgetTester tester) async {
    // The default system preference schema.
    final SystemPreferenceSchema schema = SystemPreferenceSchema();

    // Build the app and trigger a frame, then wait for the app to settle.
    await tester.pumpWidget(ProviderScope(child: CoreApp(schema: schema)));
    await tester.pumpAndSettle();

    await selectMastodonServer(tester, 'mastodon.social');
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Open the drawer to switch servers.
    final Finder drawerButton = find.byIcon(Icons.read_more_rounded);
    await tester.tap(drawerButton);
    await tester.pump(const Duration(milliseconds: 500));

    final Finder drawer = find.byType(GlacialDrawer);
    expect(drawer, findsOneWidget, reason: 'Glacial drawer should be present');
    await tester.pump();

    // Find the switch server button and tap it.
    final Finder icon = find.byIcon(Icons.swap_horiz);
    expect(icon, findsOneWidget, reason: 'Switch server icon should be present');
    await tester.tap(icon);
    await tester.pump(const Duration(seconds: 1));

    await selectMastodonServer(tester, 'g0v.social');
    await tester.pumpAndSettle();
  });
}

// vim: set ts=2 sw=2 sts=2 et:
