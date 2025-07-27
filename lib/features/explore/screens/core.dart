// The Search widget is used to search for a Mastodon server.
import 'package:flutter/material.dart';

import 'package:glacial/core.dart';

class Explorer extends StatefulWidget {
  final double size;
  final double maxWidth;

  const Explorer({
    super.key,
    this.size = 24,
    this.maxWidth = 320,
  });

  @override
  State<Explorer> createState() => _ExplorerState();
}

class _ExplorerState extends State<Explorer> with SingleTickerProviderStateMixin {
  final TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode();

  bool showInput = false;

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: widget.maxWidth),
      child: Padding(
        padding: const EdgeInsets.only(top: 4.0, right: 8.0),
        child: buildContent(),
      ),
    );
  }

  Widget buildContent() {
    final Widget icon = IconButton(
      icon: Icon(Icons.search, size: widget.size),
      tooltip: AppLocalizations.of(context)?.btn_search ?? "Search",
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      onPressed: onShowSearch,
    );

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: showInput ? buildSearchBar() : icon,
    );
  }

  // the search bar to search for a Mastodon server
  Widget buildSearchBar() {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        prefixIcon: IconButton(
          icon: Icon(Icons.search, size: widget.size),
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          onPressed: () => onSearch(),
        ),
        suffixIcon: buildCleanButton(),
      ),

      onChanged: (string) => setState(() {}),
      onSubmitted: (string) => onSearch(),
    );
  }

  // The clean-up button to clear the text field.
  Widget buildCleanButton() {
    return  IconButton(
      icon: Icon(Icons.clear, size: widget.size),
      tooltip: AppLocalizations.of(context)?.btn_close ?? "Close",
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      onPressed: () {
        controller.clear();
        setState(() => showInput = false);
      },
    );
  }

  void onShowSearch() async {
    setState(() => showInput = true);
    focusNode.requestFocus();
  }

  void onSearch() async {
  }
}

// vim: set ts=2 sw=2 sts=2 et:
