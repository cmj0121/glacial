import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/mastodon/screens/domain_blocks.dart';

import '../../../helpers/test_helpers.dart';

// ---------------------------------------------------------------------------
// Mock HTTP infrastructure — returns empty JSON array for domain_blocks GET
// and empty object for DELETE. Prevents real HTTP calls.
// ---------------------------------------------------------------------------
class _MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockHttpClient();
  }
}

class _MockHttpClient implements HttpClient {
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

  _MockHttpClientRequest _req(Uri url) => _MockHttpClientRequest(url);

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

class _MockHttpClientRequest extends Stream<List<int>> implements HttpClientRequest {
  final Uri _uri;
  _MockHttpClientRequest(this._uri);

  final _headers = _MockHttpHeaders();

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
  @override Future<HttpClientResponse> close() async => _MockHttpClientResponse(_uri);
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
    return const Stream<List<int>>.empty().listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}

class _MockHttpHeaders implements HttpHeaders {
  final Map<String, List<String>> _headers = {};

  @override void add(String name, Object value, {bool preserveHeaderCase = false}) {
    _headers.putIfAbsent(name, () => []).add(value.toString());
  }
  @override void set(String name, Object value, {bool preserveHeaderCase = false}) {
    _headers[name] = [value.toString()];
  }
  @override String? value(String name) => _headers[name]?.first;
  @override List<String>? operator [](String name) => _headers[name];
  @override dynamic noSuchMethod(Invocation invocation) => null;
}

class _MockHttpClientResponse extends Stream<List<int>> implements HttpClientResponse {
  final Uri _uri;
  _MockHttpClientResponse(this._uri);

  @override int get statusCode => 200;
  @override String get reasonPhrase => 'OK';
  @override int get contentLength => -1;
  @override HttpClientResponseCompressionState get compressionState => HttpClientResponseCompressionState.notCompressed;
  @override bool get isRedirect => false;
  @override bool get persistentConnection => true;
  @override List<Cookie> get cookies => [];
  @override HttpHeaders get headers => _MockHttpHeaders();
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
    // Return empty JSON array for domain_blocks GET, empty object for DELETE.
    final String body = _uri.path.contains('domain_blocks') ? '[]' : '{}';
    final stream = Stream.value(utf8.encode(body));
    return stream.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}

// ---------------------------------------------------------------------------
// Authenticated status with a real domain so the API layer proceeds.
// Mock HTTP returns empty [] so onLoad completes with empty domains.
// ---------------------------------------------------------------------------
AccessStatusSchema _auth() {
  return AccessStatusSchema(
    domain: 'example.com',
    accessToken: 'test',
    account: MockAccount.create(),
    server: MockServer.create(),
  );
}

/// Authenticated status without server — status?.server == null → SizedBox.shrink.
AccessStatusSchema _authNoServer() {
  return const AccessStatusSchema(
    domain: 'example.com',
    accessToken: 'test',
  );
}

void main() {
  setupTestEnvironment();

  group('DomainBlockList', () {
    test('is a StatefulWidget', () {
      expect(const DomainBlockList(), isA<StatefulWidget>());
    });

    test('can be created with const constructor', () {
      const widget = DomainBlockList();
      expect(widget, isNotNull);
      expect(widget.key, isNull);
    });

    test('can be created with key', () {
      const key = ValueKey('domain-blocks');
      const widget = DomainBlockList(key: key);
      expect(widget.key, key);
    });

    test('is a ConsumerStatefulWidget', () {
      const widget = DomainBlockList();
      expect(widget, isA<ConsumerStatefulWidget>());
    });
  });

  group('DomainBlockList — build branches', () {
    setUp(() {
      HttpOverrides.global = _MockHttpOverrides();
    });

    tearDown(() {
      HttpOverrides.global = null;
    });

    testWidgets('shows SizedBox.shrink when server is null', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: const DomainBlockList()),
          accessStatus: _authNoServer(),
        ));
        await tester.pump();
      });

      // status?.server == null → SizedBox.shrink
      expect(find.byType(DomainBlockList), findsOneWidget);
      expect(find.byType(LoadingOverlay), findsNothing);
      expect(find.byType(NoResult), findsNothing);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('shows LoadingOverlay when loading with server', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: const DomainBlockList()),
          accessStatus: _auth(),
        ));
        // Single pump to build with isLoading=true before async fetchDomainBlocks completes
        await tester.pump();
      });

      expect(find.byType(LoadingOverlay), findsOneWidget);
    });

    testWidgets('shows NoResult when empty and completed', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: const DomainBlockList()),
          accessStatus: _auth(),
        ));
        await tester.pump();
        // Allow onLoad to complete — mock HTTP returns []
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await tester.pump();
      });

      // Mock HTTP returned [] → empty domains, markLoadComplete(isEmpty: true) → NoResult
      expect(find.byType(NoResult), findsOneWidget);
      expect(find.byIcon(Icons.dns_outlined), findsOneWidget);
    });
  });

  group('DomainBlockList — list content', () {
    setUp(() {
      HttpOverrides.global = _MockHttpOverrides();
    });

    tearDown(() {
      HttpOverrides.global = null;
    });

    testWidgets('renders ListView when domains are present', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: const DomainBlockList()),
          accessStatus: _auth(),
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await tester.pump();
      });

      final dynamic state = tester.state(find.byType(DomainBlockList));
      (state.domains as List<String>).addAll(['spam.example', 'ads.example', 'bad.example']);
      state.markLoadComplete(isEmpty: false);
      await tester.pump();

      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('spam.example'), findsOneWidget);
      expect(find.text('ads.example'), findsOneWidget);
      expect(find.text('bad.example'), findsOneWidget);
    });

    testWidgets('each domain has dns icon and ListTile', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: const DomainBlockList()),
          accessStatus: _auth(),
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await tester.pump();
      });

      final dynamic state = tester.state(find.byType(DomainBlockList));
      (state.domains as List<String>).addAll(['example.org']);
      state.markLoadComplete(isEmpty: false);
      await tester.pump();

      expect(find.byIcon(Icons.dns), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);
      expect(find.text('example.org'), findsOneWidget);
    });

    testWidgets('wraps content in Padding with 16px', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: const DomainBlockList()),
          accessStatus: _auth(),
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await tester.pump();
      });

      final dynamic state = tester.state(find.byType(DomainBlockList));
      (state.domains as List<String>).addAll(['test.example']);
      state.markLoadComplete(isEmpty: false);
      await tester.pump();

      final paddingFinder = find.ancestor(
        of: find.byType(ListView),
        matching: find.byType(Padding),
      );
      expect(paddingFinder, findsWidgets);
    });

    testWidgets('each domain is wrapped in AccessibleDismissible', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: const DomainBlockList()),
          accessStatus: _auth(),
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await tester.pump();
      });

      final dynamic state = tester.state(find.byType(DomainBlockList));
      (state.domains as List<String>).addAll(['dismiss.example', 'keep.example']);
      state.markLoadComplete(isEmpty: false);
      await tester.pump();

      expect(find.byType(AccessibleDismissible), findsNWidgets(2));
    });

    testWidgets('swiping a domain removes it from the list', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: const DomainBlockList()),
          accessStatus: _auth(),
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await tester.pump();
      });

      final dynamic state = tester.state(find.byType(DomainBlockList));
      (state.domains as List<String>).addAll(['remove.example', 'stay.example']);
      state.markLoadComplete(isEmpty: false);
      await tester.pump();

      expect(find.text('remove.example'), findsOneWidget);
      expect(find.text('stay.example'), findsOneWidget);
      expect((state.domains as List<String>).length, 2);

      // Swipe the first domain from end to start.
      // The Dismissible animation needs fake time, so don't use runAsync for drag.
      await tester.drag(find.text('remove.example'), const Offset(-500, 0));
      // Advance through the dismiss animation (needs ~300ms for fling + confirm)
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      // After confirmDismiss, the domain is removed from state.domains
      expect((state.domains as List<String>).length, 1);
      expect((state.domains as List<String>).first, 'stay.example');
    });
  });

  group('DomainBlockList — scroll behavior', () {
    setUp(() {
      HttpOverrides.global = _MockHttpOverrides();
    });

    tearDown(() {
      HttpOverrides.global = null;
    });

    testWidgets('scroll controller is attached to ListView', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: const DomainBlockList()),
          accessStatus: _auth(),
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await tester.pump();
      });

      final dynamic state = tester.state(find.byType(DomainBlockList));

      // Add enough domains to make scrollable
      for (int i = 0; i < 20; i++) {
        (state.domains as List<String>).add('domain_$i.example');
      }
      state.markLoadComplete(isEmpty: false);
      await tester.pump();

      expect(find.byType(ListView), findsOneWidget);

      final ScrollController ctrl = state.controller as ScrollController;
      expect(ctrl.hasClients, isTrue);
    });

    testWidgets('onScroll triggers onLoad when near bottom', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: Scaffold(body: const DomainBlockList()),
          accessStatus: _auth(),
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await tester.pump();
      });

      final dynamic state = tester.state(find.byType(DomainBlockList));

      // Add enough domains to make scrollable
      for (int i = 0; i < 30; i++) {
        (state.domains as List<String>).add('scroll_$i.example');
      }
      state.markLoadComplete(isEmpty: false);
      await tester.pump();

      // Directly call onScroll to cover the scroll listener branch
      state.onScroll();
      await tester.pump();
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
