// Reusable mock HTTP infrastructure for testing API calls.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Route handler type: given method + URL, return (statusCode, body).
typedef MockRouteHandler = (int, String) Function(String method, Uri url);

/// Default handler that returns 200 with empty JSON object.
(int, String) _defaultHandler(String method, Uri url) => (200, '{}');

/// Mock HttpOverrides that intercepts all HTTP calls with configurable responses.
class MockHttpOverrides extends HttpOverrides {
  final MockRouteHandler handler;

  MockHttpOverrides({this.handler = _defaultHandler});

  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      MockHttpClient(handler: handler);
}

/// Mock HttpClient that delegates all methods to MockHttpClientRequest.
class MockHttpClient implements HttpClient {
  final MockRouteHandler handler;

  MockHttpClient({required this.handler});

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

  MockHttpClientRequest _req(String method, Uri url) => MockHttpClientRequest(method, url, handler);

  @override Future<HttpClientRequest> delete(String host, int port, String path) async => _req('DELETE', Uri.parse('https://$host:$port$path'));
  @override Future<HttpClientRequest> deleteUrl(Uri url) async => _req('DELETE', url);
  @override Future<HttpClientRequest> get(String host, int port, String path) async => _req('GET', Uri.parse('https://$host:$port$path'));
  @override Future<HttpClientRequest> getUrl(Uri url) async => _req('GET', url);
  @override Future<HttpClientRequest> head(String host, int port, String path) async => _req('HEAD', Uri.parse('https://$host:$port$path'));
  @override Future<HttpClientRequest> headUrl(Uri url) async => _req('HEAD', url);
  @override Future<HttpClientRequest> open(String method, String host, int port, String path) async => _req(method, Uri.parse('https://$host:$port$path'));
  @override Future<HttpClientRequest> openUrl(String method, Uri url) async => _req(method, url);
  @override Future<HttpClientRequest> patch(String host, int port, String path) async => _req('PATCH', Uri.parse('https://$host:$port$path'));
  @override Future<HttpClientRequest> patchUrl(Uri url) async => _req('PATCH', url);
  @override Future<HttpClientRequest> post(String host, int port, String path) async => _req('POST', Uri.parse('https://$host:$port$path'));
  @override Future<HttpClientRequest> postUrl(Uri url) async => _req('POST', url);
  @override Future<HttpClientRequest> put(String host, int port, String path) async => _req('PUT', Uri.parse('https://$host:$port$path'));
  @override Future<HttpClientRequest> putUrl(Uri url) async => _req('PUT', url);
}

/// Mock HttpClientRequest that captures method and returns configurable response.
class MockHttpClientRequest extends Stream<List<int>> implements HttpClientRequest {
  final String _method;
  final Uri _uri;
  final MockRouteHandler _handler;
  final FakeHttpHeaders _headers = FakeHttpHeaders();

  MockHttpClientRequest(this._method, this._uri, this._handler);

  @override Encoding encoding = utf8;
  @override HttpHeaders get headers => _headers;
  @override Uri get uri => _uri;
  @override bool bufferOutput = true;
  @override int get contentLength => -1;
  @override set contentLength(int value) {}
  @override bool followRedirects = true;
  @override int maxRedirects = 5;
  @override bool persistentConnection = true;
  @override String get method => _method;
  @override HttpConnectionInfo? get connectionInfo => null;
  @override List<Cookie> get cookies => [];
  @override Future<HttpClientResponse> get done => close();
  @override void abort([Object? exception, StackTrace? stackTrace]) {}
  @override void add(List<int> data) {}
  @override void addError(Object error, [StackTrace? stackTrace]) {}
  @override Future addStream(Stream<List<int>> stream) async {}
  @override Future<HttpClientResponse> close() async {
    final (statusCode, body) = _handler(_method, _uri);
    return MockHttpClientResponse(statusCode, body);
  }
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
  }) => const Stream<List<int>>.empty().listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
}

/// Mock HttpClientResponse with configurable statusCode and body.
class MockHttpClientResponse extends Stream<List<int>> implements HttpClientResponse {
  final int _statusCode;
  final String _body;

  MockHttpClientResponse(this._statusCode, this._body);

  @override int get statusCode => _statusCode;
  @override String get reasonPhrase => _statusCode == 200 ? 'OK' : 'Error';
  @override int get contentLength => -1;
  @override HttpClientResponseCompressionState get compressionState => HttpClientResponseCompressionState.notCompressed;
  @override bool get isRedirect => false;
  @override bool get persistentConnection => true;
  @override List<Cookie> get cookies => [];
  @override HttpHeaders get headers => FakeHttpHeaders();
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
    return Stream.value(_body.codeUnits).listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}

/// Minimal fake HttpHeaders implementation.
class FakeHttpHeaders implements HttpHeaders {
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

// ---------------------------------------------------------------------------
// JSON builder helpers for test data
// ---------------------------------------------------------------------------

/// Build a valid account JSON map.
String accountJson({
  String id = '1',
  String username = 'testuser',
  String acct = 'testuser',
  String displayName = 'Test User',
  String url = 'https://example.com/@testuser',
  String note = 'A test account',
}) => jsonEncode({
  'id': id,
  'username': username,
  'acct': acct,
  'display_name': displayName,
  'url': url,
  'note': note,
  'locked': false,
  'bot': false,
  'indexable': false,
  'avatar': 'https://example.com/avatar.png',
  'avatar_static': 'https://example.com/avatar.png',
  'header': 'https://example.com/header.png',
  'header_static': 'https://example.com/header.png',
  'followers_count': 10,
  'following_count': 20,
  'statuses_count': 100,
  'last_status_at': '2025-01-01',
  'created_at': '2024-01-01T00:00:00.000Z',
  'emojis': [],
  'fields': [],
});

/// Build a valid status JSON map.
String statusJson({
  String id = 'status-1',
  String content = '<p>Hello world</p>',
  String visibility = 'public',
  String? inReplyToId,
  String? inReplyToAccountId,
  Map<String, dynamic>? account,
}) {
  final accountData = account ?? {
    'id': '1',
    'username': 'testuser',
    'acct': 'testuser',
    'display_name': 'Test User',
    'url': 'https://example.com/@testuser',
    'note': '',
    'locked': false,
    'bot': false,
    'indexable': false,
    'avatar': 'https://example.com/avatar.png',
    'avatar_static': 'https://example.com/avatar.png',
    'header': 'https://example.com/header.png',
    'header_static': 'https://example.com/header.png',
    'followers_count': 0,
    'following_count': 0,
    'statuses_count': 0,
    'last_status_at': '2025-01-01',
    'created_at': '2024-01-01T00:00:00.000Z',
    'emojis': [],
    'fields': [],
  };

  return jsonEncode({
    'id': id,
    'created_at': '2025-01-01T12:00:00.000Z',
    'in_reply_to_id': inReplyToId,
    'in_reply_to_account_id': inReplyToAccountId,
    'sensitive': false,
    'spoiler_text': '',
    'visibility': visibility,
    'language': 'en',
    'uri': 'https://example.com/statuses/$id',
    'url': 'https://example.com/@testuser/$id',
    'replies_count': 0,
    'reblogs_count': 0,
    'favourites_count': 0,
    'favourited': false,
    'reblogged': false,
    'muted': false,
    'bookmarked': false,
    'pinned': false,
    'content': content,
    'reblog': null,
    'account': accountData,
    'media_attachments': [],
    'mentions': [],
    'tags': [],
    'emojis': [],
    'card': null,
    'poll': null,
  });
}

/// Build a valid status context JSON (ancestors + descendants).
String statusContextJson({
  List<String>? ancestorIds,
  List<String>? descendantIds,
}) {
  final ancestors = (ancestorIds ?? []).map((id) => jsonDecode(statusJson(id: id))).toList();
  final descendants = (descendantIds ?? []).map((id) => jsonDecode(statusJson(id: id))).toList();

  return jsonEncode({
    'ancestors': ancestors,
    'descendants': descendants,
  });
}

/// Build an attachment JSON.
String attachmentJson({
  String id = 'att-1',
  String type = 'image',
  String url = 'https://example.com/media/image.png',
  String? description = 'A test image',
}) => jsonEncode({
  'id': id,
  'type': type,
  'url': url,
  'preview_url': 'https://example.com/media/preview.png',
  'remote_url': null,
  'description': description,
  'blurhash': 'LEHV6nWB2yk8pyo0adR*.7kCMdnj',
});

/// Build search result JSON.
String searchResultJson({
  List<Map<String, dynamic>>? accounts,
  List<Map<String, dynamic>>? statuses,
  List<Map<String, dynamic>>? hashtags,
}) => jsonEncode({
  'accounts': accounts ?? [],
  'statuses': statuses ?? [],
  'hashtags': hashtags ?? [],
});

/// Build a list of status JSON strings as a JSON array string.
String statusListJson({int count = 3}) {
  final statuses = List.generate(count, (i) => jsonDecode(statusJson(id: 'status-${i + 1}')));
  return jsonEncode(statuses);
}

// vim: set ts=2 sw=2 sts=2 et:
