// Widget tests for SystemPreference and SystemPreferenceType.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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

}

// vim: set ts=2 sw=2 sts=2 et:
