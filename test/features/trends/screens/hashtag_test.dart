// Widget tests for Hashtag components.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/features/trends/screens/hashtag.dart';
import 'package:glacial/features/trends/screens/chart.dart';

import '../../../helpers/test_helpers.dart';

/// Mock HttpOverrides that returns a valid hashtag JSON for tags API requests.
class _HashtagMockHttpOverrides extends HttpOverrides {
  final bool following;
  _HashtagMockHttpOverrides({this.following = false});

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockHttpClient(following: following);
  }
}

/// A minimal mock HttpClient that returns a valid hashtag JSON.
class _MockHttpClient implements HttpClient {
  final bool following;
  _MockHttpClient({this.following = false});

  @override
  bool autoUncompress = true;

  @override
  Duration? connectionTimeout;

  @override
  Duration idleTimeout = const Duration(seconds: 15);

  @override
  int? maxConnectionsPerHost;

  @override
  String? userAgent;

  @override
  void addCredentials(Uri url, String realm, HttpClientCredentials credentials) {}

  @override
  void addProxyCredentials(String host, int port, String realm, HttpClientCredentials credentials) {}

  @override
  set authenticate(Future<bool> Function(Uri url, String scheme, String? realm)? f) {}

  @override
  set authenticateProxy(Future<bool> Function(String host, int port, String scheme, String? realm)? f) {}

  @override
  set badCertificateCallback(bool Function(X509Certificate cert, String host, int port)? callback) {}

  @override
  void close({bool force = false}) {}

  @override
  set connectionFactory(Future<ConnectionTask<Socket>> Function(Uri url, String? proxyHost, int? proxyPort)? f) {}

  @override
  set findProxy(String Function(Uri url)? f) {}

  @override
  set keyLog(Function(String line)? callback) {}

  @override
  Future<HttpClientRequest> delete(String host, int port, String path) async =>
      _MockHttpClientRequest(Uri.parse('https://$host:$port$path'), following: following);

  @override
  Future<HttpClientRequest> deleteUrl(Uri url) async =>
      _MockHttpClientRequest(url, following: following);

  @override
  Future<HttpClientRequest> get(String host, int port, String path) async =>
      _MockHttpClientRequest(Uri.parse('https://$host:$port$path'), following: following);

  @override
  Future<HttpClientRequest> getUrl(Uri url) async =>
      _MockHttpClientRequest(url, following: following);

  @override
  Future<HttpClientRequest> head(String host, int port, String path) async =>
      _MockHttpClientRequest(Uri.parse('https://$host:$port$path'), following: following);

  @override
  Future<HttpClientRequest> headUrl(Uri url) async =>
      _MockHttpClientRequest(url, following: following);

  @override
  Future<HttpClientRequest> open(String method, String host, int port, String path) async =>
      _MockHttpClientRequest(Uri.parse('https://$host:$port$path'), following: following);

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async =>
      _MockHttpClientRequest(url, following: following);

  @override
  Future<HttpClientRequest> patch(String host, int port, String path) async =>
      _MockHttpClientRequest(Uri.parse('https://$host:$port$path'), following: following);

  @override
  Future<HttpClientRequest> patchUrl(Uri url) async =>
      _MockHttpClientRequest(url, following: following);

  @override
  Future<HttpClientRequest> post(String host, int port, String path) async =>
      _MockHttpClientRequest(Uri.parse('https://$host:$port$path'), following: following);

  @override
  Future<HttpClientRequest> postUrl(Uri url) async =>
      _MockHttpClientRequest(url, following: following);

  @override
  Future<HttpClientRequest> put(String host, int port, String path) async =>
      _MockHttpClientRequest(Uri.parse('https://$host:$port$path'), following: following);

  @override
  Future<HttpClientRequest> putUrl(Uri url) async =>
      _MockHttpClientRequest(url, following: following);
}

class _MockHttpClientRequest extends Stream<List<int>> implements HttpClientRequest {
  final Uri _uri;
  final bool following;
  _MockHttpClientRequest(this._uri, {this.following = false});

  final _headers = _MockHttpHeaders();

  @override
  Encoding encoding = utf8;

  @override
  HttpHeaders get headers => _headers;

  @override
  Uri get uri => _uri;

  @override
  bool bufferOutput = true;

  @override
  int get contentLength => -1;

  @override
  set contentLength(int value) {}

  @override
  bool followRedirects = true;

  @override
  int maxRedirects = 5;

  @override
  bool persistentConnection = true;

  @override
  String get method => 'GET';

  @override
  HttpConnectionInfo? get connectionInfo => null;

  @override
  List<Cookie> get cookies => [];

  @override
  Future<HttpClientResponse> get done => close();

  @override
  void abort([Object? exception, StackTrace? stackTrace]) {}

  @override
  void add(List<int> data) {}

  @override
  void addError(Object error, [StackTrace? stackTrace]) {}

  @override
  Future addStream(Stream<List<int>> stream) async {}

  @override
  Future<HttpClientResponse> close() async {
    return _MockHttpClientResponse(_uri, following: following);
  }

  @override
  Future flush() async {}

  @override
  void write(Object? object) {}

  @override
  void writeAll(Iterable objects, [String separator = '']) {}

  @override
  void writeCharCode(int charCode) {}

  @override
  void writeln([Object? object = '']) {}

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

  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {
    _headers.putIfAbsent(name, () => []).add(value.toString());
  }

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {
    _headers[name] = [value.toString()];
  }

  @override
  String? value(String name) => _headers[name]?.first;

  @override
  List<String>? operator [](String name) => _headers[name];

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MockHttpClientResponse extends Stream<List<int>> implements HttpClientResponse {
  final Uri _uri;
  final bool following;
  _MockHttpClientResponse(this._uri, {this.following = false});

  @override
  int get statusCode => 200;

  @override
  String get reasonPhrase => 'OK';

  @override
  int get contentLength => -1;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  bool get isRedirect => false;

  @override
  bool get persistentConnection => true;

  @override
  List<Cookie> get cookies => [];

  @override
  HttpHeaders get headers => _MockHttpHeaders();

  @override
  HttpConnectionInfo? get connectionInfo => null;

  @override
  X509Certificate? get certificate => null;

  @override
  List<RedirectInfo> get redirects => [];

  @override
  Future<HttpClientResponse> redirect([String? method, Uri? url, bool? followLoops]) async => this;

  @override
  Future<Socket> detachSocket() {
    throw UnsupportedError('detachSocket');
  }

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    final String body;
    if (_uri.path.contains('/api/v1/tags/')) {
      body = '{"name":"flutter","url":"https://example.com/tags/flutter","history":[],"following":$following}';
    } else {
      body = '{}';
    }
    final stream = Stream.value(body.codeUnits);
    return stream.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}

void main() {
  setUpAll(() => setupTestEnvironment());

  group('TagLite', () {
    testWidgets('displays hashtag text with # prefix', (tester) async {
      final tag = MockTag.create(name: 'flutter');

      await tester.pumpWidget(createTestWidget(
        child: TagLite(schema: tag),
      ));
      await tester.pumpAndSettle();

      expect(find.text('#flutter'), findsOneWidget);
    });

    testWidgets('wraps in Container with decoration', (tester) async {
      final tag = MockTag.create();

      await tester.pumpWidget(createTestWidget(
        child: TagLite(schema: tag),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('uses padding around content', (tester) async {
      final tag = MockTag.create();

      await tester.pumpWidget(createTestWidget(
        child: TagLite(schema: tag),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(Padding), findsWidgets);
    });

    testWidgets('is tappable', (tester) async {
      final tag = MockTag.create();

      await tester.pumpWidget(createTestWidget(
        child: TagLite(schema: tag),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(TagLite), findsOneWidget);
    });

    testWidgets('onTap triggers navigation to hashtag page', (tester) async {
      final tag = MockTag.create(name: 'darttag');

      await tester.pumpWidget(createTestWidget(
        child: TagLite(schema: tag),
      ));
      await tester.pumpAndSettle();

      // Tap the tag — triggers context.push which throws without GoRouter
      await tester.tap(find.text('#darttag'));
      await tester.pump();

      // Consume the expected GoRouter error
      expect(tester.takeException(), isNotNull);
    });
  });

  group('Hashtag', () {
    testWidgets('displays hashtag name with # prefix', (tester) async {
      final hashtag = MockHashtag.create(name: 'dart');

      await tester.pumpWidget(createTestWidget(
        child: Hashtag(schema: hashtag),
      ));
      await tester.pumpAndSettle();

      expect(find.text('#dart'), findsOneWidget);
    });

    testWidgets('displays usage count text', (tester) async {
      final hashtag = MockHashtag.create();

      await tester.pumpWidget(createTestWidget(
        child: Hashtag(schema: hashtag),
      ));
      await tester.pumpAndSettle();

      // Should show usage text
      expect(find.textContaining('used in the past days'), findsOneWidget);
    });

    testWidgets('displays HistoryLineChart', (tester) async {
      final hashtag = MockHashtag.create();

      await tester.pumpWidget(createTestWidget(
        child: Hashtag(schema: hashtag),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(HistoryLineChart), findsOneWidget);
    });

    testWidgets('uses Row layout', (tester) async {
      final hashtag = MockHashtag.create();

      await tester.pumpWidget(createTestWidget(
        child: Hashtag(schema: hashtag),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('wraps in Container with border', (tester) async {
      final hashtag = MockHashtag.create();

      await tester.pumpWidget(createTestWidget(
        child: Hashtag(schema: hashtag),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('is tappable', (tester) async {
      final hashtag = MockHashtag.create();

      await tester.pumpWidget(createTestWidget(
        child: Hashtag(schema: hashtag),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(Hashtag), findsOneWidget);
    });

    testWidgets('onTap triggers navigation to hashtag page', (tester) async {
      final hashtag = MockHashtag.create(name: 'flutterdev');

      await tester.pumpWidget(createTestWidget(
        child: Hashtag(schema: hashtag),
      ));
      await tester.pumpAndSettle();

      // Tap the hashtag — triggers context.push which throws without GoRouter
      await tester.tap(find.text('#flutterdev'));
      await tester.pump();

      // Consume the expected GoRouter error
      expect(tester.takeException(), isNotNull);
    });
  });

  group('HistoryLineChart', () {
    testWidgets('renders with history data', (tester) async {
      final history = MockHistory.createList(count: 5);

      await tester.pumpWidget(createTestWidget(
        child: HistoryLineChart(schemas: history),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(HistoryLineChart), findsOneWidget);
    });

    testWidgets('uses ConstrainedBox for sizing', (tester) async {
      final history = MockHistory.createList();

      await tester.pumpWidget(createTestWidget(
        child: HistoryLineChart(schemas: history),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ConstrainedBox), findsWidgets);
    });

    testWidgets('accepts custom maxHeight', (tester) async {
      final history = MockHistory.createList();

      await tester.pumpWidget(createTestWidget(
        child: HistoryLineChart(schemas: history, maxHeight: 50),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(HistoryLineChart), findsOneWidget);
    });

    testWidgets('accepts custom maxWidth', (tester) async {
      final history = MockHistory.createList();

      await tester.pumpWidget(createTestWidget(
        child: HistoryLineChart(schemas: history, maxWidth: 100),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(HistoryLineChart), findsOneWidget);
    });

    testWidgets('renders with empty history', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const HistoryLineChart(schemas: []),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(HistoryLineChart), findsOneWidget);
    });

    testWidgets('renders with single history entry', (tester) async {
      final history = [MockHistory.create()];

      await tester.pumpWidget(createTestWidget(
        child: HistoryLineChart(schemas: history),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(HistoryLineChart), findsOneWidget);
    });
  });

  group('FollowedHashtagButton', () {
    test('is a ConsumerStatefulWidget', () {
      const widget = FollowedHashtagButton(hashtag: 'test');
      expect(widget, isA<ConsumerStatefulWidget>());
    });

    test('accepts hashtag parameter', () {
      const widget = FollowedHashtagButton(hashtag: 'flutter');
      expect(widget.hashtag, 'flutter');
    });

    testWidgets('renders with anonymous status (no token)', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: FollowedHashtagButton(hashtag: 'test')),
          accessStatus: MockAccessStatus.anonymous(),
        ));
        await tester.pump();
        // Allow async onReload to complete
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await tester.pump();
      });

      // With anonymous status, getHashtag fails → schema is null → SizedBox.shrink
      expect(find.byType(FollowedHashtagButton), findsOneWidget);
    });

    testWidgets('renders with authenticated status', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: FollowedHashtagButton(hashtag: 'flutter')),
          accessStatus: MockAccessStatus.authenticated(server: MockServer.create()),
        ));
        await tester.pump();
        // Allow async onReload to complete
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await tester.pump();
      });

      expect(find.byType(FollowedHashtagButton), findsOneWidget);
    });

    testWidgets('shows SizedBox.shrink when schema is null', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: FollowedHashtagButton(hashtag: 'nonexistent')),
          accessStatus: MockAccessStatus.anonymous(),
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await tester.pump();
      });

      // No IconButton should be shown since schema is null
      expect(find.byType(IconButton), findsNothing);
    });

    testWidgets('renders with different hashtag values', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: FollowedHashtagButton(hashtag: 'dart')),
          accessStatus: MockAccessStatus.anonymous(),
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await tester.pump();
      });

      expect(find.byType(FollowedHashtagButton), findsOneWidget);
    });

    testWidgets('shows bookmark_border icon when schema loaded and not following', (tester) async {
      // Use mock HTTP overrides that return valid hashtag JSON with following=false
      final prevOverrides = HttpOverrides.current;
      HttpOverrides.global = _HashtagMockHttpOverrides(following: false);

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: FollowedHashtagButton(hashtag: 'flutter')),
          accessStatus: MockAccessStatus.authenticated(server: MockServer.create()),
        ));
        await tester.pump();
        // Wait for the async getHashtag call to complete
        await Future<void>.delayed(const Duration(milliseconds: 500));
        await tester.pump();
      });

      // schema is now non-null with following=false, should show bookmark_border
      expect(find.byType(IconButton), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_border), findsOneWidget);

      // Restore the previous HTTP overrides
      HttpOverrides.global = prevOverrides;
    });

    testWidgets('shows filled bookmark icon when schema loaded and following', (tester) async {
      // Use mock HTTP overrides that return valid hashtag JSON with following=true
      final prevOverrides = HttpOverrides.current;
      HttpOverrides.global = _HashtagMockHttpOverrides(following: true);

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: FollowedHashtagButton(hashtag: 'flutter')),
          accessStatus: MockAccessStatus.authenticated(server: MockServer.create()),
        ));
        await tester.pump();
        // Wait for the async getHashtag call to complete
        await Future<void>.delayed(const Duration(milliseconds: 500));
        await tester.pump();
      });

      // schema is now non-null with following=true, should show filled bookmark
      expect(find.byType(IconButton), findsOneWidget);
      expect(find.byIcon(Icons.bookmark), findsOneWidget);

      // Restore the previous HTTP overrides
      HttpOverrides.global = prevOverrides;
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
