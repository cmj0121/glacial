// The extensions implementation for the preference feature.
import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';

extension SystemPreferenceSchemaExtension on Storage {
  // Load the system preference settings from the storage.
  Future<SystemPreferenceSchema?> loadPreference({WidgetRef? ref}) async {
    final String? json = await getString(SystemPreferenceSchema.key);
    final SystemPreferenceSchema? preference = json == null ? null : SystemPreferenceSchema.fromString(json);

    ref?.read(preferenceProvider.notifier).state = preference;
    return preference;
  }

  // Save the system preference settings to the storage.
  Future<void> savePreference(SystemPreferenceSchema schema, {WidgetRef? ref}) async {
    final String json = jsonEncode(schema.toJson());
    await setString(SystemPreferenceSchema.key, json);

    ref?.read(preferenceProvider.notifier).state = schema;
  }
}
// vim: set ts=2 sw=2 sts=2 et:
