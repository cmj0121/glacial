// Shared server selection logic used by both v1 ServerExplorer and v2 server picker.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/mastodon/extensions.dart';
import 'package:glacial/features/models.dart';

/// Handles server selection: saves to storage, updates provider, configures Sentry.
/// Returns the [RoutePath] to navigate to.
Future<RoutePath> selectServer({
  required ServerSchema schema,
  required WidgetRef ref,
}) async {
  final Storage storage = Storage();
  final AccessStatusSchema current = ref.read(accessStatusProvider) ?? AccessStatusSchema();
  List<ServerInfoSchema> history = current.history.toList();

  // If the server not already in the history, add it.
  if (!history.any((ServerInfoSchema info) => info.domain == schema.domain)) {
    history.add(schema.toInfo());
  }

  // Build a clean status without carrying over stale accessToken from
  // the previous server — prevents isSignedIn from being wrong.
  final AccessStatusSchema clean = AccessStatusSchema(domain: schema.domain)
      .copyWith(history: history, server: schema);

  logger.i("selectServer: ${schema.domain}");
  await storage.saveAccessStatus(clean, ref: ref);
  await storage.loadAccessStatus(ref: ref);

  Sentry.configureScope((scope) {
    scope.setTag('mastodon.server', schema.domain);
  });

  final AccessStatusSchema? updated = ref.read(accessStatusProvider);
  final bool isSignedIn = updated?.isSignedIn == true;
  final timelinesAccess = schema.config.timelinesAccess;
  final bool hasTimeline = SidebarButtonType.timeline.isAccessible(
    isSignedIn: isSignedIn, access: timelinesAccess,
  );

  return hasTimeline ? RoutePath.timeline : RoutePath.trends;
}

// vim: set ts=2 sw=2 sts=2 et:
