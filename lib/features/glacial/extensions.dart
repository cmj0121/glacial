// The extensions implementation for the glacial feature.

import 'package:glacial/core.dart';

final keyServerHistory = 'server_history';

extension ServerExtensions on Storage {
  // get the history of the used servers
  List<String> get serverHistory => getStringList(keyServerHistory);

	// set the history of the used servers
  set serverHistory(List<String> value) => setStringList(keyServerHistory, value);
}

// vim: set ts=2 sw=2 sts=2 et:
