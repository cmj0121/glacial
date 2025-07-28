// The extensions implementation for the preference feature.
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';

extension SystemPreferenceSchemaExtension on Storage {
  // Load the system preference settings from the storage.
  Future<SystemPreferenceSchema?> loadPreference(WidgetRef ref) async {
    final String? json = await getString(SystemPreferenceSchema.key);
    final SystemPreferenceSchema? preference = json == null ? null : SystemPreferenceSchema.fromString(json);

    ref.read(preferenceProvider.notifier).state = preference;
    logger.i("loaded system preference: $json");
    return preference;
  }
}
// vim: set ts=2 sw=2 sts=2 et:
