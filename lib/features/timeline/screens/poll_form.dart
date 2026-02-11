// The poll form for the status, which allows the user to create a poll with options.
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';

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
    for (final controller in controllers) {
      controller.dispose();
    }
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
          final String text = timeago.format(expiration, locale: timeagoLocale(context)).replaceFirst("~", "");

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
