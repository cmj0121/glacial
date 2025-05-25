// The Status widget to show the toots from user.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/glacial/models/server.dart';
import 'package:glacial/features/timeline/models/core.dart';
import 'package:glacial/features/timeline/screens/core.dart';

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
            onTap: () => context.push(RoutePath.userProfile.path, extra: schema),
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
    final Storage storage = Storage();
    final String text = schema.displayName.isEmpty ? schema.username : schema.displayName;

    return storage.replaceEmojiToWidget(text, emojis: schema.emojis);
  }
}

// The account profile to show the details of the user.
class AccountProfile extends ConsumerWidget {
  final AccountSchema schema;
  final double bannerHeight;
  final double avatarSize;

  const AccountProfile({
    super.key,
    required this.schema,
    this.bannerHeight = 200,
    this.avatarSize = 80,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          buildBanner(context),
          const SizedBox(height: 16),
          buildContent(context, ref),
        ],
      ),
    );
  }

  Widget buildContent(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        buildName(context, ref),
        HtmlDone(
          html: schema.note,
          emojis: schema.emojis,
        ),
        const Divider(),
        TimelineBuilder(type: TimelineType.user, account: schema),
      ],
    );
  }

  // Show the user name and the account name.
  Widget buildName(BuildContext context, WidgetRef ref) {
    final ServerSchema? server = ref.watch(currentServerProvider);

    final String acct = schema.acct.contains('@') ? schema.acct : '${schema.username}@${server?.domain ?? '-'}';

    return Row(
      children: [
        // The location of the user and show as the badge.
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(acct),
        ),
      ],
    );
  }

  // Build the fixed banner of the account profile and the avatar.
  // It will be fixed in the top of the screen.
  Widget buildBanner(BuildContext context) {
    return SizedBox(
      height: bannerHeight,
      child: buildBannerContent(context),
    );
  }

  // Build the banner of the account profile, including the header, the
  // avatar and the metadata.
  Widget buildBannerContent(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        buildHeader(context),
        Positioned(
          left: 0,
          bottom: 0,
          width: avatarSize,
          height: avatarSize,
          child: buildAvatar(context),
        ),
      ],
    );
  }

  // Build the header of the account profile, as the part of the banner.
  Widget buildHeader(BuildContext context) {
    final Widget banner = CachedNetworkImage(
      imageUrl: schema.header,
      placeholder: (context, url) => const CircularProgressIndicator(),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: OverflowBox(
        alignment: Alignment.center,
        maxWidth: double.infinity,
        maxHeight: double.infinity,
        child: MediaHero(child: banner),
      ),
    );
  }

  // Build the Avatar of the user.
  Widget buildAvatar(BuildContext context) {
    final Widget avatar = CachedNetworkImage(
      imageUrl: schema.avatar,
      placeholder: (context, url) => const CircularProgressIndicator(),
      errorWidget: (context, url, error) => const Icon(Icons.error),
      fit: BoxFit.cover,
    );

    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 2),
        color: Theme.of(context).colorScheme.surface,
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: MediaHero(child: avatar),
      ),
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
