// Tests for SystemPreferenceSchema model.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/features/models.dart';

void main() {
  group('SystemPreferenceSchema', () {
    test('default values', () {
      const pref = SystemPreferenceSchema();
      expect(pref.theme, ThemeMode.dark);
      expect(pref.visibility, VisibilityType.public);
      expect(pref.sensitive, true);
      expect(pref.refreshInterval, const Duration(seconds: 30));
      expect(pref.loadedTop, false);
      expect(pref.replyTag, ReplyTagType.all);
      expect(pref.locale, isNull);
      expect(pref.quotePolicy, QuotePolicyType.public);
      expect(pref.fontScale, 1.0);
      expect(pref.hideReplies, false);
      expect(pref.hideReblogs, false);
      expect(pref.autoPlayVideo, true);
      expect(pref.timelineLimit, 40);
      expect(pref.imageQuality, ImageQualityType.medium);
    });

    test('toJson and fromJson round-trip', () {
      const pref = SystemPreferenceSchema(
        server: 'example.com',
        theme: ThemeMode.light,
        visibility: VisibilityType.unlisted,
        sensitive: false,
        refreshInterval: Duration(seconds: 60),
        loadedTop: true,
        replyTag: ReplyTagType.poster,
        locale: Locale('ja'),
        fontScale: 1.2,
        hideReplies: true,
        hideReblogs: true,
        autoPlayVideo: false,
        timelineLimit: 80,
        imageQuality: ImageQualityType.high,
      );
      final json = pref.toJson();
      final restored = SystemPreferenceSchema.fromJson(json);
      expect(restored.server, 'example.com');
      expect(restored.theme, ThemeMode.light);
      expect(restored.visibility, VisibilityType.unlisted);
      expect(restored.sensitive, false);
      expect(restored.refreshInterval.inSeconds, 60);
      expect(restored.loadedTop, true);
      expect(restored.replyTag, ReplyTagType.poster);
      expect(restored.locale?.languageCode, 'ja');
      expect(restored.fontScale, 1.2);
      expect(restored.hideReplies, true);
      expect(restored.hideReblogs, true);
      expect(restored.autoPlayVideo, false);
      expect(restored.timelineLimit, 80);
      expect(restored.imageQuality, ImageQualityType.high);
    });

    test('fromString parses JSON string', () {
      final json = jsonEncode({
        'theme': 'light',
        'visibility': 'private',
        'sensitive': true,
        'refresh_interval': 45,
      });
      final pref = SystemPreferenceSchema.fromString(json);
      expect(pref.theme, ThemeMode.light);
      expect(pref.visibility, VisibilityType.private);
      expect(pref.sensitive, true);
      expect(pref.refreshInterval.inSeconds, 45);
    });

    test('fromJson uses defaults for missing fields', () {
      final pref = SystemPreferenceSchema.fromJson({});
      expect(pref.theme, ThemeMode.dark);
      expect(pref.visibility, VisibilityType.public);
      expect(pref.fontScale, 1.0);
      expect(pref.autoPlayVideo, true);
    });

    test('copyWith creates new instance with updated values', () {
      const pref = SystemPreferenceSchema();
      final updated = pref.copyWith(
        theme: ThemeMode.light,
        fontScale: 1.4,
        hideReplies: true,
      );
      expect(updated.theme, ThemeMode.light);
      expect(updated.fontScale, 1.4);
      expect(updated.hideReplies, true);
      expect(updated.visibility, VisibilityType.public);
    });

    test('fromJson handles unknown theme gracefully', () {
      final pref = SystemPreferenceSchema.fromJson({'theme': 'nonexistent'});
      expect(pref.theme, ThemeMode.dark);
    });

    test('fromJson handles unknown visibility gracefully', () {
      final pref = SystemPreferenceSchema.fromJson({'visibility': 'nonexistent'});
      expect(pref.visibility, VisibilityType.public);
    });

    test('fromJson handles unknown imageQuality gracefully', () {
      final pref = SystemPreferenceSchema.fromJson({'image_quality': 'nonexistent'});
      expect(pref.imageQuality, ImageQualityType.medium);
    });

    test('fromJson handles unknown replyTag gracefully', () {
      final pref = SystemPreferenceSchema.fromJson({'reply_tag': 'nonexistent'});
      expect(pref.replyTag, ReplyTagType.all);
    });

    test('toJson locale serializes as language tag', () {
      const pref = SystemPreferenceSchema(locale: Locale('de'));
      final json = pref.toJson();
      expect(json['locale'], 'de');
    });

    test('toJson null locale serializes as null', () {
      const pref = SystemPreferenceSchema();
      final json = pref.toJson();
      expect(json['locale'], isNull);
    });
  });

  group('ReplyTagType', () {
    test('icon returns correct icons', () {
      expect(ReplyTagType.all.icon(), Icons.group);
      expect(ReplyTagType.poster.icon(), Icons.person);
      expect(ReplyTagType.none.icon(), Icons.cancel);
    });
  });

  group('ImageQualityType', () {
    test('all values exist', () {
      expect(ImageQualityType.values, hasLength(3));
      expect(ImageQualityType.values, contains(ImageQualityType.low));
      expect(ImageQualityType.values, contains(ImageQualityType.medium));
      expect(ImageQualityType.values, contains(ImageQualityType.high));
    });
  });

  group('SystemPreferenceType', () {
    test('icons return different values for active and inactive', () {
      for (final type in SystemPreferenceType.values) {
        final activeIcon = type.icon(active: true);
        final inactiveIcon = type.icon(active: false);
        expect(activeIcon, isNot(equals(inactiveIcon)),
            reason: '${type.name} should have different active/inactive icons');
      }
    });

    test('all values exist', () {
      expect(SystemPreferenceType.values, hasLength(3));
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
