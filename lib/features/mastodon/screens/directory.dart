// The Public page to list accounts visible in the directory.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

// The public page to list accounts visible in the directory, which is public
// and can be accessed by anyone.
class DirectoryAccount extends ConsumerStatefulWidget {
  const DirectoryAccount({super.key});

  @override
  ConsumerState<DirectoryAccount> createState() => _DirectoryAccountState();
}

class _DirectoryAccountState extends ConsumerState<DirectoryAccount> with PaginatedListMixin {
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
      return const SizedBox.shrink();
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
  void onScroll() async {
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
