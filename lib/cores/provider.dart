// The shared provider for the Glacial application.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/features/glacial/models/server.dart';
import 'package:glacial/features/timeline/models/core.dart';

// The global state to access resource crossing the modules
final navigatorKey = GlobalKey<NavigatorState>();

// The global provider to declare the selected Mastodon server and access token
final currentServerProvider = StateProvider<ServerSchema?>((ref) => null);
final currentAccessTokenProvider = StateProvider<String?>((ref) => null);
final currentUserProvider = StateProvider<AccountSchema?>((ref) => null);

// vim: set ts=2 sw=2 sts=2 et:
