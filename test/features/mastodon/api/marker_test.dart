// Tests for marker API extensions.
import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/mastodon/extensions.dart';

void main() {
  group('MarkerExtensions with no domain', () {
    AccessStatusSchema noDomainAuth() =>
        const AccessStatusSchema(domain: '', accessToken: 'token');

    test('getMarker completes when no domain', () async {
      final result = await noDomainAuth().getMarker(type: TimelineMarkerType.home);
      expect(result, isA<MarkersSchema>());
    });

    test('setMarker completes when no domain', () async {
      final result = await noDomainAuth().setMarker(id: '123', type: TimelineMarkerType.home);
      expect(result, isA<MarkersSchema>());
    });
  });

  group('MarkerExtensions with valid domain exercises HTTP call lines', () {
    const auth = AccessStatusSchema(
      domain: 'nonexistent-server-12345.invalid',
      accessToken: 'test-token',
    );

    // getMarker uses getAPI which catches errors and returns null → parsed as '{}'
    test('getMarker completes with default on network error', () async {
      final result = await auth.getMarker(type: TimelineMarkerType.home);
      expect(result, isA<MarkersSchema>());
    });

    // setMarker uses postAPI which throws on network error
    test('setMarker throws on network error', () {
      expect(
        () => auth.setMarker(id: '123', type: TimelineMarkerType.notifications),
        throwsA(anything),
      );
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
