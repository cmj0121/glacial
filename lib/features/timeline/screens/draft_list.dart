// The draft list bottom sheet for managing saved drafts.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';

// Bottom sheet that displays saved drafts for the current account.
class DraftListSheet extends ConsumerStatefulWidget {
  final AccessStatusSchema? status;

  const DraftListSheet({super.key, required this.status});

  @override
  ConsumerState<DraftListSheet> createState() => _DraftListSheetState();
}

class _DraftListSheetState extends ConsumerState<DraftListSheet> {
  List<DraftSchema> drafts = [];
  bool isLoading = true;

  String? get _compositeKey {
    final String? domain = widget.status?.domain;
    final String? accountId = widget.status?.account?.id;
    if (domain == null || accountId == null) return null;
    return '$domain@$accountId';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => onLoad());
  }

  Future<void> onLoad() async {
    final String? key = _compositeKey;
    if (key == null) {
      if (mounted) setState(() => isLoading = false);
      return;
    }

    final Storage storage = Storage();
    final List<DraftSchema> saved = await storage.loadDrafts(key);

    if (mounted) {
      setState(() {
        drafts = saved;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final String title = l10n?.txt_drafts_title ?? 'Drafts';

    if (isLoading) return const ClockProgressIndicator();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          drafts.isEmpty ? buildEmptyState(context) : buildDraftList(),
        ],
      ),
    );
  }

  Widget buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final String text = l10n?.txt_no_drafts ?? 'No drafts';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Text(text, style: TextStyle(color: Theme.of(context).disabledColor)),
      ),
    );
  }

  Widget buildDraftList() {
    return Flexible(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: drafts.length,
        itemBuilder: (context, index) => buildDraftTile(drafts[index]),
      ),
    );
  }

  Widget buildDraftTile(DraftSchema draft) {
    final String preview = draft.content.length > 80
        ? '${draft.content.substring(0, 80)}...'
        : draft.content;
    final String duration = timeago.format(draft.updatedAt, locale: timeagoLocale(context));

    return Dismissible(
      key: ValueKey(draft.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Theme.of(context).colorScheme.error,
        child: Icon(Icons.delete, color: Theme.of(context).colorScheme.onError),
      ),
      onDismissed: (_) => onRemoveDraft(draft),
      child: ListTile(
        leading: Icon(
          draft.inReplyToId != null ? Icons.reply : Icons.edit_note,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          preview.isNotEmpty ? preview : (draft.spoiler ?? '...'),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            Text(duration, style: const TextStyle(color: Colors.grey)),
            if (draft.poll != null) ...[
              const SizedBox(width: 8),
              Icon(Icons.poll, size: 14, color: Colors.grey),
            ],
            if (draft.quoteToId != null) ...[
              const SizedBox(width: 8),
              Icon(Icons.format_quote, size: 14, color: Colors.grey),
            ],
          ],
        ),
        trailing: Icon(Icons.chevron_right, color: Theme.of(context).disabledColor),
        onTap: () => onOpenDraft(draft),
      ),
    );
  }

  Future<void> onOpenDraft(DraftSchema draft) async {
    Navigator.of(context).pop();
    context.push(RoutePath.postDraft.path, extra: draft);
  }

  Future<void> onRemoveDraft(DraftSchema draft) async {
    final String? key = _compositeKey;
    if (key == null) return;

    final Storage storage = Storage();
    await storage.removeDraft(key, draft.id);

    if (mounted) {
      final l10n = AppLocalizations.of(context);
      final String message = l10n?.msg_draft_deleted ?? 'Draft deleted';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      setState(() => drafts.removeWhere((d) => d.id == draft.id));
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
