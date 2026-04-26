import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/features/models.dart';

void main() {
  group('EmojiSchema.splitEmoji', () {
    test('returns the whole string when there are no shortcode candidates', () {
      expect(EmojiSchema.splitEmoji('Hello world'), ['Hello world']);
    });

    test('treats a lone colon as plain text', () {
      expect(EmojiSchema.splitEmoji('Hello: world'), ['Hello: world']);
    });

    test('does not match smileys without a closing colon', () {
      expect(EmojiSchema.splitEmoji('hi :)'), ['hi :)']);
      expect(EmojiSchema.splitEmoji('hi :-)'), ['hi :-)']);
      expect(EmojiSchema.splitEmoji('hi :D'), ['hi :D']);
    });

    test('does not match a single colon in time-of-day', () {
      expect(EmojiSchema.splitEmoji('At 12:30 PM'), ['At 12:30 PM']);
    });

    test('does not match empty :: shortcodes', () {
      expect(EmojiSchema.splitEmoji('foo::bar'), ['foo::bar']);
    });

    test('matches a basic alphanumeric shortcode', () {
      expect(EmojiSchema.splitEmoji('hi :wave: bye'), ['hi ', ':wave:', ' bye']);
    });

    test('matches shortcodes containing _, +, -', () {
      expect(EmojiSchema.splitEmoji(':fast_food:'), [':fast_food:']);
      expect(EmojiSchema.splitEmoji(':+1:'), [':+1:']);
      expect(EmojiSchema.splitEmoji(':my-emoji:'), [':my-emoji:']);
    });

    test('matches Pleroma/Akkoma shortcodes containing a period', () {
      expect(EmojiSchema.splitEmoji(':my.emoji:'), [':my.emoji:']);
      expect(EmojiSchema.splitEmoji('hi :emoji.v2: bye'), ['hi ', ':emoji.v2:', ' bye']);
    });

    test('matches adjacent shortcodes', () {
      expect(EmojiSchema.splitEmoji(':hi::bye:'), [':hi:', ':bye:']);
    });

    test('non-greedy: a:b:c yields a single :b: candidate', () {
      expect(EmojiSchema.splitEmoji('a:b:c'), ['a', ':b:', 'c']);
    });

    test('does not match shortcodes containing whitespace or accented chars', () {
      expect(EmojiSchema.splitEmoji(':my emoji:'), [':my emoji:']);
      expect(EmojiSchema.splitEmoji(':café:'), [':café:']);
    });
  });

  group('EmojiSchema.replaceEmojiToHTML', () {
    const wave = EmojiSchema(
      shortcode: 'wave',
      url: 'https://example.com/wave.png',
      staticUrl: 'https://example.com/wave.png',
    );

    test('returns plain text when content has no shortcodes', () {
      expect(EmojiSchema.replaceEmojiToHTML('hello'), 'hello');
    });

    test('replaces a known shortcode with an img tag', () {
      final String html = EmojiSchema.replaceEmojiToHTML('hi :wave:', emojis: [wave]);
      expect(html, contains("<img src='https://example.com/wave.png'"));
      expect(html, startsWith('hi '));
    });

    test('leaves an unknown shortcode as literal text', () {
      expect(EmojiSchema.replaceEmojiToHTML('hi :unknown:', emojis: const []), 'hi :unknown:');
    });
  });

  group('EmojiSchema toJson/fromJson', () {
    test('round-trips required fields', () {
      const emoji = EmojiSchema(
        shortcode: 'wave',
        url: 'https://example.com/wave.png',
        staticUrl: 'https://example.com/wave_static.png',
      );

      final Map<String, dynamic> json = emoji.toJson();
      final EmojiSchema parsed = EmojiSchema.fromJson(json);

      expect(parsed.shortcode, 'wave');
      expect(parsed.url, 'https://example.com/wave.png');
      expect(parsed.staticUrl, 'https://example.com/wave_static.png');
      expect(parsed.visible, true);
      expect(parsed.category, isNull);
    });

    test('round-trips optional category', () {
      const emoji = EmojiSchema(
        shortcode: 'wave',
        url: 'https://example.com/wave.png',
        staticUrl: 'https://example.com/wave.png',
        category: 'greetings',
      );

      final EmojiSchema parsed = EmojiSchema.fromJson(emoji.toJson());
      expect(parsed.category, 'greetings');
    });

    test('parses legacy visible_in_picker field', () {
      final EmojiSchema parsed = EmojiSchema.fromJson({
        'shortcode': 'wave',
        'url': 'https://example.com/wave.png',
        'static_url': 'https://example.com/wave.png',
        'visible_in_picker': false,
      });

      expect(parsed.visible, false);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
