// The integration test for the app to switch Mastodon servers.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:integration_test/integration_test.dart';

import 'package:glacial/app.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

import 'misc.dart';

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
