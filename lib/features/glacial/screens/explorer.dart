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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Flexible(child: buildSearchBar()),
        const SizedBox(width: 16),
        Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.history),
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
    logger.i("searching for $keyword");

    setState(() {
      child = Text("Searching $keyword ...");
    });
  }
}

// vim: set ts=2 sw=2 sts=2 et:
