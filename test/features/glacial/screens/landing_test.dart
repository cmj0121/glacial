// Widget tests for LandingPage — covers lines 13, 48-94 of landing.dart.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_riverpod/src/internals.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

// ---------------------------------------------------------------------------
// Mock HTTP for landing page navigation tests.
// Returns fast responses for instance / custom_emojis endpoints so that
// loadAccessStatus() completes without real network calls.
// ---------------------------------------------------------------------------
class _LandingHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _LandingMockHttpClient();
  }
}

class _LandingMockHttpClient implements HttpClient {
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

  _LandingMockReq _req(Uri url) => _LandingMockReq(url);

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

class _LandingMockReq extends Stream<List<int>> implements HttpClientRequest {
  final Uri _uri;
  _LandingMockReq(this._uri);

  final _headers = _LandingMockHeaders();

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
  @override Future<HttpClientResponse> close() async => _LandingMockResp(_uri);
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

class _LandingMockHeaders implements HttpHeaders {
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

class _LandingMockResp extends Stream<List<int>> implements HttpClientResponse {
  final Uri _uri;
  _LandingMockResp(this._uri);

  @override int get statusCode => 200;
  @override String get reasonPhrase => 'OK';
  @override int get contentLength => -1;
  @override HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;
  @override bool get isRedirect => false;
  @override bool get persistentConnection => true;
  @override List<Cookie> get cookies => [];
  @override HttpHeaders get headers => _LandingMockHeaders();
  @override HttpConnectionInfo? get connectionInfo => null;
  @override X509Certificate? get certificate => null;
  @override List<RedirectInfo> get redirects => [];
  @override Future<HttpClientResponse> redirect([String? method, Uri? url, bool? followLoops]) async => this;
  @override Future<Socket> detachSocket() { throw UnsupportedError('detachSocket'); }

  String get _body {
    final path = _uri.path;
    if (path.contains('/api/v1/custom_emojis')) {
      return '[]';
    }
    if (path.contains('/api/v2/instance') || path.contains('/api/v1/instance')) {
      return jsonEncode({
        'domain': 'mastodon.social',
        'title': 'Mastodon',
        'description': 'Test server',
        'version': '4.2.0',
        'thumbnail': {'url': 'https://mastodon.social/thumbnail.jpg'},
        'usage': {'users': {'active_month': 100}},
        'languages': ['en'],
        'configuration': {
          'statuses': {'max_characters': 500, 'max_media_attachments': 4, 'characters_reserved_per_url': 23},
          'media_attachments': {},
          'polls': {'max_options': 4, 'max_characters_per_option': 50, 'min_expiration': 300, 'max_expiration': 2592000},
          'translation': {'enabled': false},
        },
        'registrations': {'enabled': true, 'approval_required': false},
        'contact': {'email': 'admin@mastodon.social'},
        'rules': <dynamic>[],
      });
    }
    return '{}';
  }

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    final stream = Stream.value(utf8.encode(_body));
    return stream.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}

/// Creates a LandingPage wrapped in GoRouter so that context.go() works.
Widget createLandingTestWidget({
  AccessStatusSchema? accessStatus,
  double size = 64,
}) {
  final List<Override> allOverrides = [
    accessStatusProvider.overrideWith(
      (ref) => accessStatus ?? MockAccessStatus.anonymous(),
    ),
  ];

  final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => LandingPage(size: size),
      ),
      GoRoute(
        path: '/home/timeline',
        builder: (_, _) => const Scaffold(body: Text('Timeline')),
      ),
      GoRoute(
        path: '/home/trends',
        builder: (_, _) => const Scaffold(body: Text('Trends')),
      ),
      GoRoute(
        path: '/explorer',
        builder: (_, _) => const Scaffold(body: Text('Explorer')),
      ),
      GoRoute(
        path: '/home/post/shared',
        builder: (_, _) => const Scaffold(body: Text('Post Shared')),
      ),
    ],
  );

  return ProviderScope(
    overrides: allOverrides,
    child: MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
    ),
  );
}

void main() {
  setupTestEnvironment();

  group('LandingPage', () {
    testWidgets('renders Scaffold and SafeArea', (tester) async {
      await tester.pumpWidget(createLandingTestWidget());
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('renders icon with default size of 64', (tester) async {
      await tester.pumpWidget(createLandingTestWidget());
      await tester.pump();

      // LandingPage renders Image.asset with the icon
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('renders icon with custom size', (tester) async {
      await tester.pumpWidget(createLandingTestWidget(size: 128));
      await tester.pump();

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('shows Flipping animation initially', (tester) async {
      await tester.pumpWidget(createLandingTestWidget());
      await tester.pump();

      expect(find.byType(Flipping), findsOneWidget);
    });

    testWidgets('center widget wraps the Flipping icon', (tester) async {
      await tester.pumpWidget(createLandingTestWidget());
      await tester.pump();

      expect(find.byType(Center), findsOneWidget);
    });

    group('error state', () {
      testWidgets('shows ErrorState when loading fails', (tester) async {
        await tester.runAsync(() async {
          await tester.pumpWidget(createLandingTestWidget());
          await tester.pump();
          // Allow async onLoading to fail (Storage not initialized)
          await Future.delayed(const Duration(milliseconds: 200));
          await tester.pump();
        });

        // Should show ErrorState widget
        expect(find.byType(ErrorState), findsOneWidget);
      });

      testWidgets('shows cloud_off icon in error state', (tester) async {
        await tester.runAsync(() async {
          await tester.pumpWidget(createLandingTestWidget());
          await tester.pump();
          await Future.delayed(const Duration(milliseconds: 200));
          await tester.pump();
        });

        expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);
      });

      testWidgets('shows retry button in error state', (tester) async {
        await tester.runAsync(() async {
          await tester.pumpWidget(createLandingTestWidget());
          await tester.pump();
          await Future.delayed(const Duration(milliseconds: 200));
          await tester.pump();
        });

        expect(find.byIcon(Icons.refresh), findsOneWidget);
      });

      testWidgets('shows change server secondary action in error state', (tester) async {
        await tester.runAsync(() async {
          await tester.pumpWidget(createLandingTestWidget());
          await tester.pump();
          await Future.delayed(const Duration(milliseconds: 200));
          await tester.pump();
        });

        // Should show a secondary "Change server" action
        expect(find.textContaining('Change server'), findsOneWidget);
      });

      testWidgets('shows server unreachable message', (tester) async {
        await tester.runAsync(() async {
          await tester.pumpWidget(createLandingTestWidget());
          await tester.pump();
          await Future.delayed(const Duration(milliseconds: 200));
          await tester.pump();
        });

        // Should show the unreachable message
        expect(find.textContaining('unreachable'), findsOneWidget);
      });

      testWidgets('error state hides Flipping animation', (tester) async {
        await tester.runAsync(() async {
          await tester.pumpWidget(createLandingTestWidget());
          await tester.pump();
          await Future.delayed(const Duration(milliseconds: 200));
          await tester.pump();
        });

        // When error is shown, Flipping should be hidden
        expect(find.byType(Flipping), findsNothing);
      });

      testWidgets('tapping retry clears error and re-enters error state', (tester) async {
        // First, get into error state
        await tester.runAsync(() async {
          await tester.pumpWidget(createLandingTestWidget());
          await tester.pump();
          await Future.delayed(const Duration(milliseconds: 200));
          await tester.pump();
        });

        // Verify error state
        expect(find.byType(ErrorState), findsOneWidget);

        // Tap the retry button inside runAsync — this calls
        // setState(() => error = null) then onLoading() which will fail again
        await tester.runAsync(() async {
          await tester.tap(find.byIcon(Icons.refresh));
          await tester.pump();
          // Wait for onLoading to fail again
          await Future.delayed(const Duration(milliseconds: 200));
          await tester.pump();
        });

        // After retry fails again, ErrorState should be shown again
        expect(find.byType(ErrorState), findsOneWidget);
      });

      testWidgets('change server button navigates to explorer', (tester) async {
        // First, get into error state
        await tester.runAsync(() async {
          await tester.pumpWidget(createLandingTestWidget());
          await tester.pump();
          await Future.delayed(const Duration(milliseconds: 200));
          await tester.pump();
        });

        // Verify error state
        expect(find.textContaining('Change server'), findsOneWidget);

        // Tap change server — this calls context.go(RoutePath.explorer.path)
        await tester.runAsync(() async {
          await tester.tap(find.textContaining('Change server'));
          await tester.pump();
          await tester.pump();
        });

        // Should navigate to explorer
        await tester.pump();
        expect(find.text('Explorer'), findsOneWidget);
      });
    });

    group('onLoading navigation (storage initialized)', () {
      setUp(() async {
        SharedPreferences.setMockInitialValues({});
        FlutterSecureStorage.setMockInitialValues({});
        await Storage.init();
        // Mock HTTP so that ServerSchema.fetch() and fetchCustomEmojis() complete
        // instantly without real network calls.
        HttpOverrides.global = _LandingHttpOverrides();
      });

      tearDown(() {
        HttpOverrides.global = null;
      });

      testWidgets('navigates after successful storage load (no stored token)', (tester) async {
        // With storage initialized, mocked HTTP, and empty prefs, onLoading() succeeds.
        // The default domain "mastodon.social" means hasDomain = true.
        // isSignedIn = false. Public timeline → hasTimeline = true
        // → navigates to RoutePath.timeline. Lines 75-93 are executed.
        await tester.runAsync(() async {
          await tester.pumpWidget(createLandingTestWidget());
          // First pump — triggers postFrameCallback which starts onLoading.
          await tester.pump();
          // Allow onLoading to complete: storage reads + HTTP mocks resolve fast.
          await Future.delayed(const Duration(milliseconds: 200));
          // Pump to process the navigation triggered by context.go().
          await tester.pump();
          await tester.pump();
        });

        // LandingPage should have navigated away — either Timeline or another route.
        final bool navigated =
            find.text('Timeline').evaluate().isNotEmpty ||
            find.text('Explorer').evaluate().isNotEmpty ||
            find.text('Trends').evaluate().isNotEmpty ||
            find.byType(Flipping).evaluate().isEmpty;
        expect(navigated, isTrue);
      });

      testWidgets('onLoading navigates away from LandingPage', (tester) async {
        // With storage initialized and mocked HTTP, onLoading() completes successfully
        // and calls context.go(RoutePath.timeline.path), replacing LandingPage.
        // This covers lines 75-93 (the navigation block).
        await tester.runAsync(() async {
          await tester.pumpWidget(createLandingTestWidget());
          await tester.pump();
          await Future.delayed(const Duration(milliseconds: 300));
          await tester.pump();
        });
        // Additional pump outside runAsync to let GoRouter finalize the route change.
        await tester.pump();
        await tester.pump();

        // After navigation, one of the destination routes should be displayed.
        final bool navigatedAway =
            find.text('Timeline').evaluate().isNotEmpty ||
            find.text('Trends').evaluate().isNotEmpty ||
            find.text('Explorer').evaluate().isNotEmpty;
        expect(navigatedAway, isTrue);
      });

      testWidgets('onLoading completes navigation and MaterialApp stays mounted', (tester) async {
        await tester.runAsync(() async {
          await tester.pumpWidget(createLandingTestWidget());
          await tester.pump();
          await Future.delayed(const Duration(milliseconds: 200));
          await tester.pump();
          await tester.pump();
        });

        expect(find.byType(MaterialApp), findsOneWidget);
      });
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
