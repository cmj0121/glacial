// The E2E test for all the possible timeline tab.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/app.dart';
import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

import 'misc.dart';

void main() {
  testWidgets('[E2E] test all timeline tabs', (WidgetTester tester) async {
    await prologue(domain: 'mastodon.social');

    // The default system preference schema.
    final SystemPreferenceSchema schema = SystemPreferenceSchema();

    // Build the app and trigger a frame, then wait for the app to settle.
    await tester.pumpWidget(ProviderScope(child: CoreApp(schema: schema)));
    await tester.pumpAndSettle();

    final Timeline timeline = tester.widget<Timeline>(find.byType(Timeline));
    final Finder tab = find.byType(SwipeTabBar);
    expect(timeline.type, TimelineType.home, reason: 'Local timeline should be selected');

    for (final TimelineType type in TimelineType.values.where((e) => e != TimelineType.home && e.inTimelineTab)) {
      final Finder tabBtn = find.descendant(of: tab, matching: find.byIcon(type.icon(active: false)));
      expect(tabBtn, findsOneWidget, reason: '${type.name} tab button should be present');

      await tester.tap(tabBtn);
      await tester.pumpAndSettle(const Duration(seconds: 1));
    }

    final Finder exploreBtn = find.byIcon(TimelineType.public.icon(active: false));
    await tester.tap(exploreBtn);
    // Test scroll the explore tab.
    await tester.pumpAndSettle(const Duration(seconds: 1));
    for (int i = 0; i < 3; i++) {
      await tester.fling(find.byType(Timeline), const Offset(0, -600), 1000);
      await tester.pumpAndSettle(const Duration(seconds: 1));
    }
  });
}


// vim: set ts=2 sw=2 sts=2 et:
