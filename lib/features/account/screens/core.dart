// The Status widget to show the toots from user.
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';

// The account widget to show the account information.
class Account extends StatelessWidget {
  final AccountSchema schema;
  final double size;

  const Account({
    super.key,
    required this.schema,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
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
    return CachedNetworkImage(
      imageUrl: schema.avatar,
      placeholder: (context, url) => ClockProgressIndicator(size: size),
      errorWidget: (context, url, error) => const Icon(Icons.error),
      imageBuilder: (context, imageProvider) => ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image(
          image: imageProvider,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
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
        Text(schema.displayName.isEmpty ? schema.username : schema.displayName),
        Text('@${schema.acct}', style: const TextStyle(color: Colors.grey), overflow: TextOverflow.ellipsis),
      ],
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
