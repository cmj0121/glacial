// The Trends link that have been shared more than others.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
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
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        child: buildContent(context),
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

// vim: set ts=2 sw=2 sts=2 et:
