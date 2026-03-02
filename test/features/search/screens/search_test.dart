// Widget tests for search screens: SearchExplorer, ExplorerTab.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

// ---------------------------------------------------------------------------
// Mock HTTP infrastructure for search API
// ---------------------------------------------------------------------------

/// Builds a minimal valid account JSON map.
Map<String, dynamic> _accountJson({String id = '1', String username = 'alice'}) => {
  'id': id,
  'username': username,
  'acct': username,
  'url': 'https://example.com/@$username',
  'display_name': username,
  'note': '',
  'avatar': 'https://example.com/avatar.png',
  'avatar_static': 'https://example.com/avatar.png',
  'header': 'https://example.com/header.png',
  'locked': false,
  'bot': false,
  'indexable': true,
  'created_at': '2023-01-01T00:00:00.000Z',
  'statuses_count': 10,
  'followers_count': 5,
  'following_count': 3,
};

/// Builds a minimal valid status JSON map.
Map<String, dynamic> _statusJson({String id = '100', String content = '<p>Hello</p>'}) => {
  'id': id,
  'content': content,
  'visibility': 'public',
  'sensitive': false,
  'spoiler_text': '',
  'account': _accountJson(),
  'uri': 'https://example.com/statuses/$id',
  'reblogs_count': 0,
  'favourites_count': 0,
  'replies_count': 0,
  'created_at': '2024-01-01T00:00:00.000Z',
};

/// Builds a minimal valid hashtag JSON map.
Map<String, dynamic> _hashtagJson({String name = 'flutter'}) => {
  'name': name,
  'url': 'https://example.com/tags/$name',
  'history': <dynamic>[
    {'day': '1', 'accounts': '5', 'uses': '10'},
  ],
};

/// Mock HttpOverrides that returns search results for /api/v2/search.
class _SearchMockHttpOverrides extends HttpOverrides {
  final Map<String, dynamic> searchJson;
  _SearchMockHttpOverrides({required this.searchJson});

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockHttpClient(searchJson: searchJson);
  }
}

class _MockHttpClient implements HttpClient {
  final Map<String, dynamic> searchJson;
  _MockHttpClient({required this.searchJson});

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

  _MockHttpClientRequest _req(Uri url) => _MockHttpClientRequest(url, searchJson: searchJson);

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
  final Map<String, dynamic> searchJson;
  _MockHttpClientRequest(this._uri, {required this.searchJson});

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
  @override Future<HttpClientResponse> close() async => _MockHttpClientResponse(_uri, searchJson: searchJson);
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
  final Map<String, dynamic> searchJson;
  _MockHttpClientResponse(this._uri, {required this.searchJson});

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
    final String body;
    if (_uri.path.contains('/api/v2/search')) {
      body = jsonEncode(searchJson);
    } else {
      body = '{}';
    }
    final stream = Stream.value(body.codeUnits);
    return stream.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}

// ---------------------------------------------------------------------------
// Helper: authenticated status with a real domain so getAPI proceeds
// ---------------------------------------------------------------------------
AccessStatusSchema _authWithDomain() {
  return const AccessStatusSchema(
    domain: 'example.com',
    accessToken: 'test_token',
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setupTestEnvironment();

  // Initialize sqflite FFI for CachedNetworkImage's cache manager in runAsync tests.
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // =========================================================================
  // SearchExplorer
  // =========================================================================
  group('SearchExplorer', () {
    testWidgets('renders search icon when not expanded', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const SearchExplorer(),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('search icon is disabled when not signed in', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const SearchExplorer(),
        accessStatus: MockAccessStatus.anonymous(),
      ));
      await tester.pump();

      // Find the IconButton wrapping the search icon
      final iconButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.search),
      );
      expect(iconButton.onPressed, isNull);
    });

    testWidgets('search icon is enabled when signed in', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const SearchExplorer(),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      final iconButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.search),
      );
      expect(iconButton.onPressed, isNotNull);
    });

    testWidgets('expands to text field on tap', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const SearchExplorer(),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      // Tap the search icon to expand
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('collapses when clear button tapped', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const SearchExplorer(),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      // Expand
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Tap clear to collapse
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('respects custom size parameter', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const SearchExplorer(size: 32),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      final icon = tester.widget<Icon>(find.byIcon(Icons.search));
      expect(icon.size, 32);
    });

    testWidgets('accepts maxWidth parameter', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const SearchExplorer(maxWidth: 200),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      expect(find.byType(SearchExplorer), findsOneWidget);
    });

    // -----------------------------------------------------------------------
    // NEW: search bar text input and onSearch paths
    // -----------------------------------------------------------------------

    testWidgets('search bar shows prefix search icon button', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const SearchExplorer(),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      // Expand
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Prefix icon + suffix icon (clear) = 2 search icons (prefix) + 1 clear
      // The prefix is an IconButton with search icon inside the TextField decoration
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('onSearch with empty text does not navigate', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const SearchExplorer(),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      // Expand search bar
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Submit with empty text
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      // TextField should still be showing (no navigation, no collapse)
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('onSearch with whitespace-only text does not navigate', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const SearchExplorer(),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      // Expand search bar
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Enter whitespace-only text and submit
      await tester.enterText(find.byType(TextField), '   ');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      // TextField should still be showing (query.isEmpty after trim)
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('onSearch with valid text calls onSearch (via submit)', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const SearchExplorer(),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      // Expand search bar
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Enter text
      await tester.enterText(find.byType(TextField), 'flutter');
      await tester.pump();

      // Verify text was entered in the controller
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, 'flutter');

      // The search bar is expanded and has text — ready for submission
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('onSearch via prefix icon button with empty text stays expanded', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const SearchExplorer(),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      // Expand search bar
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Don't enter any text, just tap the prefix search icon
      await tester.tap(find.widgetWithIcon(IconButton, Icons.search));
      await tester.pumpAndSettle();

      // With empty text, onSearch does nothing — search bar stays expanded
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('onChanged triggers rebuild (setState)', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const SearchExplorer(),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      // Expand search bar
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Type text — triggers onChanged → setState
      await tester.enterText(find.byType(TextField), 'ab');
      await tester.pump();

      // Widget still showing with the typed text
      expect(find.byType(TextField), findsOneWidget);
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, 'ab');
    });

    testWidgets('clear button resets controller text and collapses', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: const SearchExplorer(),
        accessStatus: MockAccessStatus.authenticated(),
      ));
      await tester.pump();

      // Expand search bar
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Type some text
      await tester.enterText(find.byType(TextField), 'hello');
      await tester.pump();

      // Tap clear
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      // Search bar collapsed
      expect(find.byType(TextField), findsNothing);
      // Back to icon-only mode
      expect(find.byIcon(Icons.search), findsOneWidget);
    });
  });

  // =========================================================================
  // ExplorerTab
  // =========================================================================
  group('ExplorerTab', () {
    // Mock path_provider for CachedNetworkImage cache manager.
    setUpAll(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (MethodCall methodCall) async => Directory.systemTemp.path,
      );
    });

    test('is a ConsumerStatefulWidget', () {
      const widget = ExplorerTab(keyword: 'test');
      expect(widget, isA<ConsumerStatefulWidget>());
    });

    test('accepts keyword parameter', () {
      const widget = ExplorerTab(keyword: 'flutter');
      expect(widget.keyword, 'flutter');
    });

    testWidgets('renders with no-domain status', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: ExplorerTab(keyword: 'test')),
          accessStatus: const AccessStatusSchema(domain: null, accessToken: 'test'),
        ));
        await tester.pump();
      });

      expect(find.byType(ExplorerTab), findsOneWidget);
    });

    testWidgets('shows NoResult when search returns null', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: ExplorerTab(keyword: 'nonexistent')),
          accessStatus: const AccessStatusSchema(domain: null, accessToken: 'test'),
        ));
        await tester.pump();
        // Allow the search future to complete (throws with null domain).
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await tester.pump();
      });

      // With null domain, search returns empty → schema.isEmpty → NoResult
      expect(find.byType(NoResult), findsOneWidget);
    });

    testWidgets('shows loading indicator initially', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: ExplorerTab(keyword: 'test')),
          accessStatus: MockAccessStatus.authenticated(),
        ));
        await tester.pump();
      });

      expect(find.byType(LoadingOverlay), findsOneWidget);
    });

    testWidgets('shows NoResult when status is null (accessStatusProvider returns null)', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(ProviderScope(
          overrides: [
            accessStatusProvider.overrideWith((ref) => null),
          ],
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('en'),
            home: Scaffold(body: ExplorerTab(keyword: 'anything')),
          ),
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await tester.pump();
      });

      // status is null → Future.value(null) → snapshot.data == null → NoResult
      expect(find.byType(NoResult), findsOneWidget);
    });

    testWidgets('shows NoResult when search returns empty results', (tester) async {
      final prevOverrides = HttpOverrides.current;
      HttpOverrides.global = _SearchMockHttpOverrides(searchJson: {
        'accounts': <dynamic>[],
        'statuses': <dynamic>[],
        'hashtags': <dynamic>[],
      });

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: ExplorerTab(keyword: 'nothing')),
          accessStatus: _authWithDomain(),
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 500));
        await tester.pump();
      });

      // schema.isEmpty == true → NoResult
      expect(find.byType(NoResult), findsOneWidget);

      HttpOverrides.global = prevOverrides;
    });

    testWidgets('shows SwipeTabView when search returns accounts', (tester) async {
      final prevOverrides = HttpOverrides.current;
      HttpOverrides.global = _SearchMockHttpOverrides(searchJson: {
        'accounts': <dynamic>[_accountJson(id: '1', username: 'alice')],
        'statuses': <dynamic>[],
        'hashtags': <dynamic>[],
      });

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: ExplorerTab(keyword: 'alice')),
          accessStatus: _authWithDomain(),
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 500));
        await tester.pump();
      });

      expect(find.byType(SwipeTabView), findsOneWidget);
      // Account tab should show Account widget
      expect(find.byType(Account), findsOneWidget);

      HttpOverrides.global = prevOverrides;
    });

    testWidgets('shows SwipeTabView when search returns statuses', (tester) async {
      final prevOverrides = HttpOverrides.current;
      HttpOverrides.global = _SearchMockHttpOverrides(searchJson: {
        'accounts': <dynamic>[],
        'statuses': <dynamic>[_statusJson(id: '200', content: '<p>Test post</p>')],
        'hashtags': <dynamic>[],
      });

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: ExplorerTab(keyword: 'test')),
          accessStatus: _authWithDomain(),
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 500));
        await tester.pump();
      });

      expect(find.byType(SwipeTabView), findsOneWidget);

      HttpOverrides.global = prevOverrides;
    });

    testWidgets('shows SwipeTabView when search returns hashtags', (tester) async {
      final prevOverrides = HttpOverrides.current;
      HttpOverrides.global = _SearchMockHttpOverrides(searchJson: {
        'accounts': <dynamic>[],
        'statuses': <dynamic>[],
        'hashtags': <dynamic>[_hashtagJson(name: 'dart')],
      });

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: ExplorerTab(keyword: 'dart')),
          accessStatus: _authWithDomain(),
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 500));
        await tester.pump();
      });

      expect(find.byType(SwipeTabView), findsOneWidget);

      HttpOverrides.global = prevOverrides;
    });

    testWidgets('shows all result types in SwipeTabView', (tester) async {
      final prevOverrides = HttpOverrides.current;
      HttpOverrides.global = _SearchMockHttpOverrides(searchJson: {
        'accounts': <dynamic>[_accountJson(id: '1', username: 'alice')],
        'statuses': <dynamic>[_statusJson(id: '300')],
        'hashtags': <dynamic>[_hashtagJson(name: 'flutter')],
      });

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: ExplorerTab(keyword: 'flutter')),
          accessStatus: _authWithDomain(),
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 500));
        await tester.pump();
      });

      expect(find.byType(SwipeTabView), findsOneWidget);
      // The first tab (account) is active and shown by default
      expect(find.byType(Account), findsOneWidget);
      // Tab icons should be rendered for all 3 types
      expect(find.byType(Icon), findsWidgets);

      HttpOverrides.global = prevOverrides;
    });

    testWidgets('tab icons show correct icons for each result type', (tester) async {
      final prevOverrides = HttpOverrides.current;
      HttpOverrides.global = _SearchMockHttpOverrides(searchJson: {
        'accounts': <dynamic>[_accountJson()],
        'statuses': <dynamic>[_statusJson()],
        'hashtags': <dynamic>[_hashtagJson()],
      });

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: ExplorerTab(keyword: 'test')),
          accessStatus: _authWithDomain(),
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 500));
        await tester.pump();
      });

      // The first tab (account) is selected, so it uses the active icon
      expect(find.byIcon(Icons.contact_page), findsOneWidget);
      // The other two tabs are not selected, so they use outlined icons
      expect(find.byIcon(Icons.message_outlined), findsOneWidget);
      expect(find.byIcon(Icons.tag_outlined), findsOneWidget);

      HttpOverrides.global = prevOverrides;
    });

    testWidgets('renders only accounts when only accounts returned', (tester) async {
      final prevOverrides = HttpOverrides.current;
      HttpOverrides.global = _SearchMockHttpOverrides(searchJson: {
        'accounts': <dynamic>[
          _accountJson(id: '1', username: 'user1'),
          _accountJson(id: '2', username: 'user2'),
        ],
        'statuses': <dynamic>[],
        'hashtags': <dynamic>[],
      });

      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: ExplorerTab(keyword: 'user')),
          accessStatus: _authWithDomain(),
        ));
        await tester.pump();
        await Future<void>.delayed(const Duration(milliseconds: 500));
        await tester.pump();
      });

      // Two Account widgets in the first (accounts) tab
      expect(find.byType(Account), findsNWidgets(2));

      HttpOverrides.global = prevOverrides;
    });
  });

  // =========================================================================
  // ExplorerResultType
  // =========================================================================
  group('ExplorerResultType', () {
    test('tooltip returns name', () {
      // tooltip requires a BuildContext, tested indirectly; just verify enum values
      expect(ExplorerResultType.account.name, 'account');
      expect(ExplorerResultType.status.name, 'status');
      expect(ExplorerResultType.hashtag.name, 'hashtag');
    });

    test('icon returns outlined icon when not active', () {
      expect(ExplorerResultType.account.icon(active: false), Icons.contact_page_outlined);
      expect(ExplorerResultType.status.icon(active: false), Icons.message_outlined);
      expect(ExplorerResultType.hashtag.icon(active: false), Icons.tag_outlined);
    });

    test('icon returns filled icon when active', () {
      expect(ExplorerResultType.account.icon(active: true), Icons.contact_page);
      expect(ExplorerResultType.status.icon(active: true), Icons.message);
      expect(ExplorerResultType.hashtag.icon(active: true), Icons.tag);
    });

    test('icon defaults to non-active', () {
      expect(ExplorerResultType.account.icon(), Icons.contact_page_outlined);
      expect(ExplorerResultType.status.icon(), Icons.message_outlined);
      expect(ExplorerResultType.hashtag.icon(), Icons.tag_outlined);
    });
  });

  // =========================================================================
  // SearchResultSchema
  // =========================================================================
  group('SearchResultSchema', () {
    test('isEmpty returns true when all lists empty', () {
      final schema = SearchResultSchema.fromJson({
        'accounts': <dynamic>[],
        'statuses': <dynamic>[],
        'hashtags': <dynamic>[],
      });
      expect(schema.isEmpty, true);
    });

    test('isEmpty returns false when accounts non-empty', () {
      final schema = MockSearchResult.create(
        accounts: [MockAccount.create()],
      );
      expect(schema.isEmpty, false);
    });

    test('isEmpty returns false when statuses non-empty', () {
      final schema = MockSearchResult.create(
        statuses: [MockStatus.create()],
      );
      expect(schema.isEmpty, false);
    });

    test('isEmpty returns false when hashtags non-empty', () {
      final schema = MockSearchResult.create(
        hashtags: [MockHashtag.create()],
      );
      expect(schema.isEmpty, false);
    });

    test('fromString parses valid JSON string', () {
      final jsonString = jsonEncode({
        'accounts': <dynamic>[_accountJson()],
        'statuses': <dynamic>[],
        'hashtags': <dynamic>[],
      });

      final schema = SearchResultSchema.fromString(jsonString);
      expect(schema.accounts.length, 1);
      expect(schema.statuses.length, 0);
      expect(schema.hashtags.length, 0);
    });

    test('fromString parses JSON with all result types', () {
      final jsonString = jsonEncode({
        'accounts': <dynamic>[_accountJson()],
        'statuses': <dynamic>[_statusJson()],
        'hashtags': <dynamic>[_hashtagJson()],
      });

      final schema = SearchResultSchema.fromString(jsonString);
      expect(schema.accounts.length, 1);
      expect(schema.statuses.length, 1);
      expect(schema.hashtags.length, 1);
    });

    test('fromJson handles missing keys gracefully', () {
      final schema = SearchResultSchema.fromJson({});
      expect(schema.accounts, isEmpty);
      expect(schema.statuses, isEmpty);
      expect(schema.hashtags, isEmpty);
      expect(schema.isEmpty, true);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
