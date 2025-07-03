// The Search widget is used to search for a Mastodon server.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

// The general search widget to search for a Mastodon server, may return the account, status, or hashtag.
class Explorer extends ConsumerStatefulWidget {
  final double size;
  final double maxWidth;

  const Explorer({
    super.key,
    this.size = 22,
    this.maxWidth = 260,
  });

  @override
  ConsumerState<Explorer> createState() => _ExplorerState();
}

class _ExplorerState extends ConsumerState<Explorer> {
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
      child: buildContent(),
    );
  }

  Widget buildContent() {
    final Widget icon = IconButton(
      icon: Icon(Icons.search, size: widget.size),
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

        hintText: AppLocalizations.of(context)?.txt_search_helper ?? 'Search for something interesting',
        hintStyle: TextStyle(color: Theme.of(context).colorScheme.surfaceBright),
      ),

      onChanged: (string) => setState(() {}),
      onSubmitted: (string) => onSearch(),
    );
  }

  // The clean-up button to clear the text field.
  Widget buildCleanButton() {
    return  IconButton(
      icon: Icon(Icons.clear, size: widget.size),
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
    final String keyword = controller.text.trim();
    if (keyword.isEmpty) {
      logger.w("Search keyword is empty, ignoring search request.");
      return;
    }

    controller.clear();
    setState(() => showInput = false);
    context.push(RoutePath.search.path, extra: keyword);
  }
}

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

  @override
  void initState() {
    super.initState();
    controller = TabController(length: types.length, vsync: this);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ServerSchema? server = ref.watch(serverProvider);
    final String? accessToken = ref.watch(accessTokenProvider);

    if (server == null) {
      logger.w("No server selected, but it's required to show the explorer.");
      return const SizedBox.shrink();
    }

    return FutureBuilder(
      future: server.search(keyword: widget.keyword, accessToken: accessToken),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Align(
            alignment: Alignment.topCenter,
            child: const LinearProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          final String text = AppLocalizations.of(context)?.txt_invalid_instance ?? 'Invalid instance: ${server.domain}';
          return Text(text, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.red));
        }

        final SearchResultSchema schema = snapshot.data!;
        return buildContent(schema);
      }
    );
  }

  Widget buildContent(SearchResultSchema schema) {
    if (schema.isEmpty) {
      final String? text = AppLocalizations.of(context)?.txt_no_results_found(widget.keyword);
      return NoResult(message: text ?? 'No results found for "${widget.keyword}"');
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
            (isSelected ?
              Theme.of(context).colorScheme.primary :
              Theme.of(context).colorScheme.onSurface
            ) : Theme.of(context).disabledColor;

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
            content = Account(schema: schema.accounts[index], showStats: true);
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
