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

  group('StreamingService disconnect', () {
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

    test('disconnect clears state and resets attempts', () async {
      service.subscribe(StreamType.user);
      await Future.delayed(Duration.zero);

      expect(service.state, StreamingConnectionState.connected);

      service.disconnect();

      expect(service.state, StreamingConnectionState.disconnected);
    });

    test('disconnect is idempotent', () {
      service.disconnect();
      service.disconnect();

      expect(service.state, StreamingConnectionState.disconnected);
    });

    test('connect while already connected is no-op', () async {
      service.subscribe(StreamType.user);
      await Future.delayed(Duration.zero);

      expect(service.state, StreamingConnectionState.connected);

      // Second connect should be ignored
      await service.connect();

      expect(service.state, StreamingConnectionState.connected);
    });
  });

  group('StreamingService error handling', () {
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

    test('connection failure with throwing factory schedules reconnect', () async {
      int callCount = 0;
      final failService = StreamingService(
        domain: 'fail.social',
        channelFactory: (_) {
          callCount++;
          throw Exception('Connection refused');
        },
      );

      failService.subscribe(StreamType.user);
      await Future.delayed(Duration.zero);

      expect(failService.state, StreamingConnectionState.reconnecting);
      expect(callCount, 1);

      failService.dispose();
    });
  });

  group('StreamingService _streamTypeFromKey', () {
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

    test('subscribe sends re-subscribe messages on reconnect', () async {
      // Subscribe to user stream
      service.subscribe(StreamType.user);
      await Future.delayed(Duration.zero);

      expect(service.state, StreamingConnectionState.connected);
      // First subscribe message
      expect(mockChannel.sentMessages.length, greaterThanOrEqualTo(1));

      // Subscribe to hashtag stream
      service.subscribe(StreamType.hashtag, tag: 'dart');
      await Future.delayed(Duration.zero);

      // Should have sent a subscribe for hashtag too
      final lastMsg = jsonDecode(mockChannel.sentMessages.last);
      expect(lastMsg['type'], 'subscribe');
      expect(lastMsg['stream'], 'hashtag');
      expect(lastMsg['tag'], 'dart');
    });

    test('subscribe with list sends list parameter on connected', () async {
      service.subscribe(StreamType.user);
      await Future.delayed(Duration.zero);

      service.subscribe(StreamType.list, listId: '42');
      await Future.delayed(Duration.zero);

      final listMsg = mockChannel.sentMessages
          .map((s) => jsonDecode(s) as Map<String, dynamic>)
          .where((m) => m['stream'] == 'list')
          .first;
      expect(listMsg['list'], '42');
    });
  });

  group('StreamingService pause/resume edge cases', () {
    test('resume without subscriptions does not connect', () {
      final service = StreamingService(
        domain: 'test.social',
        channelFactory: (_) => MockWebSocketChannel(),
      );

      service.resume();

      expect(service.state, StreamingConnectionState.disconnected);
      expect(service.isPaused, isFalse);

      service.dispose();
    });

    test('pause then resume reconnects subscriptions', () async {
      int callCount = 0;
      final channels = [MockWebSocketChannel(), MockWebSocketChannel()];

      final service = StreamingService(
        domain: 'test.social',
        accessToken: 'token',
        channelFactory: (_) {
          final ch = channels[callCount.clamp(0, 1)];
          callCount++;
          return ch;
        },
      );

      service.subscribe(StreamType.user);
      await Future.delayed(Duration.zero);

      expect(service.state, StreamingConnectionState.connected);

      service.pause();
      expect(service.state, StreamingConnectionState.disconnected);
      expect(service.isPaused, isTrue);

      service.resume();
      await Future.delayed(Duration.zero);

      expect(service.state, StreamingConnectionState.connected);
      expect(service.isPaused, isFalse);

      service.dispose();
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

  group('pauseAllStreaming and resumeAllStreaming', () {
    tearDown(() {
      disposeStreamingService('pause-test.social');
      disposeStreamingService('pause-test.social@user1');
    });

    test('pauseAllStreaming pauses all registered services', () async {
      final ch1 = MockWebSocketChannel();
      final ch2 = MockWebSocketChannel();

      final s1 = getStreamingService('pause-test.social',
          accessToken: 'token', channelFactory: (_) => ch1);
      final s2 = getStreamingService('pause-test.social',
          accountId: 'user1', accessToken: 'token', channelFactory: (_) => ch2);

      s1.subscribe(StreamType.user);
      s2.subscribe(StreamType.user);
      await Future.delayed(Duration.zero);

      expect(s1.state, StreamingConnectionState.connected);
      expect(s2.state, StreamingConnectionState.connected);

      pauseAllStreaming();

      expect(s1.isPaused, isTrue);
      expect(s2.isPaused, isTrue);
      expect(s1.state, StreamingConnectionState.disconnected);
      expect(s2.state, StreamingConnectionState.disconnected);
    });

    test('resumeAllStreaming resumes all paused services', () async {
      final channels = <MockWebSocketChannel>[];
      final s1 = getStreamingService('pause-test.social',
          accessToken: 'token', channelFactory: (_) {
        final ch = MockWebSocketChannel();
        channels.add(ch);
        return ch;
      });

      s1.subscribe(StreamType.user);
      await Future.delayed(Duration.zero);

      pauseAllStreaming();
      expect(s1.isPaused, isTrue);

      resumeAllStreaming();
      await Future.delayed(Duration.zero);

      expect(s1.isPaused, isFalse);
      expect(s1.state, StreamingConnectionState.connected);
    });
  });

  group('StreamingService.buildKey edge cases', () {
    test('builds key for hashtag without tag parameter', () {
      expect(StreamingService.buildKey(StreamType.hashtag), 'hashtag:');
    });

    test('builds key for list without listId parameter', () {
      expect(StreamingService.buildKey(StreamType.list), 'list:');
    });

    test('builds key for direct stream', () {
      expect(StreamingService.buildKey(StreamType.direct), 'direct');
    });
  });

  group('StreamingService unsubscribe edge cases', () {
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

    test('unsubscribing sends unsubscribe message when other subs remain', () async {
      // Subscribe to two streams so unsubscribing one doesn't trigger disconnect
      final unsub = service.subscribe(StreamType.user);
      service.subscribe(StreamType.direct);
      await Future.delayed(Duration.zero);

      unsub();
      await Future.delayed(Duration.zero);

      // Should find an unsubscribe message among sent messages
      final unsubMsgs = mockChannel.sentMessages
          .map((s) => jsonDecode(s) as Map<String, dynamic>)
          .where((m) => m['type'] == 'unsubscribe')
          .toList();
      expect(unsubMsgs, isNotEmpty);
      expect(unsubMsgs.first['stream'], 'user');
    });

    test('unsubscribing hashtag sends tag in unsubscribe message', () async {
      // Keep user stream active so disconnect doesn't fire
      service.subscribe(StreamType.user);
      final unsub = service.subscribe(StreamType.hashtag, tag: 'flutter');
      await Future.delayed(Duration.zero);

      unsub();
      await Future.delayed(Duration.zero);

      final unsubMsgs = mockChannel.sentMessages
          .map((s) => jsonDecode(s) as Map<String, dynamic>)
          .where((m) => m['type'] == 'unsubscribe')
          .toList();
      expect(unsubMsgs, isNotEmpty);
      expect(unsubMsgs.first['stream'], 'hashtag');
      expect(unsubMsgs.first['tag'], 'flutter');
    });

    test('unsubscribing list sends listId in unsubscribe message', () async {
      // Keep user stream active so disconnect doesn't fire
      service.subscribe(StreamType.user);
      final unsub = service.subscribe(StreamType.list, listId: '99');
      await Future.delayed(Duration.zero);

      unsub();
      await Future.delayed(Duration.zero);

      final unsubMsgs = mockChannel.sentMessages
          .map((s) => jsonDecode(s) as Map<String, dynamic>)
          .where((m) => m['type'] == 'unsubscribe')
          .toList();
      expect(unsubMsgs, isNotEmpty);
      expect(unsubMsgs.first['stream'], 'list');
      expect(unsubMsgs.first['list'], '99');
    });
  });

  group('StreamingService events edge cases', () {
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

    test('multiple event types are dispatched correctly', () async {
      service.subscribe(StreamType.user);
      await Future.delayed(Duration.zero);

      final events = <StreamingEvent>[];
      service.events.listen(events.add);

      // Send update event
      mockChannel.addIncoming(jsonEncode({
        'event': 'update',
        'stream': ['user'],
        'payload': '{}',
      }));

      // Send filters_changed event
      mockChannel.addIncoming(jsonEncode({
        'event': 'filters_changed',
        'stream': ['user'],
      }));

      await Future.delayed(Duration.zero);

      expect(events.length, 2);
      expect(events[0].type, StreamingEventType.update);
      expect(events[1].type, StreamingEventType.filtersChanged);
    });

    test('event with unknown type is parsed as unknown', () async {
      service.subscribe(StreamType.user);
      await Future.delayed(Duration.zero);

      final events = <StreamingEvent>[];
      service.events.listen(events.add);

      mockChannel.addIncoming(jsonEncode({
        'event': 'some_new_event',
        'stream': ['user'],
      }));

      await Future.delayed(Duration.zero);

      expect(events.length, 1);
      expect(events.first.type, StreamingEventType.unknown);
    });
  });

  // ---------------------------------------------------------------------------
  // Connection error and done handling
  // ---------------------------------------------------------------------------

  group('StreamingService connection lifecycle', () {
    late MockWebSocketChannel mockChannel;
    late StreamingService service;

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

    test('stream error triggers _handleDisconnect and reconnect', () async {
      service.subscribe(StreamType.user);
      await Future.delayed(Duration.zero);

      // Trigger an error on the stream
      mockChannel._incomingController.addError(Exception('Connection lost'));
      await Future.delayed(Duration.zero);

      // After error, state should be reconnecting (since subscriptions exist)
      expect(service.state, StreamingConnectionState.reconnecting);
    });

    test('stream done triggers _handleDisconnect', () async {
      service.subscribe(StreamType.user);
      await Future.delayed(Duration.zero);

      // Close the stream (triggers _onDone)
      await mockChannel._incomingController.close();
      await Future.delayed(Duration.zero);

      // After done, state should be reconnecting (since subscriptions exist)
      expect(service.state, StreamingConnectionState.reconnecting);
    });

    test('stream done without subscriptions stays disconnected', () async {
      final unsub = service.subscribe(StreamType.user);
      await Future.delayed(Duration.zero);

      // Unsubscribe first, then trigger close
      unsub();
      await Future.delayed(Duration.zero);

      // Service should be disconnected, not reconnecting
      expect(service.state, StreamingConnectionState.disconnected);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
