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
    this.bannerHeight = 180,
    this.avatarSize = 72,
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

    final bool isSelf = schema.id == status.account?.id;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBannerZone(context, status, isSelf),
              const SizedBox(height: 16),
              _buildStatsRow(context),
              if (!isSelf) ...[
                FamiliarFollowers(schema: schema),
                FeaturedTags(schema: schema),
              ],
              _buildBio(context),
              _buildFields(context),
            ],
          ),
        ),
      ),
    );
  }

  // Banner with avatar overlapping bottom-left, display name + acct
  // overlay at the bottom, and edit/relationship button top-right.
  Widget _buildBannerZone(BuildContext context, AccessStatusSchema status, bool isSelf) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final String acct = schema.acct.contains('@') ? schema.acct : '${schema.acct}@${status.domain}';

    return SizedBox(
      height: bannerHeight + avatarSize / 2,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Banner image
          Positioned.fill(
            bottom: avatarSize / 2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: schema.header,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => ShimmerEffect(
                      child: ColoredBox(color: scheme.surfaceContainerHighest),
                    ),
                    errorWidget: (_, _, _) => const ImageErrorPlaceholder(),
                  ),
                  // Gradient scrim for text legibility
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 80,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
                        ),
                      ),
                    ),
                  ),
                  // Name + acct on the banner
                  Positioned(
                    left: avatarSize + 12,
                    right: 12,
                    bottom: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          schema.displayName.isNotEmpty ? schema.displayName : schema.acct,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '@$acct',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Avatar
          Positioned(
            left: 12,
            bottom: 0,
            child: Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                border: Border.all(color: scheme.surface, width: 3),
                shape: BoxShape.circle,
                color: scheme.surface,
              ),
              child: ClipOval(
                child: Semantics(
                  label: schema.displayName.isNotEmpty ? schema.displayName : schema.acct,
                  child: CachedNetworkImage(
                    imageUrl: schema.avatar,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => ShimmerEffect(
                      child: ColoredBox(color: scheme.surfaceContainerHighest),
                    ),
                    errorWidget: (_, _, _) => const ImageErrorPlaceholder(),
                  ),
                ),
              ),
            ),
          ),
          // Action button (edit + follow-request badge for self, relationship for others)
          Positioned(
            right: 12,
            bottom: avatarSize / 2 + 8,
            child: isSelf
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FollowRequestBadge(),
                      const SizedBox(width: 8),
                      EditProfilePage.icon(),
                    ],
                  )
                : Relationship(schema: schema),
          ),
          // Bot badge
          if (schema.bot)
            Positioned(
              left: avatarSize + 12,
              bottom: avatarSize / 2 + 8,
              child: Tooltip(
                message: AppLocalizations.of(context)?.desc_profile_bot ?? 'Bot',
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: scheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.smart_toy_outlined, size: 14, color: scheme.onSecondaryContainer),
                      const SizedBox(width: 4),
                      Text('BOT', style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSecondaryContainer,
                        fontWeight: FontWeight.w700,
                      )),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _StatChip(
            icon: Icons.article_outlined,
            count: schema.statusesCount,
            label: AppLocalizations.of(context)?.btn_profile_post ?? 'Posts',
            onTap: onStatusesTap,
          ),
          const SizedBox(width: 20),
          _StatChip(
            icon: Icons.people_outline,
            count: schema.followersCount,
            label: AppLocalizations.of(context)?.btn_profile_followers ?? 'Followers',
            onTap: onFollowersTap,
          ),
          const SizedBox(width: 20),
          _StatChip(
            icon: Icons.person_add_alt,
            count: schema.followingCount,
            label: AppLocalizations.of(context)?.btn_profile_following ?? 'Following',
            onTap: onFollowingTap,
          ),
          const Spacer(),
          if (schema.locked)
            Tooltip(
              message: AppLocalizations.of(context)?.desc_profile_locked ?? 'Locked',
              child: Icon(Icons.lock_person, size: 18, color: scheme.onSurfaceVariant),
            ),
          if (schema.discoverable ?? false) ...[
            const SizedBox(width: 8),
            Tooltip(
              message: AppLocalizations.of(context)?.desc_profile_discoverable ?? 'Discoverable',
              child: Icon(Icons.travel_explore, size: 18, color: scheme.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBio(BuildContext context) {
    if (schema.note.isEmpty || schema.note == '<p></p>') return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: HtmlDone(html: schema.note),
    );
  }

  Widget _buildFields(BuildContext context) {
    if (schema.fields.isEmpty) return const SizedBox.shrink();

    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(height: 1, color: scheme.outlineVariant.withValues(alpha: 0.3)),
        ...schema.fields.map((field) => Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.3)),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      field.name.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                    if (field.verifiedAt != null) ...[
                      const SizedBox(width: 6),
                      Icon(Icons.verified, size: 14, color: scheme.tertiary),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                HtmlDone(html: field.value),
              ],
            ),
          ),
        )),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final int count;
  final String label;
  final VoidCallback? onTap;

  const _StatChip({
    required this.icon,
    required this.count,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _formatCount(count),
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 10000) return '${(n / 1000).toStringAsFixed(0)}K';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}

// vim: set ts=2 sw=2 sts=2 et:
