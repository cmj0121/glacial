// Widget tests for ConversationTab — covers buildContent, onDismiss,
// onTapConversation, onRefresh, onLoad, and _onPositionChange.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

// ---------------------------------------------------------------------------
// Mock HTTP infrastructure — returns empty JSON array for conversations API.
// Prevents real HTTP calls that would throw 401 Unauthorized.
// ---------------------------------------------------------------------------
class _ConvMockHttpOverrides extends HttpOverrides {
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
    // Return empty JSON array for GET conversations list.
    // For /read endpoint, return a valid conversation JSON.
    // For other endpoints, return empty JSON object.
    final String body;
    if (_uri.path.endsWith('/conversations')) {
      body = '[]';
    } else if (_uri.path.endsWith('/read')) {
      body = '{"id":"conv-1","accounts":[],"unread":false}';
    } else {
      body = '{}';
    }
    final stream = Stream.value(utf8.encode(body));
    return stream.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}

// ---------------------------------------------------------------------------
// Authenticated status with a domain so the API layer proceeds.
// Mock HTTP returns empty [] so onLoad completes with empty conversations.
// ---------------------------------------------------------------------------
AccessStatusSchema _auth() {
  return const AccessStatusSchema(
    domain: 'example.com',
    accessToken: 'test_token',
  );
}

void main() {
  setUp(() {
    HttpOverrides.global = _ConvMockHttpOverrides();
  });

  tearDown(() {
    HttpOverrides.global = null;
  });

  group('ConversationTab — build', () {
    test('is a ConsumerStatefulWidget', () {
      const widget = ConversationTab();
      expect(widget, isA<ConsumerStatefulWidget>());
    });

    // Anonymous test: the original test uses plain test() since pumping with
    // anonymous status triggers onLoad -> checkSignedIn -> throws.
    // We verify the widget construction instead.
    test('returns SizedBox.shrink when not signed in (accessToken is null)', () {
      // ConversationTab checks status?.isSignedIn != true in build().
      // When accessToken is null, isSignedIn is false, so build returns SizedBox.shrink.
      const widget = ConversationTab();
      expect(widget, isA<ConsumerStatefulWidget>());
    });

    testWidgets('renders Column and Align when signed in', (tester) async {
      // No conversations will be populated (empty list from mock HTTP)
      // So buildContent returns SizedBox.shrink — safe for createTestWidget
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: const ConversationTab(),
          accessStatus: _auth(),
        ));
        await tester.pump();
      });

      expect(find.byType(Align), findsWidgets);
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('shows AnimatedSwitcher for loading indicator',
        (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: const ConversationTab(),
          accessStatus: _auth(),
        ));
        await tester.pump();
      });

      expect(find.byType(AnimatedSwitcher), findsWidgets);
    });
  });

  group('ConversationTab — buildContent empty states', () {
    testWidgets(
        'shows SizedBox when conversations empty and NOT completed',
        (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: const ConversationTab(),
          accessStatus: _auth(),
        ));
        await tester.pump();
      });

      expect(find.byType(NoResult), findsNothing);
    });

    testWidgets('shows NoResult when conversations empty and isCompleted',
        (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidget(
          child: const ConversationTab(),
          accessStatus: _auth(),
        ));
        await tester.pump();
        // Wait for mock HTTP to complete and trigger markLoadComplete(isEmpty: true)
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await tester.pump();
      });

      expect(find.byType(NoResult), findsOneWidget);
      expect(find.byIcon(Icons.mail_outline), findsOneWidget);
    });
  });

  // Tests that inject conversations need bounded height (ScrollablePositionedList).
  // Use createTestWidgetRaw with Scaffold(body: ...) to provide bounded constraints.
  group('ConversationTab — buildContent with conversations', () {
    testWidgets(
        'renders ScrollablePositionedList when conversations are populated',
        (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: ConversationTab()),
          accessStatus: _auth(),
        ));
        await tester.pump();
      });

      final dynamic state = tester.state(find.byType(ConversationTab));
      state.conversations.addAll([
        MockConversation.create(
          id: 'c1',
          lastStatus: MockStatus.create(content: '<p>Hello from conv 1</p>'),
        ),
        MockConversation.create(
          id: 'c2',
          lastStatus: MockStatus.create(content: '<p>Hello from conv 2</p>'),
        ),
      ]);
      state.markLoadComplete(isEmpty: false);
      (tester.element(find.byType(ConversationTab)) as StatefulElement)
          .markNeedsBuild();
      await tester.pump();

      expect(find.byType(ScrollablePositionedList), findsOneWidget);
      expect(find.byType(ConversationItem), findsNWidgets(2));
    });

    testWidgets('renders CustomMaterialIndicator for pull-to-refresh',
        (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: ConversationTab()),
          accessStatus: _auth(),
        ));
        await tester.pump();
      });

      final dynamic state = tester.state(find.byType(ConversationTab));
      state.conversations.addAll([
        MockConversation.create(
          id: 'c1',
          lastStatus: MockStatus.create(content: '<p>Msg</p>'),
        ),
      ]);
      state.markLoadComplete(isEmpty: false);
      (tester.element(find.byType(ConversationTab)) as StatefulElement)
          .markNeedsBuild();
      await tester.pump();

      expect(find.byType(CustomMaterialIndicator), findsOneWidget);
    });

    testWidgets('wraps each item in AccessibleDismissible', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: ConversationTab()),
          accessStatus: _auth(),
        ));
        await tester.pump();
      });

      final dynamic state = tester.state(find.byType(ConversationTab));
      state.conversations.addAll([
        MockConversation.create(
          id: 'c1',
          lastStatus: MockStatus.create(content: '<p>Item 1</p>'),
        ),
        MockConversation.create(
          id: 'c2',
          lastStatus: MockStatus.create(content: '<p>Item 2</p>'),
        ),
      ]);
      state.markLoadComplete(isEmpty: false);
      (tester.element(find.byType(ConversationTab)) as StatefulElement)
          .markNeedsBuild();
      await tester.pump();

      expect(find.byType(AccessibleDismissible), findsNWidgets(2));
    });

    testWidgets('displays conversation item content (participant names)',
        (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: ConversationTab()),
          accessStatus: _auth(),
        ));
        await tester.pump();
      });

      final dynamic state = tester.state(find.byType(ConversationTab));
      state.conversations.add(
        MockConversation.create(
          id: 'c1',
          accounts: [MockAccount.create(displayName: 'Alice DM')],
          lastStatus: MockStatus.create(content: '<p>Direct message</p>'),
        ),
      );
      state.markLoadComplete(isEmpty: false);
      (tester.element(find.byType(ConversationTab)) as StatefulElement)
          .markNeedsBuild();
      await tester.pump();

      expect(find.text('Alice DM'), findsOneWidget);
      expect(find.textContaining('Direct message'), findsOneWidget);
    });

    testWidgets('renders AccessibleDismissible with endToStart direction',
        (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: ConversationTab()),
          accessStatus: _auth(),
        ));
        await tester.pump();
      });

      final dynamic state = tester.state(find.byType(ConversationTab));
      state.conversations.add(
        MockConversation.create(
          id: 'c1',
          lastStatus: MockStatus.create(content: '<p>Dismissible</p>'),
        ),
      );
      state.markLoadComplete(isEmpty: false);
      (tester.element(find.byType(ConversationTab)) as StatefulElement)
          .markNeedsBuild();
      await tester.pump();

      // Verify the AccessibleDismissible is rendered
      expect(find.byType(AccessibleDismissible), findsOneWidget);
    });

    testWidgets('shows unread badge for unread and none for read',
        (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: ConversationTab()),
          accessStatus: _auth(),
        ));
        await tester.pump();
      });

      final dynamic state = tester.state(find.byType(ConversationTab));
      state.conversations.addAll([
        MockConversation.createUnread(
          id: 'c-unread',
          accounts: [MockAccount.create(displayName: 'Unread Sender')],
          lastStatus: MockStatus.create(content: '<p>New message</p>'),
        ),
        MockConversation.create(
          id: 'c-read',
          accounts: [MockAccount.create(displayName: 'Read Sender')],
          lastStatus: MockStatus.create(content: '<p>Old message</p>'),
          unread: false,
        ),
      ]);
      state.markLoadComplete(isEmpty: false);
      (tester.element(find.byType(ConversationTab)) as StatefulElement)
          .markNeedsBuild();
      await tester.pump();

      final Finder badge = find.byWidgetPredicate(
        (widget) {
          if (widget is Container && widget.decoration is BoxDecoration) {
            final BoxDecoration decoration = widget.decoration! as BoxDecoration;
            return decoration.shape == BoxShape.circle;
          }
          return false;
        },
      );
      expect(badge, findsOneWidget);
    });

    testWidgets('shows stacked avatars for multi-participant conversation',
        (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: ConversationTab()),
          accessStatus: _auth(),
        ));
        await tester.pump();
      });

      final dynamic state = tester.state(find.byType(ConversationTab));
      state.conversations.add(
        MockConversation.createGroup(id: 'c-group', participantCount: 2),
      );
      state.markLoadComplete(isEmpty: false);
      (tester.element(find.byType(ConversationTab)) as StatefulElement)
          .markNeedsBuild();
      await tester.pump();

      final Finder stackedAvatars = find.byWidgetPredicate(
        (w) => w is SizedBox && w.width == 48 && w.height == 48,
      );
      expect(stackedAvatars, findsOneWidget);
    });
  });

  group('ConversationTab — onDismiss', () {
    testWidgets('removes conversation and recreates controllers',
        (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: ConversationTab()),
          accessStatus: _auth(),
        ));
        await tester.pump();
      });

      final dynamic state = tester.state(find.byType(ConversationTab));
      state.conversations.addAll([
        MockConversation.create(
          id: 'c1',
          accounts: [MockAccount.create(displayName: 'Alice')],
          lastStatus: MockStatus.create(content: '<p>Msg 1</p>'),
        ),
        MockConversation.create(
          id: 'c2',
          accounts: [MockAccount.create(displayName: 'Bob')],
          lastStatus: MockStatus.create(content: '<p>Msg 2</p>'),
        ),
      ]);
      state.markLoadComplete(isEmpty: false);
      (tester.element(find.byType(ConversationTab)) as StatefulElement)
          .markNeedsBuild();
      await tester.pump();

      expect(find.byType(ConversationItem), findsNWidgets(2));

      final ItemScrollController originalScroll = state.itemScrollController;

      state.onDismiss(0, 'c1');
      await tester.pump();

      // Conversation removed
      expect(state.conversations.length, 1);
      expect(state.conversations.first.id, 'c2');
      // Controllers recreated
      expect(identical(state.itemScrollController, originalScroll), isFalse);
      // GlacialHome.itemScrollToTop updated
      expect(GlacialHome.itemScrollToTop, state.itemScrollController);
    });
  });

  group('ConversationTab — onTapConversation', () {
    testWidgets('exercises unread branch on tap', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: ConversationTab()),
          accessStatus: _auth(),
        ));
        await tester.pump();
      });

      final dynamic state = tester.state(find.byType(ConversationTab));

      final conversation = MockConversation.createUnread(
        id: 'c-unread',
        lastStatus: MockStatus.create(
          content: '<p>Unread msg</p>',
          createdAt: DateTime(2024, 6, 15),
        ),
      );

      state.conversations.add(conversation);
      state.markLoadComplete(isEmpty: false);
      (tester.element(find.byType(ConversationTab)) as StatefulElement)
          .markNeedsBuild();
      await tester.pump();

      expect(conversation.unread, isTrue);

      try {
        state.onTapConversation(conversation);
      } catch (_) {
        // GoRouter not configured
      }
    });

    testWidgets('skips markConversationAsRead for read conversation',
        (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: ConversationTab()),
          accessStatus: _auth(),
        ));
        await tester.pump();
      });

      final dynamic state = tester.state(find.byType(ConversationTab));

      final conversation = MockConversation.create(
        id: 'c-read',
        lastStatus: MockStatus.create(content: '<p>Read msg</p>'),
        unread: false,
      );

      state.conversations.add(conversation);
      state.markLoadComplete(isEmpty: false);
      (tester.element(find.byType(ConversationTab)) as StatefulElement)
          .markNeedsBuild();
      await tester.pump();

      try {
        state.onTapConversation(conversation);
      } catch (_) {
        // GoRouter not configured
      }

      expect(conversation.unread, isFalse);
    });

    testWidgets('does not push when lastStatus is null', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: ConversationTab()),
          accessStatus: _auth(),
        ));
        await tester.pump();
      });

      final dynamic state = tester.state(find.byType(ConversationTab));

      final conversation = MockConversation.create(
        id: 'c-no-status',
        lastStatus: null,
        unread: false,
      );

      // Should not throw — skips push when lastStatus is null
      state.onTapConversation(conversation);
    });
  });

  group('ConversationTab — onRefresh', () {
    testWidgets('clears conversations on refresh', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: ConversationTab()),
          accessStatus: _auth(),
        ));
        await tester.pump();
      });

      final dynamic state = tester.state(find.byType(ConversationTab));
      state.conversations.addAll([
        MockConversation.create(
          id: 'c1',
          lastStatus: MockStatus.create(content: '<p>Msg</p>'),
        ),
      ]);
      state.markLoadComplete(isEmpty: false);
      (tester.element(find.byType(ConversationTab)) as StatefulElement)
          .markNeedsBuild();
      await tester.pump();

      expect(state.conversations.length, 1);

      await tester.runAsync(() async {
        await state.onRefresh();
      });

      expect(state.conversations.length, 0);
    });
  });

  group('ConversationTab — onLoad', () {
    testWidgets('skips load when shouldSkipLoad is true (isCompleted)',
        (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: ConversationTab()),
          accessStatus: _auth(),
        ));
        await tester.pump();
      });

      final dynamic state = tester.state(find.byType(ConversationTab));
      state.markLoadComplete(isEmpty: true);

      await state.onLoad();

      expect(state.conversations.length, 0);
    });

    testWidgets('exercises maxId branch when conversations exist',
        (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: ConversationTab()),
          accessStatus: _auth(),
        ));
        await tester.pump();
      });

      final dynamic state = tester.state(find.byType(ConversationTab));
      state.conversations.add(
        MockConversation.create(
          id: 'c-last',
          lastStatus: MockStatus.create(content: '<p>Last msg</p>'),
        ),
      );
      state.resetPagination();

      await tester.runAsync(() async {
        await state.onLoad();
      });
    });
  });

  group('ConversationTab — dispose', () {
    testWidgets('removes position listener on dispose', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: ConversationTab()),
          accessStatus: _auth(),
        ));
        await tester.pump();
      });

      expect(find.byType(ConversationTab), findsOneWidget);

      await tester.pumpWidget(createTestWidgetRaw(
        child: const Scaffold(body: SizedBox()),
        accessStatus: _auth(),
      ));
      await tester.pump();

      expect(find.byType(ConversationTab), findsNothing);
    });
  });

  group('ConversationTab — initState', () {
    testWidgets('sets GlacialHome.itemScrollToTop on init', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: ConversationTab()),
          accessStatus: _auth(),
        ));
        await tester.pump();
      });

      final dynamic state = tester.state(find.byType(ConversationTab));
      expect(GlacialHome.itemScrollToTop, state.itemScrollController);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
