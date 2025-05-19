// The extensions implementation for the glacial feature.
import 'dart:async';

import 'package:glacial/core.dart';

final keyServerHistory = 'server_history';
final keyLastServer = 'last_server';

extension ServerExtensions on Storage {
  // Get and Set the last used server
  Future<String?> loadLastServer() async => await getString(keyLastServer);
  void saveLastServer(String server) => setString(keyLastServer, server);

  // get the history of the used servers
  List<String> get serverHistory => getStringList(keyServerHistory);

	// set the history of the used servers
  set serverHistory(List<String> value) => setStringList(keyServerHistory, value);
}

// vim: set ts=2 sw=2 sts=2 et:
