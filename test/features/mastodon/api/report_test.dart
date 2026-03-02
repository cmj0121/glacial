// Tests for report API extensions.
import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/mastodon/extensions.dart';

void main() {
  ReportFileSchema reportSchema() => const ReportFileSchema(
        accountID: 'acc-1',
        comment: 'spam',
        category: ReportCategoryType.spam,
      );

  group('ReportExtensions with no domain', () {
    AccessStatusSchema noDomainAuth() =>
        const AccessStatusSchema(domain: '', accessToken: 'token');

    test('report throws when no domain (model parse error)', () {
      // postAPI returns null → '{}' → fromString fails on required fields
      expect(() => noDomainAuth().report(reportSchema()), throwsA(anything));
    });
  });

  group('ReportExtensions with valid domain exercises HTTP call lines', () {
    const auth = AccessStatusSchema(
      domain: 'nonexistent-server-12345.invalid',
      accessToken: 'test-token',
    );

    // report uses postAPI which throws on network error
    test('report throws on network error', () {
      expect(() => auth.report(reportSchema()), throwsA(anything));
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
