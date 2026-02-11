// The account profile to show the details of the user.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

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
          case AccountProfileType.domainBlock:
            return const DomainBlockList();
        }
      }
    );
  }

  bool get isSelfProfile => widget.schema.id == status?.account?.id;
}

// vim: set ts=2 sw=2 sts=2 et:
