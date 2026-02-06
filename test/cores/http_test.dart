import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/cores/http.dart';

void main() {
  group('HttpException', () {
    test('creates exception with required fields', () {
      final exception = HttpException(
        statusCode: 404,
        message: 'Not Found',
        uri: Uri.parse('https://example.com/api/test'),
      );

      expect(exception.statusCode, 404);
      expect(exception.message, 'Not Found');
      expect(exception.uri.path, '/api/test');
      expect(exception.body, isNull);
    });

    test('creates exception with optional body', () {
      final exception = HttpException(
        statusCode: 400,
        message: 'Bad Request',
        uri: Uri.parse('https://example.com/api/test'),
        body: '{"error": "Invalid input"}',
      );

      expect(exception.body, '{"error": "Invalid input"}');
    });

    test('isClientError returns true for 4xx codes', () {
      expect(
        HttpException(statusCode: 400, message: '', uri: Uri.parse('http://x')).isClientError,
        isTrue,
      );
      expect(
        HttpException(statusCode: 404, message: '', uri: Uri.parse('http://x')).isClientError,
        isTrue,
      );
      expect(
        HttpException(statusCode: 499, message: '', uri: Uri.parse('http://x')).isClientError,
        isTrue,
      );
      expect(
        HttpException(statusCode: 500, message: '', uri: Uri.parse('http://x')).isClientError,
        isFalse,
      );
    });

    test('isServerError returns true for 5xx codes', () {
      expect(
        HttpException(statusCode: 500, message: '', uri: Uri.parse('http://x')).isServerError,
        isTrue,
      );
      expect(
        HttpException(statusCode: 503, message: '', uri: Uri.parse('http://x')).isServerError,
        isTrue,
      );
      expect(
        HttpException(statusCode: 400, message: '', uri: Uri.parse('http://x')).isServerError,
        isFalse,
      );
    });

    test('isUnauthorized returns true for 401', () {
      expect(
        HttpException(statusCode: 401, message: '', uri: Uri.parse('http://x')).isUnauthorized,
        isTrue,
      );
      expect(
        HttpException(statusCode: 403, message: '', uri: Uri.parse('http://x')).isUnauthorized,
        isFalse,
      );
    });

    test('isForbidden returns true for 403', () {
      expect(
        HttpException(statusCode: 403, message: '', uri: Uri.parse('http://x')).isForbidden,
        isTrue,
      );
      expect(
        HttpException(statusCode: 401, message: '', uri: Uri.parse('http://x')).isForbidden,
        isFalse,
      );
    });

    test('isNotFound returns true for 404', () {
      expect(
        HttpException(statusCode: 404, message: '', uri: Uri.parse('http://x')).isNotFound,
        isTrue,
      );
      expect(
        HttpException(statusCode: 400, message: '', uri: Uri.parse('http://x')).isNotFound,
        isFalse,
      );
    });

    test('isRateLimited returns true for 429', () {
      expect(
        HttpException(statusCode: 429, message: '', uri: Uri.parse('http://x')).isRateLimited,
        isTrue,
      );
      expect(
        HttpException(statusCode: 400, message: '', uri: Uri.parse('http://x')).isRateLimited,
        isFalse,
      );
    });

    test('toString provides useful message', () {
      final exception = HttpException(
        statusCode: 404,
        message: 'Not Found',
        uri: Uri.parse('https://example.com/api/test'),
      );

      expect(exception.toString(), 'HttpException: 404 Not Found (/api/test)');
    });
  });

  group('UriEx', () {
    test('creates https URI for non-localhost', () {
      final uri = UriEx.handle('example.com', '/api/test');

      expect(uri.scheme, 'https');
      expect(uri.host, 'example.com');
      expect(uri.path, '/api/test');
    });

    test('creates http URI for localhost', () {
      final uri = UriEx.handle('localhost:3000', '/api/test');

      expect(uri.scheme, 'http');
      expect(uri.host, 'localhost');
      expect(uri.port, 3000);
      expect(uri.path, '/api/test');
    });

    test('handles query parameters', () {
      final uri = UriEx.handle('example.com', '/api/test', {'key': 'value'});

      expect(uri.queryParameters['key'], 'value');
    });

    test('handles null path', () {
      final uri = UriEx.handle('example.com');

      expect(uri.path, '');
    });
  });

  group('HttpTimeoutException', () {
    test('creates exception with uri and timeout', () {
      final exception = HttpTimeoutException(
        uri: Uri.parse('https://example.com/api/test'),
        timeout: const Duration(seconds: 30),
      );

      expect(exception.uri.path, '/api/test');
      expect(exception.timeout.inSeconds, 30);
    });

    test('toString provides useful message', () {
      final exception = HttpTimeoutException(
        uri: Uri.parse('https://example.com/api/test'),
        timeout: const Duration(seconds: 30),
      );

      expect(exception.toString(), contains('timed out'));
      expect(exception.toString(), contains('30s'));
    });
  });

  group('RateLimitException', () {
    test('creates exception with all fields', () {
      final resetAt = DateTime.now().add(const Duration(minutes: 5));
      final exception = RateLimitException(
        uri: Uri.parse('https://example.com/api/test'),
        limit: 300,
        remaining: 0,
        resetAt: resetAt,
        retryAfter: const Duration(seconds: 60),
      );

      expect(exception.uri.path, '/api/test');
      expect(exception.limit, 300);
      expect(exception.remaining, 0);
      expect(exception.resetAt, resetAt);
      expect(exception.retryAfter.inSeconds, 60);
    });

    test('toString provides useful message', () {
      final exception = RateLimitException(
        uri: Uri.parse('https://example.com/api/test'),
        limit: 300,
        remaining: 0,
        resetAt: DateTime.now(),
        retryAfter: const Duration(seconds: 60),
      );

      expect(exception.toString(), contains('Rate limited'));
      expect(exception.toString(), contains('60s'));
    });
  });

  group('RetryConfig', () {
    test('default config has expected values', () {
      const config = RetryConfig.defaultConfig;

      expect(config.maxRetries, 3);
      expect(config.baseDelay.inSeconds, 1);
      expect(config.backoffMultiplier, 2.0);
    });

    test('getDelay returns exponential backoff', () {
      const config = RetryConfig(
        baseDelay: Duration(seconds: 1),
        backoffMultiplier: 2.0,
      );

      expect(config.getDelay(1).inSeconds, 2);
      expect(config.getDelay(2).inSeconds, 4);
      expect(config.getDelay(3).inSeconds, 6);
    });

    test('custom config overrides defaults', () {
      const config = RetryConfig(
        maxRetries: 5,
        baseDelay: Duration(milliseconds: 500),
        backoffMultiplier: 1.5,
      );

      expect(config.maxRetries, 5);
      expect(config.baseDelay.inMilliseconds, 500);
      expect(config.backoffMultiplier, 1.5);
    });
  });

  group('defaultTimeout', () {
    test('is 30 seconds', () {
      expect(defaultTimeout.inSeconds, 30);
    });
  });
}
