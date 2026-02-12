import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:glacial/cores/streaming.dart';
import 'package:glacial/features/mastodon/models/streaming.dart';

// A mock WebSocket channel that exposes controllers for testing.
class MockWebSocketChannel implements WebSocketChannel {
  final StreamController<dynamic> _incomingController = StreamController<dynamic>.broadcast();
  final StreamController<dynamic> _outgoingController = StreamController<dynamic>();
  late final _MockSink _sink;

  final List<String> sentMessages = [];

  MockWebSocketChannel() {
    _sink = _MockSink(_outgoingController);
    _outgoingController.stream.listen((data) {
      sentMessages.add(data as String);
    });
  }

  void addIncoming(String data) => _incomingController.add(data);

  @override
  Stream<dynamic> get stream => _incomingController.stream;

  @override
  WebSocketSink get sink => _sink;

  @override
  int? get closeCode => null;

  @override
  String? get closeReason => null;

  @override
  String? get protocol => null;

  @override
  Future<void> get ready => Future.value();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockSink implements WebSocketSink {
  final StreamController<dynamic> _controller;

  _MockSink(this._controller);

  @override
  void add(dynamic data) => _controller.add(data);

  @override
  void addError(Object error, [StackTrace? stackTrace]) => _controller.addError(error, stackTrace);

  @override
  Future addStream(Stream stream) => _controller.addStream(stream);

  @override
  Future close([int? closeCode, String? closeReason]) async {
    await _controller.close();
  }

  @override
  Future get done => _controller.done;
}

void main() {
  group('StreamingService.buildKey', () {
    test('builds key for simple stream types', () {
      expect(StreamingService.buildKey(StreamType.user), 'user');
      expect(StreamingService.buildKey(StreamType.publicLocal), 'public:local');
      expect(StreamingService.buildKey(StreamType.publicRemote), 'public:remote');
      expect(StreamingService.buildKey(StreamType.public), 'public');
      expect(StreamingService.buildKey(StreamType.direct), 'direct');
    });

    test('builds key for hashtag with tag', () {
      expect(StreamingService.buildKey(StreamType.hashtag, tag: 'flutter'), 'hashtag:flutter');
    });

    test('builds key for list with listId', () {
      expect(StreamingService.buildKey(StreamType.list, listId: '42'), 'list:42');
    });

    test('builds key for hashtag without tag', () {
      expect(StreamingService.buildKey(StreamType.hashtag), 'hashtag:');
    });
  });

  group('StreamingService subscriptions', () {
    late StreamingService service;
    late MockWebSocketChannel mockChannel;

    setUp(() {
      mockChannel = MockWebSocketChannel();
      service = StreamingService(
        domain: 'mastodon.social',
        accessToken: 'test-token',
        channelFactory: (_) => mockChannel,
      );
    });

    tearDown(() {
      service.dispose();
    });

    test('starts in disconnected state', () {
      expect(service.state, StreamingConnectionState.disconnected);
    });

    test('subscribe connects and sends subscribe message', () async {
      service.subscribe(StreamType.user);

      // Allow async connect to complete.
      await Future.delayed(Duration.zero);

      expect(service.state, StreamingConnectionState.connected);
      expect(service.subscriptions, {'user': 1});

      // Check that a subscribe message was sent.
      expect(mockChannel.sentMessages, isNotEmpty);
      final msg = jsonDecode(mockChannel.sentMessages.first);
      expect(msg['type'], 'subscribe');
      expect(msg['stream'], 'user');
    });

    test('reference counting increments on multiple subscribes', () async {
      service.subscribe(StreamType.user);
      service.subscribe(StreamType.user);

      await Future.delayed(Duration.zero);

      expect(service.subscriptions['user'], 2);
    });

    test('unsubscribe decrements reference count', () async {
      final unsub1 = service.subscribe(StreamType.user);
      service.subscribe(StreamType.user);

      await Future.delayed(Duration.zero);

      unsub1();
      expect(service.subscriptions['user'], 1);
    });

    test('last unsubscribe removes key and disconnects', () async {
      final unsub = service.subscribe(StreamType.user);

      await Future.delayed(Duration.zero);

      unsub();

      // Allow disconnect to complete.
      await Future.delayed(Duration.zero);

      expect(service.subscriptions, isEmpty);
      expect(service.state, StreamingConnectionState.disconnected);
    });

    test('unsubscribe callback is idempotent', () async {
      final unsub = service.subscribe(StreamType.user);
      service.subscribe(StreamType.user);

      await Future.delayed(Duration.zero);

      unsub();
      unsub(); // Second call should be no-op.
      expect(service.subscriptions['user'], 1);
    });

    test('subscribe with hashtag sends tag parameter', () async {
      service.subscribe(StreamType.hashtag, tag: 'dart');

      await Future.delayed(Duration.zero);

      expect(service.subscriptions, {'hashtag:dart': 1});
      final msg = jsonDecode(mockChannel.sentMessages.last);
      expect(msg['stream'], 'hashtag');
      expect(msg['tag'], 'dart');
    });

    test('subscribe with list sends list parameter', () async {
      service.subscribe(StreamType.list, listId: '99');

      await Future.delayed(Duration.zero);

      expect(service.subscriptions, {'list:99': 1});
      final msg = jsonDecode(mockChannel.sentMessages.last);
      expect(msg['stream'], 'list');
      expect(msg['list'], '99');
    });
  });

  group('StreamingService events', () {
    late StreamingService service;
    late MockWebSocketChannel mockChannel;

    setUp(() {
      mockChannel = MockWebSocketChannel();
      service = StreamingService(
        domain: 'mastodon.social',
        accessToken: 'test-token',
        channelFactory: (_) => mockChannel,
      );
    });

    tearDown(() {
      service.dispose();
    });

    test('broadcasts parsed events from WebSocket', () async {
      service.subscribe(StreamType.user);
      await Future.delayed(Duration.zero);

      final events = <StreamingEvent>[];
      service.events.listen(events.add);

      mockChannel.addIncoming(jsonEncode({
        'event': 'delete',
        'stream': ['user'],
        'payload': '12345',
      }));

      await Future.delayed(Duration.zero);

      expect(events.length, 1);
      expect(events.first.type, StreamingEventType.delete);
      expect(events.first.deletedStatusId, '12345');
    });

    test('ignores malformed messages', () async {
      service.subscribe(StreamType.user);
      await Future.delayed(Duration.zero);

      final events = <StreamingEvent>[];
      service.events.listen(events.add);

      mockChannel.addIncoming('not json');

      await Future.delayed(Duration.zero);

      expect(events, isEmpty);
    });
  });

  group('StreamingService pause/resume', () {
    late StreamingService service;
    late MockWebSocketChannel mockChannel;
    late MockWebSocketChannel resumeChannel;

    setUp(() {
      mockChannel = MockWebSocketChannel();
      int callCount = 0;
      resumeChannel = MockWebSocketChannel();

      service = StreamingService(
        domain: 'mastodon.social',
        accessToken: 'test-token',
        channelFactory: (_) {
          callCount++;
          return callCount == 1 ? mockChannel : resumeChannel;
        },
      );
    });

    tearDown(() {
      service.dispose();
    });

    test('pause disconnects without clearing subscriptions', () async {
      service.subscribe(StreamType.user);
      await Future.delayed(Duration.zero);

      service.pause();
      expect(service.isPaused, isTrue);
      expect(service.state, StreamingConnectionState.disconnected);
      expect(service.subscriptions, isNotEmpty);
    });

    test('resume reconnects with active subscriptions', () async {
      service.subscribe(StreamType.user);
      await Future.delayed(Duration.zero);

      service.pause();
      service.resume();

      await Future.delayed(Duration.zero);

      expect(service.isPaused, isFalse);
      expect(service.state, StreamingConnectionState.connected);
    });
  });

  group('StreamingService.reconnectDelay', () {
    test('first attempt uses base delay approximately', () {
      final delay = StreamingService.reconnectDelay(0);
      // Base is 1000ms, jitter up to ±25% → 750..1250
      expect(delay.inMilliseconds, greaterThanOrEqualTo(750));
      expect(delay.inMilliseconds, lessThanOrEqualTo(1250));
    });

    test('increases exponentially', () {
      final delay0 = StreamingService.reconnectDelay(0);
      final delay3 = StreamingService.reconnectDelay(3);
      // At attempt 3: base = 1000 * 2^3 = 8000ms
      // Even with jitter, attempt 3 should be significantly larger than attempt 0
      expect(delay3.inMilliseconds, greaterThan(delay0.inMilliseconds));
    });

    test('caps at maxReconnectDelay', () {
      final delay = StreamingService.reconnectDelay(100);
      // Max is 5 minutes = 300,000ms, with jitter up to +25% = 375,000
      expect(delay.inMilliseconds, lessThanOrEqualTo(375000));
    });
  });

  group('Global streaming helpers', () {
    tearDown(() {
      disposeStreamingService('test.social');
      disposeStreamingService('test.social@user1');
      disposeStreamingService('test.social@user2');
    });

    test('getStreamingService creates and reuses service', () {
      final s1 = getStreamingService('test.social', accessToken: 'token1');
      final s2 = getStreamingService('test.social', accessToken: 'token2');
      expect(identical(s1, s2), isTrue);
    });

    test('disposeStreamingService removes service', () {
      final s1 = getStreamingService('test.social');
      disposeStreamingService('test.social');
      final s2 = getStreamingService('test.social');
      expect(identical(s1, s2), isFalse);
    });

    test('getStreamingService with accountId creates composite key', () {
      final s1 = getStreamingService('test.social', accountId: 'user1');
      final s2 = getStreamingService('test.social', accountId: 'user1');
      expect(identical(s1, s2), isTrue);
    });

    test('different accountIds on same domain create separate services', () {
      final s1 = getStreamingService('test.social', accountId: 'user1');
      final s2 = getStreamingService('test.social', accountId: 'user2');
      expect(identical(s1, s2), isFalse);
    });

    test('disposeStreamingService with composite key', () {
      final s1 = getStreamingService('test.social', accountId: 'user1');
      disposeStreamingService('test.social@user1');
      final s2 = getStreamingService('test.social', accountId: 'user1');
      expect(identical(s1, s2), isFalse);
    });

    test('service without accountId is separate from service with accountId', () {
      final s1 = getStreamingService('test.social');
      final s2 = getStreamingService('test.social', accountId: 'user1');
      expect(identical(s1, s2), isFalse);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
