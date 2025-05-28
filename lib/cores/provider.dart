// The shared provider for the Glacial application.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/core.dart';

// The global state to access resource crossing the modules
final navigatorKey = GlobalKey<NavigatorState>();

// The global provider to declare the selected Mastodon server and access token
final currentServerProvider = StateProvider<ServerSchema?>((ref) => null);
final currentAccessTokenProvider = StateProvider<String?>((ref) => null);
final currentUserProvider = StateProvider<AccountSchema?>((ref) => null);

// clear the current server, access token, user information, and other related providers
Future<void> clearProvider(WidgetRef ref) async {
  final Storage storage = Storage();
  ref.read(currentServerProvider.notifier).state = null;
  ref.read(currentAccessTokenProvider.notifier).state = null;
  ref.read(currentUserProvider.notifier).state = null;

  storage.saveLastServer(null);
}

// Try to update the current server, access token, user information, and other related providers
Future<void> onLoading(WidgetRef ref, ServerSchema? schema, String? accessToken) async {
  final Storage storage = Storage();
  final AccountSchema? account = await schema?.getAuthUser(accessToken);

  ref.read(currentServerProvider.notifier).state = schema;
  ref.read(currentAccessTokenProvider.notifier).state = accessToken;
  ref.read(currentUserProvider.notifier).state = account;

  storage.saveLastServer(schema?.domain);
}


// vim: set ts=2 sw=2 sts=2 et:
