// Widget tests for PaginatedListMixin.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/cores/screens/animations.dart';
import 'package:glacial/cores/screens/pagination.dart';

import '../../helpers/test_helpers.dart';

// Concrete widget to test the PaginatedListMixin.
class _TestPaginatedWidget extends StatefulWidget {
  final Future<void> Function(_TestPaginatedWidgetState state)? onInit;

  const _TestPaginatedWidget({this.onInit});

  @override
  State<_TestPaginatedWidget> createState() => _TestPaginatedWidgetState();
}

class _TestPaginatedWidgetState extends State<_TestPaginatedWidget>
    with PaginatedListMixin {
  void rebuild() => setState(() {});

  @override
  void initState() {
    super.initState();
    if (widget.onInit != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await widget.onInit!(this);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('isLoading: $isLoading'),
        Text('isRefresh: $isRefresh'),
        Text('isCompleted: $isCompleted'),
        Text('shouldSkipLoad: $shouldSkipLoad'),
        buildLoadingIndicator(),
      ],
    );
  }
}

void main() {
  setupTestEnvironment();

  group('PaginatedListMixin', () {
    testWidgets('initial state has all flags false', (tester) async {
      await tester.pumpWidget(createTestWidget(child: const _TestPaginatedWidget()));
      await tester.pump();

      expect(find.text('isLoading: false'), findsOneWidget);
      expect(find.text('isRefresh: false'), findsOneWidget);
      expect(find.text('isCompleted: false'), findsOneWidget);
      expect(find.text('shouldSkipLoad: false'), findsOneWidget);
    });

    testWidgets('setLoading updates isLoading flag', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: _TestPaginatedWidget(
          onInit: (state) async => state.setLoading(true),
        ),
      ));
      await tester.pump();
      await tester.pump();

      expect(find.text('isLoading: true'), findsOneWidget);
      expect(find.text('shouldSkipLoad: true'), findsOneWidget);
    });

    testWidgets('markLoadComplete with isEmpty false keeps isCompleted false', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: _TestPaginatedWidget(
          onInit: (state) async {
            state.setLoading(true);
            state.markLoadComplete(isEmpty: false);
          },
        ),
      ));
      await tester.pump();
      await tester.pump();

      expect(find.text('isLoading: false'), findsOneWidget);
      expect(find.text('isCompleted: false'), findsOneWidget);
    });

    testWidgets('markLoadComplete with isEmpty true sets isCompleted', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: _TestPaginatedWidget(
          onInit: (state) async {
            state.setLoading(true);
            state.markLoadComplete(isEmpty: true);
          },
        ),
      ));
      await tester.pump();
      await tester.pump();

      expect(find.text('isLoading: false'), findsOneWidget);
      expect(find.text('isCompleted: true'), findsOneWidget);
      expect(find.text('shouldSkipLoad: true'), findsOneWidget);
    });

    testWidgets('refreshList resets state and calls load function', (tester) async {
      bool loadCalled = false;

      await tester.pumpWidget(createTestWidget(
        child: _TestPaginatedWidget(
          onInit: (state) async {
            // Set completed first
            state.markLoadComplete(isEmpty: true);
            // Now refresh
            await state.refreshList(() async {
              loadCalled = true;
              state.markLoadComplete(isEmpty: false);
            });
          },
        ),
      ));
      await tester.pump();
      await tester.pump();

      expect(loadCalled, isTrue);
      expect(find.text('isCompleted: false'), findsOneWidget);
      expect(find.text('isRefresh: false'), findsOneWidget);
    });

    testWidgets('resetPagination clears all flags', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: _TestPaginatedWidget(
          onInit: (state) async {
            state.setLoading(true);
            state.markLoadComplete(isEmpty: true);
            state.resetPagination();
            // Need to rebuild
            state.rebuild();
          },
        ),
      ));
      await tester.pump();
      await tester.pump();

      expect(find.text('isLoading: false'), findsOneWidget);
      expect(find.text('isRefresh: false'), findsOneWidget);
      expect(find.text('isCompleted: false'), findsOneWidget);
    });

    testWidgets('buildLoadingIndicator shows ClockProgressIndicator when loading', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: _TestPaginatedWidget(
          onInit: (state) async => state.setLoading(true),
        ),
      ));
      await tester.pump();
      await tester.pump();

      expect(find.byType(ClockProgressIndicator), findsOneWidget);
    });

    testWidgets('buildLoadingIndicator shows SizedBox.shrink when not loading', (tester) async {
      await tester.pumpWidget(createTestWidget(child: const _TestPaginatedWidget()));
      await tester.pump();

      expect(find.byType(ClockProgressIndicator), findsNothing);
    });

    testWidgets('shouldSkipLoad is true when isCompleted', (tester) async {
      await tester.pumpWidget(createTestWidget(
        child: _TestPaginatedWidget(
          onInit: (state) async {
            state.markLoadComplete(isEmpty: true);
          },
        ),
      ));
      await tester.pump();
      await tester.pump();

      expect(find.text('shouldSkipLoad: true'), findsOneWidget);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
