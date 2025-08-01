// The extensions implementation for the glacial feature.
import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';

export 'api/timeline.dart';
export 'api/trends.dart';

extension AccessStatusExtension on Storage {
  // Load the access status from the storage.
  Future<AccessStatusSchema?> loadAccessStatus({WidgetRef? ref}) async {
    final String? json = await getString(AccessStatusSchema.key);
    final AccessStatusSchema? status = json == null ? null : AccessStatusSchema.fromString(json);
    final String? domain = status?.server?.isNotEmpty == true ? status?.server : null;
    final ServerSchema? schema = domain == null ? null : await ServerSchema.fetch(domain);

    ref?.read(accessStatusProvider.notifier).state = status?.copyWith(schema: schema);
    return status;
  }

  // Save the access status to the storage.
  Future<void> saveAccessStatus(AccessStatusSchema schema, {WidgetRef? ref}) async {
    final String json = jsonEncode(schema.toJson());
    await setString(AccessStatusSchema.key, json);

    ref?.read(accessStatusProvider.notifier).state = schema;
  }
}

// vim: set ts=2 sw=2 sts=2 et:
