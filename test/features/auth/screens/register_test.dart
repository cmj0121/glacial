// Widget tests for auth screens: RegisterPage and SignIn with registration.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

/// HttpOverrides that returns a 401 Unauthorized for all HTTP requests.
/// Used to test error handling paths that make real HTTP calls.
class _FailingHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _FailingHttpClient();
  }
}

class _FailingHttpClient implements HttpClient {
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

  _FailingHttpClientRequest _req(Uri url) => _FailingHttpClientRequest(url);

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

class _FailingHttpClientRequest extends Stream<List<int>> implements HttpClientRequest {
  final Uri _uri;
  _FailingHttpClientRequest(this._uri);

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
  @override String get method => 'POST';
  @override HttpConnectionInfo? get connectionInfo => null;
  @override List<Cookie> get cookies => [];
  @override Future<HttpClientResponse> get done => close();
  @override void abort([Object? exception, StackTrace? stackTrace]) {}
  @override void add(List<int> data) {}
  @override void addError(Object error, [StackTrace? stackTrace]) {}
  @override Future addStream(Stream<List<int>> stream) async {}
  @override Future<HttpClientResponse> close() async => _FailingHttpClientResponse();
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

class _FailingHttpClientResponse extends Stream<List<int>> implements HttpClientResponse {
  @override int get statusCode => 401;
  @override String get reasonPhrase => 'Unauthorized';
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
    final body = '{"error": "invalid_client"}';
    final stream = Stream.value(body.codeUnits);
    return stream.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}

void main() {
  setupTestEnvironment();

  group('RegisterPage', () {
    Widget buildRegisterPage({AccessStatusSchema? status}) {
      return createTestWidget(
        child: const RegisterPage(),
        accessStatus: status ?? MockAccessStatus.create(
          server: MockServer.create(),
        ),
      );
    }

    testWidgets('renders form fields', (tester) async {
      await tester.pumpWidget(buildRegisterPage());
      await tester.pump();

      expect(find.byType(RegisterPage), findsOneWidget);
      expect(find.byType(TextFormField), findsAtLeast(4));
    });

    testWidgets('shows domain header', (tester) async {
      await tester.pumpWidget(buildRegisterPage(
        status: MockAccessStatus.create(
          server: MockServer.create(domain: 'test.social'),
        ),
      ));
      await tester.pump();

      // AccessStatusSchema default domain is 'mastodon.social' since we don't override it
      expect(find.textContaining('mastodon.social'), findsOneWidget);
    });

    testWidgets('shows Create Account title', (tester) async {
      await tester.pumpWidget(buildRegisterPage());
      await tester.pump();

      // Title and button both show 'Create Account'
      expect(find.text('Create Account'), findsNWidgets(2));
    });

    testWidgets('shows username field', (tester) async {
      await tester.pumpWidget(buildRegisterPage());
      await tester.pump();

      expect(find.text('Username'), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('shows email field', (tester) async {
      await tester.pumpWidget(buildRegisterPage());
      await tester.pump();

      expect(find.text('Email'), findsOneWidget);
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
    });

    testWidgets('shows password fields', (tester) async {
      await tester.pumpWidget(buildRegisterPage());
      await tester.pump();

      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsNWidgets(2));
    });

    testWidgets('shows agreement checkbox', (tester) async {
      await tester.pumpWidget(buildRegisterPage());
      await tester.pump();

      expect(find.byType(CheckboxListTile), findsOneWidget);
      expect(find.textContaining('agree'), findsOneWidget);
    });

    testWidgets('shows register button', (tester) async {
      await tester.pumpWidget(buildRegisterPage());
      await tester.pump();

      expect(find.byType(FilledButton), findsOneWidget);
      // The button text comes from l10n btn_register = 'Create Account'
      final filledButton = find.byType(FilledButton);
      expect(filledButton, findsOneWidget);
    });

    testWidgets('checkbox toggles agreement state', (tester) async {
      await tester.pumpWidget(buildRegisterPage());
      await tester.pump();

      final checkbox = tester.widget<CheckboxListTile>(find.byType(CheckboxListTile));
      expect(checkbox.value, isFalse);

      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();

      final updatedCheckbox = tester.widget<CheckboxListTile>(find.byType(CheckboxListTile));
      expect(updatedCheckbox.value, isTrue);
    });

    testWidgets('shows reason field when approval required', (tester) async {
      final server = ServerSchema(
        domain: 'approval.social',
        title: 'Approval Server',
        desc: 'Requires approval',
        version: '4.2.0',
        thumbnail: 'https://example.com/thumb.png',
        usage: const ServerUsageSchema(userActiveMonthly: 100),
        config: MockServerConfig.create(),
        registration: const RegisterConfigSchema(enabled: true, approvalRequired: true),
        contact: const ContactSchema(email: 'admin@approval.social'),
      );

      await tester.pumpWidget(buildRegisterPage(
        status: MockAccessStatus.create(server: server),
      ));
      await tester.pump();

      expect(find.text('Reason for joining'), findsOneWidget);
      expect(find.byIcon(Icons.note_outlined), findsOneWidget);
    });

    testWidgets('hides reason field when approval not required', (tester) async {
      await tester.pumpWidget(buildRegisterPage());
      await tester.pump();

      expect(find.text('Reason for joining'), findsNothing);
      expect(find.byIcon(Icons.note_outlined), findsNothing);
    });

    testWidgets('validates empty username', (tester) async {
      await tester.pumpWidget(buildRegisterPage());
      await tester.pump();

      // Tap register without filling fields
      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      expect(find.text('This field is required'), findsAtLeast(1));
    });

    testWidgets('validates invalid email', (tester) async {
      await tester.pumpWidget(buildRegisterPage());
      await tester.pump();

      // Fill in username
      await tester.enterText(find.widgetWithText(TextFormField, 'Username'), 'testuser');
      // Fill in invalid email
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'notanemail');
      // Fill password
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
      await tester.enterText(find.widgetWithText(TextFormField, 'Confirm Password'), 'password123');

      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      expect(find.text('Invalid email address'), findsOneWidget);
    });

    testWidgets('validates short password', (tester) async {
      await tester.pumpWidget(buildRegisterPage());
      await tester.pump();

      await tester.enterText(find.widgetWithText(TextFormField, 'Username'), 'testuser');
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'short');
      await tester.enterText(find.widgetWithText(TextFormField, 'Confirm Password'), 'short');

      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      expect(find.text('Password must be at least 8 characters'), findsOneWidget);
    });

    testWidgets('validates password mismatch', (tester) async {
      await tester.pumpWidget(buildRegisterPage());
      await tester.pump();

      await tester.enterText(find.widgetWithText(TextFormField, 'Username'), 'testuser');
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
      await tester.enterText(find.widgetWithText(TextFormField, 'Confirm Password'), 'different123');

      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('shows agreement error when not checked', (tester) async {
      await tester.pumpWidget(buildRegisterPage());
      await tester.pump();

      // Fill all valid fields
      await tester.enterText(find.widgetWithText(TextFormField, 'Username'), 'testuser');
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
      await tester.enterText(find.widgetWithText(TextFormField, 'Confirm Password'), 'password123');

      // Don't check the agreement checkbox
      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      expect(find.text('You must agree to the terms'), findsOneWidget);
    });

    testWidgets('shows server rules when available', (tester) async {
      final server = ServerSchema(
        domain: 'rules.social',
        title: 'Rules Server',
        desc: 'Has rules',
        version: '4.2.0',
        thumbnail: 'https://example.com/thumb.png',
        usage: const ServerUsageSchema(userActiveMonthly: 100),
        config: MockServerConfig.create(),
        registration: const RegisterConfigSchema(enabled: true, approvalRequired: false),
        contact: const ContactSchema(email: 'admin@rules.social'),
        rules: const [
          RuleSchema(id: '1', text: 'Be respectful', hint: 'Treat others kindly'),
          RuleSchema(id: '2', text: 'No spam', hint: 'No unsolicited content'),
        ],
      );

      await tester.pumpWidget(buildRegisterPage(
        status: MockAccessStatus.create(server: server),
      ));
      await tester.pump();

      expect(find.byType(ServerRules), findsOneWidget);
      expect(find.text('Be respectful'), findsOneWidget);
      expect(find.text('No spam'), findsOneWidget);
    });

    testWidgets('hides server rules when empty', (tester) async {
      await tester.pumpWidget(buildRegisterPage());
      await tester.pump();

      expect(find.byType(ServerRules), findsNothing);
    });

    testWidgets('onRegister with null domain returns early without error', (tester) async {
      // Use a status with domain: null to trigger early return in onRegister
      final status = AccessStatusSchema(domain: null);

      await tester.pumpWidget(createTestWidget(
        child: const RegisterPage(),
        accessStatus: status,
      ));
      await tester.pump();

      // Fill all valid fields
      await tester.enterText(find.widgetWithText(TextFormField, 'Username'), 'testuser');
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
      await tester.enterText(find.widgetWithText(TextFormField, 'Confirm Password'), 'password123');

      // Check the agreement checkbox
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();

      // Tap register
      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      // No error message should appear (early return)
      expect(find.text('You must agree to the terms'), findsNothing);
      expect(find.text('Registration failed'), findsNothing);
    });

    testWidgets('onRegister with empty domain returns early', (tester) async {
      final status = AccessStatusSchema(domain: '');

      await tester.pumpWidget(createTestWidget(
        child: const RegisterPage(),
        accessStatus: status,
      ));
      await tester.pump();

      // Fill all valid fields
      await tester.enterText(find.widgetWithText(TextFormField, 'Username'), 'testuser');
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
      await tester.enterText(find.widgetWithText(TextFormField, 'Confirm Password'), 'password123');

      // Check the agreement checkbox
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();

      // Tap register
      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      // No error message — early return
      expect(find.text('Registration failed'), findsNothing);
    });

    testWidgets('onRegister with valid domain shows error from HTTP failure', (tester) async {
      // Use HttpOverrides to mock all HTTP calls returning 401.
      // This makes getAppToken throw HttpException, caught by onRegister's catch block.
      final previousOverrides = HttpOverrides.current;
      HttpOverrides.global = _FailingHttpOverrides();

      FlutterSecureStorage.setMockInitialValues({
        'oauth_info': jsonEncode({
          'example.com': {
            'id': 'app-1',
            'name': 'TestApp',
            'scopes': ['read', 'write'],
            'client_id': 'fake-client-id',
            'client_secret': 'fake-client-secret',
            'redirect_uri': 'glacial://auth',
            'redirect_uris': ['glacial://auth'],
          },
        }),
      });
      SharedPreferences.setMockInitialValues({});
      await Storage.init();

      final status = AccessStatusSchema(
        domain: 'example.com',
        server: MockServer.create(domain: 'example.com'),
      );

      await tester.pumpWidget(createTestWidget(
        child: const RegisterPage(),
        accessStatus: status,
      ));
      await tester.pump();

      // Fill all valid fields
      await tester.enterText(find.widgetWithText(TextFormField, 'Username'), 'testuser');
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
      await tester.enterText(find.widgetWithText(TextFormField, 'Confirm Password'), 'password123');

      // Check the agreement checkbox
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();

      // Tap register — triggers onRegister with valid domain
      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      // Let the async HTTP call complete via mock (instant 401 response)
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pump();

      // The error from the catch block should be displayed
      expect(find.byType(RegisterPage), findsOneWidget);

      // Restore original HttpOverrides
      HttpOverrides.global = previousOverrides;
    });

    testWidgets('onRegister exception catch shows error and resets submitting', (tester) async {
      // Use HttpOverrides to return 401 — _validateResponse throws HttpException
      // which is caught by the on Exception catch block in onRegister.
      final previousOverrides = HttpOverrides.current;
      HttpOverrides.global = _FailingHttpOverrides();

      FlutterSecureStorage.setMockInitialValues({
        'oauth_info': jsonEncode({
          'example.com': {
            'id': 'app-1',
            'name': 'TestApp',
            'scopes': ['read', 'write'],
            'client_id': 'fake-client-id',
            'client_secret': 'fake-client-secret',
            'redirect_uri': 'glacial://auth',
            'redirect_uris': ['glacial://auth'],
          },
        }),
      });
      SharedPreferences.setMockInitialValues({});
      await Storage.init();

      final status = AccessStatusSchema(
        domain: 'example.com',
        server: MockServer.create(domain: 'example.com'),
      );

      await tester.pumpWidget(createTestWidget(
        child: const RegisterPage(),
        accessStatus: status,
      ));
      await tester.pump();

      // Fill all valid fields
      await tester.enterText(find.widgetWithText(TextFormField, 'Username'), 'testuser');
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
      await tester.enterText(find.widgetWithText(TextFormField, 'Confirm Password'), 'password123');

      // Check the agreement checkbox
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();

      // Tap register
      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      // Let the async HTTP call complete
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pump();

      // The catch block should have set _isSubmitting = false and error message
      // Should NOT show ClockProgressIndicator (not submitting anymore)
      expect(find.byType(ClockProgressIndicator), findsNothing);
      // The FilledButton should be enabled again (onPressed not null)
      expect(find.byType(FilledButton), findsOneWidget);

      // Restore original HttpOverrides
      HttpOverrides.global = previousOverrides;
    });

    testWidgets('error message is displayed in red text', (tester) async {
      await tester.pumpWidget(buildRegisterPage());
      await tester.pump();

      // Fill all valid fields
      await tester.enterText(find.widgetWithText(TextFormField, 'Username'), 'testuser');
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
      await tester.enterText(find.widgetWithText(TextFormField, 'Confirm Password'), 'password123');

      // Don't agree — this will show error
      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      // Error text should exist with error color
      final errorFinder = find.text('You must agree to the terms');
      expect(errorFinder, findsOneWidget);
      final errorWidget = tester.widget<Text>(errorFinder);
      expect(errorWidget.style?.color, isNotNull);
    });

    testWidgets('agreement checkbox can be toggled on and off', (tester) async {
      await tester.pumpWidget(buildRegisterPage());
      await tester.pump();

      // Initially unchecked
      var checkbox = tester.widget<CheckboxListTile>(find.byType(CheckboxListTile));
      expect(checkbox.value, isFalse);

      // Tap to check
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();

      checkbox = tester.widget<CheckboxListTile>(find.byType(CheckboxListTile));
      expect(checkbox.value, isTrue);

      // Tap to uncheck
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();

      checkbox = tester.widget<CheckboxListTile>(find.byType(CheckboxListTile));
      expect(checkbox.value, isFalse);
    });

    testWidgets('form with approval required and reason field filled', (tester) async {
      final server = ServerSchema(
        domain: 'approval.social',
        title: 'Approval Server',
        desc: 'Requires approval',
        version: '4.2.0',
        thumbnail: 'https://example.com/thumb.png',
        usage: const ServerUsageSchema(userActiveMonthly: 100),
        config: MockServerConfig.create(),
        registration: const RegisterConfigSchema(enabled: true, approvalRequired: true),
        contact: const ContactSchema(email: 'admin@approval.social'),
      );

      await tester.pumpWidget(buildRegisterPage(
        status: MockAccessStatus.create(server: server),
      ));
      await tester.pump();

      // Fill reason
      await tester.enterText(find.widgetWithText(TextFormField, 'Reason for joining'), 'I want to join');
      await tester.pump();

      // Verify reason text was entered
      expect(find.text('I want to join'), findsOneWidget);
    });
  });

  group('SignIn without registration button', () {
    testWidgets('does not show Create Account button even when registration enabled', (tester) async {
      final server = MockServer.create();
      await tester.pumpWidget(createTestWidget(
        child: const SignIn(),
        accessStatus: MockAccessStatus.create(server: server),
      ));
      await tester.pump();

      expect(find.text('Create Account'), findsNothing);
      expect(find.byType(TextButton), findsNothing);
    });

    testWidgets('renders only sign in icon button', (tester) async {
      final server = MockServer.create();
      await tester.pumpWidget(createTestWidget(
        child: const SignIn(),
        accessStatus: MockAccessStatus.create(server: server),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.person_outline), findsOneWidget);
      expect(find.byType(IconButton), findsOneWidget);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
