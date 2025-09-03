// The integration test for the app to switch Mastodon servers.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:glacial/app.dart';
import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

import 'misc.dart';

void main() {
  isTestMode = true;
  SharedPreferences.setMockInitialValues({});

  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('[E2E] show trends info', (WidgetTester tester) async {
    // The default system preference schema.
    final SystemPreferenceSchema schema = SystemPreferenceSchema();

    // Build the app and trigger a frame, then wait for the app to settle.
    await tester.pumpWidget(ProviderScope(child: CoreApp(schema: schema)));
    await tester.pumpAndSettle();

    await selectMastodonServer(tester, 'mastodon.social');
    await tester.pumpAndSettle(const Duration(seconds: 1));

    final Finder trendingBtn = find.byIcon(Icons.trending_up_outlined);
    expect(trendingBtn, findsOneWidget, reason: 'Trending button should be present');
    await tester.tap(trendingBtn);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    final Finder trendsTab = find.byType(Trends);
    expect(trendsTab, findsOneWidget, reason: 'Trends tab should be present');
    final Trends tab = tester.widget<Trends>(trendsTab);
    expect(tab.type, TrendsType.statuses, reason: 'Status trends should be selected');

    // switch to another trends type.
    final Finder tagsTab = find.byIcon(TrendsType.tags.icon(active: false));
    expect(tagsTab, findsOneWidget, reason: 'Tags trends tab should be present');
    await tester.tap(tagsTab);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Click the trending tags tab and verify the type.
    final Finder hashtagTab = find.byType(Hashtag).first;
    await tester.tap(hashtagTab);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    final Finder timeline = find.byType(Timeline);
    expect(timeline, findsOneWidget, reason: 'Timeline should be present in the trends tab');
    final Timeline timelineWidget = tester.widget<Timeline>(timeline);
    expect(timelineWidget.type, TimelineType.hashtag, reason: 'Timeline should be a hashtag timeline');


  });
}

// vim: set ts=2 sw=2 sts=2 et:
