// The misc widget that used for the user profile page.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

// The followed hashtags widget to show the followed hashtags of the user.
class FollowedHashtags extends ConsumerStatefulWidget {
  const FollowedHashtags({super.key});

  @override
  ConsumerState<FollowedHashtags> createState() => _FollowedHashtagsState();
}

class _FollowedHashtagsState extends ConsumerState<FollowedHashtags> {
  final ScrollController controller = ScrollController();

  late final AccessStatusSchema? status = ref.read(accessStatusProvider);

  String? maxId;
  bool isLoading = false;
  bool isCompleted = false;
  List<HashtagSchema> hashtags = [];

  @override
  void initState() {
    super.initState();
    controller.addListener(onScroll);
    onLoad();
  }

  @override
  void dispose() {
    controller.removeListener(onScroll);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (status?.server == null) {
      logger.w("No server selected, but it's required to show the followed hashtags.");
      return const SizedBox.shrink();
    }

    if (hashtags.isEmpty && isLoading) {
      return const Center(child: ClockProgressIndicator());
    } else if (hashtags.isEmpty && isCompleted) {
      return const NoResult(icon: Icons.coffee);
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: buildContent(),
    );
  }

  Widget buildContent() {
    return ListView.builder(
      controller: controller,
      itemCount: hashtags.length,
      itemBuilder: (context, index) {
        final HashtagSchema hashtag = hashtags[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Hashtag(schema: hashtag),
        );
      },
    );
  }

  // Handle the scroll event to load more hashtags.
  void onScroll() {
    if (controller.position.pixels >= controller.position.maxScrollExtent - 100 && !isLoading) {
      onLoad();
    }
  }

  // Load the followed hashtags from the server.
  Future<void> onLoad() async {
    if (isLoading || isCompleted) return;

    setState(() => isLoading = true);

    final (newHashtags, newMaxID) = await status?.fetchFollowedHashtags(maxId: maxId) ?? ([], null);

    setState(() {
      isLoading = false;
      isCompleted = newHashtags.isEmpty || newMaxID == null;
      maxId = newMaxID;
      hashtags.addAll(newHashtags as List<HashtagSchema>);
    });
  }
}

// The list of the account for the user profile page.
class AccountList extends ConsumerStatefulWidget {
  final Future<(List<AccountSchema>, String?)> Function({String? maxId})? loader;

  const AccountList({
    super.key,
    this.loader,
  });

  @override
  ConsumerState<AccountList> createState() => _AccountListState();
}

class _AccountListState extends ConsumerState<AccountList> {
  final ScrollController controller = ScrollController();

  late final AccessStatusSchema? status = ref.read(accessStatusProvider);

  String? maxId;
  bool isLoading = false;
  bool isCompleted = false;
  List<AccountSchema> accounts = [];

  @override
  void initState() {
    super.initState();
    controller.addListener(onScroll);
    onLoad();
  }

  @override
  void dispose() {
    controller.removeListener(onScroll);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (status?.server == null) {
      logger.w("No server selected, but it's required to show the account list.");
      return const SizedBox.shrink();
    }

    if (accounts.isEmpty && isLoading) {
      return const Center(child: ClockProgressIndicator());
    } else if (accounts.isEmpty && isCompleted) {
      final String message = AppLocalizations.of(context)?.txt_no_result ?? "No results found";
      return NoResult(message: message, icon: Icons.coffee);
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: buildContent(),
    );
  }

  Widget buildContent() {
    return ListView.builder(
      controller: controller,
      itemCount: accounts.length,
      itemBuilder: (context, index) {
        final AccountSchema account = accounts[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Account(schema: account),
        );
      },
    );
  }

  // Handle the scroll event to load more accounts.
  void onScroll() {
    if (controller.position.pixels >= controller.position.maxScrollExtent - 100 && !isLoading) {
      onLoad();
    }
  }

  // Load the accounts from the server.
  Future<void> onLoad() async {
    if (isLoading || isCompleted) return;

    setState(() => isLoading = true);

    final (newAccounts, newMaxID) = await widget.loader?.call(maxId: maxId) ?? ([], null);

    setState(() {
      isLoading = false;
      isCompleted = newAccounts.isEmpty || newMaxID == null;
      maxId = newMaxID;
      accounts.addAll(newAccounts as List<AccountSchema>);
    });
  }
}


// vim: set ts=2 sw=2 sts=2 et:
