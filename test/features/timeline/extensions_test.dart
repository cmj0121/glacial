// Unit tests for DraftStorageExtension.
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:glacial/cores/storage.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';

void main() {
  const String key = 'test.server@12345';

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await Storage.init();
  });

  group('DraftStorageExtension', () {
    test('loadDrafts returns empty list when no drafts stored', () async {
      final storage = Storage();
      final drafts = await storage.loadDrafts(key);
      expect(drafts, isEmpty);
    });

    test('saveDraft stores and loadDrafts retrieves a single draft', () async {
      final storage = Storage();
      final draft = DraftSchema(
        id: 'draft-1',
        content: 'Hello',
        updatedAt: DateTime.parse('2025-01-15T10:00:00.000Z'),
      );

      await storage.saveDraft(key, draft);
      final drafts = await storage.loadDrafts(key);

      expect(drafts.length, 1);
      expect(drafts.first.id, 'draft-1');
      expect(drafts.first.content, 'Hello');
    });

    test('saveDraft updates existing draft by id (upsert)', () async {
      final storage = Storage();
      final draft = DraftSchema(
        id: 'draft-1',
        content: 'Original',
        updatedAt: DateTime.parse('2025-01-15T10:00:00.000Z'),
      );

      await storage.saveDraft(key, draft);

      final updated = draft.copyWith(
        content: 'Updated',
        updatedAt: DateTime.parse('2025-01-15T11:00:00.000Z'),
      );
      await storage.saveDraft(key, updated);

      final drafts = await storage.loadDrafts(key);
      expect(drafts.length, 1);
      expect(drafts.first.content, 'Updated');
    });

    test('saveDraft adds new draft alongside existing ones', () async {
      final storage = Storage();
      final draft1 = DraftSchema(
        id: 'draft-1',
        content: 'First',
        updatedAt: DateTime.parse('2025-01-15T10:00:00.000Z'),
      );
      final draft2 = DraftSchema(
        id: 'draft-2',
        content: 'Second',
        updatedAt: DateTime.parse('2025-01-15T11:00:00.000Z'),
      );

      await storage.saveDraft(key, draft1);
      await storage.saveDraft(key, draft2);

      final drafts = await storage.loadDrafts(key);
      expect(drafts.length, 2);
    });

    test('saveDraft trims to maxDrafts', () async {
      final storage = Storage();

      // Save maxDrafts + 5 drafts.
      for (int i = 0; i < DraftSchema.maxDrafts + 5; i++) {
        await storage.saveDraft(key, DraftSchema(
          id: 'draft-$i',
          content: 'Draft $i',
          updatedAt: DateTime.parse('2025-01-15T10:00:00.000Z').add(Duration(minutes: i)),
        ));
      }

      final drafts = await storage.loadDrafts(key);
      expect(drafts.length, DraftSchema.maxDrafts);
    });

    test('removeDraft removes specific draft by id', () async {
      final storage = Storage();
      final draft1 = DraftSchema(id: 'draft-1', content: 'First', updatedAt: DateTime.now());
      final draft2 = DraftSchema(id: 'draft-2', content: 'Second', updatedAt: DateTime.now());

      await storage.saveDraft(key, draft1);
      await storage.saveDraft(key, draft2);
      await storage.removeDraft(key, 'draft-1');

      final drafts = await storage.loadDrafts(key);
      expect(drafts.length, 1);
      expect(drafts.first.id, 'draft-2');
    });

    test('removeDraft with non-existent id does nothing', () async {
      final storage = Storage();
      final draft = DraftSchema(id: 'draft-1', content: 'Test', updatedAt: DateTime.now());

      await storage.saveDraft(key, draft);
      await storage.removeDraft(key, 'non-existent');

      final drafts = await storage.loadDrafts(key);
      expect(drafts.length, 1);
    });

    test('clearDrafts removes all drafts for a composite key', () async {
      final storage = Storage();
      final draft1 = DraftSchema(id: 'draft-1', content: 'First', updatedAt: DateTime.now());
      final draft2 = DraftSchema(id: 'draft-2', content: 'Second', updatedAt: DateTime.now());

      await storage.saveDraft(key, draft1);
      await storage.saveDraft(key, draft2);
      await storage.clearDrafts(key);

      final drafts = await storage.loadDrafts(key);
      expect(drafts, isEmpty);
    });

    test('drafts are scoped per composite key', () async {
      final storage = Storage();
      const String key2 = 'other.server@99';

      await storage.saveDraft(key, DraftSchema(id: 'a', content: 'Key1', updatedAt: DateTime.now()));
      await storage.saveDraft(key2, DraftSchema(id: 'b', content: 'Key2', updatedAt: DateTime.now()));

      final drafts1 = await storage.loadDrafts(key);
      final drafts2 = await storage.loadDrafts(key2);

      expect(drafts1.length, 1);
      expect(drafts1.first.content, 'Key1');
      expect(drafts2.length, 1);
      expect(drafts2.first.content, 'Key2');
    });

    test('loadDrafts returns drafts sorted by updatedAt descending', () async {
      final storage = Storage();

      await storage.saveDraft(key, DraftSchema(
        id: 'old',
        content: 'Old',
        updatedAt: DateTime.parse('2025-01-01T10:00:00.000Z'),
      ));
      await storage.saveDraft(key, DraftSchema(
        id: 'new',
        content: 'New',
        updatedAt: DateTime.parse('2025-06-01T10:00:00.000Z'),
      ));
      await storage.saveDraft(key, DraftSchema(
        id: 'mid',
        content: 'Mid',
        updatedAt: DateTime.parse('2025-03-01T10:00:00.000Z'),
      ));

      final drafts = await storage.loadDrafts(key);
      expect(drafts[0].id, 'new');
      expect(drafts[1].id, 'mid');
      expect(drafts[2].id, 'old');
    });

    test('saveDraft with poll data persists correctly', () async {
      final storage = Storage();
      final draft = DraftSchema(
        id: 'poll-draft',
        content: 'Poll question',
        poll: NewPollSchema(
          options: ['Yes', 'No', 'Maybe'],
          expiresIn: 3600,
          multiple: true,
        ),
        updatedAt: DateTime.now(),
      );

      await storage.saveDraft(key, draft);
      final drafts = await storage.loadDrafts(key);

      expect(drafts.first.poll, isNotNull);
      expect(drafts.first.poll!.options, ['Yes', 'No', 'Maybe']);
      expect(drafts.first.poll!.expiresIn, 3600);
      expect(drafts.first.poll!.multiple, true);
    });
  });
}

// vim: set ts=2 sw=2 sts=2 et:
