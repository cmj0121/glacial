// The entry point of the app that initializes the environment and starts the app.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'package:glacial/app.dart';
import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';

void main() async {
  // needed if you intend to initialize in the `main` function
  WidgetsFlutterBinding.ensureInitialized();

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
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  FlutterError.onError = (FlutterErrorDetails details) {
    // Handle Flutter errors globally
    final String stack = details.stack?.toString() ?? "No stack trace available";
    logger.e("Flutter Error: ${details.exceptionAsString()}\n$stack");
  };

  // Initialization settings for both iOS and macOS
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
  const DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings();

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
    macOS: initializationSettingsDarwin,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  await init();

  logger.d("completely preloaded system-wise settings ...");
}

// Initialize for the local services
Future<void> init() async {
  await dotenv.load(fileName: ".env");
  await Info.init();
  await Storage.init();
}


// The entry point of the app that starts the Flutter application.
void start() async {
  FlutterNativeSplash.remove();
  final SystemPreferenceSchema? schema = await Storage().loadPreference();

  runApp(
    // Adding ProviderScope enables Riverpod for the entire project
    ProviderScope(child: CoreApp(schema: schema)),
  );
}

// vim: set ts=2 sw=2 sts=2 et:
