// The Mastodon server explorer and find a server to connect to.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

// The history drawer that shows the search history of the user.
class HistoryDrawer extends ConsumerStatefulWidget {
  final ValueChanged<String>? onTap;

  const HistoryDrawer({
    super.key,
    this.onTap,
  });

  @override
  ConsumerState<HistoryDrawer> createState() => _HistoryDrawerState();
}

class _HistoryDrawerState extends ConsumerState<HistoryDrawer> {
  late List<ServerInfoSchema> history;

  @override
  void initState() {
    super.initState();

    final AccessStatusSchema? status = ref.read(accessStatusProvider);
    history = status?.history ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: buildContent(),
    );
  }

  // Build the main content of the history drawer, which is a reorderable list view.
  Widget buildContent() {
    return Padding(
      padding: const EdgeInsets.only(top: 32, left: 16, right: 16, bottom: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            AppLocalizations.of(context)?.txt_search_history ?? "Search History",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const Divider(),
          Expanded(child: buildHistory()),
          TextButton.icon(
            icon: const Icon(Icons.cleaning_services),
            label: Text(AppLocalizations.of(context)?.btn_clear ?? "Clear"),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.secondary),
            onPressed: onClearHistoryAll,
          ),
        ],
      ),
    );
  }

  // Build the reorderable list view for the history drawer.
  Widget buildHistory() {
    return ReorderableListView.builder(
      itemCount: history.length,
      itemBuilder: (context, index) {
        final ServerInfoSchema info = history[index];
        final Widget item = ListTile(
          title: MastodonServerInfo(schema: info),
          selectedTileColor: Theme.of(context).colorScheme.primary,
          onTap: () => widget.onTap?.call(info.domain),
        );

        return Dismissible(
          key: ValueKey(info.domain),
          background: Container(
            alignment: Alignment.centerLeft,
            color: Colors.red,
            child: const Icon(Icons.delete_forever_rounded, color: Colors.white),
          ),
          direction: DismissDirection.startToEnd,
          onDismissed: (direction) => onRemoveHistory(info),
          child: item,
        );
      },
      onReorder: onReorder,
    );
  }

  // Reorder the history list when the user drags the item.
  void onReorder(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex--;
    }

    final ServerInfoSchema domain = history.removeAt(oldIndex);
    history.insert(newIndex, domain);
    onUpdateHistory();
  }

  // Remove a specific history item when the user swipes it away.
  void onRemoveHistory(ServerInfoSchema domain) async {
    history.remove(domain);
    onUpdateHistory();
  }

  // Clear all the search history.
  void onClearHistoryAll() async {
    history.clear();
    onUpdateHistory();
    context.pop(); // Close the drawer after clearing the history
  }

  // Update the history in the state and notify the parent widget.
  void onUpdateHistory() async {
    final Storage storage = Storage();
    final AccessStatusSchema status = ref.read(accessStatusProvider) ?? AccessStatusSchema();

    storage.saveAccessStatus(status.copyWith(history: history), ref: ref);
    setState(() {});
  }
}

// vim: set ts=2 sw=2 sts=2 et:
