// The Poll widget to display a poll with options and a submit button.
import 'package:flutter/material.dart';

import 'package:glacial/features/models.dart';
import 'package:timeago/timeago.dart' as timeago;

class Poll extends StatefulWidget {
  final PollSchema? schema;

  const Poll({
    super.key,
    this.schema,
  });

  @override
  State<Poll> createState() => _PollState();
}

class _PollState extends State<Poll> {
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
  void onVote() {
  }
}

// vim: set ts=2 sw=2 sts=2 et:
