// Tests for Debouncer and canonicalizeHtml utilities.
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
}

// vim: set ts=2 sw=2 sts=2 et:
