// The wrapper of the HTTP request and add the extra headers
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;
import 'package:mime/mime.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:glacial/core.dart';

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

/// Validate HTTP response and throw HttpException for error status codes.
http.Response _validateResponse(http.Response response, Uri uri) {
  if (response.statusCode >= 400) {
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
Future<http.Response> get(Uri url, {Map<String, String>? headers, bool validateStatus = true}) async {
  final PackageInfo? info = Info().info;

  if (info != null ){
    headers = headers ?? <String, String>{};
    headers['User-Agent'] = userAgent;
    headers['Content-Type'] = 'application/json; charset=UTF-8';
  }

  logger.d("[GET] $url");
  final response = await http.get(url, headers: headers);
  return validateStatus ? _validateResponse(response, url) : response;
}

// The wrapper of the HTTP request and add the package info as the user agent
Future<http.Response> post(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding, bool validateStatus = true}) async {
  final PackageInfo? info = Info().info;

  if (info != null ){
    headers = headers ?? <String, String>{};
    headers['User-Agent'] = userAgent;
    headers['Content-Type'] = 'application/json; charset=UTF-8';
  }

  logger.d("[POST] $url");
  final response = await http.post(url, headers: headers, body: body, encoding: encoding);
  return validateStatus ? _validateResponse(response, url) : response;
}

// The wrapper of the HTTP request and add the package info as the user agent
Future<http.Response> put(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding, bool validateStatus = true}) async {
  final PackageInfo? info = Info().info;

  if (info != null ){
    headers = headers ?? <String, String>{};
    headers['User-Agent'] = userAgent;
    headers['Content-Type'] = 'application/json; charset=UTF-8';
  }

  logger.d("[PUT] $url");
  final response = await http.put(url, headers: headers, body: body, encoding: encoding);
  return validateStatus ? _validateResponse(response, url) : response;
}

// The wrapper of the HTTP request and add the package info as the user agent
Future<http.Response> patch(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding, bool validateStatus = true}) async {
  final PackageInfo? info = Info().info;

  if (info != null){
    headers = headers ?? <String, String>{};
    headers['User-Agent'] = userAgent;
    headers['Content-Type'] = 'application/json; charset=UTF-8';
  }

  logger.d("[PATCH] $url");
  final response = await http.patch(url, headers: headers, body: body, encoding: encoding);
  return validateStatus ? _validateResponse(response, url) : response;
}

// The wrapper of the HTTP request and add the package info as the user agent
Future<http.Response> delete(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding, bool validateStatus = true}) async {
  final PackageInfo? info = Info().info;

  if (info != null ){
    headers = headers ?? <String, String>{};
    headers['User-Agent'] = userAgent;
    headers['Content-Type'] = 'application/json; charset=UTF-8';
  }

  logger.d("[DELETE] $url");
  final response = await http.delete(url, headers: headers, body: body, encoding: encoding);
  return validateStatus ? _validateResponse(response, url) : response;
}

// The wrapper for the multipart request, which is used to upload files with customized method.
Future<http.Response> multiparts(Uri url, {
  required String method,
  required Map<String, File> files,
  Map<String, dynamic>? json,
  Map<String, String>? headers,
  Encoding? encoding,
  bool validateStatus = true,
}) async {
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
  final http.StreamedResponse response = await request.send();
  final String body = await response.stream.bytesToString();

  final httpResponse = http.Response(body, response.statusCode, headers: response.headers);
  return validateStatus ? _validateResponse(httpResponse, url) : httpResponse;
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
