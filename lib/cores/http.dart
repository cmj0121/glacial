// The warpper of the HTTP request and add the extra headers
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import 'package:glacial/core.dart';

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
Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
  final PackageInfo? info = Info().info;

  if (info != null ){
    headers = headers ?? <String, String>{};
    headers['User-Agent'] = userAgent;
  }

  return http.get(url, headers: headers);
}

// The wrapper of the HTTP request and add the package info as the user agent
Future<http.Response> post(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
  final PackageInfo? info = Info().info;

  if (info != null ){
    headers = headers ?? <String, String>{};
    headers['User-Agent'] = userAgent;
  }

  return http.post(url, headers: headers, body: body, encoding: encoding);
}

// The wrapper of the HTTP request and add the package info as the user agent
Future<http.Response> delete(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
  final PackageInfo? info = Info().info;

  if (info != null ){
    headers = headers ?? <String, String>{};
    headers['User-Agent'] = userAgent;
  }

  return http.delete(url, headers: headers, body: body, encoding: encoding);
}

// vim: set ts=2 sw=2 sts=2 et:
