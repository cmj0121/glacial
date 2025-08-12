// The Mastodon server explorer and find a server to connect to.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

// The main search page that shows the search bar and the possible mastodon servers.
class ServerExplorer extends ConsumerStatefulWidget {
  const ServerExplorer({super.key});

  @override
  ConsumerState<ServerExplorer> createState() => _ServerExplorerState();
}

class _ServerExplorerState extends ConsumerState<ServerExplorer> {
  final TextEditingController controller = TextEditingController();
  final Storage storage = Storage();

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
      drawer: HistoryDrawer(onTap: (String server) {
        controller.text = server;
        onSearch();
        context.pop();
      }),
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
    final AccessStatusSchema? status = ref.watch(accessStatusProvider);

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
              onPressed: status?.history.isEmpty ?? true ? null : () => Scaffold.of(context).openDrawer(),
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

    setState( () => child = MastodonServer.builder(domain: query, onTap: onSelect) );
  }

  // The callback when user clicks the mastodon server.
  void onSelect(ServerSchema schema) async {
    final AccessStatusSchema status = ref.read(accessStatusProvider) ?? AccessStatusSchema();
    List<ServerInfoSchema> history = status.history.toList();

    // If the server not already in the history, add it.
    if (!history.any((ServerInfoSchema info) => info.domain == schema.domain)) {
      history.add(schema.toInfo());
    }

    logger.i("onTap: ${schema.domain}");
    await storage.saveAccessStatus(status.copyWith(domain: schema.domain, history: history), ref: ref);

    if (mounted) {
      context.go(RoutePath.timeline.path);
    }
  }

  // Clear the search text field and reset the search results.
  void onClearSearch() {
    controller.clear();
    setState(() => child = null);
  }
}

// vim: set ts=2 sw=2 sts=2 et:
