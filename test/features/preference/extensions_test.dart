// Tests for SystemPreferenceExtension on Storage.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';

import '../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  group('SystemPreferenceExtension', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await Storage.init();
    });

    test('loadPreference returns null when no data stored', () async {
      final result = await Storage().loadPreference();
      expect(result, isNull);
    });

    test('savePreference stores and loadPreference retrieves', () async {
      const schema = SystemPreferenceSchema(theme: ThemeMode.light, sensitive: false);
      await Storage().savePreference(schema);

      final loaded = await Storage().loadPreference();
      expect(loaded, isNotNull);
      expect(loaded!.theme, ThemeMode.light);
      expect(loaded.sensitive, false);
    });

    test('savePreference overwrites previous value', () async {
      const schema1 = SystemPreferenceSchema(fontScale: 1.0);
      await Storage().savePreference(schema1);

      const schema2 = SystemPreferenceSchema(fontScale: 1.3);
      await Storage().savePreference(schema2);

      final loaded = await Storage().loadPreference();
      expect(loaded!.fontScale, 1.3);
    });

    testWidgets('savePreference with ref updates preferenceProvider', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await Storage.init();

      late WidgetRef capturedRef;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            preferenceProvider.overrideWith((ref) => null),
          ],
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, _) {
                capturedRef = ref;
                final pref = ref.watch(preferenceProvider);
                return Text(pref?.theme.name ?? 'none');
              },
            ),
          ),
        ),
      );

      // Initially the preference provider is null
      expect(find.text('none'), findsOneWidget);

      // Save preference with ref — this covers line 25
      const schema = SystemPreferenceSchema(theme: ThemeMode.light);
      await Storage().savePreference(schema, ref: capturedRef);
      await tester.pump();

      // The provider should now have the saved preference
      expect(find.text('light'), findsOneWidget);
    });

    testWidgets('loadPreference with ref updates preferenceProvider', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await Storage.init();

      // Pre-save a preference to storage
      const schema = SystemPreferenceSchema(theme: ThemeMode.dark);
      await Storage().savePreference(schema);

      late WidgetRef capturedRef;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            preferenceProvider.overrideWith((ref) => null),
          ],
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, _) {
                capturedRef = ref;
                final pref = ref.watch(preferenceProvider);
                return Text(pref?.theme.name ?? 'none');
              },
            ),
          ),
        ),
      );

      // Initially the preference provider is null
      expect(find.text('none'), findsOneWidget);

      // Load preference with ref — this covers line 16
      await Storage().loadPreference(ref: capturedRef);
      await tester.pump();

      // The provider should now have the loaded preference
      expect(find.text('dark'), findsOneWidget);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
