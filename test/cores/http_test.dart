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
}
