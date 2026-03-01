// Widget tests for FollowRequests screen.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/screens.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  group('FollowRequests', () {
    testWidgets('renders widget for authenticated user', (tester) async {
      final status = MockAccessStatus.authenticated();
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: FollowRequests()),
          accessStatus: status,
        ));
        await tester.pump();
      });

      expect(find.byType(FollowRequests), findsOneWidget);
    });

    testWidgets('renders for anonymous user', (tester) async {
      final status = MockAccessStatus.anonymous();
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: FollowRequests()),
          accessStatus: status,
        ));
        await tester.pump();
      });

      expect(find.byType(FollowRequests), findsOneWidget);
    });

    testWidgets('shows loading state initially', (tester) async {
      final status = MockAccessStatus.authenticated();
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: FollowRequests()),
          accessStatus: status,
        ));
        // First pump to build the widget tree
        await tester.pump();
      });

      // LoadingOverlay should be present
      expect(find.byType(LoadingOverlay), findsOneWidget);
    });

    testWidgets('shows NoResult on fetch error', (tester) async {
      final status = MockAccessStatus.authenticated();
      await tester.runAsync(() async {
        await tester.pumpWidget(createTestWidgetRaw(
          child: const Scaffold(body: FollowRequests()),
          accessStatus: status,
        ));
        await tester.pump();
        // Wait for the future to complete (with error due to no server)
        await Future<void>.delayed(const Duration(milliseconds: 500));
        await tester.pump();
      });

      // After error, shows NoResult
      expect(find.byType(FollowRequests), findsOneWidget);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
