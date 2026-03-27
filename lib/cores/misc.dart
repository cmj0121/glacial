// The miscellaneous utilities and constants for the Glacial app.
import 'dart:async';

import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

const double iconSize = 32.0; // The default icon size used in the app.
const double tabSize = 24.0; // The default tab size used in the app.

// The logger instance.
final Logger logger = Logger(
  printer: PrettyPrinter(
    colors: false, // Disable color for better compatibility with some terminals
    printEmojis: false, // Disable emojis for better readability
  ),
);

// The system-wide package info.
class Info {
  static PackageInfo? _packageInfo;

  static Future<void> init() async {
    _packageInfo = await PackageInfo.fromPlatform();
  }

  PackageInfo? get info => _packageInfo;
}

// The debounce helper to delay the function call and avoid triggering
// multiple times.
class Debouncer {
  final Duration duration;
  Timer? _timer;
  bool _locked = false;

  Debouncer({this.duration = const Duration(milliseconds: 250)});

  // Only call the action once after the time duration has passed.
  void call(Function() action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  // Only call the action once when it called, and lock the action
  // until the duration has passed.
  void callOnce(Function() action) {
    if (_locked) return;

    action();
    _locked = true;

    _timer = Timer(duration, () => _locked = false);
  }

  void cancel() {
    _timer?.cancel();
  }
}

// Show a snackbar with the given message and duration.
Future<void> showSnackbar(BuildContext context, String message, {
  Duration duration = const Duration(seconds: 2),
  TextStyle? textStyle,
}) async {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message, style: textStyle), duration: duration),
  );
}

// Send the local notification with the given title and body.
Future<void> sendLocalNotification(String title, String body, {int? uid, int? badgeNumber, String? payload}) async {
  final DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails();
  final NotificationDetails platformChannelSpecifics = NotificationDetails(
    iOS: darwinNotificationDetails,
    macOS: darwinNotificationDetails,
  );

  await flutterLocalNotificationsPlugin.show(id: uid ?? 0, title: title, body: body, notificationDetails: platformChannelSpecifics, payload: payload);
  AppBadgePlus.updateBadge(badgeNumber ?? 0);
}

// Get the timeago short locale string for the current context.
// Maps Flutter locale to the registered timeago short locale key.
String timeagoLocale(BuildContext context) {
  final String code = Localizations.localeOf(context).languageCode;
  const Map<String, String> localeMap = {
    'en': 'en_short',
    'de': 'de_short',
    'es': 'es_short',
    'fr': 'fr_short',
    'ja': 'ja',
    'ko': 'ko',
    'pt': 'pt_br_short',
    'zh': 'zh',
  };
  return localeMap[code] ?? 'en_short';
}

// Canonicalize the HTML content into the plain text content.
String canonicalizeHtml(String html) {
  // Remove HTML tags and decode HTML entities.
  final RegExp htmlTagRegExp = RegExp(r'<[^>]*>', multiLine: true);
  final String plainText = html.replaceAll(htmlTagRegExp, '').replaceAll('&nbsp;', ' ');
  return plainText.trim();
}

// vim: set ts=2 sw=2 sts=2 et:
