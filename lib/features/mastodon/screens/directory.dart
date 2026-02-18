// The Public page to list accounts visible in the directory and endorsements.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

// The type of directory tab to display.
enum DirectoryType {
  directory,
  endorsements;

  // Feature toggle: set to true to enable the endorsements tab.
  static const bool enableEndorsements = false;

  bool get enabled {
    switch (this) {
      case DirectoryType.directory:
        return true;
      case DirectoryType.endorsements:
        return enableEndorsements;
    }
  }

  String tooltip(BuildContext context) {
    switch (this) {
      case DirectoryType.directory:
        return AppLocalizations.of(context)?.btn_drawer_directory ?? "Directory";
      case DirectoryType.endorsements:
        return AppLocalizations.of(context)?.btn_drawer_endorsed ?? "Featured Profiles";
    }
  }

  IconData icon({bool active = false}) {
    switch (this) {
      case DirectoryType.directory:
        return active ? Icons.groups : Icons.groups_outlined;
      case DirectoryType.endorsements:
        return active ? Icons.star : Icons.star_outline;
    }
  }
}

// The tabbed container for directory and endorsements.
class DirectoryTab extends ConsumerStatefulWidget {
  const DirectoryTab({super.key});

  @override
  ConsumerState<DirectoryTab> createState() => _DirectoryTabState();
}

class _DirectoryTabState extends ConsumerState<DirectoryTab> with SingleTickerProviderStateMixin {
  late final List<DirectoryType> tabs = DirectoryType.values.where((t) => t.enabled).toList();
  late final AccessStatusSchema? status = ref.read(accessStatusProvider);
  late final TabController controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(
      length: tabs.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (tabs.length == 1) {
      return buildTab(tabs.first);
    }

    final bool isSignedIn = status?.accessToken?.isNotEmpty == true;

    return SwipeTabView(
      tabController: controller,
      itemCount: tabs.length,
      tabBuilder: (context, index) {
        final DirectoryType type = tabs[index];
        final bool isSelected = controller.index == index;
        final bool isActivate = type != DirectoryType.endorsements || isSignedIn;
        final Color color = isActivate ?
            isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface :
            Theme.of(context).disabledColor;

        return Tooltip(
          message: type.tooltip(context),
          child: Icon(type.icon(active: isSelected), color: color, size: tabSize),
        );
      },
      itemBuilder: (context, index) => buildTab(tabs[index]),
      onTabTappable: (index) => tabs[index] != DirectoryType.endorsements || isSignedIn,
    );
  }

  Widget buildTab(DirectoryType type) {
    switch (type) {
      case DirectoryType.directory:
        return const _DirectoryList();
      case DirectoryType.endorsements:
        return AccountList(
          loader: status?.fetchEndorsedAccounts,
          onDismiss: (account) async => status?.unendorseAccount(accountId: account.id),
        );
    }
  }
}

// The paginated list of directory accounts.
class _DirectoryList extends ConsumerStatefulWidget {
  const _DirectoryList();

  @override
  ConsumerState<_DirectoryList> createState() => _DirectoryListState();
}

class _DirectoryListState extends ConsumerState<_DirectoryList> with PaginatedListMixin {
  final double loadingThreshold = 180;

  late final ScrollController controller = ScrollController();
  late final AccessStatusSchema? status = ref.read(accessStatusProvider);

  List<AccountSchema> accounts = [];
  Set<String> accountIDs = {};

  @override
  void initState() {
    super.initState();
    controller.addListener(onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load the accounts when the widget is built.
      onLoad();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildLoadingIndicator(),
          Flexible(child: buildContent()),
        ],
      ),
    );
  }

  // Build the list of accounts in the directory.
  Widget buildContent() {
    if (accounts.isEmpty) {
      if (isLoading) return const SizedBox.shrink();
      return const NoResult();
    }

    return ListView.builder(
      controller: controller,
      itemCount: accounts.length,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Account(schema: accounts[index]),
        );
      }
    );
  }

  // Detect the scroll event and load more statuses when the user scrolls to the
  // almost bottom of the list.
  Future<void> onScroll() async {
    if (controller.position.pixels >= controller.position.maxScrollExtent - loadingThreshold) {
      onLoad();
    }
  }

  // Load more accounts from the current selected Mastodon server.
  Future<void> onLoad() async {
    if (shouldSkipLoad) return;

    setLoading(true);

    final int offset = accounts.length;
    final List<AccountSchema> fetchedAccounts = await status?.fetchDirectoryAccounts(offset: offset) ?? [];
    final List<AccountSchema> newAccounts = fetchedAccounts.where((e) => !accountIDs.contains(e.id)).toList();

    if (mounted) {
      setState(() {
        accounts.addAll(newAccounts);
        accountIDs.addAll(newAccounts.map((e) => e.id));
      });
      markLoadComplete(isEmpty: fetchedAccounts.isEmpty);
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
