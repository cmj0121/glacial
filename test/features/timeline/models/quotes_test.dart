import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';

void main() {
  // JSON helpers
  Map<String, dynamic> accountJson({String id = '1'}) => {
    'id': id,
    'username': 'testuser',
    'acct': 'testuser',
    'url': 'https://example.com/@testuser',
    'display_name': 'Test User',
    'note': '',
    'avatar': 'https://example.com/avatar.png',
    'avatar_static': 'https://example.com/avatar.png',
    'header': 'https://example.com/header.png',
    'locked': false,
    'bot': false,
    'indexable': true,
    'created_at': '2024-01-01T00:00:00.000Z',
    'statuses_count': 10,
    'followers_count': 5,
    'following_count': 3,
  };

  Map<String, dynamic> statusJson({String id = '100'}) => {
    'id': id,
    'content': '<p>Hello</p>',
    'visibility': 'public',
    'sensitive': false,
    'spoiler_text': '',
    'account': accountJson(),
    'uri': 'https://example.com/statuses/$id',
    'reblogs_count': 0,
    'favourites_count': 0,
    'replies_count': 0,
    'created_at': '2024-06-15T12:00:00.000Z',
  };

  group('QuoteStateType', () {
    test('fromString parses all known values', () {
      for (final state in QuoteStateType.values) {
        expect(QuoteStateType.fromString(state.name), state);
      }
    });

    test('fromString falls back to unauthorized for unknown', () {
      expect(QuoteStateType.fromString('invalid'), QuoteStateType.unauthorized);
      expect(QuoteStateType.fromString(''), QuoteStateType.unauthorized);
    });
  });

  group('QuoteSchema', () {
    test('fromJson parses accepted quote with status', () {
      final json = {
        'state': 'accepted',
        'quoted_status': statusJson(id: '50'),
        'quoted_status_id': '50',
      };
      final quote = QuoteSchema.fromJson(json);

      expect(quote.state, QuoteStateType.accepted);
      expect(quote.quotedStatus, isNotNull);
      expect(quote.quotedStatus!.id, '50');
      expect(quote.quotedStatusID, '50');
    });

    test('fromJson parses pending quote without status', () {
      final json = {
        'state': 'pending',
        'quoted_status_id': '50',
      };
      final quote = QuoteSchema.fromJson(json);

      expect(quote.state, QuoteStateType.pending);
      expect(quote.quotedStatus, isNull);
      expect(quote.quotedStatusID, '50');
    });

    test('fromJson handles null optional fields', () {
      final json = {'state': 'rejected'};
      final quote = QuoteSchema.fromJson(json);

      expect(quote.state, QuoteStateType.rejected);
      expect(quote.quotedStatus, isNull);
      expect(quote.quotedStatusID, isNull);
    });

    test('fromString round-trip', () {
      final json = {
        'state': 'accepted',
        'quoted_status_id': '50',
      };
      final quote = QuoteSchema.fromString(jsonEncode(json));

      expect(quote.state, QuoteStateType.accepted);
      expect(quote.quotedStatusID, '50');
    });
  });

  group('QuoteApprovalType', () {
    test('fromString parses all known values', () {
      for (final type in QuoteApprovalType.values) {
        expect(QuoteApprovalType.fromString(type.name), type);
      }
    });

    test('fromString falls back to unsupportedPolicy for unknown', () {
      expect(QuoteApprovalType.fromString('invalid'), QuoteApprovalType.unsupportedPolicy);
    });
  });

  group('CurrentQuoteApprovalType', () {
    test('fromString parses all known values', () {
      for (final type in CurrentQuoteApprovalType.values) {
        expect(CurrentQuoteApprovalType.fromString(type.name), type);
      }
    });

    test('fromString falls back to unknown for unrecognized', () {
      expect(CurrentQuoteApprovalType.fromString('invalid'), CurrentQuoteApprovalType.unknown);
    });
  });

  group('QuoteApprovalSchema', () {
    test('fromJson parses automatic and manual lists', () {
      final json = {
        'automatic': ['public', 'followers'],
        'manual': ['following'],
        'current_user': 'automatic',
      };
      final approval = QuoteApprovalSchema.fromJson(json);

      expect(approval.automatic.length, 2);
      expect(approval.automatic[0], QuoteApprovalType.public);
      expect(approval.automatic[1], QuoteApprovalType.followers);
      expect(approval.manual.length, 1);
      expect(approval.manual[0], QuoteApprovalType.following);
      expect(approval.currentUser, CurrentQuoteApprovalType.automatic);
    });

    test('fromJson handles empty lists', () {
      final json = {
        'automatic': <String>[],
        'manual': <String>[],
        'current_user': 'denied',
      };
      final approval = QuoteApprovalSchema.fromJson(json);

      expect(approval.automatic, isEmpty);
      expect(approval.manual, isEmpty);
      expect(approval.currentUser, CurrentQuoteApprovalType.denied);
    });

    test('fromString round-trip', () {
      final json = {
        'automatic': ['public'],
        'manual': [],
        'current_user': 'automatic',
      };
      final approval = QuoteApprovalSchema.fromString(jsonEncode(json));

      expect(approval.automatic.length, 1);
      expect(approval.currentUser, CurrentQuoteApprovalType.automatic);
    });

    test('toUser returns public when automatic has public', () {
      final approval = QuoteApprovalSchema(
        automatic: [QuoteApprovalType.public],
        manual: [],
        currentUser: CurrentQuoteApprovalType.automatic,
      );

      expect(approval.toUser, QuotePolicyType.public);
    });

    test('toUser returns followers when best is followers', () {
      final approval = QuoteApprovalSchema(
        automatic: [QuoteApprovalType.followers],
        manual: [QuoteApprovalType.following],
        currentUser: CurrentQuoteApprovalType.automatic,
      );

      expect(approval.toUser, QuotePolicyType.followers);
    });

    test('toUser returns nobody when both lists empty', () {
      final approval = QuoteApprovalSchema(
        automatic: [],
        manual: [],
        currentUser: CurrentQuoteApprovalType.denied,
      );

      expect(approval.toUser, QuotePolicyType.nobody);
    });

    test('toUser returns nobody for unsupportedPolicy', () {
      final approval = QuoteApprovalSchema(
        automatic: [QuoteApprovalType.unsupportedPolicy],
        manual: [],
        currentUser: CurrentQuoteApprovalType.unknown,
      );

      expect(approval.toUser, QuotePolicyType.nobody);
    });
  });

  group('QuotePolicyType', () {
    test('fromString parses all known values', () {
      for (final type in QuotePolicyType.values) {
        expect(QuotePolicyType.fromString(type.name), type);
      }
    });

    test('fromString falls back to nobody for unknown', () {
      expect(QuotePolicyType.fromString('invalid'), QuotePolicyType.nobody);
    });

    test('next cycles through values', () {
      expect(QuotePolicyType.public.next, QuotePolicyType.followers);
      expect(QuotePolicyType.followers.next, QuotePolicyType.nobody);
      expect(QuotePolicyType.nobody.next, QuotePolicyType.public);
    });

    test('icon returns correct icons for each value', () {
      expect(QuotePolicyType.public.icon, Icons.format_quote_sharp);
      expect(QuotePolicyType.followers.icon, Icons.group);
      expect(QuotePolicyType.nobody.icon, Icons.lock);
    });

    testWidgets('title returns localized strings', (tester) async {
      late String publicTitle, followersTitle, nobodyTitle;
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
            publicTitle = QuotePolicyType.public.title(context);
            followersTitle = QuotePolicyType.followers.title(context);
            nobodyTitle = QuotePolicyType.nobody.title(context);
            return const SizedBox.shrink();
          }),
        ),
      );
      await tester.pumpAndSettle();
      expect(publicTitle, isNotEmpty);
      expect(followersTitle, isNotEmpty);
      expect(nobodyTitle, isNotEmpty);
    });

    testWidgets('description returns localized strings', (tester) async {
      late String publicDesc, followersDesc, nobodyDesc;
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
            publicDesc = QuotePolicyType.public.description(context);
            followersDesc = QuotePolicyType.followers.description(context);
            nobodyDesc = QuotePolicyType.nobody.description(context);
            return const SizedBox.shrink();
          }),
        ),
      );
      await tester.pumpAndSettle();
      expect(publicDesc, isNotEmpty);
      expect(followersDesc, isNotEmpty);
      expect(nobodyDesc, isNotEmpty);
    });
  });

  group('QuoteApprovalType icon and tooltip', () {
    test('icon returns correct icons for each value', () {
      expect(QuoteApprovalType.public.icon, Icons.format_quote_sharp);
      expect(QuoteApprovalType.followers.icon, Icons.group);
      expect(QuoteApprovalType.following.icon, Icons.person_add);
      expect(QuoteApprovalType.unsupportedPolicy.icon, Icons.cancel_outlined);
    });

    testWidgets('tooltip returns localized strings for all values', (tester) async {
      late String publicTip, followersTip, followingTip, unsupportedTip;
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
            publicTip = QuoteApprovalType.public.tooltip(context);
            followersTip = QuoteApprovalType.followers.tooltip(context);
            followingTip = QuoteApprovalType.following.tooltip(context);
            unsupportedTip = QuoteApprovalType.unsupportedPolicy.tooltip(context);
            return const SizedBox.shrink();
          }),
        ),
      );
      await tester.pumpAndSettle();
      expect(publicTip, isNotEmpty);
      expect(followersTip, isNotEmpty);
      expect(followingTip, isNotEmpty);
      expect(unsupportedTip, isNotEmpty);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
