// Widget tests for SystemPreference and SystemPreferenceType.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

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

    // Note: SystemPreference widget tests are limited because buildAppInfo()
    // requires PackageInfo which is unavailable in test environment.
    // The SystemPreferenceType enum tests below cover the tab configuration.
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
}

// vim: set ts=2 sw=2 sts=2 et:
