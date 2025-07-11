// The Poll widget to display a poll with options and a submit button.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';

class Poll extends ConsumerStatefulWidget {
  final PollSchema? schema;
  final ValueChanged<PollSchema>? onChanged;

  const Poll({
    super.key,
    this.schema,
    this.onChanged,
  });

  @override
  ConsumerState<Poll> createState() => _PollState();
}

class _PollState extends ConsumerState<Poll> {
  int? selectedOption;
  late List<bool> selectedOptions = widget.schema?.options.map((_) => false).toList() ?? [];

  @override
  Widget build(BuildContext context) {
    if (widget.schema == null) {
      return const SizedBox.shrink();
    }

    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...buildOptions(widget.schema!),
            buildActions(widget.schema!),
          ],
        ),
      ),
    );
  }

  // The list of the options in the poll.
  List<Widget> buildOptions(PollSchema schema) {
    return schema.options.map((option) {
      final int index = schema.options.indexOf(option);

      switch (schema.multiple) {
        case true:
          return CheckboxListTile(
            title: Text(option.title),
            value: selectedOptions[index],
            visualDensity: VisualDensity.compact,
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (bool? value) {
              setState(() => selectedOptions[index] = value ?? false);
            },
          );
        case false:
          return RadioListTile(
            title: Text(option.title),
            value: index,
            visualDensity: VisualDensity.compact,
            groupValue: selectedOption,
            onChanged: (int? value) {
              setState(() => value == null ? selectedOption = null : selectedOption = value);
            },
          );
      }
    }).toList();
  }

  // The possible actions and metadata of the poll.
  Widget buildActions(PollSchema schema) {
    final bool canVote = selectedOption != null || selectedOptions.any((e) => e);
    final Duration expiresIn = schema.expiresAt?.difference(DateTime.now()) ?? Duration.zero;
    final String remainingTime = timeago.format(DateTime.now().subtract(expiresIn), locale: 'en_short');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: canVote ? onVote : null,
          child: const Text('Vote'),
        ),
        const Spacer(),

        Text("${schema.votersCount ?? schema.votesCount} votes, ~$remainingTime"),
      ],
    );
  }

  // Submits the selected options to the server.
  void onVote() async {
    final ServerSchema? server = ref.read(serverProvider);
    final String? accessToken = ref.read(accessTokenProvider);

    final List<int?> choices = [
      selectedOption,
      ...selectedOptions.asMap().entries.map((entry) => entry.value ? entry.key : null),
    ];
    final List<String> selectedChoices = choices.where((entry) => entry != null).map((entry) => entry.toString()).toList();

    if (server == null || accessToken == null || selectedChoices.isEmpty) {
      logger.w("Cannot vote: server or access token is null, or no choices selected.");
      return;
    }

    final PollSchema poll = await server.votePoll(schema: widget.schema!, accessToken: accessToken, choices: selectedChoices);
    widget.onChanged?.call(poll);
  }
}

// vim: set ts=2 sw=2 sts=2 et:
