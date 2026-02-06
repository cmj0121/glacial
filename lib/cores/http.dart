// The wrapper of the HTTP request and add the extra headers
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;
import 'package:mime/mime.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:glacial/core.dart';

/// Default timeout duration for HTTP requests.
const Duration defaultTimeout = Duration(seconds: 30);

/// Exception thrown when an HTTP request fails with a non-successful status code.
class HttpException implements Exception {
  final int statusCode;
  final String message;
  final String? body;
  final Uri uri;

  HttpException({
    required this.statusCode,
    required this.message,
    required this.uri,
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
class HttpTimeoutException implements Exception {
  final Uri uri;
  final Duration timeout;

  HttpTimeoutException({required this.uri, required this.timeout});

  @override
  String toString() => 'HttpTimeoutException: Request to ${uri.path} timed out after ${timeout.inSeconds}s';
}

/// Exception thrown when rate limited by the server.
class RateLimitException implements Exception {
  final Uri uri;
  final int limit;
  final int remaining;
  final DateTime resetAt;
  final Duration retryAfter;

  RateLimitException({
    required this.uri,
    required this.limit,
    required this.remaining,
    required this.resetAt,
    required this.retryAfter,
  });

  @override
  String toString() => 'RateLimitException: Rate limited on ${uri.path}, retry after ${retryAfter.inSeconds}s';
}

/// Configuration for HTTP retry behavior.
class RetryConfig {
  final int maxRetries;
  final Duration baseDelay;
  final double backoffMultiplier;

  const RetryConfig({
    this.maxRetries = 3,
    this.baseDelay = const Duration(seconds: 1),
    this.backoffMultiplier = 2.0,
  });

  static const RetryConfig defaultConfig = RetryConfig();

  Duration getDelay(int attempt) {
    final int multiplier = (backoffMultiplier * attempt).round();
    return baseDelay * multiplier;
  }
}

/// Parse rate limit headers from response.
RateLimitException? _parseRateLimitHeaders(http.Response response, Uri uri) {
  if (response.statusCode != 429) return null;

  final String? limitHeader = response.headers['x-ratelimit-limit'];
  final String? remainingHeader = response.headers['x-ratelimit-remaining'];
  final String? resetHeader = response.headers['x-ratelimit-reset'];
  final String? retryAfterHeader = response.headers['retry-after'];

  final int limit = int.tryParse(limitHeader ?? '') ?? 300;
  final int remaining = int.tryParse(remainingHeader ?? '') ?? 0;
  final DateTime resetAt = resetHeader != null
      ? DateTime.tryParse(resetHeader) ?? DateTime.now().add(const Duration(minutes: 5))
      : DateTime.now().add(const Duration(minutes: 5));
  final Duration retryAfter = retryAfterHeader != null
      ? Duration(seconds: int.tryParse(retryAfterHeader) ?? 60)
      : resetAt.difference(DateTime.now());

  return RateLimitException(
    uri: uri,
    limit: limit,
    remaining: remaining,
    resetAt: resetAt,
    retryAfter: retryAfter.isNegative ? const Duration(seconds: 60) : retryAfter,
  );
}

/// Execute an HTTP request with retry logic for transient failures.
Future<http.Response> withRetry(
  Future<http.Response> Function() request, {
  Uri? uri,
  RetryConfig config = RetryConfig.defaultConfig,
}) async {
  int attempt = 0;
  while (true) {
    try {
      return await request();
    } on HttpException catch (e) {
      // Only retry on server errors (5xx), not client errors (4xx)
      if (!e.isServerError || attempt >= config.maxRetries) {
        rethrow;
      }
      attempt++;
      final Duration delay = config.getDelay(attempt);
      logger.w("[HTTP] Retry $attempt/${config.maxRetries} after ${delay.inSeconds}s for ${e.uri.path}");
      await Future.delayed(delay);
    } on HttpTimeoutException {
      if (attempt >= config.maxRetries) rethrow;
      attempt++;
      final Duration delay = config.getDelay(attempt);
      logger.w("[HTTP] Retry $attempt/${config.maxRetries} after timeout");
      await Future.delayed(delay);
    } on SocketException {
      if (attempt >= config.maxRetries) rethrow;
      attempt++;
      final Duration delay = config.getDelay(attempt);
      logger.w("[HTTP] Retry $attempt/${config.maxRetries} after connection error");
      await Future.delayed(delay);
    }
  }
}

/// Validate HTTP response and throw HttpException for error status codes.
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

// Specify the user agent for the HTTP request and add the package name
// and version to the user agent string.
String get userAgent {
  final PackageInfo? info = Info().info;

  if (info != null ){
    return '${info.appName}/${info.version}';
  }

  return 'Glacial/0.1.0';
}

// The wrapper of the HTTP request and add the package info as the user agent
Future<http.Response> get(Uri url, {Map<String, String>? headers, bool validateStatus = true, Duration? timeout}) async {
  final PackageInfo? info = Info().info;
  final Duration effectiveTimeout = timeout ?? defaultTimeout;

  if (info != null ){
    headers = headers ?? <String, String>{};
    headers['User-Agent'] = userAgent;
    headers['Content-Type'] = 'application/json; charset=UTF-8';
  }

  logger.d("[GET] $url");
  try {
    final response = await http.get(url, headers: headers).timeout(effectiveTimeout);
    return validateStatus ? _validateResponse(response, url) : response;
  } on TimeoutException {
    throw HttpTimeoutException(uri: url, timeout: effectiveTimeout);
  }
}

// The wrapper of the HTTP request and add the package info as the user agent
Future<http.Response> post(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding, bool validateStatus = true, Duration? timeout}) async {
  final PackageInfo? info = Info().info;
  final Duration effectiveTimeout = timeout ?? defaultTimeout;

  if (info != null ){
    headers = headers ?? <String, String>{};
    headers['User-Agent'] = userAgent;
    headers['Content-Type'] = 'application/json; charset=UTF-8';
  }

  logger.d("[POST] $url");
  try {
    final response = await http.post(url, headers: headers, body: body, encoding: encoding).timeout(effectiveTimeout);
    return validateStatus ? _validateResponse(response, url) : response;
  } on TimeoutException {
    throw HttpTimeoutException(uri: url, timeout: effectiveTimeout);
  }
}

// The wrapper of the HTTP request and add the package info as the user agent
Future<http.Response> put(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding, bool validateStatus = true, Duration? timeout}) async {
  final PackageInfo? info = Info().info;
  final Duration effectiveTimeout = timeout ?? defaultTimeout;

  if (info != null ){
    headers = headers ?? <String, String>{};
    headers['User-Agent'] = userAgent;
    headers['Content-Type'] = 'application/json; charset=UTF-8';
  }

  logger.d("[PUT] $url");
  try {
    final response = await http.put(url, headers: headers, body: body, encoding: encoding).timeout(effectiveTimeout);
    return validateStatus ? _validateResponse(response, url) : response;
  } on TimeoutException {
    throw HttpTimeoutException(uri: url, timeout: effectiveTimeout);
  }
}

// The wrapper of the HTTP request and add the package info as the user agent
Future<http.Response> patch(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding, bool validateStatus = true, Duration? timeout}) async {
  final PackageInfo? info = Info().info;
  final Duration effectiveTimeout = timeout ?? defaultTimeout;

  if (info != null){
    headers = headers ?? <String, String>{};
    headers['User-Agent'] = userAgent;
    headers['Content-Type'] = 'application/json; charset=UTF-8';
  }

  logger.d("[PATCH] $url");
  try {
    final response = await http.patch(url, headers: headers, body: body, encoding: encoding).timeout(effectiveTimeout);
    return validateStatus ? _validateResponse(response, url) : response;
  } on TimeoutException {
    throw HttpTimeoutException(uri: url, timeout: effectiveTimeout);
  }
}

// The wrapper of the HTTP request and add the package info as the user agent
Future<http.Response> delete(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding, bool validateStatus = true, Duration? timeout}) async {
  final PackageInfo? info = Info().info;
  final Duration effectiveTimeout = timeout ?? defaultTimeout;

  if (info != null ){
    headers = headers ?? <String, String>{};
    headers['User-Agent'] = userAgent;
    headers['Content-Type'] = 'application/json; charset=UTF-8';
  }

  logger.d("[DELETE] $url");
  try {
    final response = await http.delete(url, headers: headers, body: body, encoding: encoding).timeout(effectiveTimeout);
    return validateStatus ? _validateResponse(response, url) : response;
  } on TimeoutException {
    throw HttpTimeoutException(uri: url, timeout: effectiveTimeout);
  }
}

// The wrapper for the multipart request, which is used to upload files with customized method.
Future<http.Response> multiparts(Uri url, {
  required String method,
  required Map<String, File> files,
  Map<String, dynamic>? json,
  Map<String, String>? headers,
  Encoding? encoding,
  bool validateStatus = true,
  Duration? timeout,
}) async {
  final Duration effectiveTimeout = timeout ?? defaultTimeout;
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

  final request = http.MultipartRequest(method.toUpperCase(), url)
    ..headers.addAll(headers ?? {})
    ..fields.addAll((json ?? {}).map((key, value) => MapEntry(key, value.toString())))
    ..files.addAll(multipartFiles);

  logger.d("[RAW] sending ${request.method} request to $url with multipart files");
  try {
    final http.StreamedResponse response = await request.send().timeout(effectiveTimeout);
    final String body = await response.stream.bytesToString();

    final httpResponse = http.Response(body, response.statusCode, headers: response.headers);
    return validateStatus ? _validateResponse(httpResponse, url) : httpResponse;
  } on TimeoutException {
    throw HttpTimeoutException(uri: url, timeout: effectiveTimeout);
  }
}

// Handle the protocol based on the URL scheme, using HTTP if the host is localhost
class UriEx {
  static Uri handle(String authority, [String? unencodedPath, Map<String, dynamic>? queryParameters ]) {
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
