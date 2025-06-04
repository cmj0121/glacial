// The Mastodon server explorer.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

// The main search page that shows the search bar and the possible
// mastodon servers.
class ServerExplorer extends ConsumerStatefulWidget {
  const ServerExplorer({super.key});

  @override
  ConsumerState<ServerExplorer> createState() => _ServerExplorerState();
}

class _ServerExplorerState extends ConsumerState<ServerExplorer> {
  final TextEditingController controller = TextEditingController();
  final Storage storage = Storage();

  Widget? child;
  late List<String> history;

  @override
  void initState() {
    super.initState();
    history = storage.serverHistory;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

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
      drawer: Drawer(child: buildSidebar()),
    );
  }

  // The main content of the explorer page, shows the search bar and the
  // mastodon server list.
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

  // The sidebar of the explorer page, shows the search history
  Widget buildSidebar() {
    final bool isEmpty = history.isEmpty;

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
          Expanded(child: buildServerHistory()),
          TextButton.icon(
            icon: const Icon(Icons.cleaning_services),
            label: Text(AppLocalizations.of(context)?.btn_clean_all ?? "Clear All"),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.secondary,
            ),
            onPressed: isEmpty ? null : () {
              storage.serverHistory = [];
              setState(() => history = []);
            },
          ),
        ],
      ),
    );
  }

  // The header of the explorer page, shows the search bar and the history
  // button to show the search history.
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
              onPressed: () => Scaffold.of(context).openDrawer(),
              tooltip: "Search History",
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

        hintText: AppLocalizations.of(context)?.txt_search_mastodon ?? "mastodon.social",
        hintStyle: TextStyle(color: Theme.of(context).colorScheme.surfaceBright),
        helperText: AppLocalizations.of(context)?.txt_search_helper ?? 'Search for something interesting',

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
      onPressed: () {
        controller.clear();
        setState(() => child = null);
      },
    );
  }

  // The history of the search, shows the list of mastodon servers that the user
  // can select it again.
  Widget buildServerHistory() {
    return ReorderableListView.builder(
      itemCount: history.length,
      itemBuilder: (context, index) {
        final String domain = history[index];
        final Widget item = ListTile(
          title: Text(domain, overflow: TextOverflow.ellipsis),
          selectedTileColor: Theme.of(context).colorScheme.primary,
          onTap: () {
            controller.text = domain;
            onSearch();
            Navigator.of(context).pop();
          },
        );

        return Dismissible(
          key: ValueKey(domain),
          background: Container(
            alignment: Alignment.centerLeft,
            color: Colors.red,
            child: const Icon(Icons.delete_forever_rounded, color: Colors.white),
          ),
          direction: DismissDirection.startToEnd,
          onDismissed: (direction) {
            history.removeAt(index);
            storage.serverHistory = history;
            setState(() {});
          },
          child: item,
        );
      },
      onReorder: onReorder,
    );
  }

  // The search function that is called when the user presses the search
  void onSearch() async {
    final String keyword = controller.text.trim();

    if (keyword.isEmpty) {
      return;
    }

    setState( () => child = MastodonServer.builder(domain: keyword, onTap: onSelect) );
  }

  // The callback when user clicks the mastodon server.
  void onSelect(ServerSchema schema) async {
    logger.i("onTap: ${schema.domain}");

    setState(() {
      if (!history.contains(schema.domain)) {
        history.add(schema.domain);
        storage.serverHistory = history;
      }
    });

    if (mounted) {
      context.push(RoutePath.wip.path, extra: schema);
    }
  }

  // Reorder the history list when the user drags the item.
  void onReorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex--;
    }

    final String domain = history.removeAt(oldIndex);
    history.insert(newIndex, domain);
    storage.serverHistory = history;
  }
}

// vim: set ts=2 sw=2 sts=2 et:
