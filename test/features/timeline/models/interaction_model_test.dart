// Unit and widget tests for StatusInteraction enum.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';

void main() {
  group('StatusInteraction', () {
    group('icon inactive', () {
      test('reply returns turn_left_outlined', () {
        expect(StatusInteraction.reply.icon(), Icons.turn_left_outlined);
      });

      test('reblog returns repeat_outlined', () {
        expect(StatusInteraction.reblog.icon(), Icons.repeat_outlined);
      });

      test('quote returns format_quote_outlined', () {
        expect(StatusInteraction.quote.icon(), Icons.format_quote_outlined);
      });

      test('favourite returns star_outline_outlined', () {
        expect(StatusInteraction.favourite.icon(), Icons.star_outline_outlined);
      });

      test('bookmark returns bookmark_outline_outlined', () {
        expect(StatusInteraction.bookmark.icon(), Icons.bookmark_outline_outlined);
      });

      test('share returns share_outlined', () {
        expect(StatusInteraction.share.icon(), Icons.share_outlined);
      });

      test('filter returns filter_alt_outlined', () {
        expect(StatusInteraction.filter.icon(), Icons.filter_alt_outlined);
      });

      test('mute returns volume_mute_outlined', () {
        expect(StatusInteraction.mute.icon(), Icons.volume_mute_outlined);
      });

      test('block returns block_outlined', () {
        expect(StatusInteraction.block.icon(), Icons.block_outlined);
      });

      test('report returns feedback_outlined', () {
        expect(StatusInteraction.report.icon(), Icons.feedback_outlined);
      });

      test('pin returns push_pin_outlined', () {
        expect(StatusInteraction.pin.icon(), Icons.push_pin_outlined);
      });

      test('edit returns edit_outlined', () {
        expect(StatusInteraction.edit.icon(), Icons.edit_outlined);
      });

      test('policy returns format_quote_outlined', () {
        expect(StatusInteraction.policy.icon(), Icons.format_quote_outlined);
      });

      test('delete returns delete_outline_outlined', () {
        expect(StatusInteraction.delete.icon(), Icons.delete_outline_outlined);
      });
    });

    group('icon active', () {
      test('reply returns turn_left', () {
        expect(StatusInteraction.reply.icon(active: true), Icons.turn_left);
      });

      test('reblog returns repeat', () {
        expect(StatusInteraction.reblog.icon(active: true), Icons.repeat);
      });

      test('quote returns format_quote', () {
        expect(StatusInteraction.quote.icon(active: true), Icons.format_quote);
      });

      test('favourite returns star', () {
        expect(StatusInteraction.favourite.icon(active: true), Icons.star);
      });

      test('bookmark returns bookmark', () {
        expect(StatusInteraction.bookmark.icon(active: true), Icons.bookmark);
      });

      test('share returns share', () {
        expect(StatusInteraction.share.icon(active: true), Icons.share);
      });

      test('filter returns filter_alt', () {
        expect(StatusInteraction.filter.icon(active: true), Icons.filter_alt);
      });

      test('mute returns volume_off', () {
        expect(StatusInteraction.mute.icon(active: true), Icons.volume_off);
      });

      test('block returns block', () {
        expect(StatusInteraction.block.icon(active: true), Icons.block);
      });

      test('report returns feedback_rounded', () {
        expect(StatusInteraction.report.icon(active: true), Icons.feedback_rounded);
      });

      test('pin returns push_pin', () {
        expect(StatusInteraction.pin.icon(active: true), Icons.push_pin);
      });

      test('edit returns edit', () {
        expect(StatusInteraction.edit.icon(active: true), Icons.edit);
      });

      test('policy returns format_quote', () {
        expect(StatusInteraction.policy.icon(active: true), Icons.format_quote);
      });

      test('delete returns delete', () {
        expect(StatusInteraction.delete.icon(active: true), Icons.delete);
      });
    });

    group('tooltip', () {
      testWidgets('returns localized strings for all values', (tester) async {
        final Map<StatusInteraction, String> results = {};
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: Builder(builder: (context) {
              for (final action in StatusInteraction.values) {
                results[action] = action.tooltip(context);
              }
              return const SizedBox.shrink();
            }),
          ),
        );
        await tester.pumpAndSettle();
        for (final entry in results.entries) {
          expect(entry.value, isNotEmpty, reason: '${entry.key} tooltip should not be empty');
        }
      });
    });

    group('isBuiltIn', () {
      test('reply is built-in', () {
        expect(StatusInteraction.reply.isBuiltIn, isTrue);
      });

      test('reblog is built-in', () {
        expect(StatusInteraction.reblog.isBuiltIn, isTrue);
      });

      test('quote is built-in', () {
        expect(StatusInteraction.quote.isBuiltIn, isTrue);
      });

      test('favourite is built-in', () {
        expect(StatusInteraction.favourite.isBuiltIn, isTrue);
      });

      test('bookmark is built-in', () {
        expect(StatusInteraction.bookmark.isBuiltIn, isTrue);
      });

      test('share is built-in', () {
        expect(StatusInteraction.share.isBuiltIn, isTrue);
      });

      test('filter is not built-in', () {
        expect(StatusInteraction.filter.isBuiltIn, isFalse);
      });

      test('mute is not built-in', () {
        expect(StatusInteraction.mute.isBuiltIn, isFalse);
      });

      test('block is not built-in', () {
        expect(StatusInteraction.block.isBuiltIn, isFalse);
      });

      test('report is not built-in', () {
        expect(StatusInteraction.report.isBuiltIn, isFalse);
      });

      test('pin is not built-in', () {
        expect(StatusInteraction.pin.isBuiltIn, isFalse);
      });

      test('edit is not built-in', () {
        expect(StatusInteraction.edit.isBuiltIn, isFalse);
      });

      test('policy is not built-in', () {
        expect(StatusInteraction.policy.isBuiltIn, isFalse);
      });

      test('delete is not built-in', () {
        expect(StatusInteraction.delete.isBuiltIn, isFalse);
      });
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
