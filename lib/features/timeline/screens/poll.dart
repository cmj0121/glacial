// The Poll widget to display a poll with options and a submit button.
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:glacial/core.dart';
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
      final int totalCount = schema.options.map((o) => o.votesCount ?? 0).reduce((a, b) => a + b);

      if (!canVote) {
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
      }

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
    final bool showVoteBtn = canVote && selectedOption != null || selectedOptions.any((e) => e);
    final Duration expiresIn = schema.expiresAt?.difference(DateTime.now()) ?? Duration.zero;
    final String remainingTime = timeago.format(DateTime.now().subtract(expiresIn), locale: 'en_short');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (showVoteBtn) TextButton(onPressed: canVote ? onVote : null, child: const Text('Vote')),
        const Spacer(),

        (isClosed) ?
          Text("${schema.votersCount ?? schema.votesCount} votes", style: TextStyle(color: Theme.of(context).disabledColor)) :
          Text("${schema.votersCount ?? schema.votesCount} votes / ~$remainingTime"),
      ],
    );
  }

  // Submits the selected options to the server.
  void onVote() async {
  }

  bool get isClosed => widget.schema?.expiresAt?.isAfter(DateTime.now()) == false;
  bool get canVote => widget.schema?.voted == false && !isClosed;
}

// The poll form for the status, which allows the user to create a poll with options.
class PollForm extends ConsumerStatefulWidget {
  final NewPollSchema? schema;
  final ValueChanged<NewPollSchema>? onChanged;

  const PollForm({
    super.key,
    this.schema,
    this.onChanged,
  });

  @override
  ConsumerState<PollForm> createState() => _PollFormState();
}

class _PollFormState extends ConsumerState<PollForm> {
  final List<Duration> durations = [
    const Duration(minutes: 5),
    const Duration(minutes: 30),
    const Duration(hours: 1),
    const Duration(hours: 6),
    const Duration(hours: 12),
    const Duration(days: 1),
    const Duration(days: 7),
  ];

  late final AccessStatusSchema? status = ref.read(accessStatusProvider);
  late final List<TextEditingController> controllers;
  late final int maxPollCount = status?.server?.config.polls.maxOptions ?? 4;

  @override
  void initState() {

    super.initState();

    controllers = List.generate(maxPollCount, (index) => TextEditingController());
  }

  @override
  void dispose() {
    controllers.map((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.schema == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: buildContent(widget.schema!),
    );
  }

  // Build the content of the poll form.
  Widget buildContent(NewPollSchema schema) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...buildOptions(schema),
        const SizedBox(height: 8),
        buildActions(schema),
      ],
    );
  }

  // Build the list of the options for the poll.
  List<Widget> buildOptions(NewPollSchema schema) {
    return List.generate(schema.options.length, (index) {
      final String option = schema.options[index];
      final IconData icon = option.isEmpty ? Icons.check_box_outline_blank : Icons.check_box;

      final TextEditingController controller = controllers[index];
      controller.text = option;

      return Focus(
        onFocusChange: (hasFocus) {
          if (!hasFocus) {
            onEditCompleted();
          }
        },
        child: TextField(
          controller: controller,
          maxLength: status?.server?.config.polls.maxCharacters ?? 100,
          decoration: InputDecoration(icon: Icon(icon), border: const OutlineInputBorder()),
          onSubmitted: (_) => onEditCompleted(),
        ),
      );
    });
  }

  // Build the actions for the poll form, such as toggling totals visibility and multiple choice.
  Widget buildActions(NewPollSchema schema) {
    final bool hideTotals = schema.hideTotals ?? false;
    final bool multiple = schema.multiple ?? false;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        buildExpiresDropdown(schema),
        const SizedBox(width: 8),
        Tooltip(
          message: AppLocalizations.of(context)?.desc_poll_show_hide_total,
          child: TextButton.icon(
            label: Text(
              (
                hideTotals ?
                  AppLocalizations.of(context)?.txt_poll_show_total :
                  AppLocalizations.of(context)?.txt_poll_hide_total
              ) ?? '',
            ),
            icon: Icon(hideTotals ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              // Toggle the visibility of the poll totals.
              final NewPollSchema poll = schema.copyWith(hideTotals: !hideTotals);
              widget.onChanged?.call(poll);
            },
          ),
        ),
        const SizedBox(width: 8),
        TextButton.icon(
          label: Text(
            (
              multiple ?
                AppLocalizations.of(context)?.txt_poll_multiple :
                AppLocalizations.of(context)?.txt_poll_single
            ) ?? '',
          ),
          icon: Icon(multiple ? Icons.checklist_outlined : Icons.check_outlined),
          onPressed: () {
            // Toggle the visibility of the poll totals.
            final NewPollSchema poll = schema.copyWith(multiple: !multiple);
            widget.onChanged?.call(poll);
          },
        ),
      ],
    );
  }

  // The expired dropdown to select the expiration time for the poll.
  Widget buildExpiresDropdown(NewPollSchema schema) {
    final Duration expiresIn = Duration(seconds: schema.expiresIn);
    final DateTime now = DateTime.now().toUtc();

    return DropdownButtonHideUnderline(
      child: DropdownButton(
        value: expiresIn,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        borderRadius: BorderRadius.circular(8),
        icon: const SizedBox.shrink(),
        items: durations.map((duration) {
          final DateTime expiration = now.subtract(duration);
          final String text = timeago.format(expiration, locale: 'en_short').replaceFirst("~", "");

          return DropdownMenuItem<Duration>(
            value: duration,
            child: Text(text),
          );
        }).toList(),
        onChanged: (Duration? newValue) {
          if (newValue == null) return;

          final NewPollSchema poll = schema.copyWith(expiresIn: newValue.inSeconds);
          widget.onChanged?.call(poll);
        },
      ),
    );
  }

  void onEditCompleted() {
    final List<String> options = controllers.map((controller) => controller.text).where((text) => text.isNotEmpty).toList();
    final int maxOptionsCount = max(2, options.length + 1);

    final NewPollSchema newPoll = widget.schema!.copyWith(
      options: [
        ...options,
        ...List.generate(
          min(maxOptionsCount, maxPollCount) - options.length,
          (_) => "",
        ),
      ],
    );

    widget.onChanged?.call(newPoll);
  }
}

// vim: set ts=2 sw=2 sts=2 et:
