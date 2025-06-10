// The extensions implementation for the glacial feature.
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';

final keyServerHistory = 'server_history';
final keyLastServer = 'last_server';

extension ServerExtensions on Storage {
  // Get and Set the last used server
  Future<String?> loadLastServer() async => await getString(keyLastServer);
  Future<void> saveLastServer(String? server) async {
    if (server == null || server.isEmpty) {
      await remove(keyLastServer);
      return;
    }

    await setString(keyLastServer, server);
  }

  // get the history of the used servers
  List<String> get serverHistory => getStringList(keyServerHistory);

	// set the history of the used servers
  set serverHistory(List<String> value) => setStringList(keyServerHistory, value);
}

extension ProviderExtensions on Storage {
  // Clear and reset all the provider states.
  Future<void> clearProvider(WidgetRef ref) async {
    final Storage storage = Storage();

    ref.read(serverProvider.notifier).state = null;
    ref.read(accessTokenProvider.notifier).state = null;
    ref.read(accountProvider.notifier).state = null;

    storage.purgeCachedEmojis();
    storage.purgeCachedStatuses();

    saveLastServer(null);
  }

  // Load the possible last provider state from the storage.
  Future<void> reloadProvider(WidgetRef ref) async {
    final String? lastServer = await loadLastServer();
    final String? accessToken = await loadAccessToken(lastServer);

    if (lastServer != null && lastServer.isNotEmpty) {
      final ServerSchema server = await ServerSchema.fetch(lastServer);
      ref.read(serverProvider.notifier).state = server;

      if (accessToken != null && accessToken.isNotEmpty) {
        ref.read(accessTokenProvider.notifier).state = accessToken;
        ref.read(accountProvider.notifier).state = await server.getUserByAccessToken(accessToken);
      }
    }
  }

  // Update the provider state based on the current server and access token.
  Future<void> updateProvider(WidgetRef ref, ServerSchema server, String? accessToken) async {
    ref.read(serverProvider.notifier).state = server;
    ref.read(accessTokenProvider.notifier).state = accessToken;

    ref.read(accountProvider.notifier).state = await server.getUserByAccessToken(accessToken);

    await saveLastServer(server.domain);
    await saveAccessToken(server.domain, accessToken);
  }
}

// vim: set ts=2 sw=2 sts=2 et:
