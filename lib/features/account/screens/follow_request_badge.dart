// The pending follow request badge to show the pending follow request.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';

class FollowRequestBadge extends ConsumerStatefulWidget {
  const FollowRequestBadge({super.key});

  @override
  ConsumerState<FollowRequestBadge> createState() => _FollowRequestBadgeState();
}

class _FollowRequestBadgeState extends ConsumerState<FollowRequestBadge> {
  late final AccessStatusSchema? status = ref.read(accessStatusProvider);

  int pendingCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => onLoad());
  }

  @override
  Widget build(BuildContext context) {
    if (pendingCount == 0) {
      // No need to show the badge when there is no pending follow request or the follow request page is selected.
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: IconButton(
        icon: Icon(Icons.pending_actions),
        style: IconButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.onTertiary,
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () => context.push(RoutePath.followRequests.path),
      ),
    );
  }

  // Try to load the ending follow requests when the widget is built.
  Future<void> onLoad() async {
    final List<AccountSchema> accounts = await status?.fetchFollowRequests() ?? [];
    final int count = accounts.length;

    if (mounted) setState(() => pendingCount = count);
  }
}

// vim: set ts=2 sw=2 sts=2 et:
