// The Status widget to show the toots from user.
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';

// The account widget to show the account information.
class Account extends StatelessWidget {
  final AccountSchema schema;
  final double maxHeight;

  const Account({
    super.key,
    required this.schema,
    this.maxHeight = 52,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: maxHeight,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          late Widget content;

          if (constraints.maxHeight < 24) {
            content = Row(
              children: [
                buildAvatar(),
                const SizedBox(width: 6),
                buildDisplayName(),
              ]
            );
          } else {
            content = buildContent();
          }

          return InkWellDone(
            onTap: () => context.push(RoutePath.wip.path, extra: schema),
            child: content,
          );
        },
      ),
    );
  }

  Widget buildContent() {
    final Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildAvatar(),
        const SizedBox(width: 16),
        buildName(),
      ],
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: content,
    );
  }

  // Build the Avatar of the user.
  Widget buildAvatar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: schema.avatar,
        placeholder: (context, url) => const CircularProgressIndicator(),
        errorWidget: (context, url, error) => const Icon(Icons.error),
        fit: BoxFit.cover,
      ),
    );
  }

  // Build the display name and the account name of the user.
  Widget buildName() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildDisplayName(),
        Text('@${schema.acct}', style: const TextStyle(color: Colors.grey), overflow: TextOverflow.ellipsis),
      ],
    );
  }

  // Build display name with the emoji
  Widget buildDisplayName() {
    return Text(schema.displayName.isEmpty ? schema.username : schema.displayName);
  }
}

// vim: set ts=2 sw=2 sts=2 et:
