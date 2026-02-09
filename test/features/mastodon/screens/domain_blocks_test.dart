import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glacial/features/mastodon/screens/domain_blocks.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setupTestEnvironment();

  group('DomainBlockList', () {
    test('is a StatefulWidget', () {
      expect(const DomainBlockList(), isA<StatefulWidget>());
    });

    test('can be created with const constructor', () {
      const widget = DomainBlockList();
      expect(widget, isNotNull);
      expect(widget.key, isNull);
    });

    test('can be created with key', () {
      const key = ValueKey('domain-blocks');
      const widget = DomainBlockList(key: key);
      expect(widget.key, key);
    });

    test('is a ConsumerStatefulWidget', () {
      const widget = DomainBlockList();
      expect(widget, isA<ConsumerStatefulWidget>());
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
