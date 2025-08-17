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

class _DirectoryAccountState extends ConsumerState<DirectoryAccount> {
  final double loadingThreshold = 180;

  late final ScrollController controller = ScrollController();
  late final AccessStatusSchema? status = ref.read(accessStatusProvider);

  bool isRefresh = false;
  bool isLoading = false;
  bool isCompleted = false;
  List<AccountSchema> accounts = [];

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
          (isLoading && !isRefresh) ? ClockProgressIndicator() : const SizedBox.shrink(),
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
  void onLoad() async {
    if (isLoading || isCompleted) {
      return;
    }

    if (mounted) setState(() => isLoading = true);

    final int offset = this.accounts.length;
    final List<AccountSchema> accounts = await status?.fetchDirectoryAccounts(offset: offset) ?? [];

    if (mounted) {
      setState(() {
        isRefresh = false;
        isLoading = false;
        isCompleted = accounts.isEmpty;
        this.accounts.addAll(accounts);
      });
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
