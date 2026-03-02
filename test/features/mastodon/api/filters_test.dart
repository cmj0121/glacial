// Tests for filters API extensions.
import 'package:flutter_test/flutter_test.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/mastodon/extensions.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  AccessStatusSchema noDomainAuth() =>
      const AccessStatusSchema(domain: '', accessToken: 'token');

  const auth = AccessStatusSchema(
    domain: 'nonexistent-server-12345.invalid',
    accessToken: 'test-token',
  );

  FilterFormSchema filterForm() => const FilterFormSchema(
        title: 'Test Filter',
        context: [FilterContext.home],
        action: FilterAction.warn,
      );

  FiltersSchema filter() => const FiltersSchema(
        id: 'filter-1',
        title: 'Test Filter',
        context: [FilterContext.home],
        action: FilterAction.warn,
      );

  // ---------------------------------------------------------------------------
  // No-domain tests: getAPI returns null, postAPI/putAPI return null
  // GET-based methods parse '[]' or return null → succeed
  // POST/PUT-based methods parse '{}' → fromJson fails on required fields
  // DELETE-based methods → succeed (void)
  // ---------------------------------------------------------------------------
  group('FiltersExtensions with no domain', () {
    test('fetchFilters completes when no domain', () async {
      final result = await noDomainAuth().fetchFilters();
      expect(result, isEmpty);
    });

    test('deleteFilter completes when no domain', () async {
      await noDomainAuth().deleteFilter(id: 'f-1');
    });

    test('getFilter returns null when no domain', () async {
      final result = await noDomainAuth().getFilter(id: 'f-1');
      expect(result, isNull);
    });

    test('fetchFilterStatuses completes when no domain', () async {
      final result = await noDomainAuth().fetchFilterStatuses(filter: filter());
      expect(result, isEmpty);
    });

    test('removeFilterStatus completes when no domain', () async {
      await noDomainAuth().removeFilterStatus(
        status: const FilterStatusSchema(id: 'fs-1', statusId: 's-1'),
      );
    });

    test('fetchFilterKeywords completes when no domain', () async {
      final result = await noDomainAuth().fetchFilterKeywords(filterId: 'f-1');
      expect(result, isEmpty);
    });

    test('getFilterKeyword returns null when no domain', () async {
      final result = await noDomainAuth().getFilterKeyword(id: 'kw-1');
      expect(result, isNull);
    });

    test('deleteFilterKeyword completes when no domain', () async {
      await noDomainAuth().deleteFilterKeyword(id: 'kw-1');
    });

    test('getFilterStatus returns null when no domain', () async {
      final result = await noDomainAuth().getFilterStatus(id: 'fs-1');
      expect(result, isNull);
    });

    // POST/PUT methods throw when no domain because postAPI returns null →
    // '{}' is parsed but fromJson fails on required fields
    test('createFilter throws when no domain (model parse error)', () {
      expect(() => noDomainAuth().createFilter(schema: filterForm()), throwsA(anything));
    });

    test('updateFilter throws when no domain (model parse error)', () {
      expect(() => noDomainAuth().updateFilter(id: 'f-1', schema: filterForm()), throwsA(anything));
    });

    test('addFilterStatus throws when no domain (model parse error)', () {
      expect(
        () => noDomainAuth().addFilterStatus(filter: filter(), status: MockStatus.create()),
        throwsA(anything),
      );
    });

    test('addFilterKeyword throws when no domain (model parse error)', () {
      expect(
        () => noDomainAuth().addFilterKeyword(filterId: 'f-1', keyword: 'spam'),
        throwsA(anything),
      );
    });

    test('updateFilterKeyword throws when no domain (model parse error)', () {
      expect(
        () => noDomainAuth().updateFilterKeyword(id: 'kw-1', keyword: 'updated', wholeWord: true),
        throwsA(anything),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // Valid-domain tests: exercises the actual HTTP call lines
  // ---------------------------------------------------------------------------
  group('FiltersExtensions with valid domain exercises HTTP call lines', () {
    // GET methods catch errors and return null/default (getAPI swallows errors)
    test('fetchFilters completes with default on network error', () async {
      final result = await auth.fetchFilters();
      expect(result, isEmpty);
    });

    test('getFilter returns null on network error', () async {
      final result = await auth.getFilter(id: 'f-1');
      expect(result, isNull);
    });

    test('fetchFilterStatuses completes with empty list on network error', () async {
      final result = await auth.fetchFilterStatuses(filter: filter());
      expect(result, isEmpty);
    });

    test('fetchFilterKeywords completes with empty list on network error', () async {
      final result = await auth.fetchFilterKeywords(filterId: 'f-1');
      expect(result, isEmpty);
    });

    test('getFilterKeyword returns null on network error', () async {
      final result = await auth.getFilterKeyword(id: 'kw-1');
      expect(result, isNull);
    });

    test('getFilterStatus returns null on network error', () async {
      final result = await auth.getFilterStatus(id: 'fs-1');
      expect(result, isNull);
    });

    // POST/PUT/DELETE methods throw on network error (no catch block)
    test('createFilter throws on network error', () {
      expect(() => auth.createFilter(schema: filterForm()), throwsA(anything));
    });

    test('updateFilter throws on network error', () {
      expect(
        () => auth.updateFilter(id: 'f-1', schema: filterForm()),
        throwsA(anything),
      );
    });

    test('deleteFilter throws on network error', () {
      expect(() => auth.deleteFilter(id: 'f-1'), throwsA(anything));
    });

    test('addFilterStatus throws on network error', () {
      expect(
        () => auth.addFilterStatus(filter: filter(), status: MockStatus.create()),
        throwsA(anything),
      );
    });

    test('removeFilterStatus throws on network error', () {
      expect(
        () => auth.removeFilterStatus(
          status: const FilterStatusSchema(id: 'fs-1', statusId: 's-1'),
        ),
        throwsA(anything),
      );
    });

    test('addFilterKeyword throws on network error', () {
      expect(
        () => auth.addFilterKeyword(filterId: 'f-1', keyword: 'test'),
        throwsA(anything),
      );
    });

    test('updateFilterKeyword throws on network error', () {
      expect(
        () => auth.updateFilterKeyword(id: 'kw-1', keyword: 'updated'),
        throwsA(anything),
      );
    });

    test('deleteFilterKeyword throws on network error', () {
      expect(() => auth.deleteFilterKeyword(id: 'kw-1'), throwsA(anything));
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
