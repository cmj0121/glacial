// The wrapper of the HTTP request and add the extra headers
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;
import 'package:mime/mime.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:glacial/core.dart';

// ============================================================================
// Constants
// ============================================================================

/// Default timeout duration for HTTP requests.
const Duration defaultTimeout = Duration(seconds: 30);

/// Default rate limit when header is missing.
const int defaultRateLimit = 300;

/// Default retry-after duration when rate limited.
const Duration defaultRetryAfter = Duration(seconds: 60);

/// Default rate limit reset duration when header is missing.
const Duration defaultRateLimitReset = Duration(minutes: 5);

// ============================================================================
// Exception Classes
// ============================================================================

/// Base exception for all HTTP-related errors in Glacial.
abstract class GlacialHttpException implements Exception {
  final Uri uri;
  const GlacialHttpException({required this.uri});
}

/// Exception thrown when an HTTP request fails with a non-successful status code.
class HttpException extends GlacialHttpException {
  final int statusCode;
  final String message;
  final String? body;

  const HttpException({
    required this.statusCode,
    required this.message,
    required super.uri,
    this.body,
  });

  bool get isClientError => statusCode >= 400 && statusCode < 500;
  bool get isServerError => statusCode >= 500;
  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isRateLimited => statusCode == 429;

  @override
  String toString() => 'HttpException: $statusCode $message (${uri.path})';
}

/// Exception thrown when an HTTP request times out.
class HttpTimeoutException extends GlacialHttpException {
  final Duration timeout;

  const HttpTimeoutException({required super.uri, required this.timeout});

  @override
  String toString() => 'HttpTimeoutException: Request to ${uri.path} timed out after ${timeout.inSeconds}s';
}

/// Exception thrown when rate limited by the server.
class RateLimitException extends GlacialHttpException {
  final int limit;
  final int remaining;
  final DateTime resetAt;
  final Duration retryAfter;

  const RateLimitException({
    required super.uri,
    required this.limit,
    required this.remaining,
    required this.resetAt,
    required this.retryAfter,
  });

  @override
  String toString() => 'RateLimitException: Rate limited on ${uri.path}, retry after ${retryAfter.inSeconds}s';
}

// ============================================================================
// Retry Configuration
// ============================================================================

/// Configuration for HTTP retry behavior with exponential backoff and jitter.
class RetryConfig {
  final int maxRetries;
  final Duration baseDelay;
  final double backoffMultiplier;
  final double jitterFactor;

  const RetryConfig({
    this.maxRetries = 3,
    this.baseDelay = const Duration(seconds: 1),
    this.backoffMultiplier = 2.0,
    this.jitterFactor = 0.1,
  });

  static const RetryConfig defaultConfig = RetryConfig();
  static const RetryConfig none = RetryConfig(maxRetries: 0);

  /// Calculate delay with exponential backoff and jitter.
  /// Formula: baseDelay * (multiplier ^ attempt) * (1 + random jitter)
  Duration getDelay(int attempt) {
    final double exponentialFactor = pow(backoffMultiplier, attempt).toDouble();
    final int baseMs = (baseDelay.inMilliseconds * exponentialFactor).round();

    // Add jitter: random value between -jitterFactor and +jitterFactor
    final Random random = Random();
    final double jitter = 1.0 + (random.nextDouble() * 2 - 1) * jitterFactor;
    final int delayMs = (baseMs * jitter).round();

    return Duration(milliseconds: delayMs);
  }
}

// ============================================================================
// Internal Helpers
// ============================================================================

/// Parse rate limit headers from response.
RateLimitException? _parseRateLimitHeaders(http.Response response, Uri uri) {
  if (response.statusCode != 429) return null;

  final String? limitHeader = response.headers['x-ratelimit-limit'];
  final String? remainingHeader = response.headers['x-ratelimit-remaining'];
  final String? resetHeader = response.headers['x-ratelimit-reset'];
  final String? retryAfterHeader = response.headers['retry-after'];

  final int limit = int.tryParse(limitHeader ?? '') ?? defaultRateLimit;
  final int remaining = int.tryParse(remainingHeader ?? '') ?? 0;
  final DateTime resetAt = resetHeader != null
      ? DateTime.tryParse(resetHeader) ?? DateTime.now().add(defaultRateLimitReset)
      : DateTime.now().add(defaultRateLimitReset);
  final Duration retryAfter = retryAfterHeader != null
      ? Duration(seconds: int.tryParse(retryAfterHeader) ?? defaultRetryAfter.inSeconds)
      : resetAt.difference(DateTime.now());

  return RateLimitException(
    uri: uri,
    limit: limit,
    remaining: remaining,
    resetAt: resetAt,
    retryAfter: retryAfter.isNegative ? defaultRetryAfter : retryAfter,
  );
}

/// Validate HTTP response and throw appropriate exception for error status codes.
http.Response _validateResponse(http.Response response, Uri uri) {
  if (response.statusCode >= 400) {
    // Check for rate limiting first
    final RateLimitException? rateLimitError = _parseRateLimitHeaders(response, uri);
    if (rateLimitError != null) {
      logger.w("[HTTP] Rate limited - ${uri.path}, retry after ${rateLimitError.retryAfter.inSeconds}s");
      throw rateLimitError;
    }

    logger.e("[HTTP] ${response.statusCode} ${response.reasonPhrase} - ${uri.path}");
    throw HttpException(
      statusCode: response.statusCode,
      message: response.reasonPhrase ?? 'Unknown error',
      uri: uri,
      body: response.body,
    );
  }
  return response;
}

/// Prepare headers with User-Agent and Content-Type.
Map<String, String> _prepareHeaders(Map<String, String>? headers) {
  final Map<String, String> result = Map<String, String>.from(headers ?? {});
  result['User-Agent'] = userAgent;
  result['Content-Type'] = 'application/json; charset=UTF-8';
  return result;
}

/// Execute an HTTP request with optional retry logic.
Future<http.Response> _executeWithRetry({
  required Future<http.Response> Function() request,
  required Uri uri,
  required Duration timeout,
  required bool validateStatus,
  RetryConfig? retry,
}) async {
  final RetryConfig config = retry ?? RetryConfig.none;

  int attempt = 0;
  while (true) {
    try {
      final response = await request().timeout(timeout);
      return validateStatus ? _validateResponse(response, uri) : response;
    } on TimeoutException {
      if (attempt >= config.maxRetries) {
        throw HttpTimeoutException(uri: uri, timeout: timeout);
      }
      attempt++;
      final Duration delay = config.getDelay(attempt);
      logger.w("[HTTP] Retry $attempt/${config.maxRetries} after timeout on ${uri.path}");
      await Future.delayed(delay);
    } on HttpException catch (e) {
      // Only retry on server errors (5xx), not client errors (4xx)
      if (!e.isServerError || attempt >= config.maxRetries) {
        rethrow;
      }
      attempt++;
      final Duration delay = config.getDelay(attempt);
      logger.w("[HTTP] Retry $attempt/${config.maxRetries} after ${e.statusCode} on ${uri.path}");
      await Future.delayed(delay);
    } on RateLimitException catch (e) {
      if (attempt >= config.maxRetries) rethrow;
      attempt++;
      // Use the server-provided retry-after duration
      final Duration delay = e.retryAfter;
      logger.w("[HTTP] Retry $attempt/${config.maxRetries} after rate limit, waiting ${delay.inSeconds}s");
      await Future.delayed(delay);
    } on SocketException {
      if (attempt >= config.maxRetries) rethrow;
      attempt++;
      final Duration delay = config.getDelay(attempt);
      logger.w("[HTTP] Retry $attempt/${config.maxRetries} after connection error on ${uri.path}");
      await Future.delayed(delay);
    }
  }
}

// ============================================================================
// Public API
// ============================================================================

/// Get the user agent string for HTTP requests.
String get userAgent {
  final PackageInfo? info = Info().info;
  if (info != null) {
    return '${info.appName}/${info.version}';
  }
  return 'Glacial/0.1.0';
}

/// HTTP GET request with optional retry support.
Future<http.Response> get(
  Uri url, {
  Map<String, String>? headers,
  bool validateStatus = true,
  Duration? timeout,
  RetryConfig? retry,
}) async {
  final Duration effectiveTimeout = timeout ?? defaultTimeout;
  final Map<String, String> preparedHeaders = _prepareHeaders(headers);

  logger.d("[GET] $url");
  return _executeWithRetry(
    request: () => http.get(url, headers: preparedHeaders),
    uri: url,
    timeout: effectiveTimeout,
    validateStatus: validateStatus,
    retry: retry,
  );
}

/// HTTP POST request with optional retry support.
Future<http.Response> post(
  Uri url, {
  Map<String, String>? headers,
  Object? body,
  Encoding? encoding,
  bool validateStatus = true,
  Duration? timeout,
  RetryConfig? retry,
}) async {
  final Duration effectiveTimeout = timeout ?? defaultTimeout;
  final Map<String, String> preparedHeaders = _prepareHeaders(headers);

  logger.d("[POST] $url");
  return _executeWithRetry(
    request: () => http.post(url, headers: preparedHeaders, body: body, encoding: encoding),
    uri: url,
    timeout: effectiveTimeout,
    validateStatus: validateStatus,
    retry: retry,
  );
}

/// HTTP PUT request with optional retry support.
Future<http.Response> put(
  Uri url, {
  Map<String, String>? headers,
  Object? body,
  Encoding? encoding,
  bool validateStatus = true,
  Duration? timeout,
  RetryConfig? retry,
}) async {
  final Duration effectiveTimeout = timeout ?? defaultTimeout;
  final Map<String, String> preparedHeaders = _prepareHeaders(headers);

  logger.d("[PUT] $url");
  return _executeWithRetry(
    request: () => http.put(url, headers: preparedHeaders, body: body, encoding: encoding),
    uri: url,
    timeout: effectiveTimeout,
    validateStatus: validateStatus,
    retry: retry,
  );
}

/// HTTP PATCH request with optional retry support.
Future<http.Response> patch(
  Uri url, {
  Map<String, String>? headers,
  Object? body,
  Encoding? encoding,
  bool validateStatus = true,
  Duration? timeout,
  RetryConfig? retry,
}) async {
  final Duration effectiveTimeout = timeout ?? defaultTimeout;
  final Map<String, String> preparedHeaders = _prepareHeaders(headers);

  logger.d("[PATCH] $url");
  return _executeWithRetry(
    request: () => http.patch(url, headers: preparedHeaders, body: body, encoding: encoding),
    uri: url,
    timeout: effectiveTimeout,
    validateStatus: validateStatus,
    retry: retry,
  );
}

/// HTTP DELETE request with optional retry support.
Future<http.Response> delete(
  Uri url, {
  Map<String, String>? headers,
  Object? body,
  Encoding? encoding,
  bool validateStatus = true,
  Duration? timeout,
  RetryConfig? retry,
}) async {
  final Duration effectiveTimeout = timeout ?? defaultTimeout;
  final Map<String, String> preparedHeaders = _prepareHeaders(headers);

  logger.d("[DELETE] $url");
  return _executeWithRetry(
    request: () => http.delete(url, headers: preparedHeaders, body: body, encoding: encoding),
    uri: url,
    timeout: effectiveTimeout,
    validateStatus: validateStatus,
    retry: retry,
  );
}

/// Multipart HTTP request for file uploads with optional retry support.
Future<http.Response> multiparts(
  Uri url, {
  required String method,
  required Map<String, File> files,
  Map<String, dynamic>? json,
  Map<String, String>? headers,
  Encoding? encoding,
  bool validateStatus = true,
  Duration? timeout,
  RetryConfig? retry,
}) async {
  final Duration effectiveTimeout = timeout ?? defaultTimeout;
  final Map<String, String> preparedHeaders = _prepareHeaders(headers);

  // Build multipart files
  final futures = files.entries.map((entry) async {
    final String name = entry.key;
    final String filepath = entry.value.path;
    final String mime = lookupMimeType(filepath) ?? "application/octet-stream";

    return await http.MultipartFile.fromPath(
      name,
      filepath,
      contentType: http_parser.MediaType.parse(mime),
    );
  }).toList();
  final List<http.MultipartFile> multipartFiles = await Future.wait(futures);

  logger.d("[${method.toUpperCase()}] $url (multipart)");

  return _executeWithRetry(
    request: () async {
      final request = http.MultipartRequest(method.toUpperCase(), url)
        ..headers.addAll(preparedHeaders)
        ..fields.addAll((json ?? {}).map((key, value) => MapEntry(key, value.toString())))
        ..files.addAll(multipartFiles);

      final http.StreamedResponse response = await request.send();
      final String body = await response.stream.bytesToString();
      return http.Response(body, response.statusCode, headers: response.headers);
    },
    uri: url,
    timeout: effectiveTimeout,
    validateStatus: validateStatus,
    retry: retry,
  );
}

// ============================================================================
// URI Utilities
// ============================================================================

/// Handle the protocol based on the URL scheme, using HTTP if the host is localhost.
class UriEx {
  static Uri handle(String authority, [String? unencodedPath, Map<String, dynamic>? queryParameters]) {
    final String path = unencodedPath ?? '';
    final bool isLocalhost = authority.startsWith('localhost');

    if (isLocalhost) {
      return Uri.http(authority, path, queryParameters);
    } else {
      return Uri.https(authority, path, queryParameters);
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
