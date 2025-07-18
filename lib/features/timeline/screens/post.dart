// The new status button to create a new status.
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as picker;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

// The form of the new status that user can fill in to create a new status.
class StatusForm extends ConsumerStatefulWidget {
  final StatusSchema? replyTo;

  const StatusForm({
    super.key,
    this.replyTo,
  });

  @override
  ConsumerState<StatusForm> createState() => _StatusFormState();
}

class _StatusFormState extends ConsumerState<StatusForm> {
  final FocusNode focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();
  final double medisWidth = 100;
  final String ikey = Uuid().v4();

  late final TextEditingController controller;

  VisibilityType vtype = VisibilityType.public;
  List<AttachmentSchema> medias = [];
  NewPollSchema? poll;
  String? spoiler;
  DateTime? scheduledAt;

  @override
  void initState() {
    super.initState();

    late final AccountSchema? account = ref.read(accountProvider);

    List<String> accts = [
      ...(widget.replyTo?.mentions ?? []).map((mention) => mention.acct),
      widget.replyTo?.account.acct ?? "",
    ];

    // remove self mentions and empty mentions
    accts.removeWhere((acct) => acct == account?.acct || acct.isEmpty);

    final String mentioned = accts.toSet().toList().map((acct) => "@$acct").join(" ");
    controller = TextEditingController(text: mentioned.isEmpty ? "" : "$mentioned ");
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String? replyText = widget.replyTo?.content;
    final Widget replyWidget = replyText == null ?
      const SizedBox.shrink() :
      ColorFiltered(
        colorFilter: ColorFilter.mode(Colors.grey, BlendMode.modulate),
        child: HtmlDone(
          html: replyText,
          emojis: widget.replyTo?.emojis ?? [],
        ),
      );

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          replyWidget,

          ClipRRect(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  // Build the content of the status form.
  Widget buildContent() {
    final ServerSchema? server = ref.read(serverProvider);

    if (server == null) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSpoilerField(),
        buildTextField(),
        const SizedBox(height: 16),
        PollForm(server: server, schema: poll, onChanged: (poll) => setState(() => this.poll = poll)),
        buildMedias(),
        Flexible(child: buildActions()),
      ],
    );
  }

  // Build the text form for the status content.
  Widget buildTextField() {
    final int maxLines = 6;
    final ServerSchema? schema = ref.read(serverProvider);

    return AutoCompleteForm(
      maxSuggestions: 7,
      controller: controller,
      builder: (context, textEditingController, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: textEditingController,
          focusNode: focusNode,
          maxLines: maxLines,
          minLines: maxLines,
          maxLength: schema?.config.statuses.maxCharacters ?? 500,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
          ),
        );
      },
    );
  }

  // Build the optional spoiler text field for the status.
  Widget buildSpoilerField() {
    if (spoiler == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.warning, color: Theme.of(context).colorScheme.tertiary),
          suffixIcon: Icon(Icons.warning, color: Theme.of(context).colorScheme.tertiary),
          border: const OutlineInputBorder(),
        ),
        onChanged: (value) => setState(() => spoiler = value),
      ),
    );
  }

  // Build the uploaded media files list.
  Widget buildMedias() {
    if (medias.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: medias.map((media) => Flexible(child: buildMedia(media))).toList(),
    );
  }

  // Build the media that can change the description of the media files, or remove
  // the media files from the list.
  Widget buildMedia(AttachmentSchema media) {
    final String url = media.previewUrl ?? media.url;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: url,
            width: medisWidth,
            height: medisWidth,
            fit: BoxFit.cover,
            placeholder: (context, url) => const ClockProgressIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.error, color: Colors.red),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: Icon(Icons.remove_circle, color: Theme.of(context).colorScheme.tertiary),
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              onPressed: () => setState(() => medias.remove(media)),
            ),
          ),
        ],
      ),
    );
  }

  // Build the possible actions for the post status form.
  Widget buildActions() {
    final ServerSchema? server = ref.read(serverProvider);
    final int maxMedias = server?.config.statuses.maxAttachments ?? 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        VisibilitySelector(type: vtype, onChanged: (type) => setState(() => vtype = type)),
        IconButton(
          icon: Icon(Icons.perm_media_rounded, color: medias.isEmpty ? null : Theme.of(context).colorScheme.primary),
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          onPressed: (poll == null && maxMedias > medias.length) ? onImagePicker : null,
        ),
        IconButton(
          icon: Icon(Icons.poll_outlined,),
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          onPressed: medias.isNotEmpty ? null : () {
            setState(() => poll = poll == null ? NewPollSchema(options: ["", ""]) : null);
          },
        ),
        IconButton(
          icon: Icon(Icons.warning, color: spoiler == null ? null : Theme.of(context).colorScheme.tertiary),
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          onPressed: () => setState(() => spoiler = spoiler == null ? "" : null),
        ),
        const Spacer(),
        TextButton.icon(
          icon: Icon(Icons.chat),
          label: Text(AppLocalizations.of(context)?.btn_post ?? "Post"),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.primary,
          ),
          onPressed: onPost,
          onLongPress: onSchedulePost,
        ),
      ],
    );
  }

  // The atction to image picker and upload media files.
  void onImagePicker() async {
    final ServerSchema? server = ref.read(serverProvider);
    final String? accessToken = ref.read(accessTokenProvider);

    final ImagePicker picker = ImagePicker();
    final XFile? media = await picker.pickMedia();

    if (media == null) {
      logger.d("No image selected, cannot upload media files.");
      return;
    }

    if (server == null || accessToken == null) {
      logger.w("No server selected or access token, cannot upload media files.");
      return;
    }

    final String filepath = media.path;
    final AttachmentSchema attachment = await server.uploadMedia(filepath: filepath, accessToken: accessToken);
    setState(() => medias.add(attachment));
  }

  // The callback when the user clicks the post button.
  void onPost() async {
    if (controller.text.isEmpty) {
      // empty content, do nothing
      return;
    }


    final NewStatusSchema schema = NewStatusSchema(
      status: controller.text,
      mediaIDs: medias.map((media) => media.id).toList(),
      poll: poll,
      spoiler: spoiler,
      visibility: vtype,
      inReplyToID: widget.replyTo?.id,
      scheduledAt: scheduledAt,
    );

    final ServerSchema? server = ref.watch(serverProvider);
    final String? accessToken = ref.watch(accessTokenProvider);

    if (server == null || accessToken == null) {
      final String text = AppLocalizations.of(context)?.txt_invalid_instance ?? "No server selected";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(text),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    await server.createStatus(status: schema, accessToken: accessToken, ikey: ikey);
    if (mounted) {
      context.pop();
    }
  }

  // The callback when the user long presses the post button to schedule the post.
  void onSchedulePost() async {
    final DateTime now = DateTime.now();
    final DateTime? datetime = await picker.DatePicker.showDateTimePicker(
      context,
      currentTime: now,
    );
    if (datetime == null) {
      logger.d("No date selected for scheduling the post.");
      return;
    }

    logger.d("scheduling post at ${datetime.toUtc().toIso8601String()}");
    setState(() => scheduledAt = datetime.toUtc());
    onPost();
  }
}

// The autocomplete form for the status input field, which can suggest accounts or hashtags.
class AutoCompleteForm extends ConsumerStatefulWidget {
  final int maxSuggestions;
  final String initialText;
  final TextEditingController? controller;
  final AutocompleteFieldViewBuilder? builder;

  const AutoCompleteForm({
    super.key,
    this.maxSuggestions = 10,
    this.initialText = "",
    this.controller,
    this.builder,
  });

  @override
  ConsumerState<AutoCompleteForm> createState() => _AutoCompleteFormState();
}

class _AutoCompleteFormState extends ConsumerState<AutoCompleteForm> {
  final FocusNode focusNode = FocusNode();

  late final TextEditingController controller;

  String type = '';

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      // Only dispose the controller if it was created in this widget.
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ServerSchema? server = ref.read(serverProvider);
    final String? accessToken = ref.read(accessTokenProvider);

    return RawAutocomplete<String>(
      textEditingController: controller,
      focusNode: focusNode,
      displayStringForOption: replaceText,
      fieldViewBuilder: widget.builder,
      optionsBuilder: (TextEditingValue value) async {
        final String text = value.text;
        final int atIndex = text.lastIndexOf("@");
        final int hashIndex = text.lastIndexOf("#");
        final int spaceIndex = text.lastIndexOf(" ");

        if (atIndex < 0 && hashIndex < 0 || (max(atIndex, hashIndex) < spaceIndex)) {
          // If the last token is not an @ or #, return an empty list.
          return const Iterable.empty();
        }

        final String prefix = text.substring(max(atIndex, hashIndex) + 1);
        type = atIndex > hashIndex ? "accounts" : "hashtags";

        final List<String>? token = await server?.findSuggestions(prefix: prefix, type: type, accessToken: accessToken);
        final List<String> suggestions = token?.take(widget.maxSuggestions).toList() ?? [];

        logger.d("autocomplete suggestions for '$prefix': $suggestions");
        return suggestions;
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            child: Container(
              width: 400,
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final String option = options.elementAt(index);
                  final String text = "${type == 'accounts' ? '@' : '#'}$option";
                  return ListTile(title: Text(text), onTap: () {
                    onSelected(text);
                    focusNode.requestFocus();
                  });
                },
              ),
            ),
          ),
        );
      },
    );
  }

  // Replace the text in the controller with the selected suggestion.
  String replaceText(String value) {
    // only replace the token that is being edited
    final String text = controller.text;
    final int index = text.lastIndexOf(type == 'accounts' ? '@' : '#');

    return "${text.substring(0, index)}$value ";
  }
}

// The poll form for the status, which allows the user to create a poll with options.
class PollForm extends StatefulWidget {
  final ServerSchema server;
  final NewPollSchema? schema;
  final ValueChanged<NewPollSchema>? onChanged;

  const PollForm({
    super.key,
    required this.server,
    this.schema,
    this.onChanged,
  });

  @override
  State<PollForm> createState() => _PollFormState();
}

class _PollFormState extends State<PollForm> {
  final List<Duration> durations = [
    const Duration(minutes: 5),
    const Duration(minutes: 30),
    const Duration(hours: 1),
    const Duration(hours: 6),
    const Duration(hours: 12),
    const Duration(days: 1),
    const Duration(days: 7),
  ];

  late final List<TextEditingController> controllers;
  late final List<FocusNode> focusNodes;

  @override
  void initState() {
    final int count = widget.server.config.polls.maxOptions;

    super.initState();

    controllers = List.generate(count, (index) => TextEditingController());
    focusNodes = List.generate(count, (index) => FocusNode()..addListener(() => onEditCompleted()));
  }

  @override
  void dispose() {
    controllers.map((controller) => controller.dispose());
    focusNodes.map((focusNode) => focusNode.dispose());
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

      return TextField(
        controller: controller,
        focusNode: focusNodes[index],
        maxLength: widget.server.config.polls.maxCharacters,
        decoration: InputDecoration(
          icon: Icon(icon),
          helperText: "Option ${index + 1}",
          border: const OutlineInputBorder(),
        ),
        onSubmitted: (_) => onEditCompleted(),
        onTapOutside: (_) => onEditCompleted(),
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
        IconButton(
          icon: Icon(hideTotals ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            // Toggle the visibility of the poll totals.
            final NewPollSchema poll = schema.copyWith(hideTotals: !hideTotals);
            widget.onChanged?.call(poll);
          },
        ),
        const SizedBox(width: 8),
        IconButton(
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

    return DropdownButton(
      value: expiresIn,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      borderRadius: BorderRadius.circular(8),
      icon: Icon(Icons.timer),
      items: durations.map((duration) {
        final DateTime expiration = now.subtract(duration);
        final String text = timeago.format(expiration, locale: 'en_short').replaceFirst("~", "");

        return DropdownMenuItem<Duration>(value: duration, child: Text(text));
      }).toList(),
      onChanged: (Duration? newValue) {
        if (newValue == null) return;

        final NewPollSchema poll = schema.copyWith(expiresIn: newValue.inSeconds);
        widget.onChanged?.call(poll);
      },
    );
  }

  void onEditCompleted() {
    final List<String> options = controllers.map((controller) => controller.text).where((text) => text.isNotEmpty).toList();
    final int maxOptionsCount = max(2, options.length + 1);

    final NewPollSchema newPoll = widget.schema!.copyWith(
      options: [
        ...options,
        ...List.generate(
          min(maxOptionsCount, widget.server.config.polls.maxOptions) - options.length,
          (_) => "",
        ),
      ],
    );

    widget.onChanged?.call(newPoll);
  }
}

// vim: set ts=2 sw=2 sts=2 et:
