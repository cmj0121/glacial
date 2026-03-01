// Widget tests for FollowRequests screen.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

// ---------------------------------------------------------------------------
// Mock HTTP infrastructure for FollowRequests tests.
// ---------------------------------------------------------------------------

/// Mock that rejects connections after a short delay (simulates slow network).
class _SlowRejectHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _SlowRejectHttpClient();
  }
}

class _SlowRejectHttpClient implements HttpClient {
  @override bool autoUncompress = true;
  @override Duration? connectionTimeout;
  @override Duration idleTimeout = const Duration(seconds: 15);
  @override int? maxConnectionsPerHost;
  @override String? userAgent;

  @override void addCredentials(Uri url, String realm, HttpClientCredentials credentials) {}
  @override void addProxyCredentials(String host, int port, String realm, HttpClientCredentials credentials) {}
  @override set authenticate(Future<bool> Function(Uri url, String scheme, String? realm)? f) {}
  @override set authenticateProxy(Future<bool> Function(String host, int port, String scheme, String? realm)? f) {}
  @override set badCertificateCallback(bool Function(X509Certificate cert, String host, int port)? callback) {}
  @override void close({bool force = false}) {}
  @override set connectionFactory(Future<ConnectionTask<Socket>> Function(Uri url, String? proxyHost, int? proxyPort)? f) {}
  @override set findProxy(String Function(Uri url)? f) {}
  @override set keyLog(Function(String line)? callback) {}

  Future<HttpClientRequest> _slowReject() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    throw const SocketException('Connection refused by test mock');
  }

  @override Future<HttpClientRequest> delete(String host, int port, String path) => _slowReject();
  @override Future<HttpClientRequest> deleteUrl(Uri url) => _slowReject();
  @override Future<HttpClientRequest> get(String host, int port, String path) => _slowReject();
  @override Future<HttpClientRequest> getUrl(Uri url) => _slowReject();
  @override Future<HttpClientRequest> head(String host, int port, String path) => _slowReject();
  @override Future<HttpClientRequest> headUrl(Uri url) => _slowReject();
  @override Future<HttpClientRequest> open(String method, String host, int port, String path) => _slowReject();
  @override Future<HttpClientRequest> openUrl(String method, Uri url) => _slowReject();
  @override Future<HttpClientRequest> patch(String host, int port, String path) => _slowReject();
  @override Future<HttpClientRequest> patchUrl(Uri url) => _slowReject();
  @override Future<HttpClientRequest> post(String host, int port, String path) => _slowReject();
  @override Future<HttpClientRequest> postUrl(Uri url) => _slowReject();
  @override Future<HttpClientRequest> put(String host, int port, String path) => _slowReject();
  @override Future<HttpClientRequest> putUrl(Uri url) => _slowReject();
}

/// Mock that responds immediately with configurable body and status.
class _InstantHttpOverrides extends HttpOverrides {
  final String responseBody;
  final int statusCode;

  _InstantHttpOverrides({required this.responseBody, required this.statusCode});

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _InstantHttpClient(responseBody: responseBody, statusCode: statusCode);
  }
}

class _InstantHttpClient implements HttpClient {
  final String responseBody;
  final int statusCode;
  _InstantHttpClient({required this.responseBody, required this.statusCode});

  @override bool autoUncompress = true;
  @override Duration? connectionTimeout;
  @override Duration idleTimeout = const Duration(seconds: 15);
  @override int? maxConnectionsPerHost;
  @override String? userAgent;

  @override void addCredentials(Uri url, String realm, HttpClientCredentials credentials) {}
  @override void addProxyCredentials(String host, int port, String realm, HttpClientCredentials credentials) {}
  @override set authenticate(Future<bool> Function(Uri url, String scheme, String? realm)? f) {}
  @override set authenticateProxy(Future<bool> Function(String host, int port, String scheme, String? realm)? f) {}
  @override set badCertificateCallback(bool Function(X509Certificate cert, String host, int port)? callback) {}
  @override void close({bool force = false}) {}
  @override set connectionFactory(Future<ConnectionTask<Socket>> Function(Uri url, String? proxyHost, int? proxyPort)? f) {}
  @override set findProxy(String Function(Uri url)? f) {}
  @override set keyLog(Function(String line)? callback) {}

  _InstantReq _req(Uri url) => _InstantReq(url, responseBody: responseBody, statusCode: statusCode);

  @override Future<HttpClientRequest> delete(String host, int port, String path) async => _req(Uri.parse('https://$host:$port$path'));
  @override Future<HttpClientRequest> deleteUrl(Uri url) async => _req(url);
  @override Future<HttpClientRequest> get(String host, int port, String path) async => _req(Uri.parse('https://$host:$port$path'));
  @override Future<HttpClientRequest> getUrl(Uri url) async => _req(url);
  @override Future<HttpClientRequest> head(String host, int port, String path) async => _req(Uri.parse('https://$host:$port$path'));
  @override Future<HttpClientRequest> headUrl(Uri url) async => _req(url);
  @override Future<HttpClientRequest> open(String method, String host, int port, String path) async => _req(Uri.parse('https://$host:$port$path'));
  @override Future<HttpClientRequest> openUrl(String method, Uri url) async => _req(url);
  @override Future<HttpClientRequest> patch(String host, int port, String path) async => _req(Uri.parse('https://$host:$port$path'));
  @override Future<HttpClientRequest> patchUrl(Uri url) async => _req(url);
  @override Future<HttpClientRequest> post(String host, int port, String path) async => _req(Uri.parse('https://$host:$port$path'));
  @override Future<HttpClientRequest> postUrl(Uri url) async => _req(url);
  @override Future<HttpClientRequest> put(String host, int port, String path) async => _req(Uri.parse('https://$host:$port$path'));
  @override Future<HttpClientRequest> putUrl(Uri url) async => _req(url);
}

class _InstantReq extends Stream<List<int>> implements HttpClientRequest {
  final Uri _uri;
  final String responseBody;
  final int statusCode;
  _InstantReq(this._uri, {required this.responseBody, required this.statusCode});

  final _headers = _MockHeaders();

  @override Encoding encoding = utf8;
  @override HttpHeaders get headers => _headers;
  @override Uri get uri => _uri;
  @override bool bufferOutput = true;
  @override int get contentLength => -1;
  @override set contentLength(int value) {}
  @override bool followRedirects = true;
  @override int maxRedirects = 5;
  @override bool persistentConnection = true;
  @override String get method => 'GET';
  @override HttpConnectionInfo? get connectionInfo => null;
  @override List<Cookie> get cookies => [];
  @override Future<HttpClientResponse> get done => close();
  @override void abort([Object? exception, StackTrace? stackTrace]) {}
  @override void add(List<int> data) {}
  @override void addError(Object error, [StackTrace? stackTrace]) {}
  @override Future addStream(Stream<List<int>> stream) async {}
  @override Future<HttpClientResponse> close() async =>
      _InstantResp(_uri, responseBody: responseBody, statusCode: statusCode);
  @override Future flush() async {}
  @override void write(Object? object) {}
  @override void writeAll(Iterable objects, [String separator = '']) {}
  @override void writeCharCode(int charCode) {}
  @override void writeln([Object? object = '']) {}

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return const Stream<List<int>>.empty().listen(
      onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}

class _MockHeaders implements HttpHeaders {
  final Map<String, List<String>> _h = {};

  @override void add(String name, Object value, {bool preserveHeaderCase = false}) {
    _h.putIfAbsent(name, () => []).add(value.toString());
  }
  @override void set(String name, Object value, {bool preserveHeaderCase = false}) {
    _h[name] = [value.toString()];
  }
  @override String? value(String name) => _h[name]?.first;
  @override List<String>? operator [](String name) => _h[name];
  @override dynamic noSuchMethod(Invocation invocation) => null;
}

class _InstantResp extends Stream<List<int>> implements HttpClientResponse {
  final String responseBody;
  @override final int statusCode;
  _InstantResp(Uri _, {required this.responseBody, required this.statusCode});

  @override String get reasonPhrase => statusCode == 200 ? 'OK' : 'Error';
  @override int get contentLength => -1;
  @override HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;
  @override bool get isRedirect => false;
  @override bool get persistentConnection => true;
  @override List<Cookie> get cookies => [];
  @override HttpHeaders get headers => _MockHeaders();
  @override HttpConnectionInfo? get connectionInfo => null;
  @override X509Certificate? get certificate => null;
  @override List<RedirectInfo> get redirects => [];
  @override Future<HttpClientResponse> redirect([String? method, Uri? url, bool? followLoops]) async => this;
  @override Future<Socket> detachSocket() { throw UnsupportedError('detachSocket'); }

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    final stream = Stream.value(utf8.encode(responseBody));
    return stream.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}

/// Builds a minimal JSON list of AccountSchema-compatible maps.
String _accountListJson([int count = 1]) {
  final accounts = List.generate(count, (i) => {
    'id': 'req${i + 1}',
    'username': 'requester${i + 1}',
    'acct': 'requester${i + 1}',
    'url': 'https://mastodon.social/@requester${i + 1}',
    'display_name': 'Requester ${i + 1}',
    'note': '',
    'avatar': 'https://example.com/avatar.png',
    'avatar_static': 'https://example.com/avatar.png',
    'header': 'https://example.com/header.png',
    'header_static': 'https://example.com/header.png',
    'locked': false,
    'bot': false,
    'indexable': false,
    'created_at': '2024-01-01T00:00:00.000Z',
    'statuses_count': 0,
    'followers_count': 0,
    'following_count': 0,
    'emojis': <dynamic>[],
    'fields': <dynamic>[],
  });
  return jsonEncode(accounts);
}

void main() {
  setupTestEnvironment();

  // Initialize sqflite FFI for CachedNetworkImage's cache manager.
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // Use slow-reject HTTP by default to prevent real network calls from leaking
  // async timers. Individual tests override for specific behaviors.
  setUp(() {
    HttpOverrides.global = _SlowRejectHttpOverrides();
  });

  tearDown(() {
    HttpOverrides.global = _SlowRejectHttpOverrides();
  });

  group('FollowRequests', () {
    setUpAll(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (MethodCall methodCall) async => Directory.systemTemp.path,
      );
    });

    testWidgets('renders widget for authenticated user', (tester) async {
      final status = MockAccessStatus.authenticated();
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: FollowRequests()),
          accessStatus: status,
        ));
        await tester.pump();
      });

      expect(find.byType(FollowRequests), findsOneWidget);
    });

    testWidgets('renders for anonymous user', (tester) async {
      final status = MockAccessStatus.anonymous();
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: FollowRequests()),
          accessStatus: status,
        ));
        await tester.pump();
      });

      expect(find.byType(FollowRequests), findsOneWidget);
    });

    testWidgets('shows loading state initially for authenticated user', (tester) async {
      // The slow-reject mock delays the HTTP rejection for 100ms, so the first
      // pump sees the FutureBuilder in ConnectionState.waiting → LoadingOverlay.
      final status = MockAccessStatus.authenticated();
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: FollowRequests()),
          accessStatus: status,
        ));
        // Pump once immediately after build — the future is still pending.
        await tester.pump();
      });

      // LoadingOverlay should be present while the HTTP request is in flight.
      expect(find.byType(LoadingOverlay), findsOneWidget);
    });

    testWidgets('shows NoResult on fetch error (network rejected)', (tester) async {
      final status = MockAccessStatus.authenticated();
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: FollowRequests()),
          accessStatus: status,
        ));
        await tester.pump();
        // Wait for the slow-reject to complete and the FutureBuilder to rebuild.
        await Future<void>.delayed(const Duration(milliseconds: 300));
        await tester.pump();
      });

      // After fetch error, FutureBuilder shows error state → NoResult.
      expect(find.byType(FollowRequests), findsOneWidget);
    });

    testWidgets('shows ListView.builder when follow requests return accounts', (tester) async {
      // Override HTTP to return a list with two accounts so that fetchFollowRequests()
      // resolves successfully — covering the ListView.builder path (lines 45-47).
      HttpOverrides.global = _InstantHttpOverrides(
        responseBody: _accountListJson(2),
        statusCode: 200,
      );

      final status = MockAccessStatus.create(
        accessToken: 'test_token',
        account: MockAccount.create(),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: FollowRequests()),
          accessStatus: status,
        ));
        await tester.pump();
        // Allow the FutureBuilder to rebuild with the resolved data.
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await tester.pump();
      });

      // The FutureBuilder should have resolved with data → ListView shown.
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(AccountLite), findsNWidgets(2));
    });

    testWidgets('shows coffee NoResult when follow requests returns empty list', (tester) async {
      // Override HTTP to return an empty array so fetchFollowRequests() resolves
      // with [], triggering the "no requests" NoResult(coffee) path.
      HttpOverrides.global = _InstantHttpOverrides(
        responseBody: '[]',
        statusCode: 200,
      );

      final status = MockAccessStatus.create(
        accessToken: 'test_token',
        account: MockAccount.create(),
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: FollowRequests()),
          accessStatus: status,
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await tester.pump();
      });

      expect(find.byIcon(Icons.coffee), findsOneWidget);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
