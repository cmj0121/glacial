// The Account profile widget to show the details of the user.import 'package:flutter/material.dart';
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
            );
          case AccountProfileType.post:
          case AccountProfileType.pin:
          case AccountProfileType.schedule:
            return Timeline(
              status: status!,
              type: type.timelineType,
              account: widget.schema,
            );
          case AccountProfileType.hashtag:
            return const FollowedHashtags();
          case AccountProfileType.mute:
            return AccountList(loader: status?.fetchMutedAccounts);
          case AccountProfileType.block:
            return AccountList(loader: status?.fetchBlockedAccounts);
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

  const ProfilePage({
    super.key,
    required this.schema,
    this.bannerHeight = 200,
    this.avatarSize = 80,
    this.onStatusesTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AccessStatusSchema? status = ref.watch(accessStatusProvider);

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
          buildAccountInfo(context, status),
          const Divider(thickness: 4),
          UserStatistics(
            schema: schema,
            onStatusesTap: onStatusesTap,
          ),
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
        buildAccountName(context, status),
        const SizedBox(height: 4),
        HtmlDone(html: schema.note),
      ],
    );
  }

  // Build the account name and relationship buttons.
  Widget buildAccountName(BuildContext context, AccessStatusSchema status) {
    final String acct = schema.acct.contains('@') ? schema.acct : '${schema.acct}@${status.domain}';

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(acct, style: Theme.of(context).textTheme.labelSmall),
        ),

        const Spacer(),
        schema.id == status.account?.id ? const SizedBox.shrink() : Relationship(schema: schema),
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
    final int statuses = schema.statusesCount;
    final int followers = schema.followersCount;
    final int following = schema.followingCount;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
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
      ],
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
