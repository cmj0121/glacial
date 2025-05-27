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

        const Spacer(),
        Relationship(schema: schema),
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

// The relationship between accounts, such as following / blocking / muting / etc
class Relationship extends ConsumerStatefulWidget {
  final AccountSchema schema;
  final RelationshipSchema? relationship;

  const Relationship({
    super.key,
    required this.schema,
    this.relationship,
  });

  @override
  ConsumerState<Relationship> createState() => _RelationshipState();
}

class _RelationshipState extends ConsumerState<Relationship> {
  late RelationshipSchema? relationship;

  @override
  void initState() {
    super.initState();
    relationship = widget.relationship;
  }

  @override
  Widget build(BuildContext context) {
    final AccountSchema? currentUser = ref.watch(currentUserProvider);

    if (widget.schema.id == currentUser?.id) {
      // No relationship with self
      return const SizedBox.shrink();
    }


    if (relationship != null) {
      // If the relationship is already provided, build the content directly
      return buildContent(relationship!);
    }

    return buildContentBuilder(currentUser);
  }

  Widget buildContentBuilder(AccountSchema? currentUser) {
    final ServerSchema? server = ref.watch(currentServerProvider);
    final String? accessToken = ref.watch(currentAccessTokenProvider);

    if (currentUser == null || server == null || accessToken == null) {
      logger.w("No server or access token available for relationship.");
      return const SizedBox.shrink();
    }

    return FutureBuilder(
      future: currentUser.relationship(domain: server.domain, accessToken: accessToken, ids: [widget.schema.id]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final List<RelationshipSchema> relationships = snapshot.data!;
        final RelationshipSchema? rel = relationships.isNotEmpty ? relationships.first : null;

        if (rel == null) {
          return const SizedBox.shrink();
        }

        return buildContent(rel);
      },
    );
  }

  Widget buildContent(RelationshipSchema rel) {
    late final String text;

    if (rel.following && rel.followedBy) {
      text = AppLocalizations.of(context)?.btn_follow_mutual ?? "Mutual";
    } else if (rel.following) {
      text = AppLocalizations.of(context)?.btn_following ?? "Following";
    } else if (rel.followedBy) {
      text = AppLocalizations.of(context)?.btn_followed_by ?? "Followed by";
    } else {
      text = AppLocalizations.of(context)?.btn_follow ?? "Follow";
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildMoreActions(rel),
        const SizedBox(width: 8),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () => onFollowToggle(rel),
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white)),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget buildMoreActions(RelationshipSchema rel) {
    return PopupMenuButton(
      icon: Icon(Icons.more_horiz, color: Theme.of(context).colorScheme.onSurface),
      tooltip: '', // for disabling the tooltip
      itemBuilder: (context) {
        final List<Widget> items = [
          TextButton.icon(
            icon: Icon(rel.muting ? Icons.volume_up_outlined : Icons.volume_off),
            label: Text('Mute'),
            onPressed: null,
          ),
          TextButton.icon(
            icon: Icon(rel.blocking ? Icons.lock_open : Icons.block_outlined),
            label: Text('Block'),
            onPressed: null,
          ),
          TextButton.icon(
            icon: Icon(Icons.flag, color: Theme.of(context).colorScheme.error),
            label: Text('Report'),
            onPressed: null,
          ),
        ];

        return items.map((item) {
          return PopupMenuItem(
            child: item,
          );
        }).toList();
      },
    );
  }

  void onFollowToggle(RelationshipSchema rel) async {
    final ServerSchema? server = ref.read(currentServerProvider);
    final String? accessToken = ref.read(currentAccessTokenProvider);
    late final RelationshipSchema newRel;

    if (server == null || accessToken == null) {
      logger.w("No server or access token available for follow toggle.");
      return;
    }

    switch (rel.following) {
      case true:
        newRel = await widget.schema.unfollow(domain: server.domain, accessToken: accessToken);
        break;
      case false:
        newRel = await widget.schema.follow(domain: server.domain, accessToken: accessToken);
        break;
    }

    setState(() => relationship = newRel);
  }
}

// vim: set ts=2 sw=2 sts=2 et:
