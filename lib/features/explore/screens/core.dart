// The Search widget is used to search for a Mastodon server.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/explore/models/explorer.dart';

// The general search widget to search for a Mastodon server, may return the account, status, or hashtag.
class Explorer extends ConsumerStatefulWidget {
  const Explorer({super.key});

  @override
  ConsumerState<Explorer> createState() => _ExplorerState();
}

class _ExplorerState extends ConsumerState<Explorer> {
  final TextEditingController controller = TextEditingController();

  Widget? content;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: buildContent(),
    );
  }

  Widget buildContent() {
    return Column(
      children: [
        buildSearchBar(),
        const SizedBox(height: 8),
        Flexible(child: content ?? const SizedBox.shrink()),
      ],
    );
  }

  // the search bar to search for a Mastodon server
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
        setState(() => content = null);
      },
    );
  }

  void onSearch() async {
    setState(() => content = ExplorerTab());
  }
}

class ExplorerTab extends ConsumerStatefulWidget {
  const ExplorerTab({
    super.key,
  });

  @override
  ConsumerState<ExplorerTab> createState() => _ExplorerTabState();
}

class _ExplorerTabState extends ConsumerState<ExplorerTab> with SingleTickerProviderStateMixin {
  final List<ExplorerResultType> types = ExplorerResultType.values;
  late final TabController controller;

  Widget? content;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: types.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return SlideTabView(
      controller: controller,
      tabs: types,
      itemBuilder: (context, index) {
        return Dismissible(
          key: ValueKey('ExplorerTab-$index'),
          direction: DismissDirection.horizontal,
          onDismissed: (direction) {
            final int offset = direction == DismissDirection.startToEnd ? -1 : 1;
            controller.index = (controller.index + offset) % types.length;
          },
          child: buildContent(index),
        );
      },
    );
  }

  Widget buildContent(int index) {
    return Text('$index');
  }
}

// vim: set ts=2 sw=2 sts=2 et:
