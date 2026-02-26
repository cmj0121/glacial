// Tests for LinkSchema and HistorySchema fromJson.
import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/features/models.dart';

void main() {
  group('LinkSchema', () {
    test('fromJson parses all fields', () {
      final json = {
        'url': 'https://example.com/article',
        'title': 'Test Article',
        'description': 'A test article',
        'type': 'link',
        'author_name': 'Author',
        'author_url': 'https://example.com/author',
        'provider_name': 'Example',
        'provider_url': 'https://example.com',
        'html': '<iframe></iframe>',
        'width': 800,
        'height': 600,
        'image': 'https://example.com/image.jpg',
        'embed_url': 'https://example.com/embed',
        'history': [
          {'day': '1', 'accounts': '10', 'uses': '25'},
          {'day': '2', 'accounts': '15', 'uses': '30'},
        ],
      };
      final link = LinkSchema.fromJson(json);
      expect(link.url, 'https://example.com/article');
      expect(link.title, 'Test Article');
      expect(link.desc, 'A test article');
      expect(link.type, 'link');
      expect(link.authName, 'Author');
      expect(link.authUrl, 'https://example.com/author');
      expect(link.providerName, 'Example');
      expect(link.providerUrl, 'https://example.com');
      expect(link.html, '<iframe></iframe>');
      expect(link.width, 800);
      expect(link.height, 600);
      expect(link.image, 'https://example.com/image.jpg');
      expect(link.embedUrl, 'https://example.com/embed');
      expect(link.history, hasLength(2));
    });

    test('fromJson parses empty history', () {
      final json = {
        'url': 'https://example.com',
        'title': 'Title',
        'description': 'Desc',
        'type': 'link',
        'author_name': '',
        'author_url': '',
        'provider_name': '',
        'provider_url': '',
        'html': '',
        'width': 0,
        'height': 0,
        'image': '',
        'embed_url': '',
        'history': <Map<String, dynamic>>[],
      };
      final link = LinkSchema.fromJson(json);
      expect(link.history, isEmpty);
    });

    test('history entries parse correctly', () {
      final json = {
        'url': 'https://example.com',
        'title': 'T',
        'description': 'D',
        'type': 'link',
        'author_name': 'A',
        'author_url': 'U',
        'provider_name': 'P',
        'provider_url': 'PU',
        'html': '',
        'width': 100,
        'height': 50,
        'image': 'img',
        'embed_url': 'e',
        'history': [
          {'day': '1706745600', 'accounts': '42', 'uses': '100'},
        ],
      };
      final link = LinkSchema.fromJson(json);
      expect(link.history.first.day, '1706745600');
      expect(link.history.first.accounts, '42');
      expect(link.history.first.uses, '100');
    });
  });

  group('HistorySchema', () {
    test('fromJson parses all fields', () {
      final json = {'day': '1234567890', 'accounts': '50', 'uses': '200'};
      final history = HistorySchema.fromJson(json);
      expect(history.day, '1234567890');
      expect(history.accounts, '50');
      expect(history.uses, '200');
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
