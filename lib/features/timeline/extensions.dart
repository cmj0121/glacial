// The extensions implementation for the timeline draft feature.
import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';

extension DraftStorageExtension on Storage {
  // Load all drafts for the given account composite key, sorted by updatedAt descending.
  Future<List<DraftSchema>> loadDrafts(String compositeKey) async {
    final String? json = await getString(DraftSchema.storageKey(compositeKey));
    if (json == null) return [];

    final List<DraftSchema> drafts = DraftSchema.decode(json);
    drafts.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return drafts;
  }

  // Save a draft (upsert by id). Trims to maxDrafts, removing oldest.
  Future<void> saveDraft(String compositeKey, DraftSchema draft) async {
    final List<DraftSchema> drafts = await loadDrafts(compositeKey);

    // Remove existing draft with same id (upsert).
    drafts.removeWhere((d) => d.id == draft.id);
    drafts.insert(0, draft);

    // Trim to max drafts limit.
    while (drafts.length > DraftSchema.maxDrafts) {
      drafts.removeLast();
    }

    await setString(DraftSchema.storageKey(compositeKey), DraftSchema.encode(drafts));
  }

  // Remove a specific draft by id.
  Future<void> removeDraft(String compositeKey, String draftId) async {
    final List<DraftSchema> drafts = await loadDrafts(compositeKey);
    drafts.removeWhere((d) => d.id == draftId);
    await setString(DraftSchema.storageKey(compositeKey), DraftSchema.encode(drafts));
  }

  // Clear all drafts for the given account.
  Future<void> clearDrafts(String compositeKey) async {
    await remove(DraftSchema.storageKey(compositeKey));
  }
}

// vim: set ts=2 sw=2 sts=2 et:
