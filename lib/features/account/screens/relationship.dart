// The Status widget to show the toots from user.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/core.dart';

// The relationship action enum, used for the relationship actions.
enum RelationshipAction {
  mute,
  block,
  report;
}

class RelationshipBuilder extends ConsumerWidget {
  final AccountSchema schema;

  const RelationshipBuilder({
    super.key,
    required this.schema,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ServerSchema? server = ref.watch(currentServerProvider);
    final AccountSchema? account = ref.watch(currentUserProvider);
    final String? accessToken = ref.watch(currentAccessTokenProvider);

    if (server == null || account == null || accessToken == null) {
      logger.w("No server, account or access token available for relationship builder.");
      return const SizedBox.shrink();
    }

    return Relationship.builder(
      currentUser: account,
      user: schema,
      server: server,
      accessToken: accessToken,
    );
  }
}

// The relationship between accounts, such as following / blocking / muting / etc
class Relationship extends ConsumerStatefulWidget {
  final AccountSchema schema;
  final RelationshipSchema relationship;

  const Relationship({
    super.key,
    required this.schema,
    required this.relationship,
  });

  @override
  ConsumerState<Relationship> createState() => _RelationshipState();

  static builder({
    required AccountSchema currentUser,
    required AccountSchema user,
    required ServerSchema server,
    required String accessToken,
  }) {
    return FutureBuilder(
      future: currentUser.relationship(domain: server.domain, accessToken: accessToken, ids: [user.id]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        } else if (snapshot.hasError) {
          final String text = AppLocalizations.of(context)?.txt_invalid_instance ?? 'Invalid instance: ${server.domain}';
          return Text(text, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.red));
        }

        final List<RelationshipSchema> relationship = snapshot.data as List<RelationshipSchema>;
        final RelationshipSchema? rel = relationship.isNotEmpty ? relationship.first : null;

        if (rel == null) {
          return const SizedBox.shrink();
        }

        return Relationship(schema: user, relationship: rel);
      },
    );
  }
}

class _RelationshipState extends ConsumerState<Relationship> {
  late RelationshipSchema relationship;

  @override
  void initState() {
    super.initState();
    relationship = widget.relationship;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        buildMoreActions(),
        const SizedBox(width: 8),
        buildContent(relationship),
      ],
    );
  }

  // Build the releationship content based on the relationship schema.
  Widget buildContent(RelationshipSchema relationship) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(animation),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: buildFollowButton(),
    );
  }

  // Show the follow button based on the relationship schema.
  Widget buildFollowButton() {
    final bool canFollow = !relationship.blocking;
    late final Widget icon;
    late final String text;

    if (relationship.following && relationship.followedBy) {
      icon = const Icon(Icons.handshake_sharp);
      text = AppLocalizations.of(context)?.btn_follow_mutual ?? "Mutual";
    } else if (relationship.following) {
      icon = const Icon(Icons.star_border);
      text = AppLocalizations.of(context)?.btn_following ?? "Following";
    } else if (relationship.followedBy) {
      icon = const Icon(Icons.visibility);
      text = AppLocalizations.of(context)?.btn_followed_by ?? "Followed by";
    } else {
      icon = const Icon(Icons.person_add);
      text = AppLocalizations.of(context)?.btn_follow ?? "Follow";
    }

    return IconButton(
      key: Key('follow_button_${relationship.id}_$text'),
      icon: icon,
      tooltip: text,
      onPressed: canFollow ? onFollowToggle : null,
      style: IconButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // Build more actions for the relationship, such as mute, block, report, etc.
  Widget buildMoreActions() {
    return PopupMenuButton<RelationshipAction>(
      icon: const Icon(Icons.more_horiz),
      tooltip: '',
      itemBuilder: (BuildContext context) {
        return RelationshipAction.values.map((RelationshipAction action) {
          late final String text;
          late final IconData icon;
          late final Color color;

          switch (action) {
            case RelationshipAction.mute:
              color = relationship.muting ? Colors.grey : Theme.of(context).colorScheme.error;
              icon = relationship.muting ? Icons.volume_up : Icons.volume_off;
              text = relationship.muting ?
                  (AppLocalizations.of(context)?.btn_unmute ?? "Unmute") :
                  (AppLocalizations.of(context)?.btn_mute ?? "Mute");
              break;
            case RelationshipAction.block:
              color = relationship.blocking ? Colors.grey : Theme.of(context).colorScheme.error;
              icon = relationship.blocking ? Icons.task_alt : Icons.block;
              text = relationship.blocking ?
                  (AppLocalizations.of(context)?.btn_unblock ?? "Unblock") :
                  (AppLocalizations.of(context)?.btn_block ?? "Block");
              break;
            case RelationshipAction.report:
              color = Theme.of(context).colorScheme.error;
              icon = Icons.flag;
              text = AppLocalizations.of(context)?.btn_report ?? "Report";
              break;
          }

          return PopupMenuItem<RelationshipAction>(
            value: action,
            child: Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 4),
                Text(text, style: TextStyle(color: color)),
              ],
            ),
          );
        }).toList();
      },
      onSelected: (RelationshipAction action) {
        switch (action) {
          case RelationshipAction.mute:
            onMuteToggle();
            break;
          case RelationshipAction.block:
            onBlockToggle();
            break;
          case RelationshipAction.report:
            final String text = "not support yet, please report the user manually.";
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(text),
              ),
            );
        }
      },
    );
  }

  // Change the following status of the relationship.
  void onFollowToggle() async {
    final ServerSchema? server = ref.read(currentServerProvider);
    final String? accessToken = ref.read(currentAccessTokenProvider);
    late final RelationshipSchema newRel;

    if (server == null || accessToken == null) {
      logger.w("No server or access token available for follow toggle.");
      return;
    }

    logger.i("accessToken: $accessToken, target: ${widget.schema.id} me: ${ref.read(currentUserProvider)?.id}");
    switch (relationship.following) {
      case true:
        newRel = await widget.schema.unfollow(domain: server.domain, accessToken: accessToken);
        break;
      case false:
        newRel = await widget.schema.follow(domain: server.domain, accessToken: accessToken);
        break;
    }

    setState(() => relationship = newRel);
  }

  // Change the blocking status of the relationship.
  void onBlockToggle() async {
    final ServerSchema? server = ref.read(currentServerProvider);
    final String? accessToken = ref.read(currentAccessTokenProvider);
    late final RelationshipSchema newRel;

    if (server == null || accessToken == null) {
      logger.w("No server or access token available for block toggle.");
      return;
    }

    switch (relationship.blocking) {
      case true:
        newRel = await widget.schema.unblock(domain: server.domain, accessToken: accessToken);
        break;
      case false:
        newRel = await widget.schema.block(domain: server.domain, accessToken: accessToken);
        break;
    }

    setState(() => relationship = newRel);
  }

  // Change the muting status of the relationship.
  void onMuteToggle() async {
    final ServerSchema? server = ref.read(currentServerProvider);
    final String? accessToken = ref.read(currentAccessTokenProvider);
    late final RelationshipSchema newRel;

    if (server == null || accessToken == null) {
      logger.w("No server or access token available for mute toggle.");
      return;
    }

    switch (relationship.muting) {
      case true:
        newRel = await widget.schema.unmute(domain: server.domain, accessToken: accessToken);
        break;
      case false:
        newRel = await widget.schema.mute(domain: server.domain, accessToken: accessToken);
        break;
    }

    setState(() => relationship = newRel);
  }
}

// vim: set ts=2 sw=2 sts=2 et:
