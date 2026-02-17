// The Mastodon Streaming API data models.
import 'dart:convert';

import 'package:glacial/features/timeline/models/timeline.dart';
import 'package:glacial/features/timeline/models/status.dart';

enum StreamingEventType {
  update,
  delete,
  notification,
  statusUpdate,
  filtersChanged,
  unknown;

  factory StreamingEventType.fromString(String value) {
    return switch (value) {
      'update' => StreamingEventType.update,
      'delete' => StreamingEventType.delete,
      'notification' => StreamingEventType.notification,
      'status.update' => StreamingEventType.statusUpdate,
      'filters_changed' => StreamingEventType.filtersChanged,
      _ => StreamingEventType.unknown,
    };
  }
}

enum StreamType {
  user,
  publicLocal,
  publicRemote,
  public,
  hashtag,
  list,
  direct;

  String get streamName => switch (this) {
    StreamType.user => 'user',
    StreamType.publicLocal => 'public:local',
    StreamType.publicRemote => 'public:remote',
    StreamType.public => 'public',
    StreamType.hashtag => 'hashtag',
    StreamType.list => 'list',
    StreamType.direct => 'direct',
  };
}

class StreamingEvent {
  final StreamingEventType type;
  final List<String> stream;
  final String? payload;

  const StreamingEvent({
    required this.type,
    this.stream = const [],
    this.payload,
  });

  factory StreamingEvent.fromJson(Map<String, dynamic> json) {
    return StreamingEvent(
      type: StreamingEventType.fromString(json['event'] as String? ?? ''),
      stream: (json['stream'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      payload: json['payload'] as String?,
    );
  }

  StatusSchema? get status {
    if (payload == null) return null;
    try {
      final Map<String, dynamic> json = jsonDecode(payload!);
      return StatusSchema.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  String? get deletedStatusId {
    if (type != StreamingEventType.delete) return null;
    return payload;
  }
}

StreamType? streamTypeForTimeline(TimelineType type) {
  return switch (type) {
    TimelineType.home => StreamType.user,
    TimelineType.local => StreamType.publicLocal,
    TimelineType.federal => StreamType.publicRemote,
    TimelineType.public => StreamType.public,
    TimelineType.hashtag => StreamType.hashtag,
    TimelineType.list => StreamType.list,
    _ => null,
  };
}

// Check whether a streaming event belongs to the given timeline type.
// For hashtag/list streams, also verifies the specific tag or list ID.
bool isEventForTimeline(StreamingEvent event, TimelineType type, {String? hashtag, String? listId}) {
  final StreamType? streamType = streamTypeForTimeline(type);
  if (streamType == null) return false;
  if (!event.stream.contains(streamType.streamName)) return false;

  if (streamType == StreamType.hashtag && hashtag != null) {
    return event.stream.contains(hashtag);
  }
  if (streamType == StreamType.list && listId != null) {
    return event.stream.contains(listId);
  }

  return true;
}

// vim: set ts=2 sw=2 sts=2 et:
