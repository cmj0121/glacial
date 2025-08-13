// The integrations misc library for Glacial app testing.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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

// vim: set ts=2 sw=2 sts=2 et:
