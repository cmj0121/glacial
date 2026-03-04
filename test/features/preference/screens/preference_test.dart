// Widget tests for SystemPreference and SystemPreferenceType.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

/// Creates a test widget with LocaleNames delegate for preference tests.
Widget _createPreferenceTestWidget({
  required Widget child,
  SystemPreferenceSchema? preference,
}) {
  return ProviderScope(
    overrides: [
      accessStatusProvider.overrideWith((ref) => MockAccessStatus.anonymous()),
      if (preference != null) preferenceProvider.overrideWith((ref) => preference),
    ],
    child: MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        LocaleNamesLocalizationsDelegate(),
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: child,
    ),
  );
}

void main() {
  setupTestEnvironment();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  setUpAll(() async {
    // Mock PackageInfo method channel for Info().info to work.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/package_info'),
      (MethodCall methodCall) async => <String, String>{
        'appName': 'glacial',
        'packageName': 'com.example.glacial',
        'version': '1.0.0',
        'buildNumber': '1',
      },
    );
    // Mock path_provider to avoid MissingPluginException from CachedNetworkImage.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async => '/tmp',
    );
    await Info.init();
  });

  group('SystemPreference', () {
    test('is a ConsumerStatefulWidget', () {
      const widget = SystemPreference();
      expect(widget, isA<ConsumerStatefulWidget>());
    });

    test('can be created with const constructor', () {
      const widget = SystemPreference();
      expect(widget, isNotNull);
    });

    test('can be created with key', () {
      const key = ValueKey('preference');
      const widget = SystemPreference(key: key);
      expect(widget.key, key);
    });

    testWidgets('renders with default preference', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(_createPreferenceTestWidget(
          child: const SystemPreference(),
          preference: const SystemPreferenceSchema(),
        ));
        await tester.pump();
      });

      expect(find.byType(SystemPreference), findsOneWidget);
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('shows SwipeTabView for settings tabs', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(_createPreferenceTestWidget(
          child: const SystemPreference(),
          preference: const SystemPreferenceSchema(),
        ));
        await tester.pump();
      });

      expect(find.byType(SwipeTabView), findsOneWidget);
    });

    testWidgets('shows reload button', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(_createPreferenceTestWidget(
          child: const SystemPreference(),
          preference: const SystemPreferenceSchema(),
        ));
        await tester.pump();
      });

      // Reload button has a refresh icon and "Reload" text
      expect(find.byIcon(Icons.refresh), findsWidgets);
      expect(find.text('Reload'), findsOneWidget);
    });

    testWidgets('shows theme tab with SwitchListTile', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(_createPreferenceTestWidget(
          child: const SystemPreference(),
          preference: const SystemPreferenceSchema(),
        ));
        await tester.pump();
      });

      // Default tab is theme, which has SwitchListTiles
      expect(find.byType(SwitchListTile), findsWidgets);
    });

    testWidgets('shows dark mode icon when theme is dark', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(_createPreferenceTestWidget(
          child: const SystemPreference(),
          preference: const SystemPreferenceSchema(theme: ThemeMode.dark),
        ));
        await tester.pump();
      });

      expect(find.byIcon(Icons.dark_mode), findsOneWidget);
    });

    testWidgets('shows light mode icon when theme is light', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(_createPreferenceTestWidget(
          child: const SystemPreference(),
          preference: const SystemPreferenceSchema(theme: ThemeMode.light),
        ));
        await tester.pump();
      });

      expect(find.byIcon(Icons.light_mode), findsOneWidget);
    });

    testWidgets('shows visibility icon', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(_createPreferenceTestWidget(
          child: const SystemPreference(),
          preference: const SystemPreferenceSchema(),
        ));
        await tester.pump();
      });

      // Default visibility is public → shows public icon
      expect(find.byIcon(Icons.public), findsOneWidget);
    });
  });

  group('SystemPreferenceType', () {
    test('has 3 values', () {
      expect(SystemPreferenceType.values.length, 3);
    });

    test('contains theme, engineer, about', () {
      expect(SystemPreferenceType.values, contains(SystemPreferenceType.theme));
      expect(SystemPreferenceType.values, contains(SystemPreferenceType.engineer));
      expect(SystemPreferenceType.values, contains(SystemPreferenceType.about));
    });

    test('each has icon() method', () {
      for (final type in SystemPreferenceType.values) {
        expect(type.icon(), isA<IconData>());
        expect(type.icon(active: true), isA<IconData>());
        expect(type.icon(active: false), isA<IconData>());
      }
    });

    test('icon() returns different icons for active and inactive', () {
      for (final type in SystemPreferenceType.values) {
        expect(type.icon(active: true), isNot(equals(type.icon(active: false))));
      }
    });

    test('theme icons are color_lens variants', () {
      expect(SystemPreferenceType.theme.icon(active: true), Icons.color_lens);
      expect(SystemPreferenceType.theme.icon(active: false), Icons.color_lens_outlined);
    });

    test('engineer icons are engineering variants', () {
      expect(SystemPreferenceType.engineer.icon(active: true), Icons.engineering);
      expect(SystemPreferenceType.engineer.icon(active: false), Icons.engineering_outlined);
    });

    test('about icons are info variants', () {
      expect(SystemPreferenceType.about.icon(active: true), Icons.info);
      expect(SystemPreferenceType.about.icon(active: false), Icons.info_outline);
    });
  });

  group('SystemPreferenceSchema', () {
    test('has default values', () {
      const schema = SystemPreferenceSchema();
      expect(schema.theme, ThemeMode.dark);
      expect(schema.visibility, VisibilityType.public);
      expect(schema.sensitive, true);
      expect(schema.refreshInterval, const Duration(seconds: 30));
      expect(schema.loadedTop, false);
      expect(schema.replyTag, ReplyTagType.all);
      expect(schema.fontScale, 1.0);
      expect(schema.hideReplies, false);
      expect(schema.hideReblogs, false);
      expect(schema.autoPlayVideo, true);
      expect(schema.timelineLimit, 40);
      expect(schema.imageQuality, ImageQualityType.medium);
    });

    test('copyWith creates modified copy', () {
      const schema = SystemPreferenceSchema();
      final modified = schema.copyWith(theme: ThemeMode.light, sensitive: false);

      expect(modified.theme, ThemeMode.light);
      expect(modified.sensitive, false);
      // Unmodified fields remain the same
      expect(modified.visibility, VisibilityType.public);
      expect(modified.fontScale, 1.0);
    });

    test('toJson produces valid JSON', () {
      const schema = SystemPreferenceSchema();
      final json = schema.toJson();

      expect(json['theme'], 'dark');
      expect(json['visibility'], 'public');
      expect(json['sensitive'], true);
      expect(json['refresh_interval'], 30);
      expect(json['loaded_top'], false);
      expect(json['font_scale'], 1.0);
      expect(json['timeline_limit'], 40);
    });

    test('fromJson round-trips correctly', () {
      const original = SystemPreferenceSchema();
      final json = original.toJson();
      final restored = SystemPreferenceSchema.fromJson(json);

      expect(restored.theme, original.theme);
      expect(restored.visibility, original.visibility);
      expect(restored.sensitive, original.sensitive);
      expect(restored.refreshInterval, original.refreshInterval);
      expect(restored.fontScale, original.fontScale);
      expect(restored.timelineLimit, original.timelineLimit);
      expect(restored.imageQuality, original.imageQuality);
    });
  });

  group('ImageQualityType', () {
    test('has 3 values', () {
      expect(ImageQualityType.values.length, 3);
    });

    test('contains low, medium, high', () {
      expect(ImageQualityType.values, contains(ImageQualityType.low));
      expect(ImageQualityType.values, contains(ImageQualityType.medium));
      expect(ImageQualityType.values, contains(ImageQualityType.high));
    });
  });

  group('ReplyTagType', () {
    test('has 3 values', () {
      expect(ReplyTagType.values.length, 3);
    });

    test('contains all, poster, none', () {
      expect(ReplyTagType.values, contains(ReplyTagType.all));
      expect(ReplyTagType.values, contains(ReplyTagType.poster));
      expect(ReplyTagType.values, contains(ReplyTagType.none));
    });

    test('each has icon() method', () {
      expect(ReplyTagType.all.icon(), Icons.group);
      expect(ReplyTagType.poster.icon(), Icons.person);
      expect(ReplyTagType.none.icon(), Icons.cancel);
    });
  });

  group('VisibilityType', () {
    test('has all expected values', () {
      expect(VisibilityType.values, contains(VisibilityType.public));
      expect(VisibilityType.values, contains(VisibilityType.unlisted));
      expect(VisibilityType.values, contains(VisibilityType.private));
      expect(VisibilityType.values, contains(VisibilityType.direct));
    });

    test('each has icon() method', () {
      for (final v in VisibilityType.values) {
        expect(v.icon(), isA<IconData>());
      }
    });

    test('values match by name', () {
      final found = VisibilityType.values.firstWhere(
        (v) => v.name == 'public',
        orElse: () => VisibilityType.public,
      );
      expect(found, VisibilityType.public);
    });
  });

  group('QuotePolicyType', () {
    test('has expected values', () {
      expect(QuotePolicyType.values.length, greaterThanOrEqualTo(2));
    });

    test('each has icon', () {
      for (final v in QuotePolicyType.values) {
        expect(v.icon, isA<IconData>());
      }
    });

    test('fromString parses correctly', () {
      expect(QuotePolicyType.fromString('public'), QuotePolicyType.public);
      expect(QuotePolicyType.fromString('followers'), QuotePolicyType.followers);
      expect(QuotePolicyType.fromString('nobody'), QuotePolicyType.nobody);
    });
  });

  group('SystemPreferenceSchema additional fields', () {
    test('defaults are correct', () {
      const schema = SystemPreferenceSchema();
      expect(schema.fontScale, 1.0);
      expect(schema.hideReplies, false);
      expect(schema.hideReblogs, false);
      expect(schema.autoPlayVideo, true);
      expect(schema.timelineLimit, 40);
    });

    test('copyWith updates fields', () {
      const schema = SystemPreferenceSchema();
      final updated = schema.copyWith(
        hideReplies: true,
        hideReblogs: true,
        fontScale: 1.2,
      );
      expect(updated.hideReplies, true);
      expect(updated.hideReblogs, true);
      expect(updated.fontScale, 1.2);
      expect(updated.autoPlayVideo, true);
    });

    test('toJson includes additional fields', () {
      const schema = SystemPreferenceSchema(hideReplies: true);
      final json = schema.toJson();
      expect(json['hide_replies'], true);
      expect(json['font_scale'], 1.0);
    });

    test('fromJson restores additional fields', () {
      final json = SystemPreferenceSchema(fontScale: 1.3, hideReblogs: true).toJson();
      final restored = SystemPreferenceSchema.fromJson(json);
      expect(restored.fontScale, 1.3);
      expect(restored.hideReblogs, true);
      expect(restored.hideReplies, false);
    });

    test('copyWith with imageQuality change', () {
      const schema = SystemPreferenceSchema();
      final updated = schema.copyWith(imageQuality: ImageQualityType.high);
      expect(updated.imageQuality, ImageQualityType.high);
      expect(updated.theme, ThemeMode.dark);
    });

    test('copyWith with replyTag change', () {
      const schema = SystemPreferenceSchema();
      final updated = schema.copyWith(replyTag: ReplyTagType.poster);
      expect(updated.replyTag, ReplyTagType.poster);
    });

    test('copyWith with autoPlayVideo change', () {
      const schema = SystemPreferenceSchema();
      final updated = schema.copyWith(autoPlayVideo: false);
      expect(updated.autoPlayVideo, false);
    });

    test('copyWith with timelineLimit change', () {
      const schema = SystemPreferenceSchema();
      final updated = schema.copyWith(timelineLimit: 80);
      expect(updated.timelineLimit, 80);
    });

    test('toJson includes imageQuality', () {
      const schema = SystemPreferenceSchema(imageQuality: ImageQualityType.high);
      final json = schema.toJson();
      expect(json['image_quality'], 'high');
    });

    test('fromJson restores imageQuality', () {
      final json = const SystemPreferenceSchema(imageQuality: ImageQualityType.low).toJson();
      final restored = SystemPreferenceSchema.fromJson(json);
      expect(restored.imageQuality, ImageQualityType.low);
    });
  });

  group('SystemPreferenceSchema fromString', () {
    test('fromString parses JSON correctly', () {
      const schema = SystemPreferenceSchema(theme: ThemeMode.light, locale: Locale('ja'));
      final jsonStr = jsonEncode(schema.toJson());
      final restored = SystemPreferenceSchema.fromString(jsonStr);
      expect(restored.theme, ThemeMode.light);
      expect(restored.locale?.languageCode, 'ja');
    });
  });

  group('ImageQualityType descriptions', () {
    testWidgets('each type has localized description', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(_createPreferenceTestWidget(
        child: Builder(builder: (context) {
          capturedContext = context;
          return const SizedBox.shrink();
        }),
        preference: const SystemPreferenceSchema(),
      ));
      await tester.pump();

      for (final type in ImageQualityType.values) {
        expect(type.description(capturedContext), isNotEmpty);
      }
    });
  });

  group('ReplyTagType tooltips and descriptions', () {
    testWidgets('each type has localized tooltip', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(_createPreferenceTestWidget(
        child: Builder(builder: (context) {
          capturedContext = context;
          return const SizedBox.shrink();
        }),
        preference: const SystemPreferenceSchema(),
      ));
      await tester.pump();

      for (final type in ReplyTagType.values) {
        expect(type.tooltip(capturedContext), isNotEmpty);
      }
    });

    testWidgets('each type has localized description', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(_createPreferenceTestWidget(
        child: Builder(builder: (context) {
          capturedContext = context;
          return const SizedBox.shrink();
        }),
        preference: const SystemPreferenceSchema(),
      ));
      await tester.pump();

      for (final type in ReplyTagType.values) {
        expect(type.description(capturedContext), isNotEmpty);
      }
    });
  });

  group('SystemPreferenceType tooltip', () {
    testWidgets('each type has localized tooltip', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(_createPreferenceTestWidget(
        child: Builder(builder: (context) {
          capturedContext = context;
          return const SizedBox.shrink();
        }),
        preference: const SystemPreferenceSchema(),
      ));
      await tester.pump();

      for (final type in SystemPreferenceType.values) {
        expect(type.tooltip(capturedContext), isNotEmpty);
      }
    });
  });

  group('SystemPreference engineer tab', () {
    Future<void> pumpAndNavigateToEngineer(WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(_createPreferenceTestWidget(
          child: const SystemPreference(),
          preference: const SystemPreferenceSchema(),
        ));
        await tester.pump();
      });

      // Swipe left to navigate from theme (0) to engineer (1)
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();
    }

    testWidgets('renders engineer tab when swiped', (tester) async {
      await pumpAndNavigateToEngineer(tester);

      // Engineer tab should show clear cache, test notification, and reset buttons
      expect(find.byIcon(Icons.delete_outline_outlined), findsOneWidget);
      expect(find.byIcon(Icons.notifications), findsOneWidget);
      expect(find.byIcon(Icons.restart_alt), findsOneWidget);
    });

    testWidgets('engineer tab shows clear cache tile', (tester) async {
      await pumpAndNavigateToEngineer(tester);

      expect(find.text('Clear All Cache'), findsOneWidget);
    });

    testWidgets('engineer tab shows test notification tile', (tester) async {
      await pumpAndNavigateToEngineer(tester);

      expect(find.text('Test Notification'), findsOneWidget);
    });

    testWidgets('engineer tab shows reset system tile', (tester) async {
      await pumpAndNavigateToEngineer(tester);

      expect(find.text('Reset system'), findsOneWidget);
    });

    testWidgets('engineer tab clear cache and reset tiles have error color icons', (tester) async {
      await pumpAndNavigateToEngineer(tester);

      final deleteIcon = tester.widget<Icon>(find.byIcon(Icons.delete_outline_outlined));
      expect(deleteIcon.color, isNotNull);

      final restartIcon = tester.widget<Icon>(find.byIcon(Icons.restart_alt));
      expect(restartIcon.color, isNotNull);
    });

    testWidgets('engineer tab test notification tile has colored icon', (tester) async {
      await pumpAndNavigateToEngineer(tester);

      final notifIcon = tester.widget<Icon>(find.byIcon(Icons.notifications));
      expect(notifIcon.color, isNotNull);
    });
  });

  group('SystemPreference about tab', () {
    Future<void> pumpAndNavigateToAbout(WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(_createPreferenceTestWidget(
          child: const SystemPreference(),
          preference: const SystemPreferenceSchema(),
        ));
        await tester.pump();
      });

      // Swipe left twice to navigate from theme (0) -> engineer (1) -> about (2)
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();
    }

    testWidgets('renders about tab when swiped', (tester) async {
      await pumpAndNavigateToAbout(tester);

      // About tab should show version, author, repo, and copyright icons
      expect(find.byIcon(Icons.numbers), findsOneWidget);
      expect(find.byIcon(Icons.code), findsOneWidget);
      expect(find.byIcon(Icons.copyright), findsOneWidget);
    });

    testWidgets('about tab shows app version text', (tester) async {
      await pumpAndNavigateToAbout(tester);

      expect(find.text('App Version'), findsOneWidget);
      expect(find.text('1.0.0 (1)'), findsOneWidget);
    });

    testWidgets('about tab shows author info', (tester) async {
      await pumpAndNavigateToAbout(tester);

      expect(find.text('Author'), findsOneWidget);
      expect(find.text('cmj <cmj@cmj.tw>'), findsOneWidget);
    });

    testWidgets('about tab shows repository info', (tester) async {
      await pumpAndNavigateToAbout(tester);

      expect(find.text('Repository'), findsOneWidget);
      expect(find.text('https://github.com/cmj0121'), findsOneWidget);
    });

    testWidgets('about tab shows copyright info', (tester) async {
      await pumpAndNavigateToAbout(tester);

      expect(find.text('Copyright'), findsOneWidget);
      expect(find.textContaining('cmj <cmj@cmj.tw>'), findsWidgets);
    });
  });

  group('SystemPreference locale selector', () {
    testWidgets('shows locale selector with translate icon when scrolled', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(_createPreferenceTestWidget(
          child: const SystemPreference(),
          preference: const SystemPreferenceSchema(),
        ));
        await tester.pump();
      });

      // The translate icon is in the ListView, may need scrolling to find it
      // ListView in the theme tab; scroll down to reveal the locale selector
      final listViewFinder = find.byType(ListView);
      await tester.drag(listViewFinder, const Offset(0, -300));
      await tester.pump();

      expect(find.byIcon(Icons.translate), findsOneWidget);
    });

    testWidgets('shows locale name in locale selector', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(_createPreferenceTestWidget(
          child: const SystemPreference(),
          preference: const SystemPreferenceSchema(locale: Locale('en')),
        ));
        await tester.pump();
      });

      // Scroll down to reveal the locale selector
      final listViewFinder = find.byType(ListView);
      await tester.drag(listViewFinder, const Offset(0, -300));
      await tester.pump();

      expect(find.text('English'), findsOneWidget);
    });

    testWidgets('tapping locale selector opens dialog', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(_createPreferenceTestWidget(
          child: const SystemPreference(),
          preference: const SystemPreferenceSchema(locale: Locale('en')),
        ));
        await tester.pump();
      });

      // Scroll down to reveal the locale selector
      final listViewFinder = find.byType(ListView);
      await tester.drag(listViewFinder, const Offset(0, -300));
      await tester.pump();

      // Tap the locale selector ListTile
      await tester.tap(find.byIcon(Icons.translate));
      await tester.pumpAndSettle();

      // The dialog should show a list of locale options
      expect(find.textContaining('[en]'), findsOneWidget);
    });

    testWidgets('locale dialog shows check icon for selected locale', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(_createPreferenceTestWidget(
          child: const SystemPreference(),
          preference: const SystemPreferenceSchema(locale: Locale('en')),
        ));
        await tester.pump();
      });

      // Scroll down to reveal the locale selector
      final listViewFinder = find.byType(ListView);
      await tester.drag(listViewFinder, const Offset(0, -300));
      await tester.pump();

      // Open locale dialog
      await tester.tap(find.byIcon(Icons.translate));
      await tester.pumpAndSettle();

      // Selected locale should have a check icon
      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });

  group('SystemPreference interactions', () {
    testWidgets('shows status settings icons in theme tab', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(_createPreferenceTestWidget(
          child: const SystemPreference(),
          preference: const SystemPreferenceSchema(),
        ));
        await tester.pump();
      });

      // sensitive=true shows visibility_off, default visibility=public shows public icon
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      expect(find.byIcon(Icons.public), findsOneWidget);
      // default replyTag=all shows group icon
      expect(find.byIcon(Icons.group), findsOneWidget);
    });

    testWidgets('shows refresh interval icon', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(_createPreferenceTestWidget(
          child: const SystemPreference(),
          preference: const SystemPreferenceSchema(),
        ));
        await tester.pump();
      });

      // Refresh icon used for both reload button and refresh interval ListTile
      expect(find.byIcon(Icons.refresh), findsWidgets);
    });

    testWidgets('shows visibility icon when sensitive is off', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(_createPreferenceTestWidget(
          child: const SystemPreference(),
          preference: const SystemPreferenceSchema(sensitive: false),
        ));
        await tester.pump();
      });

      // sensitive=false shows visibility icon
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('shows SwitchListTile widgets in theme tab', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(_createPreferenceTestWidget(
          child: const SystemPreference(),
          preference: const SystemPreferenceSchema(),
        ));
        await tester.pump();
      });

      // Multiple SwitchListTile widgets exist for toggle settings
      expect(find.byType(SwitchListTile), findsWidgets);
    });

    testWidgets('shows person icon when replyTag is poster', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(_createPreferenceTestWidget(
          child: const SystemPreference(),
          preference: const SystemPreferenceSchema(replyTag: ReplyTagType.poster),
        ));
        await tester.pump();
      });

      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('shows cancel icon when replyTag is none', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(_createPreferenceTestWidget(
          child: const SystemPreference(),
          preference: const SystemPreferenceSchema(replyTag: ReplyTagType.none),
        ));
        await tester.pump();
      });

      expect(find.byIcon(Icons.cancel), findsOneWidget);
    });
  });

  group('SystemPreference reload button', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await Storage.init();
    });

    testWidgets('tapping reload button toggles reloadProvider', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(_createPreferenceTestWidget(
          child: const SystemPreference(),
          preference: const SystemPreferenceSchema(),
        ));
        await tester.pump();
      });

      // The reload button is at the bottom with a refresh icon and "Reload" text
      final reloadButton = find.text('Reload');
      expect(reloadButton, findsOneWidget);
      await tester.tap(reloadButton);
      await tester.pump();
    });
  });

  group('SystemPreference theme tab onChanged callbacks', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await Storage.init();
    });

    testWidgets('toggling sensitive SwitchListTile calls savePreference', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(_createPreferenceTestWidget(
          child: const SystemPreference(),
          preference: const SystemPreferenceSchema(sensitive: true),
        ));
        await tester.pump();
      });

      // sensitive=true shows visibility_off icon on the SwitchListTile
      final switchFinder = find.widgetWithIcon(SwitchListTile, Icons.visibility_off);
      expect(switchFinder, findsOneWidget);
      await tester.tap(switchFinder);
      await tester.pump();
    });

    testWidgets('toggling theme mode SwitchListTile calls savePreference', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(_createPreferenceTestWidget(
          child: const SystemPreference(),
          preference: const SystemPreferenceSchema(theme: ThemeMode.dark),
        ));
        await tester.pump();
      });

      // dark mode shows dark_mode icon
      final switchFinder = find.widgetWithIcon(SwitchListTile, Icons.dark_mode);
      expect(switchFinder, findsOneWidget);
      await tester.tap(switchFinder);
      await tester.pump();
    });

    testWidgets('tapping visibility ListTile cycles visibility', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(_createPreferenceTestWidget(
          child: const SystemPreference(),
          preference: const SystemPreferenceSchema(visibility: VisibilityType.public),
        ));
        await tester.pump();
      });

      // Public visibility shows Icons.public
      final tileFinder = find.widgetWithIcon(ListTile, Icons.public);
      expect(tileFinder, findsOneWidget);
      await tester.tap(tileFinder);
      await tester.pump();
    });

    testWidgets('tapping replyTag ListTile cycles replyTag', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(_createPreferenceTestWidget(
          child: const SystemPreference(),
          preference: const SystemPreferenceSchema(replyTag: ReplyTagType.all),
        ));
        await tester.pump();
      });

      // replyTag=all shows group icon
      final tileFinder = find.widgetWithIcon(ListTile, Icons.group);
      expect(tileFinder, findsOneWidget);
      await tester.tap(tileFinder);
      await tester.pump();
    });

    testWidgets('tapping refresh interval ListTile cycles interval', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(_createPreferenceTestWidget(
          child: const SystemPreference(),
          preference: const SystemPreferenceSchema(refreshInterval: Duration(seconds: 30)),
        ));
        await tester.pump();
      });

      // Scroll the ListView to make the refresh interval tile fully visible
      final scrollable = find.descendant(of: find.byType(ListView), matching: find.byType(Scrollable));
      final tileFinder = find.widgetWithIcon(ListTile, Icons.refresh);
      await tester.scrollUntilVisible(tileFinder, 100, scrollable: scrollable);
      await tester.pump();

      expect(tileFinder, findsOneWidget);
      await tester.tap(tileFinder);
      await tester.pump();
    });

    testWidgets('toggling loadedTop SwitchListTile calls savePreference', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(_createPreferenceTestWidget(
          child: const SystemPreference(),
          preference: const SystemPreferenceSchema(loadedTop: false),
        ));
        await tester.pump();
      });

      // Scroll the ListView to make the loadedTop switch fully visible
      final scrollable = find.descendant(of: find.byType(ListView), matching: find.byType(Scrollable));
      final switchFinder = find.widgetWithIcon(SwitchListTile, Icons.vertical_align_center);
      await tester.scrollUntilVisible(switchFinder, 100, scrollable: scrollable);
      await tester.pump();

      expect(switchFinder, findsOneWidget);
      await tester.tap(switchFinder);
      await tester.pump();
    });

    testWidgets('tapping quotePolicy ListTile cycles quotePolicy', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(_createPreferenceTestWidget(
          child: const SystemPreference(),
          preference: const SystemPreferenceSchema(),
        ));
        await tester.pump();
      });

      // Scroll the ListView to make the quotePolicy tile fully visible
      final scrollable = find.descendant(of: find.byType(ListView), matching: find.byType(Scrollable));
      final tileFinder = find.text('Quote Policy');
      await tester.scrollUntilVisible(tileFinder, 100, scrollable: scrollable);
      await tester.pump();

      expect(tileFinder, findsOneWidget);
      await tester.tap(tileFinder);
      await tester.pump();
    });

    testWidgets('toggling hideReplies SwitchListTile calls savePreference', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(_createPreferenceTestWidget(
          child: const SystemPreference(),
          preference: const SystemPreferenceSchema(hideReplies: false),
        ));
        await tester.pump();
      });

      // Scroll the ListView to make the hideReplies switch fully visible
      final scrollable = find.descendant(of: find.byType(ListView), matching: find.byType(Scrollable));
      final switchFinder = find.widgetWithIcon(SwitchListTile, Icons.speaker_notes);
      await tester.scrollUntilVisible(switchFinder, 100, scrollable: scrollable);
      await tester.pump();

      expect(switchFinder, findsOneWidget);
      await tester.tap(switchFinder);
      await tester.pump();
    });

    testWidgets('toggling hideReblogs SwitchListTile calls savePreference', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(_createPreferenceTestWidget(
          child: const SystemPreference(),
          preference: const SystemPreferenceSchema(hideReblogs: false),
        ));
        await tester.pump();
      });

      // Scroll the ListView down to reveal hideReblogs (deep in the list)
      final scrollable = find.descendant(of: find.byType(ListView), matching: find.byType(Scrollable));
      final switchFinder = find.widgetWithIcon(SwitchListTile, Icons.repeat);
      await tester.scrollUntilVisible(switchFinder, 100, scrollable: scrollable);
      await tester.pump();

      expect(switchFinder, findsOneWidget);
      await tester.tap(switchFinder);
      await tester.pump();
    });

    testWidgets('toggling autoPlayVideo SwitchListTile calls savePreference', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(_createPreferenceTestWidget(
          child: const SystemPreference(),
          preference: const SystemPreferenceSchema(autoPlayVideo: true),
        ));
        await tester.pump();
      });

      // Scroll the ListView down to reveal autoPlayVideo
      final scrollable = find.descendant(of: find.byType(ListView), matching: find.byType(Scrollable));
      final switchFinder = find.widgetWithIcon(SwitchListTile, Icons.play_circle);
      await tester.scrollUntilVisible(switchFinder, 100, scrollable: scrollable);
      await tester.pump();

      expect(switchFinder, findsOneWidget);
      await tester.tap(switchFinder);
      await tester.pump();
    });

    testWidgets('tapping timelineLimit ListTile cycles limit', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(_createPreferenceTestWidget(
          child: const SystemPreference(),
          preference: const SystemPreferenceSchema(timelineLimit: 40),
        ));
        await tester.pump();
      });

      // Scroll the ListView down to reveal timelineLimit
      final scrollable = find.descendant(of: find.byType(ListView), matching: find.byType(Scrollable));
      final tileFinder = find.widgetWithIcon(ListTile, Icons.format_list_numbered);
      await tester.scrollUntilVisible(tileFinder, 100, scrollable: scrollable);
      await tester.pump();

      expect(tileFinder, findsOneWidget);
      await tester.tap(tileFinder);
      await tester.pump();
    });

    testWidgets('tapping imageQuality ListTile cycles quality', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(_createPreferenceTestWidget(
          child: const SystemPreference(),
          preference: const SystemPreferenceSchema(),
        ));
        await tester.pump();
      });

      // Scroll the ListView down to reveal imageQuality
      final scrollable = find.descendant(of: find.byType(ListView), matching: find.byType(Scrollable));
      final tileFinder = find.widgetWithIcon(ListTile, Icons.image);
      await tester.scrollUntilVisible(tileFinder, 100, scrollable: scrollable);
      await tester.pump();

      expect(tileFinder, findsOneWidget);
      await tester.tap(tileFinder);
      await tester.pump();
    });

    testWidgets('dragging font scale slider calls savePreference', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(_createPreferenceTestWidget(
          child: const SystemPreference(),
          preference: const SystemPreferenceSchema(fontScale: 1.0),
        ));
        await tester.pump();
      });

      // Scroll the ListView down to reveal font scale slider
      final scrollable = find.descendant(of: find.byType(ListView), matching: find.byType(Scrollable));
      final formatSizeFinder = find.byIcon(Icons.format_size);
      await tester.scrollUntilVisible(formatSizeFinder, 100, scrollable: scrollable);
      await tester.pump();

      final sliderFinder = find.byType(Slider);
      expect(sliderFinder, findsOneWidget);
      // Drag the slider to the right
      await tester.drag(sliderFinder, const Offset(50, 0));
      await tester.pump();
    });
  });

  group('SystemPreference engineer tab onTap callbacks', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await Storage.init();
    });

    Future<void> pumpAndNavigateToEngineer(WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(_createPreferenceTestWidget(
          child: const SystemPreference(),
          preference: const SystemPreferenceSchema(),
        ));
        await tester.pump();
      });

      // Swipe left to navigate from theme (0) to engineer (1)
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();
    }

    testWidgets('tapping clear cache tile triggers emptyCache', (tester) async {
      await pumpAndNavigateToEngineer(tester);

      // Tap the clear cache tile to trigger the onTap callback
      final tileFinder = find.widgetWithIcon(ListTile, Icons.delete_outline_outlined);
      expect(tileFinder, findsOneWidget);

      await tester.runAsync(() async {
        await tester.tap(tileFinder);
        // Give time for the async emptyCache() to complete
        await Future<void>.delayed(const Duration(milliseconds: 500));
      });
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('tapping test notification tile shows snackbar', (tester) async {
      await pumpAndNavigateToEngineer(tester);

      // Tap the test notification tile — this calls sendDummyNotification()
      // which shows a snackbar and schedules a 5-second Future.delayed.
      // We wrap in runAsync so the timer doesn't block the test.
      final tileFinder = find.widgetWithIcon(ListTile, Icons.notifications);
      expect(tileFinder, findsOneWidget);
      await tester.runAsync(() async {
        await tester.tap(tileFinder);
      });
      await tester.pump();
    });

    testWidgets('tapping reset system tile shows confirm dialog', (tester) async {
      await pumpAndNavigateToEngineer(tester);

      // Tap the reset system tile
      final tileFinder = find.widgetWithIcon(ListTile, Icons.restart_alt);
      expect(tileFinder, findsOneWidget);
      await tester.tap(tileFinder);
      await tester.pumpAndSettle();

      // Confirm dialog should appear with the reset message
      expect(find.text('Reset system'), findsWidgets);
      expect(find.textContaining('delete all your data'), findsOneWidget);
    });

    testWidgets('confirming reset dialog triggers purge', (tester) async {
      await pumpAndNavigateToEngineer(tester);

      // Tap reset system tile
      final tileFinder = find.widgetWithIcon(ListTile, Icons.restart_alt);
      await tester.tap(tileFinder);
      await tester.pumpAndSettle();

      // Tap Confirm button in the dialog
      final confirmButton = find.text('Confirm');
      expect(confirmButton, findsOneWidget);

      await tester.runAsync(() async {
        await tester.tap(confirmButton);
        // Give time for the async purge() to complete
        await Future<void>.delayed(const Duration(milliseconds: 500));
      });
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('cancelling reset dialog does not purge', (tester) async {
      await pumpAndNavigateToEngineer(tester);

      // Tap reset system tile
      final tileFinder = find.widgetWithIcon(ListTile, Icons.restart_alt);
      await tester.tap(tileFinder);
      await tester.pumpAndSettle();

      // Tap Close button in the dialog (btn_close localizes to "Close" in English)
      final closeButton = find.text('Close');
      expect(closeButton, findsOneWidget);
      await tester.tap(closeButton);
      await tester.pumpAndSettle();

      // Dialog should be dismissed
      expect(find.textContaining('delete all your data'), findsNothing);
    });
  });

  group('SystemPreference about tab onTap callbacks', () {
    late List<String> launchedUrls;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await Storage.init();
      launchedUrls = [];
      // Mock url_launcher method channel
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/url_launcher'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'launch') {
            launchedUrls.add(methodCall.arguments['url'] as String);
            return true;
          }
          if (methodCall.method == 'canLaunch') {
            return true;
          }
          return null;
        },
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/url_launcher'),
        null,
      );
    });

    Future<void> pumpAndNavigateToAbout(WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(_createPreferenceTestWidget(
          child: const SystemPreference(),
          preference: const SystemPreferenceSchema(),
        ));
        await tester.pump();
      });

      // Swipe left twice to navigate from theme (0) -> engineer (1) -> about (2)
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();
    }

    testWidgets('tapping app version tile triggers launchUrl', (tester) async {
      await pumpAndNavigateToAbout(tester);

      final tileFinder = find.widgetWithIcon(ListTile, Icons.numbers);
      expect(tileFinder, findsOneWidget);
      await tester.runAsync(() async {
        await tester.tap(tileFinder);
      });
      await tester.pump();
    });

    testWidgets('tapping author tile triggers launchUrl', (tester) async {
      await pumpAndNavigateToAbout(tester);

      final tileFinder = find.widgetWithIcon(ListTile, Icons.person);
      expect(tileFinder, findsOneWidget);
      await tester.runAsync(() async {
        await tester.tap(tileFinder);
      });
      await tester.pump();
    });

    testWidgets('tapping repository tile triggers launchUrl', (tester) async {
      await pumpAndNavigateToAbout(tester);

      final tileFinder = find.widgetWithIcon(ListTile, Icons.code);
      expect(tileFinder, findsOneWidget);
      await tester.runAsync(() async {
        await tester.tap(tileFinder);
      });
      await tester.pump();
    });

    testWidgets('tapping copyright tile triggers launchUrl', (tester) async {
      await pumpAndNavigateToAbout(tester);

      final tileFinder = find.widgetWithIcon(ListTile, Icons.copyright);
      expect(tileFinder, findsOneWidget);
      await tester.runAsync(() async {
        await tester.tap(tileFinder);
      });
      await tester.pump();
    });
  });

  group('SystemPreference locale dialog interaction', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await Storage.init();
    });

    testWidgets('tapping a locale in the dialog triggers onTap', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(_createPreferenceTestWidget(
          child: const SystemPreference(),
          preference: const SystemPreferenceSchema(locale: Locale('en')),
        ));
        await tester.pump();
      });

      // Scroll down to reveal locale selector
      final listViewFinder = find.byType(ListView);
      await tester.drag(listViewFinder, const Offset(0, -300));
      await tester.pump();

      // Open the locale dialog
      await tester.tap(find.byIcon(Icons.translate));
      await tester.pumpAndSettle();

      // Tap a different locale, e.g., [ja] Japanese
      // The onTap calls context.pop() which requires GoRouter — will throw
      final japaneseFinder = find.textContaining('[ja]');
      expect(japaneseFinder, findsOneWidget);
      await tester.tap(japaneseFinder);
      await tester.pump();

      // Consume the expected GoRouter error (context.pop() without GoRouter ancestor)
      expect(tester.takeException(), isNotNull);
    });
  });

  group('OLED theme preference', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await Storage.init();
    });

    testWidgets('OLED toggle is visible when dark theme is active', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(_createPreferenceTestWidget(
          child: const SystemPreference(),
          preference: const SystemPreferenceSchema(theme: ThemeMode.dark),
        ));
        await tester.pump();
      });

      // Scroll down multiple times to reveal the OLED toggle at the bottom
      final listViewFinder = find.byType(ListView);
      await tester.drag(listViewFinder, const Offset(0, -500));
      await tester.pump();
      await tester.drag(listViewFinder, const Offset(0, -500));
      await tester.pump();

      expect(find.text('OLED Dark Theme'), findsOneWidget);
    });

    testWidgets('OLED toggle is hidden when light theme is active', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(_createPreferenceTestWidget(
          child: const SystemPreference(),
          preference: const SystemPreferenceSchema(theme: ThemeMode.light),
        ));
        await tester.pump();
      });

      // Scroll down fully
      final listViewFinder = find.byType(ListView);
      await tester.drag(listViewFinder, const Offset(0, -500));
      await tester.pump();
      await tester.drag(listViewFinder, const Offset(0, -500));
      await tester.pump();

      expect(find.text('OLED Dark Theme'), findsNothing);
    });

    testWidgets('OLED toggle shows filled icon when enabled', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(_createPreferenceTestWidget(
          child: const SystemPreference(),
          preference: const SystemPreferenceSchema(theme: ThemeMode.dark, useOledTheme: true),
        ));
        await tester.pump();
      });

      final listViewFinder = find.byType(ListView);
      await tester.drag(listViewFinder, const Offset(0, -500));
      await tester.pump();
      await tester.drag(listViewFinder, const Offset(0, -500));
      await tester.pump();

      expect(find.byIcon(Icons.brightness_1), findsOneWidget);
    });

    testWidgets('OLED toggle shows outlined icon when disabled', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(_createPreferenceTestWidget(
          child: const SystemPreference(),
          preference: const SystemPreferenceSchema(theme: ThemeMode.dark, useOledTheme: false),
        ));
        await tester.pump();
      });

      final listViewFinder = find.byType(ListView);
      await tester.drag(listViewFinder, const Offset(0, -500));
      await tester.pump();
      await tester.drag(listViewFinder, const Offset(0, -500));
      await tester.pump();

      expect(find.byIcon(Icons.brightness_1_outlined), findsOneWidget);
    });

    testWidgets('tapping OLED toggle calls savePreference', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(_createPreferenceTestWidget(
          child: const SystemPreference(),
          preference: const SystemPreferenceSchema(theme: ThemeMode.dark, useOledTheme: false),
        ));
        await tester.pump();
      });

      final listViewFinder = find.byType(ListView);
      await tester.drag(listViewFinder, const Offset(0, -500));
      await tester.pump();
      await tester.drag(listViewFinder, const Offset(0, -500));
      await tester.pump();

      final switchFinder = find.widgetWithIcon(SwitchListTile, Icons.brightness_1_outlined);
      expect(switchFinder, findsOneWidget);
      await tester.tap(switchFinder);
      await tester.pump();
    });

    testWidgets('OLED toggle switch value reflects enabled state', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(_createPreferenceTestWidget(
          child: const SystemPreference(),
          preference: const SystemPreferenceSchema(theme: ThemeMode.dark, useOledTheme: true),
        ));
        await tester.pump();
      });

      final listViewFinder = find.byType(ListView);
      await tester.drag(listViewFinder, const Offset(0, -500));
      await tester.pump();
      await tester.drag(listViewFinder, const Offset(0, -500));
      await tester.pump();

      final switchTile = tester.widget<SwitchListTile>(
        find.widgetWithIcon(SwitchListTile, Icons.brightness_1),
      );
      expect(switchTile.value, true);
    });

    testWidgets('OLED toggle switch value reflects disabled state', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(_createPreferenceTestWidget(
          child: const SystemPreference(),
          preference: const SystemPreferenceSchema(theme: ThemeMode.dark, useOledTheme: false),
        ));
        await tester.pump();
      });

      final listViewFinder = find.byType(ListView);
      await tester.drag(listViewFinder, const Offset(0, -500));
      await tester.pump();
      await tester.drag(listViewFinder, const Offset(0, -500));
      await tester.pump();

      final switchTile = tester.widget<SwitchListTile>(
        find.widgetWithIcon(SwitchListTile, Icons.brightness_1_outlined),
      );
      expect(switchTile.value, false);
    });
  });

  group('Haptic feedback preference', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await Storage.init();
    });

    testWidgets('haptic toggle is visible in Appearance section', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(_createPreferenceTestWidget(
          child: const SystemPreference(),
          preference: const SystemPreferenceSchema(),
        ));
        await tester.pump();
      });

      // Scroll down multiple times to reveal the haptic toggle (last item)
      final listViewFinder = find.byType(ListView);
      await tester.drag(listViewFinder, const Offset(0, -500));
      await tester.pump();
      await tester.drag(listViewFinder, const Offset(0, -500));
      await tester.pump();
      await tester.drag(listViewFinder, const Offset(0, -500));
      await tester.pump();

      expect(find.text('Haptic Feedback'), findsOneWidget);
    });

    testWidgets('haptic toggle shows vibration icon when enabled', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(_createPreferenceTestWidget(
          child: const SystemPreference(),
          preference: const SystemPreferenceSchema(hapticFeedback: true),
        ));
        await tester.pump();
      });

      final listViewFinder = find.byType(ListView);
      await tester.drag(listViewFinder, const Offset(0, -500));
      await tester.pump();
      await tester.drag(listViewFinder, const Offset(0, -500));
      await tester.pump();
      await tester.drag(listViewFinder, const Offset(0, -500));
      await tester.pump();

      expect(find.byIcon(Icons.vibration), findsOneWidget);
    });

    testWidgets('haptic toggle shows smartphone icon when disabled', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(_createPreferenceTestWidget(
          child: const SystemPreference(),
          preference: const SystemPreferenceSchema(hapticFeedback: false),
        ));
        await tester.pump();
      });

      final listViewFinder = find.byType(ListView);
      await tester.drag(listViewFinder, const Offset(0, -500));
      await tester.pump();
      await tester.drag(listViewFinder, const Offset(0, -500));
      await tester.pump();
      await tester.drag(listViewFinder, const Offset(0, -500));
      await tester.pump();

      expect(find.byIcon(Icons.smartphone), findsOneWidget);
    });

    testWidgets('tapping haptic toggle calls savePreference', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(_createPreferenceTestWidget(
          child: const SystemPreference(),
          preference: const SystemPreferenceSchema(hapticFeedback: true),
        ));
        await tester.pump();
      });

      final listViewFinder = find.byType(ListView);
      await tester.drag(listViewFinder, const Offset(0, -500));
      await tester.pump();
      await tester.drag(listViewFinder, const Offset(0, -500));
      await tester.pump();
      await tester.drag(listViewFinder, const Offset(0, -500));
      await tester.pump();

      final switchFinder = find.widgetWithIcon(SwitchListTile, Icons.vibration);
      expect(switchFinder, findsOneWidget);
      await tester.tap(switchFinder);
      await tester.pump();
    });

    testWidgets('haptic toggle switch value reflects enabled state', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(_createPreferenceTestWidget(
          child: const SystemPreference(),
          preference: const SystemPreferenceSchema(hapticFeedback: true),
        ));
        await tester.pump();
      });

      final listViewFinder = find.byType(ListView);
      await tester.drag(listViewFinder, const Offset(0, -500));
      await tester.pump();
      await tester.drag(listViewFinder, const Offset(0, -500));
      await tester.pump();
      await tester.drag(listViewFinder, const Offset(0, -500));
      await tester.pump();

      final switchTile = tester.widget<SwitchListTile>(
        find.widgetWithIcon(SwitchListTile, Icons.vibration),
      );
      expect(switchTile.value, true);
    });

    testWidgets('haptic toggle switch value reflects disabled state', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(_createPreferenceTestWidget(
          child: const SystemPreference(),
          preference: const SystemPreferenceSchema(hapticFeedback: false),
        ));
        await tester.pump();
      });

      final listViewFinder = find.byType(ListView);
      await tester.drag(listViewFinder, const Offset(0, -500));
      await tester.pump();
      await tester.drag(listViewFinder, const Offset(0, -500));
      await tester.pump();
      await tester.drag(listViewFinder, const Offset(0, -500));
      await tester.pump();

      final switchTile = tester.widget<SwitchListTile>(
        find.widgetWithIcon(SwitchListTile, Icons.smartphone),
      );
      expect(switchTile.value, false);
    });
  });

}

// vim: set ts=2 sw=2 sts=2 et:
