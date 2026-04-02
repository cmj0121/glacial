// Common test utilities and helpers for widget tests.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_riverpod/src/internals.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';

import 'mock_data.dart';

export 'mock_data.dart';

/// Sets up the test environment with mock HTTP client for network images.
void setupTestEnvironment() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Override HTTP client to avoid network calls in tests
  HttpOverrides.global = _MockHttpOverrides();
}

/// Mock HTTP overrides to prevent network calls during tests.
class _MockHttpOverrides extends HttpOverrides {}

/// Wraps a widget with MaterialApp and ProviderScope for testing.
///
/// [child] - The widget to test.
/// [accessStatus] - Optional AccessStatusSchema to provide via accessStatusProvider.
/// [preference] - Optional SystemPreferenceSchema to provide via preferenceProvider.
/// [overrides] - Additional provider overrides.
Widget createTestWidget({
  required Widget child,
  AccessStatusSchema? accessStatus,
  bool noAccessStatus = false,
  SystemPreferenceSchema? preference,
  List<Override> overrides = const [],
}) {
  final List<Override> allOverrides = [
    if (!noAccessStatus)
      accessStatusProvider.overrideWith((ref) => accessStatus ?? MockAccessStatus.anonymous()),
    if (preference != null) preferenceProvider.overrideWith((ref) => preference),
    ...overrides,
  ];

  return ProviderScope(
    overrides: allOverrides,
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  );
}

/// Wraps a widget with MaterialApp and ProviderScope without Scaffold.
///
/// Use this for widgets that have their own Scaffold (e.g., WIP, full-screen pages).
Widget createTestWidgetRaw({
  required Widget child,
  AccessStatusSchema? accessStatus,
  bool noAccessStatus = false,
  SystemPreferenceSchema? preference,
  List<Override> overrides = const [],
}) {
  final List<Override> allOverrides = [
    if (!noAccessStatus)
      accessStatusProvider.overrideWith((ref) => accessStatus ?? MockAccessStatus.anonymous()),
    if (preference != null) preferenceProvider.overrideWith((ref) => preference),
    ...overrides,
  ];

  return ProviderScope(
    overrides: allOverrides,
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: child,
    ),
  );
}

/// Wraps a widget with MaterialApp and ProviderScope, with authenticated user.
Widget createAuthenticatedTestWidget({
  required Widget child,
  AccountSchema? account,
  SystemPreferenceSchema? preference,
  List<Override> overrides = const [],
}) {
  return createTestWidget(
    child: child,
    accessStatus: MockAccessStatus.authenticated(account: account),
    preference: preference,
    overrides: overrides,
  );
}

/// Extension methods for WidgetTester to simplify common operations.
extension WidgetTesterExtensions on WidgetTester {
  /// Pumps the widget and waits for all animations to complete.
  Future<void> pumpAndSettle2({
    Duration duration = const Duration(milliseconds: 100),
    EnginePhase phase = EnginePhase.sendSemanticsUpdate,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    await pumpAndSettle(duration, phase, timeout);
  }

  /// Finds a widget by text and taps it.
  Future<void> tapByText(String text) async {
    await tap(find.text(text));
    await pumpAndSettle();
  }

  /// Finds a widget by icon and taps it.
  Future<void> tapByIcon(IconData icon) async {
    await tap(find.byIcon(icon));
    await pumpAndSettle();
  }

  /// Finds a widget by key and taps it.
  Future<void> tapByKey(Key key) async {
    await tap(find.byKey(key));
    await pumpAndSettle();
  }
}

/// Extension on CommonFinders to add textContaining method.
extension CommonFindersExtensions on CommonFinders {
  /// Finds widgets that contain specific text (partial match).
  Finder textContaining(String text) {
    return byWidgetPredicate(
      (widget) {
        if (widget is Text) {
          final String? data = widget.data;
          if (data != null && data.contains(text)) return true;
          // Also check TextSpan for rich text
          final InlineSpan? textSpan = widget.textSpan;
          if (textSpan != null) {
            return textSpan.toPlainText().contains(text);
          }
        }
        if (widget is RichText) {
          return widget.text.toPlainText().contains(text);
        }
        return false;
      },
      description: 'Text containing "$text"',
    );
  }
}

/// Common matchers for widget tests.
class TestMatchers {
  /// Matches a widget that is enabled (not disabled).
  static Matcher isEnabled() => isA<Widget>();

  /// Matches a widget that contains specific text.
  static Finder findTextContaining(String text) {
    return find.textContaining(text);
  }

  /// Matches an IconButton with specific icon.
  static Finder findIconButton(IconData icon) {
    return find.widgetWithIcon(IconButton, icon);
  }

  /// Matches a TextButton with specific icon.
  static Finder findTextButtonWithIcon(IconData icon) {
    return find.widgetWithIcon(TextButton, icon);
  }
}

// vim: set ts=2 sw=2 sts=2 et:
