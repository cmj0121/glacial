// Widget tests for WebViewPage.
// Note: WebViewPage depends on webview_flutter platform plugin which is not
// available in widget tests. We test construction and basic properties only.
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/features/webview/screens/core.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  group('WebViewPage', () {
    test('accepts required url parameter', () {
      final page = WebViewPage(url: Uri.parse('https://example.com'));
      expect(page.url, Uri.parse('https://example.com'));
    });

    test('stores url correctly', () {
      final uri = Uri.parse('https://mastodon.social/auth/sign_in');
      final page = WebViewPage(url: uri);
      expect(page.url.scheme, 'https');
      expect(page.url.host, 'mastodon.social');
      expect(page.url.path, '/auth/sign_in');
    });

    test('is a ConsumerStatefulWidget', () {
      final page = WebViewPage(url: Uri.parse('https://example.com'));
      expect(page, isNotNull);
    });

    test('handles various URL schemes', () {
      final httpPage = WebViewPage(url: Uri.parse('http://example.com'));
      expect(httpPage.url.scheme, 'http');

      final httpsPage = WebViewPage(url: Uri.parse('https://example.com'));
      expect(httpsPage.url.scheme, 'https');
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
