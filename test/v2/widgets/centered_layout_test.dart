import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/v2/theme.dart';
import 'package:glacial/v2/widgets/centered_layout.dart';

void main() {
  group('V2CenteredLayout', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: V2CenteredLayout(
              child: Text('Hello'),
            ),
          ),
        ),
      );

      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('constrains to default maxWidth', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: V2CenteredLayout(
              child: SizedBox.expand(),
            ),
          ),
        ),
      );

      final layout = tester.element(find.byType(V2CenteredLayout));
      final constrainedBox = layout.findAncestorWidgetOfExactType<ConstrainedBox>() ??
          tester.widget<ConstrainedBox>(
            find.descendant(
              of: find.byType(V2CenteredLayout),
              matching: find.byType(ConstrainedBox),
            ),
          );
      expect(
        constrainedBox.constraints.maxWidth,
        equals(V2Theme.maxContentWidth),
      );
    });

    testWidgets('accepts custom maxWidth', (tester) async {
      const customWidth = 600.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: V2CenteredLayout(
              maxWidth: customWidth,
              child: SizedBox.expand(),
            ),
          ),
        ),
      );

      final constrainedBox = tester.widget<ConstrainedBox>(
        find.descendant(
          of: find.byType(V2CenteredLayout),
          matching: find.byType(ConstrainedBox),
        ),
      );
      expect(constrainedBox.constraints.maxWidth, equals(customWidth));
    });
  });
}
// vim: set ts=2 sw=2 sts=2 et:
