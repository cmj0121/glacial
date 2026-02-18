// The domain blocks management screen.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';

// A list of blocked domains with swipe-to-unblock.
class DomainBlockList extends ConsumerStatefulWidget {
  const DomainBlockList({super.key});

  @override
  ConsumerState<DomainBlockList> createState() => _DomainBlockListState();
}

class _DomainBlockListState extends ConsumerState<DomainBlockList> with PaginatedListMixin {
  final ScrollController controller = ScrollController();

  late final AccessStatusSchema? status = ref.read(accessStatusProvider);

  String? maxId;
  List<String> domains = [];

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
      logger.w("No server selected, but it's required to show domain blocks.");
      return const SizedBox.shrink();
    }

    if (domains.isEmpty && isLoading) {
      return const LoadingOverlay(isLoading: true, child: SizedBox.expand());
    } else if (domains.isEmpty && isCompleted) {
      final String message = AppLocalizations.of(context)?.txt_no_domain_blocks ?? "No blocked domains";
      return NoResult(message: message, icon: Icons.dns_outlined);
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: buildContent(),
    );
  }

  Widget buildContent() {
    return ListView.builder(
      controller: controller,
      itemCount: domains.length,
      itemBuilder: (context, index) {
        final String domain = domains[index];

        return AccessibleDismissible(
          dismissKey: ValueKey(domain),
          direction: DismissDirection.endToStart,
          dismissLabel: AppLocalizations.of(context)?.lbl_swipe_remove,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            color: Theme.of(context).colorScheme.error,
            child: Icon(Icons.delete, color: Theme.of(context).colorScheme.onError),
          ),
          confirmDismiss: (_) async {
            setState(() => domains.removeAt(index));
            status?.unblockDomain(domain);
            return false;
          },
          child: ListTile(
            leading: const Icon(Icons.dns),
            title: Text(domain),
          ),
        );
      },
    );
  }

  void onScroll() {
    if (controller.position.pixels >= controller.position.maxScrollExtent - 100 && !isLoading) {
      onLoad();
    }
  }

  Future<void> onLoad() async {
    if (shouldSkipLoad) return;

    setLoading(true);

    final (newDomains, newMaxID) = await status?.fetchDomainBlocks(maxId: maxId) ?? (<String>[], null);

    if (mounted) {
      setState(() {
        maxId = newMaxID;
        domains.addAll(newDomains);
      });
      markLoadComplete(isEmpty: newDomains.isEmpty || newMaxID == null);
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
