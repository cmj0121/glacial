// The Account widget to show the account information.
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
    return InkWellDone(
      onTap: () => context.push(RoutePath.profile.path, extra: schema),
      child: buildContent(context),
    );
  }

  Widget buildContent(BuildContext context) {
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
      placeholder: (context, url) => SizedBox(
        width: size,
        height: size,
        child: ClockProgressIndicator(size: size),
      ),
      errorWidget: (context, url, error) => const Icon(Icons.error),
      imageBuilder: (context, imageProvider) {
        final Widget image = Image(
          image: imageProvider,
          width: size,
          height: size,
          fit: BoxFit.cover,
        );

        return ClipRRect(borderRadius: BorderRadius.circular(8), child: image);
      }
    );
  }

  // Build the display name and the account name of the user.
  Widget buildName() {
    final Widget name = EmojiSchema.replaceEmojiToWidget(
      schema.displayName.isEmpty ? schema.username : schema.displayName,
      emojis: schema.emojis,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        name,
        Text('@${schema.acct}', style: const TextStyle(color: Colors.grey), overflow: TextOverflow.ellipsis),
      ],
    );
  }
}

// The Avatar only widget to show the avatar of the account.
class AccountAvatar extends StatelessWidget {
  final AccountSchema schema;
  final double size;

  const AccountAvatar({
    super.key,
    required this.schema,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return InkWellDone(
      onTap: () => context.push(RoutePath.profile.path, extra: schema),
      child: Tooltip(
        message: schema.acct,
        child: buildContent(),
      ),
    );
  }

  Widget buildContent() {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: schema.avatar,
        placeholder: (context, url) => SizedBox(
          width: size,
          height: size,
          child: ClockProgressIndicator(size: size),
        ),
        errorWidget: (context, url, error) => const Icon(Icons.error),
        imageBuilder: (context, imageProvider) => Image(
          image: imageProvider,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

// The light account widget to show the avatar and the account name only.
class AccountLite extends StatelessWidget {
  final AccountSchema? schema;
  final double size;

  const AccountLite({
    super.key,
    this.schema,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    if (schema == null) {
      return const SizedBox.shrink();
    }

    final String name = schema?.displayName ?? schema?.username ?? '-';
    return ListTile(
      leading: buildAvatar(),
      title: Text(name, overflow: TextOverflow.ellipsis),
      onTap: () => context.push(RoutePath.profile.path, extra: schema),
    );
  }

  Widget buildAvatar() {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: schema!.avatar,
        placeholder: (context, url) => SizedBox(
          width: size,
          height: size,
          child: ClockProgressIndicator(size: size),
        ),
        errorWidget: (context, url, error) => const Icon(Icons.error),
        imageBuilder: (context, imageProvider) => Image(
          image: imageProvider,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
