// The Status widget to show the toots from user.
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:glacial/features/timeline/models/core.dart';

// The account widget to show the account information.
class Account extends StatelessWidget {
  final AccountSchema schema;
  final double maxHeight;

  const Account({
    super.key,
    required this.schema,
    this.maxHeight = 48,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: maxHeight,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxHeight < maxHeight) {
            return Row(
              children: [
                buildAvatar(),
                const SizedBox(width: 6),
                buildDisplayName(),
              ]
            );
          }

          return buildContent();
        },
      ),
    );
  }

  Widget buildContent() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildAvatar(),
        const SizedBox(width: 16),
        buildName(),
      ],
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
    final String text = schema.displayName.isEmpty ? schema.username : schema.displayName;
    return Text(text, overflow: TextOverflow.ellipsis);
  }
}
// vim: set ts=2 sw=2 sts=2 et:
