import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/features/mastodon/models/streaming.dart';
import 'package:glacial/features/timeline/models/timeline.dart';

void main() {
  group('StreamingEventType', () {
    test('fromString maps known event names', () {
      expect(StreamingEventType.fromString('update'), StreamingEventType.update);
      expect(StreamingEventType.fromString('delete'), StreamingEventType.delete);
      expect(StreamingEventType.fromString('notification'), StreamingEventType.notification);
      expect(StreamingEventType.fromString('status.update'), StreamingEventType.statusUpdate);
      expect(StreamingEventType.fromString('filters_changed'), StreamingEventType.filtersChanged);
    });

    test('fromString returns unknown for unrecognized events', () {
      expect(StreamingEventType.fromString('foo'), StreamingEventType.unknown);
      expect(StreamingEventType.fromString(''), StreamingEventType.unknown);
    });
  });

  group('StreamType', () {
    test('streamName returns correct API strings', () {
      expect(StreamType.user.streamName, 'user');
      expect(StreamType.publicLocal.streamName, 'public:local');
      expect(StreamType.publicRemote.streamName, 'public:remote');
      expect(StreamType.public.streamName, 'public');
      expect(StreamType.hashtag.streamName, 'hashtag');
      expect(StreamType.list.streamName, 'list');
      expect(StreamType.direct.streamName, 'direct');
    });
  });

  group('StreamingEvent', () {
    test('fromJson parses update event', () {
      final json = {
        'event': 'update',
        'stream': ['user'],
        'payload': '{"id":"123","content":"hello","visibility":"public","sensitive":false,"spoiler_text":"","account":{"id":"1","username":"test","acct":"test","display_name":"Test","avatar":"","avatar_static":"","header":"","header_static":"","followers_count":0,"following_count":0,"statuses_count":0,"created_at":"2024-01-01T00:00:00.000Z"},"uri":"https://example.com/1","reblogs_count":0,"favourites_count":0,"replies_count":0,"created_at":"2024-01-01T00:00:00.000Z"}',
      };

      final event = StreamingEvent.fromJson(json);
      expect(event.type, StreamingEventType.update);
      expect(event.stream, ['user']);
      expect(event.payload, isNotNull);
    });

    test('fromJson parses delete event', () {
      final json = {
        'event': 'delete',
        'stream': ['user'],
        'payload': '12345',
      };

      final event = StreamingEvent.fromJson(json);
      expect(event.type, StreamingEventType.delete);
      expect(event.deletedStatusId, '12345');
    });

    test('fromJson handles missing fields gracefully', () {
      final event = StreamingEvent.fromJson({'event': 'update'});
      expect(event.type, StreamingEventType.update);
      expect(event.stream, isEmpty);
      expect(event.payload, isNull);
    });

    test('status parses payload as StatusSchema', () {
      final statusJson = {
        'id': '456',
        'content': '<p>test</p>',
        'visibility': 'public',
        'sensitive': false,
        'spoiler_text': '',
        'account': {
          'id': '1',
          'username': 'user',
          'acct': 'user',
          'url': 'https://example.com/@user',
          'display_name': 'User',
          'note': '',
          'avatar': '',
          'avatar_static': '',
          'header': '',
          'locked': false,
          'bot': false,
          'indexable': false,
          'followers_count': 0,
          'following_count': 0,
          'statuses_count': 0,
          'created_at': '2024-01-01T00:00:00.000Z',
        },
        'uri': 'https://example.com/456',
        'reblogs_count': 0,
        'favourites_count': 0,
        'replies_count': 0,
        'created_at': '2024-01-01T00:00:00.000Z',
      };

      final event = StreamingEvent(
        type: StreamingEventType.update,
        payload: jsonEncode(statusJson),
      );

      final status = event.status;
      expect(status, isNotNull);
      expect(status!.id, '456');
      expect(status.content, '<p>test</p>');
    });

    test('status returns null for invalid payload', () {
      final event = StreamingEvent(
        type: StreamingEventType.update,
        payload: 'not json',
      );
      expect(event.status, isNull);
    });

    test('status returns null when payload is null', () {
      const event = StreamingEvent(type: StreamingEventType.update);
      expect(event.status, isNull);
    });

    test('deletedStatusId returns null for non-delete events', () {
      const event = StreamingEvent(
        type: StreamingEventType.update,
        payload: '123',
      );
      expect(event.deletedStatusId, isNull);
    });

    test('deletedStatusId returns payload for delete events', () {
      const event = StreamingEvent(
        type: StreamingEventType.delete,
        payload: '789',
      );
      expect(event.deletedStatusId, '789');
    });
  });

  group('streamTypeForTimeline', () {
    test('maps supported timeline types', () {
      expect(streamTypeForTimeline(TimelineType.home), StreamType.user);
      expect(streamTypeForTimeline(TimelineType.local), StreamType.publicLocal);
      expect(streamTypeForTimeline(TimelineType.federal), StreamType.publicRemote);
      expect(streamTypeForTimeline(TimelineType.public), StreamType.public);
      expect(streamTypeForTimeline(TimelineType.hashtag), StreamType.hashtag);
      expect(streamTypeForTimeline(TimelineType.list), StreamType.list);
    });

    test('returns null for unsupported timeline types', () {
      expect(streamTypeForTimeline(TimelineType.favourites), isNull);
      expect(streamTypeForTimeline(TimelineType.bookmarks), isNull);
      expect(streamTypeForTimeline(TimelineType.user), isNull);
      expect(streamTypeForTimeline(TimelineType.pin), isNull);
      expect(streamTypeForTimeline(TimelineType.schedule), isNull);
    });
  });

  group('isEventForTimeline', () {
    StreamingEvent makeEvent(List<String> stream) {
      return StreamingEvent(type: StreamingEventType.update, stream: stream);
    }

    test('matches home timeline to user stream', () {
      expect(isEventForTimeline(makeEvent(['user']), TimelineType.home), isTrue);
    });

    test('matches local timeline to public:local stream', () {
      expect(isEventForTimeline(makeEvent(['public:local']), TimelineType.local), isTrue);
    });

    test('matches federal timeline to public:remote stream', () {
      expect(isEventForTimeline(makeEvent(['public:remote']), TimelineType.federal), isTrue);
    });

    test('matches public timeline to public stream', () {
      expect(isEventForTimeline(makeEvent(['public']), TimelineType.public), isTrue);
    });

    test('rejects event from wrong stream', () {
      expect(isEventForTimeline(makeEvent(['public:local']), TimelineType.home), isFalse);
      expect(isEventForTimeline(makeEvent(['user']), TimelineType.local), isFalse);
      expect(isEventForTimeline(makeEvent(['public']), TimelineType.federal), isFalse);
      expect(isEventForTimeline(makeEvent(['public:remote']), TimelineType.public), isFalse);
    });

    test('rejects event for unsupported timeline types', () {
      expect(isEventForTimeline(makeEvent(['user']), TimelineType.favourites), isFalse);
      expect(isEventForTimeline(makeEvent(['user']), TimelineType.bookmarks), isFalse);
      expect(isEventForTimeline(makeEvent(['user']), TimelineType.pin), isFalse);
    });

    test('matches hashtag timeline with correct tag', () {
      expect(isEventForTimeline(makeEvent(['hashtag', 'flutter']), TimelineType.hashtag, hashtag: 'flutter'), isTrue);
    });

    test('rejects hashtag event with wrong tag', () {
      expect(isEventForTimeline(makeEvent(['hashtag', 'dart']), TimelineType.hashtag, hashtag: 'flutter'), isFalse);
    });

    test('matches list timeline with correct list ID', () {
      expect(isEventForTimeline(makeEvent(['list', '42']), TimelineType.list, listId: '42'), isTrue);
    });

    test('rejects list event with wrong list ID', () {
      expect(isEventForTimeline(makeEvent(['list', '99']), TimelineType.list, listId: '42'), isFalse);
    });

    test('rejects event with empty stream array', () {
      expect(isEventForTimeline(makeEvent([]), TimelineType.home), isFalse);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
