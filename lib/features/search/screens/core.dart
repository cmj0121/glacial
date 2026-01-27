// The Search widget is used to search for a Mastodon server.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

// The search explorer widget that show the search icon and the text field to search for a Mastodon server.
class SearchExplorer extends ConsumerStatefulWidget {
  final double size;
  final double maxWidth;

  const SearchExplorer({
    super.key,
    this.size = iconSize,
    this.maxWidth = 320,
  });

  @override
  ConsumerState<SearchExplorer> createState() => _ExplorerState();
}

class _ExplorerState extends ConsumerState<SearchExplorer> with SingleTickerProviderStateMixin {
  late final AccessStatusSchema? status = ref.read(accessStatusProvider);
  late final TextEditingController controller = TextEditingController();
  late final FocusNode focusNode = FocusNode();

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
        padding: const EdgeInsets.only(right: 8.0),
        child: buildContent(),
      ),
    );
  }

  Widget buildContent() {
    final bool isSignedIn = status?.accessToken?.isNotEmpty == true;

    final Widget icon = IconButton(
      icon: Icon(Icons.search, size: widget.size),
      tooltip: AppLocalizations.of(context)?.btn_search ?? "Search",
      onPressed: isSignedIn ? onShowSearch : null,
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
      onPressed: () {
        controller.clear();
        setState(() => showInput = false);
      },
    );
  }

  Future<void> onShowSearch() async {
    setState(() => showInput = true);
    focusNode.requestFocus();
  }

  Future<void> onSearch() async {
    final String query = controller.text.trim();

    if (query.isNotEmpty) {
      controller.clear();
      setState(() => showInput = false);
      context.push(RoutePath.search.path, extra: query);
    }
  }
}

// The search result explorer tab that shows the search results for a given keyword.
class ExplorerTab extends ConsumerStatefulWidget {
  final String keyword;

  const ExplorerTab({
    super.key,
    required this.keyword,
  });

  @override
  ConsumerState<ExplorerTab> createState() => _ExplorerTabState();
}

class _ExplorerTabState extends ConsumerState<ExplorerTab> with SingleTickerProviderStateMixin {
  final List<ExplorerResultType> types = ExplorerResultType.values;

  late final TabController controller;
  late final Future<SearchResultSchema?> _searchFuture;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: types.length, vsync: this);
    final AccessStatusSchema? status = ref.read(accessStatusProvider);
    _searchFuture = status?.search(keyword: widget.keyword) ?? Future.value(null);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SearchResultSchema?>(
      future: _searchFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Align(
            alignment: Alignment.topCenter,
            child: LinearProgressIndicator(),
          );
        } else if (snapshot.hasError || snapshot.data == null) {
          return const NoResult();
        }

        final SearchResultSchema schema = snapshot.data!;
        return buildContent(schema);
      }
    );
  }

  Widget buildContent(SearchResultSchema schema) {
    if (schema.isEmpty) {
      return const NoResult();
    }

    return SwipeTabView(
      tabController: controller,
      itemCount: types.length,
      tabBuilder: (context, index) {
        final ExplorerResultType type = types[index];
        final bool isSelected = controller.index == index;
        late final bool isActive;

        switch (type) {
          case ExplorerResultType.account:
            isActive = schema.accounts.isNotEmpty;
          case ExplorerResultType.status:
            isActive = schema.statuses.isNotEmpty;
          case ExplorerResultType.hashtag:
            isActive = schema.hashtags.isNotEmpty;
        }

        final Color color = isActive ?
            (isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface) :
            Theme.of(context).disabledColor;

        return Icon(type.icon(active: isSelected), color: color);
      },
      itemBuilder: (context, index) => buildTabContent(schema, index),
      onTabTappable: (index) {
        final ExplorerResultType type = types[index];
        switch (type) {
          case ExplorerResultType.account:
            return schema.accounts.isNotEmpty;
          case ExplorerResultType.status:
            return schema.statuses.isNotEmpty;
          case ExplorerResultType.hashtag:
            return schema.hashtags.isNotEmpty;
        }
      }
    );
  }

  Widget buildTabContent(SearchResultSchema schema, int index) {
    final ExplorerResultType type = types[index];
    late final int count;

    switch (type) {
      case ExplorerResultType.account:
        count = schema.accounts.length;
        break;
      case ExplorerResultType.status:
        count = schema.statuses.length;
        break;
      case ExplorerResultType.hashtag:
        count = schema.hashtags.length;
        break;
    }

    return ListView.builder(
      itemCount: count,
      itemBuilder: (context, index) {
        final Widget content;

        switch (type) {
          case ExplorerResultType.account:
            content = Account(schema: schema.accounts[index]);
          case ExplorerResultType.status:
            content = Status(schema: schema.statuses[index]);
          case ExplorerResultType.hashtag:
            content = Hashtag(schema: schema.hashtags[index]);
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: content,
        );
      },
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
