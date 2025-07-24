// The entry point of the app that initializes the environment and starts the app.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'package:glacial/app.dart';
import 'package:glacial/core.dart';

void main() async {
  await prologue();
  final String? sentryDsn = dotenv.env['SENTRY_DSN'];

  switch (sentryDsn) {
    case null:
    case '':
      logger.i("Sentry DSN is not set, Sentry will not be initialized.");
      start();
      break;
    default:
      logger.i("Sentry DSN is set, initializing Sentry...");
      await SentryFlutter.init(
        (options) {
          options.dsn = sentryDsn;
          options.tracesSampleRate = 0.1;
          options.environment = kReleaseMode ? 'production' : 'development';
        },
        appRunner: start,
      );
      break;
  }
}

// The function that runs before the app starts.
Future<void> prologue() async {
  FlutterError.onError = (FlutterErrorDetails details) {
    // Handle Flutter errors globally
    final String stack = details.stack?.toString() ?? "No stack trace available";
    logger.e("Flutter Error: ${details.exceptionAsString()}\n$stack");
  };

  await dotenv.load(fileName: ".env");
  await Info.init();

  logger.d("completely preloaded system-wise settings ...");
}

// The entry point of the app that starts the Flutter application.
void start() {
  runApp(
    // Adding ProviderScope enables Riverpod for the entire project
    const ProviderScope(child: CoreApp()),
  );
}

// vim: set ts=2 sw=2 sts=2 et:
