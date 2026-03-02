// Unit tests for platform detection utilities.
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/cores/platform.dart';

void main() {
  setUp(() {
    platformOverride = null;
  });

  tearDown(() {
    platformOverride = null;
  });

  group('platformOverride', () {
    test('currentPlatform returns android when overridden', () {
      platformOverride = PlatformType.android;
      expect(currentPlatform, PlatformType.android);
    });

    test('currentPlatform returns other when overridden', () {
      platformOverride = PlatformType.other;
      expect(currentPlatform, PlatformType.other);
    });

    test('currentPlatform returns apple when overridden', () {
      platformOverride = PlatformType.apple;
      expect(currentPlatform, PlatformType.apple);
    });
  });

  group('useMaterial', () {
    test('useMaterial returns true for android', () {
      platformOverride = PlatformType.android;
      expect(useMaterial, isTrue);
    });

    test('useMaterial returns false for apple', () {
      platformOverride = PlatformType.apple;
      expect(useMaterial, isFalse);
    });

    test('useMaterial returns false for other', () {
      platformOverride = PlatformType.other;
      expect(useMaterial, isFalse);
    });
  });

  group('useLiquidGlass', () {
    test('useLiquidGlass returns true for apple', () {
      platformOverride = PlatformType.apple;
      expect(useLiquidGlass, isTrue);
    });

    test('useLiquidGlass returns false for android', () {
      platformOverride = PlatformType.android;
      expect(useLiquidGlass, isFalse);
    });

    test('useLiquidGlass returns false for other', () {
      platformOverride = PlatformType.other;
      expect(useLiquidGlass, isFalse);
    });
  });

  group('default (no override)', () {
    test('currentPlatform returns a valid PlatformType without override', () {
      platformOverride = null;
      expect(currentPlatform, isA<PlatformType>());
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
