// The WebSocket streaming connection manager for the Mastodon Streaming API.
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:glacial/cores/misc.dart';
import 'package:glacial/features/mastodon/models/streaming.dart';

const Duration maxReconnectDelay = Duration(minutes: 5);
const Duration baseReconnectDelay = Duration(seconds: 1);
const double reconnectMultiplier = 2.0;
const double reconnectJitter = 0.25;

enum StreamingConnectionState { disconnected, connecting, connected, reconnecting }

typedef ChannelFactory = WebSocketChannel Function(Uri uri);

class StreamingService {
  final String domain;
  final String? accessToken;
  final ChannelFactory? _channelFactory;

  WebSocketChannel? _channel;
  StreamSubscription? _channelSubscription;
  StreamingConnectionState _state = StreamingConnectionState.disconnected;
  final Map<String, int> _subscriptions = {};
  final StreamController<StreamingEvent> _eventController = StreamController<StreamingEvent>.broadcast();
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;
  bool _paused = false;

  StreamingService({
    required this.domain,
    this.accessToken,
    ChannelFactory? channelFactory,
  }) : _channelFactory = channelFactory;

  StreamingConnectionState get state => _state;
  Stream<StreamingEvent> get events => _eventController.stream;
  Map<String, int> get subscriptions => Map.unmodifiable(_subscriptions);
  bool get isPaused => _paused;

  static String buildKey(StreamType type, {String? tag, String? listId}) {
    return switch (type) {
      StreamType.hashtag => 'hashtag:${tag ?? ''}',
      StreamType.list => 'list:${listId ?? ''}',
      _ => type.streamName,
    };
  }

  VoidCallback subscribe(StreamType type, {String? tag, String? listId}) {
    final String key = buildKey(type, tag: tag, listId: listId);
    _subscriptions[key] = (_subscriptions[key] ?? 0) + 1;

    if (_subscriptions[key] == 1) {
      if (_state == StreamingConnectionState.disconnected) {
        connect();
      } else if (_state == StreamingConnectionState.connected) {
        _sendSubscribe(type, tag: tag, listId: listId);
      }
    }

    bool unsubscribed = false;
    return () {
      if (unsubscribed) return;
      unsubscribed = true;
      _unsubscribe(key, type, tag: tag, listId: listId);
    };
  }

  void _unsubscribe(String key, StreamType type, {String? tag, String? listId}) {
    final int count = _subscriptions[key] ?? 0;
    if (count <= 1) {
      _subscriptions.remove(key);
      if (_state == StreamingConnectionState.connected) {
        _sendUnsubscribe(type, tag: tag, listId: listId);
      }
      if (_subscriptions.isEmpty) {
        disconnect();
      }
    } else {
      _subscriptions[key] = count - 1;
    }
  }

  Future<void> connect() async {
    if (_state == StreamingConnectionState.connected || _state == StreamingConnectionState.connecting) return;

    _state = StreamingConnectionState.connecting;

    try {
      final Uri uri = Uri.parse('wss://$domain/api/v1/streaming');
      final Uri wsUri = accessToken != null
          ? uri.replace(queryParameters: {'access_token': accessToken})
          : uri;

      _channel = _channelFactory != null ? _channelFactory(wsUri) : WebSocketChannel.connect(wsUri);

      if (_channelFactory == null) {
        await _channel!.ready;
      }

      _state = StreamingConnectionState.connected;
      _reconnectAttempts = 0;
      logger.d('[WS] Connected to $domain');

      _channelSubscription = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
      );

      // Re-subscribe to all active streams.
      for (final key in _subscriptions.keys) {
        final parts = key.split(':');
        final StreamType? type = _streamTypeFromKey(key);
        if (type != null) {
          _sendSubscribe(type, tag: parts.length > 1 ? parts.sublist(1).join(':') : null, listId: parts.length > 1 ? parts[1] : null);
        }
      }
    } catch (e) {
      logger.e('[WS] Connection failed to $domain: $e');
      _state = StreamingConnectionState.disconnected;
      _scheduleReconnect();
    }
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _channelSubscription?.cancel();
    _channelSubscription = null;
    _channel?.sink.close();
    _channel = null;
    _state = StreamingConnectionState.disconnected;
    _reconnectAttempts = 0;
  }

  void pause() {
    _paused = true;
    _channelSubscription?.cancel();
    _channelSubscription = null;
    _channel?.sink.close();
    _channel = null;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _state = StreamingConnectionState.disconnected;
  }

  void resume() {
    _paused = false;
    if (_subscriptions.isNotEmpty) {
      connect();
    }
  }

  void dispose() {
    disconnect();
    _eventController.close();
  }

  StreamType? _streamTypeFromKey(String key) {
    final String name = key.contains(':') ? key.substring(0, key.indexOf(':')) : key;
    for (final type in StreamType.values) {
      if (type.streamName == name) return type;
    }
    return null;
  }

  void _sendSubscribe(StreamType type, {String? tag, String? listId}) {
    final Map<String, dynamic> message = {
      'type': 'subscribe',
      'stream': type.streamName,
    };
    if (type == StreamType.hashtag && tag != null) message['tag'] = tag;
    if (type == StreamType.list && listId != null) message['list'] = listId;
    _channel?.sink.add(jsonEncode(message));
  }

  void _sendUnsubscribe(StreamType type, {String? tag, String? listId}) {
    final Map<String, dynamic> message = {
      'type': 'unsubscribe',
      'stream': type.streamName,
    };
    if (type == StreamType.hashtag && tag != null) message['tag'] = tag;
    if (type == StreamType.list && listId != null) message['list'] = listId;
    _channel?.sink.add(jsonEncode(message));
  }

  void _onMessage(dynamic data) {
    try {
      final Map<String, dynamic> json = jsonDecode(data as String);
      final event = StreamingEvent.fromJson(json);
      _eventController.add(event);
    } catch (e) {
      logger.w('[WS] Failed to parse message: $e');
    }
  }

  void _onError(Object error) {
    logger.e('[WS] Error on $domain: $error');
    _handleDisconnect();
  }

  void _onDone() {
    logger.d('[WS] Connection closed for $domain');
    _handleDisconnect();
  }

  void _handleDisconnect() {
    _channelSubscription?.cancel();
    _channelSubscription = null;
    _channel = null;
    _state = StreamingConnectionState.disconnected;

    if (!_paused && _subscriptions.isNotEmpty) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_paused || _subscriptions.isEmpty) return;

    _state = StreamingConnectionState.reconnecting;
    final Duration delay = reconnectDelay(_reconnectAttempts);
    _reconnectAttempts++;

    logger.d('[WS] Reconnecting to $domain in ${delay.inMilliseconds}ms (attempt $_reconnectAttempts)');

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () {
      if (!_paused && _subscriptions.isNotEmpty) {
        connect();
      }
    });
  }

  static Duration reconnectDelay(int attempt) {
    final double base = baseReconnectDelay.inMilliseconds * pow(reconnectMultiplier, attempt).toDouble();
    final double capped = min(base, maxReconnectDelay.inMilliseconds.toDouble());
    final double jitter = capped * reconnectJitter * (Random().nextDouble() * 2 - 1);
    return Duration(milliseconds: (capped + jitter).round());
  }
}

// Global service registry, keyed by domain.
final Map<String, StreamingService> _services = {};

StreamingService getStreamingService(String domain, {String? accessToken, ChannelFactory? channelFactory}) {
  return _services.putIfAbsent(domain, () => StreamingService(
    domain: domain,
    accessToken: accessToken,
    channelFactory: channelFactory,
  ));
}

void disposeStreamingService(String domain) {
  _services.remove(domain)?.dispose();
}

void pauseAllStreaming() {
  for (final service in _services.values) {
    service.pause();
  }
}

void resumeAllStreaming() {
  for (final service in _services.values) {
    service.resume();
  }
}

// vim: set ts=2 sw=2 sts=2 et:
