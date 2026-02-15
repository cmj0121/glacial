// The user profile page to show the details of the user.
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

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
      placeholder: (context, url) => ShimmerEffect(child: ColoredBox(color: Theme.of(context).colorScheme.surfaceContainerHighest)),
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
      placeholder: (context, url) => ShimmerEffect(child: ColoredBox(color: Theme.of(context).colorScheme.surfaceContainerHighest)),
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

// vim: set ts=2 sw=2 sts=2 et:
