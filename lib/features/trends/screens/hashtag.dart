// The Trends link that have been shared more than others.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

// The trends of the links that have been shared more than others.
class Hashtag extends ConsumerWidget {
  final HashtagSchema schema;

  const Hashtag({
    super.key,
    required this.schema,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? accessToken = ref.read(accessTokenProvider);

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        child: InkWellDone(
          onTap: accessToken == null ? null : () => context.push(RoutePath.hashtag.path, extra: schema),
          child: buildContent(context),
        ),
      ),
    );
  }

  Widget buildContent(BuildContext context) {
    return Row(
    children: [
        Expanded(child: buildHashtag(context)),
        const Spacer(),
        HistoryLineChart(schemas: schema.history),
      ],
    );
  }

  Widget buildHashtag(BuildContext context) {
    final int uses = schema.history.map((s) => int.parse(s.uses)).reduce((a, b) => a + b);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '#${schema.name}',
          style: Theme.of(context).textTheme.labelMedium,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Text(
          AppLocalizations.of(context)?.txt_trends_uses(uses) ?? '$uses used in the past days',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ]
    );
  }
}

// The followed hashtag button that can be used to follow or unfollow the hashtag.
class FollowedHashtagButton extends ConsumerStatefulWidget {
  final HashtagSchema schema;

  const FollowedHashtagButton({
    super.key,
    required this.schema,
  });

  @override
  ConsumerState<FollowedHashtagButton> createState() => _FollowedHashtagButtonState();
}

class _FollowedHashtagButtonState extends ConsumerState<FollowedHashtagButton> {
  late bool isFollowing = widget.schema.following == true;

  @override
  Widget build(BuildContext context) {
    final ServerSchema? server = ref.read(serverProvider);
    final String? accessToken = ref.read(accessTokenProvider);

    return IconButton(
      icon: Icon(
        isFollowing ? Icons.bookmark : Icons.bookmark_border,
        color: isFollowing ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
      ),
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      onPressed: () async {
        isFollowing ?
          await server?.unfollowHashtag(widget.schema.name, accessToken: accessToken) :
          await server?.followHashtag(widget.schema.name, accessToken: accessToken);

        setState(() => isFollowing = !isFollowing);
      },
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
