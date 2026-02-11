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
  late final AccessStatusSchema? status = ref.read(accessStatusProvider);

  int? selectedOption;

  late List<bool> selectedOptions = widget.schema?.options.map((_) => false).toList() ?? [];

  @override
  Widget build(BuildContext context) {
    if (widget.schema == null) {
      return const SizedBox.shrink();
    }

    return AdaptiveGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...(canVote ? buildOptions(widget.schema!) : buildVoteResult(widget.schema!)),
          buildActions(widget.schema!),
        ],
      ),
    );
  }

  // The list of the options in the poll.
  List<Widget> buildOptions(PollSchema schema) {
    switch (schema.multiple) {
      case true:
        return schema.options.asMap().entries.map((entry) {
          final int index = entry.key;
          final PollOptionSchema option = entry.value;

          return CheckboxListTile(
            title: Text(option.title),
            value: selectedOptions[index],
            visualDensity: VisualDensity.compact,
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (bool? value) {
              setState(() => selectedOptions[index] = value ?? false);
            },
          );
        }).toList();
      case false:
        return [
          RadioGroup(
            groupValue: selectedOption,
            onChanged: (int? value) {
              setState(() => selectedOption = value);
            },
            child: Column(
              children: schema.options.asMap().entries.map((entry) {
                return RadioListTile(
                  title: Text(entry.value.title),
                  value: entry.key,
                );
              }).toList(),
            ),
          ),
        ];
    }
  }

  // Build the final Vote results.
  List<Widget> buildVoteResult(PollSchema schema) {
    final int totalCount = schema.options.fold(0, (sum, o) => sum + (o.votesCount ?? 0));

    return schema.options.asMap().entries.map((entry) {
      final int index = entry.key;
      final PollOptionSchema option = entry.value;

      // If the poll is already voted, display the selected options.
      final int count = option.votesCount ?? 0;
      final bool isSelected = schema.ownVotes?.contains(index) ?? false;

      // show the bottom line as the ratio of votes
      return LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth * (totalCount > 0 ? count / totalCount : 0);

          return Stack(
            alignment: Alignment.bottomLeft,
            children: [
              ListTile(
                leading: Text('+$count', style: Theme.of(context).textTheme.bodySmall),
                title: Text( option.title),
                trailing: isSelected ? const Icon(Icons.check) : null,
              ),
              Container(
                height: 4,
                width: width == 0 ? 12 : width,
                decoration: BoxDecoration(
                  color: width > 0 ? Theme.of(context).colorScheme.primary : Theme.of(context).disabledColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ]
          );
        },
      );
    }).toList();
  }

  // The possible actions and metadata of the poll.
  Widget buildActions(PollSchema schema) {
    final bool showVoteBtn = canVote && choices.isNotEmpty;
    final Duration expiresIn = schema.expiresAt?.difference(DateTime.now()) ?? Duration.zero;
    final String remainingTime = timeago.format(DateTime.now().subtract(expiresIn), locale: timeagoLocale(context));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (showVoteBtn) TextButton(
          onPressed: onVote,
          child: Text(AppLocalizations.of(context)?.btn_timeline_vote ?? "Vote"),
        ),
        const Spacer(),

        Builder(builder: (context) {
          final int voteCount = schema.votersCount ?? schema.votesCount;
          final String votesText = AppLocalizations.of(context)?.txt_poll_votes(voteCount) ?? "$voteCount votes";
          return isClosed
            ? Text(votesText, style: TextStyle(color: Theme.of(context).disabledColor))
            : Text("$votesText / ~$remainingTime");
        }),
      ],
    );
  }

  // Submits the selected options to the server.
  Future<void> onVote() async {
    final PollSchema? poll = await status?.votePoll(pollID: widget.schema!.id, choices: choices);
    if (mounted && poll != null) widget.onChanged?.call(poll);
  }

  bool get isClosed => widget.schema?.expiresAt?.isAfter(DateTime.now()) == false;
  bool get canVote => widget.schema?.voted == false && !isClosed;
  List<int> get choices => [
    ...selectedOptions.asMap().entries.where((entry) => entry.value).map((entry) => entry.key),
    if (selectedOption != null) selectedOption!,
  ];
}

// vim: set ts=2 sw=2 sts=2 et:
