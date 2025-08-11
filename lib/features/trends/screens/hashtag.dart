// The Trends link that have been shared more than others.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

// The trends of the links that have been shared more than others.
class Hashtag extends StatelessWidget {
  final HashtagSchema schema;

  const Hashtag({
    super.key,
    required this.schema,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        child: InkWellDone(
          onTap: () => context.push(RoutePath.hashtag.path, extra: schema.name),
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
          '$uses used in the past days',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ]
    );
  }
}

// The simple hashtag badge that can be used to show the hashtag in a simple way.
class TagLite extends StatelessWidget {
  final TagSchema schema;

  const TagLite({
    super.key,
    required this.schema,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: InkWellDone(
          onTap: () => context.push(RoutePath.hashtag.path, extra: schema.name),
          child: buildContent(context),
        ),
      ),
    );
  }

  Widget buildContent(BuildContext context) {
    return Text(
      '#${schema.name}',
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Theme.of(context).colorScheme.onSecondaryContainer,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}

// The followed hashtag button that can be used to follow or unfollow the hashtag.
class FollowedHashtagButton extends ConsumerStatefulWidget {
  final String hashtag;

  const FollowedHashtagButton({
    super.key,
    required this.hashtag,
  });

  @override
  ConsumerState<FollowedHashtagButton> createState() => _FollowedHashtagButtonState();
}

class _FollowedHashtagButtonState extends ConsumerState<FollowedHashtagButton> {
  HashtagSchema? schema;

  @override
  void initState() {
    super.initState();
    onReload();
  }

  @override
  Widget build(BuildContext context) {
    if (schema == null) {
      return const SizedBox.shrink();
    }

    final AccessStatusSchema? status = ref.watch(accessStatusProvider);
    final bool isFollowing = schema?.following == true;

    return IconButton(
      icon: Icon(
        isFollowing ? Icons.bookmark : Icons.bookmark_border,
        color: isFollowing ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
      ),
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      onPressed: () async {
        await (isFollowing ? status?.unfollowHashtag(widget.hashtag) : status?.followHashtag(widget.hashtag));
        onReload();
      },
    );
  }

  void onReload() async {
    final AccessStatusSchema? status = ref.read(accessStatusProvider);
    final HashtagSchema? hashtag = await status?.getHashtag(widget.hashtag);
    setState(() => schema = hashtag);
  }
}

// vim: set ts=2 sw=2 sts=2 et:
