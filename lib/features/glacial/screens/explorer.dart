// The Mastodon server explorer.
import 'package:flutter/material.dart';

import 'package:glacial/core.dart';

// The main search page that shows the search bar and the possible
// mastodon servers.
class ServerExplorer extends StatefulWidget {
  const ServerExplorer({super.key});

  @override
  State<ServerExplorer> createState() => _ServerExplorerState();
}

class _ServerExplorerState extends State<ServerExplorer> {
  final TextEditingController controller = TextEditingController();

  Widget? child;

  @override
  void initState() {
    super.initState();
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
              padding: const EdgeInsets.all(16.0),
              child: buildContent(),
            ),
          ),
        ),
      ),
      drawer: const Drawer(
        child: Center(
          child: Text("Search History"),
        ),
      ),
    );
  }

  Widget buildContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildHeader(),
        const SizedBox(height: 16),
        child ?? const SizedBox.shrink(),
      ],
    );
  }

  // The header of the explorer page, shows the search bar and the history
  // button to show the search history.
  Widget buildHeader() {
    final double iconSize = 32;

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
        setState(() {});
      },
    );
  }

  void onSearch() async {
    final String keyword = controller.text.trim();

    if (keyword.isEmpty) {
      return;
    }

    setState( () => child = ServerBuilder(domain: keyword));
  }
}

class ServerBuilder extends StatelessWidget {
  final String domain;

  const ServerBuilder({
    super.key,
    required this.domain,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetch(domain),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LinearProgressIndicator();
        } else if (snapshot.hasError) {
          final String text = AppLocalizations.of(context)?.txt_invalid_instance ?? 'Invalid instance: $domain';
          return Text(text, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.red));
        }

        return Text('Finding the server: $domain');
      }
    );
  }

  Future<void> fetch(String domain) async {
    logger.i('search the mastodon server: $domain');

    final Uri url = Uri.parse('https://$domain/api/v2/instance');
    final response = await get(url);
    logger.i('response: ${response.body}');
  }
}

// vim: set ts=2 sw=2 sts=2 et:
