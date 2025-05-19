// The shared provider for the Glacial application.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/features/glacial/models/server.dart';

// The global provider to declare the selected Mastodon server and access token
final currentServerProvider = StateProvider<ServerSchema?>((ref) => null);
final currentAccessTokenProvider = StateProvider<String?>((ref) => null);

// vim: set ts=2 sw=2 sts=2 et:
