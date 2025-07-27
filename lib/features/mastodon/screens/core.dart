// The Mastodon server explorer and find a server to connect to.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';

// The main search page that shows the search bar and the possible mastodon servers.
class ServerExplorer extends ConsumerStatefulWidget {
  const ServerExplorer({super.key});

  @override
  ConsumerState<ServerExplorer> createState() => _ServerExplorerState();
}

class _ServerExplorerState extends ConsumerState<ServerExplorer> {
  final TextEditingController controller = TextEditingController();

  Widget? child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
       child: Align(
          alignment: Alignment.topCenter,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: buildContent(),
            ),
          ),
        ),
      ),
      drawer: const HistoryDrawer(),
    );
  }

  // The main content of the explorer page, shows the search bar and the mastodon server list.
  Widget buildContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildHeader(),
        const SizedBox(height: 16),
        Flexible(child: child ?? const SizedBox.shrink()),
      ],
    );
  }

  // The header of the explorer page, shows the search bar and the history button to show the search history.
  Widget buildHeader() {
    final double iconSize = 36;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Flexible(child: buildSearchBar()),
        const SizedBox(width: 16),
        Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(Icons.history, size: iconSize),
              tooltip: AppLocalizations.of(context)?.btn_history ?? "History",
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
      ],
    );
  }

  // The text field for the search bar and support typing the server name or
  // the server URL.
  Widget buildSearchBar() {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: IconButton(
          icon: Icon(Icons.search),
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          onPressed: () => onSearch(),
        ),
        suffixIcon: buildCleanButton(),
        helperText: AppLocalizations.of(context)?.txt_helper_server_explorer ?? "Search for a Mastodon server",

        hintText: AppLocalizations.of(context)?.txt_hint_server_explorer ?? "mastodon.social or keyword",
        hintStyle: TextStyle(color: Theme.of(context).colorScheme.secondaryContainer),

        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: Colors.grey, width: 1),
        ),
      ),

      onChanged: (string) => setState(() {}),
      onSubmitted: (string) => onSearch(),
    );
  }

  // The clean-up button to clear the text field.
  Widget buildCleanButton() {
    final bool isEmpty = controller.text.isEmpty;
    if (isEmpty) {
      return const SizedBox.shrink();
    }

    return  IconButton(
      icon: Icon(Icons.clear),
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      onPressed: onClearSearch,
    );
  }

  // The search function that is called when the user presses the search
  void onSearch() async {
    final String query = controller.text.trim();

    if (query.isEmpty) {
      return;
    }

    logger.d("searching server for: $query");
  }

  // Clear the search text field and reset the search results.
  void onClearSearch() {
    controller.clear();
    setState(() => child = null);
  }
}

// The history drawer that shows the search history of the user.
class HistoryDrawer extends ConsumerStatefulWidget {
  const HistoryDrawer({super.key});

  @override
  ConsumerState<HistoryDrawer> createState() => _HistoryDrawerState();
}

class _HistoryDrawerState extends ConsumerState<HistoryDrawer> {
  List<String> history = [];

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
        final String domain = history[index];
        final Widget item = ListTile(
          title: Text(domain, overflow: TextOverflow.ellipsis),
          selectedTileColor: Theme.of(context).colorScheme.primary,
          onTap: () {},
        );

        return Dismissible(
          key: ValueKey(domain),
          background: Container(
            alignment: Alignment.centerLeft,
            color: Colors.red,
            child: const Icon(Icons.delete_forever_rounded, color: Colors.white),
          ),
          direction: DismissDirection.startToEnd,
          onDismissed: (direction) => onRemoveHistory(domain),
          child: item,
        );
      },
      onReorder: onReorder,
    );
  }

  // Reorder the history list when the user drags the item.
  void onReorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex--;
    }

    final String domain = history.removeAt(oldIndex);
    history.insert(newIndex, domain);
  }

  // Remove a specific history item when the user swipes it away.
  void onRemoveHistory(String domain) {
    history.remove(domain);
    setState(() {});
  }

  // Clear all the search history.
  void onClearHistoryAll() {
  }
}

// vim: set ts=2 sw=2 sts=2 et:
