// The simple user statistics widget to show the user statistics such as followers, following, and statuses.
import 'package:flutter/material.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';

class UserStatistics extends StatelessWidget {
  final AccountSchema schema;
  final VoidCallback? onFollowersTap;
  final VoidCallback? onFollowingTap;
  final VoidCallback? onStatusesTap;

  const UserStatistics({
    super.key,
    required this.schema,
    this.onFollowersTap,
    this.onFollowingTap,
    this.onStatusesTap,
  });

  @override
  Widget build(BuildContext context) {
    final double maxWidth = 420;
    final int statuses = schema.statusesCount;
    final int followers = schema.followersCount;
    final int following = schema.followingCount;
    final List<Widget> children = [
      TextButton.icon(
        label: Text('$statuses'),
        icon: const Icon(Icons.post_add),
        onPressed: onStatusesTap,
      ),

      TextButton.icon(
        label: Text('$followers'),
        icon: const Icon(Icons.visibility),
        onPressed: onFollowersTap,
      ),
      TextButton.icon(
        label: Text('$following'),
        icon: const Icon(Icons.star),
        onPressed: onFollowingTap,
      ),

      buildFollowerLock(context),
      buildDiscoverable(context),
      buildIndexable(context),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > maxWidth) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: children,
          );
        } else {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(2, (index) {
              final int start = (children.length / 2 * index).floor();
              final int end = (children.length / 2 * (index + 1)).floor();
              final List<Widget> items = children.sublist(start, end);

              if (items.isEmpty) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: items,
                ),
              );
            }),
          );
        }
      },
    );
  }

  Widget buildFollowerLock(BuildContext context) {
    if (!schema.locked) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Tooltip(
        message: AppLocalizations.of(context)?.desc_profile_locked ?? "Manually approved followers",
        child: Icon(Icons.lock_person, color: Theme.of(context).colorScheme.secondary, size: tabSize),
      ),
    );
  }

  Widget buildDiscoverable(BuildContext context) {
    if (!(schema.discoverable ?? false)) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Tooltip(
        message: AppLocalizations.of(context)?.desc_profile_discoverable ?? "Account can be discoverable in public",
        child: Icon(Icons.travel_explore, color: Theme.of(context).colorScheme.secondary, size: tabSize),
      ),
    );
  }

  Widget buildIndexable(BuildContext context) {
    final bool showIndexable = !(schema.noindex ?? true) || schema.indexable;
    if (!showIndexable) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Tooltip(
        message: AppLocalizations.of(context)?.desc_profile_post_indexable ?? "Allow search engines to index your posts",
        child: Icon(Icons.search, color: Theme.of(context).colorScheme.secondary, size: tabSize),
      ),
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
