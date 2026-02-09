// The Account profile widget to show the details of the user.
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

// The account profile to show the details of the user.
class AccountProfile extends ConsumerStatefulWidget {
  final AccountSchema schema;

  const AccountProfile({
    super.key,
    required this.schema,
  });

  @override
  ConsumerState<AccountProfile> createState() => _AccountProfileState();
}

class _AccountProfileState extends ConsumerState<AccountProfile> with SingleTickerProviderStateMixin {
  late final AccessStatusSchema? status = ref.read(accessStatusProvider);
  late final List<AccountProfileType> types;
  late final TabController controller;

  @override
  void initState() {
    super.initState();

    types = AccountProfileType.values.where((type) => type.selfProfile || isSelfProfile).toList();
    controller = TabController(length: types.length, vsync: this);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (status?.server == null) {
      logger.w("No server selected, but it's required to show the account profile.");
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 16),
      child: buildContent(context, status!.server!),
    );
  }

  Widget buildContent(BuildContext context, ServerSchema server) {
    return SwipeTabView(
      tabController: controller,
      itemCount: types.length,
      tabBuilder: (context, index) {
        final AccountProfileType type = types[index];
        final bool isSelected = controller.index == index;
        final Color color = isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface;

        return Tooltip(
          message: type.tooltip(context),
          child: Icon(type.icon(active: isSelected), color: color, size: tabSize),
        );
      },
      itemBuilder: (context, index) {
        final AccountProfileType type = types[index];

        switch (type) {
          case AccountProfileType.profile:
            return ProfilePage(
              schema: widget.schema,
              onStatusesTap: () => controller.animateTo(AccountProfileType.post.index),
              onFollowersTap: () => controller.animateTo(AccountProfileType.followers.index),
              onFollowingTap: () => controller.animateTo(AccountProfileType.following.index),
            );
          case AccountProfileType.followers:
            return AccountList(
              loader: ({String? maxId}) =>
                status?.fetchFollowers(account: widget.schema, maxId: maxId) ?? Future.value((<AccountSchema>[], null)),
              onDismiss: isSelfProfile
                ? (account) async => status?.removeFromFollowers(accountId: account.id)
                : null,
            );
          case AccountProfileType.following:
            return AccountList(loader: ({String? maxId}) =>
              status?.fetchFollowing(account: widget.schema, maxId: maxId) ?? Future.value((<AccountSchema>[], null))
            );
          case AccountProfileType.post:
          case AccountProfileType.pin:
          case AccountProfileType.schedule:
            return Timeline(status: status!, type: type.timelineType, account: widget.schema);
          case AccountProfileType.hashtag:
            return const FollowedHashtags();
          case AccountProfileType.filter:
            return Filters(key: UniqueKey());
          case AccountProfileType.mute:
            return AccountList(
              loader: status?.fetchMutedAccounts,
              onDismiss: isSelfProfile
                  ? (account) async => status?.changeRelationship(account: account, type: RelationshipType.unmute)
                  : null,
            );
          case AccountProfileType.block:
            return AccountList(
              loader: status?.fetchBlockedAccounts,
              onDismiss: isSelfProfile
                  ? (account) async => status?.changeRelationship(account: account, type: RelationshipType.unblock)
                  : null,
            );
        }
      }
    );
  }

  bool get isSelfProfile => widget.schema.id == status?.account?.id;
}

// The user profile page to show the details of the user.
class ProfilePage extends ConsumerWidget {
  final AccountSchema schema;
  final double bannerHeight;
  final double avatarSize;
  final VoidCallback? onStatusesTap;
  final VoidCallback? onFollowersTap;
  final VoidCallback? onFollowingTap;

  const ProfilePage({
    super.key,
    required this.schema,
    this.bannerHeight = 200,
    this.avatarSize = 80,
    this.onStatusesTap,
    this.onFollowersTap,
    this.onFollowingTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AccessStatusSchema? status = ref.read(accessStatusProvider);

    if (status == null || status.domain == null) {
      logger.w("No server selected, but it's required to show the profile page.");
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildBanner(context),
          const SizedBox(height: 16),
          buildAccountName(context, status),
          if (schema.id != status.account?.id) FamiliarFollowers(schema: schema),
          FeaturedTags(schema: schema),
          UserStatistics(
            schema: schema,
            onStatusesTap: onStatusesTap,
            onFollowersTap: onFollowersTap,
            onFollowingTap: onFollowingTap,
          ),
          const Divider(thickness: 4),
          buildAccountInfo(context, status),
        ],
      ),
    );
  }

  // Build the fixed banner of the account profile and the avatar. It will be fixed in the top
  // of the screen.
  Widget buildBanner(BuildContext context) {
    final Widget banner = CachedNetworkImage(
      imageUrl: schema.header,
      placeholder: (context, url) => const ClockProgressIndicator(),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );

    return SizedBox(
      height: bannerHeight,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: OverflowBox(
              alignment: Alignment.center,
              maxWidth: double.infinity,
              maxHeight: double.infinity,
              child: MediaHero(child: banner),
            ),
          ),
          Positioned(
            left: 0,
            bottom: 0,
            width: avatarSize,
            height: avatarSize,
            child: buildAvatar(context),
          ),
        ],
      ),
    );
  }

  // Build the Avatar of the user.
  Widget buildAvatar(BuildContext context) {
    final Widget avatar = CachedNetworkImage(
      imageUrl: schema.avatar,
      placeholder: (context, url) => const ClockProgressIndicator(),
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

  // Build the account information section that shows the username, display name, and bio.
  Widget buildAccountInfo(BuildContext context, AccessStatusSchema status) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HtmlDone(html: schema.note),
        ...schema.fields.asMap().entries.map((e) => buildField(context, e.value, e.key)),
      ],
    );
  }

  Widget buildField(BuildContext context, FieldSchema field, int index) {
    final TextStyle? labelStyle = Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).disabledColor);

    return ListTile(
      leading: Icon(FieldSchema.icons[index % FieldSchema.icons.length], size: iconSize),
      title: HtmlDone(html: field.value),
      subtitle: Text(field.name, style: labelStyle),
    );
  }

  // Build the account name and relationship buttons.
  Widget buildAccountName(BuildContext context, AccessStatusSchema status) {
    final String acct = schema.acct.contains('@') ? schema.acct : '${schema.acct}@${status.domain}';
    final Widget botIcon = Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Tooltip(
        message: AppLocalizations.of(context)?.desc_profile_bot ?? "This account is a bot",
        child: Icon(Icons.smart_toy_outlined, color: Theme.of(context).colorScheme.secondary),
      ),
    );

    return Row(
      children: [
        schema.id == status.account?.id ? EditProfilePage.icon() : Relationship(schema: schema),
        schema.id == status.account?.id ? FollowRequestBadge() : const SizedBox.shrink(),

        const SizedBox(width: 8),

        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Tooltip(
              message: acct,
              child: Text(
                acct,
                style: Theme.of(context).textTheme.labelLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        schema.bot ? botIcon : const SizedBox.shrink(),
      ],
    );
  }
}

// The simple user statistics widget to show the user statistics such as followers, following, and statuses.
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
