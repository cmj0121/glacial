// Tests for Debouncer, canonicalizeHtml, timeagoLocale, and showSnackbar utilities.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/core.dart';

void main() {
  group('Debouncer', () {
    test('call executes action after duration', () async {
      final debouncer = Debouncer(duration: const Duration(milliseconds: 50));
      int count = 0;
      debouncer.call(() => count++);
      expect(count, 0);
      await Future.delayed(const Duration(milliseconds: 100));
      expect(count, 1);
    });

    test('call cancels previous pending action', () async {
      final debouncer = Debouncer(duration: const Duration(milliseconds: 50));
      int count = 0;
      debouncer.call(() => count++);
      debouncer.call(() => count += 10);
      await Future.delayed(const Duration(milliseconds: 100));
      expect(count, 10);
    });

    test('callOnce executes immediately on first call', () {
      final debouncer = Debouncer(duration: const Duration(milliseconds: 200));
      int count = 0;
      debouncer.callOnce(() => count++);
      expect(count, 1);
    });

    test('callOnce ignores subsequent calls within duration', () {
      final debouncer = Debouncer(duration: const Duration(milliseconds: 200));
      int count = 0;
      debouncer.callOnce(() => count++);
      debouncer.callOnce(() => count++);
      debouncer.callOnce(() => count++);
      expect(count, 1);
    });

    test('callOnce allows new call after duration expires', () async {
      final debouncer = Debouncer(duration: const Duration(milliseconds: 50));
      int count = 0;
      debouncer.callOnce(() => count++);
      expect(count, 1);
      await Future.delayed(const Duration(milliseconds: 100));
      debouncer.callOnce(() => count++);
      expect(count, 2);
    });

    test('cancel stops pending action', () async {
      final debouncer = Debouncer(duration: const Duration(milliseconds: 50));
      int count = 0;
      debouncer.call(() => count++);
      debouncer.cancel();
      await Future.delayed(const Duration(milliseconds: 100));
      expect(count, 0);
    });

    test('default duration is 250ms', () {
      final debouncer = Debouncer();
      expect(debouncer.duration, const Duration(milliseconds: 250));
    });
  });

  group('canonicalizeHtml', () {
    test('strips HTML tags', () {
      expect(canonicalizeHtml('<p>Hello <strong>world</strong></p>'), 'Hello world');
    });

    test('replaces &nbsp; with space', () {
      expect(canonicalizeHtml('Hello&nbsp;world'), 'Hello world');
    });

    test('trims whitespace', () {
      expect(canonicalizeHtml('  <p>Hello</p>  '), 'Hello');
    });

    test('handles empty string', () {
      expect(canonicalizeHtml(''), '');
    });

    test('handles nested tags', () {
      expect(canonicalizeHtml('<div><p>Hello <em>world</em></p></div>'), 'Hello world');
    });
  });

  group('timeagoLocale', () {
    Widget buildLocaleApp(Locale locale, void Function(BuildContext) callback) {
      return MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: locale,
        home: Builder(builder: (context) {
          callback(context);
          return const SizedBox.shrink();
        }),
      );
    }

    testWidgets('returns en_short for English locale', (tester) async {
      late String result;
      await tester.pumpWidget(buildLocaleApp(const Locale('en'), (ctx) => result = timeagoLocale(ctx)));
      await tester.pumpAndSettle();
      expect(result, 'en_short');
    });

    testWidgets('returns ja for Japanese locale', (tester) async {
      late String result;
      await tester.pumpWidget(buildLocaleApp(const Locale('ja'), (ctx) => result = timeagoLocale(ctx)));
      await tester.pumpAndSettle();
      expect(result, 'ja');
    });

    testWidgets('returns ko for Korean locale', (tester) async {
      late String result;
      await tester.pumpWidget(buildLocaleApp(const Locale('ko'), (ctx) => result = timeagoLocale(ctx)));
      await tester.pumpAndSettle();
      expect(result, 'ko');
    });

    testWidgets('returns zh for Chinese locale', (tester) async {
      late String result;
      await tester.pumpWidget(buildLocaleApp(const Locale('zh'), (ctx) => result = timeagoLocale(ctx)));
      await tester.pumpAndSettle();
      expect(result, 'zh');
    });
  });

  group('showSnackbar', () {
    testWidgets('shows snackbar with message', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showSnackbar(context, 'Test message'),
              child: const Text('Show'),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Show'));
      await tester.pump();

      expect(find.text('Test message'), findsOneWidget);
    });
  });

  group('Info', () {
    test('info returns null before init', () {
      final info = Info();
      // Before init, _packageInfo is null
      expect(info.info, isNull);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
