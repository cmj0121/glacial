// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/app.dart';
import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';

void main() {
  isTestMode = true;

  testWidgets('Launch the main app', (WidgetTester tester) async {
    final SystemPreferenceSchema schema = SystemPreferenceSchema();

    await tester.pumpWidget(ProviderScope(child: CoreApp(schema: schema)));
    await tester.pumpAndSettle();

    final Finder serverTextField = find.byType(TextField);
    expect(serverTextField, findsOneWidget, reason: 'Server text field should be present');
  });
}

// vim: set ts=2 sw=2 sts=2 et:
