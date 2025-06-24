// The entry point of the app that initializes the environment and starts the app.
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/app.dart';
import 'package:glacial/core.dart';

void main() async {
  FlutterError.onError = (FlutterErrorDetails details) {
    // Handle Flutter errors globally
    final String stack = details.stack?.toString() ?? "No stack trace available";
    logger.e("Flutter Error: ${details.exceptionAsString()}\n$stack");
  };

  await dotenv.load(fileName: ".env");
  await Info.init();
  await Storage.init(purge: false);

  logger.d("completely preloaded system-wise settings ...");
  runApp(
    // Adding ProviderScope enables Riverpod for the entire project
    const ProviderScope(child: GlacialApp()),
  );
}

// vim: set ts=2 sw=2 sts=2 et:
