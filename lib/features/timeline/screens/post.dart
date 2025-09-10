// The new status button to create a new status.
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as picker;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

// The form of the new status that user can fill in to create a new status.
class PostStatusForm extends ConsumerStatefulWidget {
  final StatusSchema? replyTo;
  final StatusSchema? editFrom;
  final ValueChanged<StatusSchema>? onPost;

  const PostStatusForm({
    super.key,
    this.replyTo,
    this.editFrom,
    this.onPost,
  });

  @override
  ConsumerState<PostStatusForm> createState() => _StatusFormState();
}

class _StatusFormState extends ConsumerState<PostStatusForm> {
  final FocusNode focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();
  final double medisWidth = 100;
  final String idempotentKey = const Uuid().v4();

  late final TextEditingController controller = TextEditingController(text: widget.editFrom?.plainText ?? "");
  late final TextEditingController spoilerController = TextEditingController(text: widget.editFrom?.spoiler ?? "");
  late final AccessStatusSchema? status = ref.read(accessStatusProvider);
  late final SystemPreferenceSchema? pref = ref.read(preferenceProvider);

  bool isScheduled = false;
  NewPollSchema? poll;
  late bool isSensitive = widget.editFrom?.sensitive ?? false;
  late String? spoiler = widget.editFrom?.spoiler.isNotEmpty == true ? widget.editFrom?.spoiler : null;
  late List<AttachmentSchema> medias = widget.editFrom?.attachments ?? [];
  late VisibilityType vtype = widget.replyTo?.visibility ?? pref?.visibility ?? VisibilityType.public;
  late DateTime? scheduledAt = widget.editFrom?.scheduledAt;

  @override
  void initState() {
    super.initState();
    onInitMentioned();
  }

  @override
  void dispose() {
    controller.dispose();
    spoilerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Dismissible(
        key: UniqueKey(),
        direction: DismissDirection.startToEnd,
        onDismissed: (_) => context.pop(),
        child: buildLayout(),
      ),
    );
  }

  Widget buildLayout() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: buildContent(),
          ),
        ),
      ],
    );
  }

  // Build the content of the status form.
  Widget buildContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildReplyTo(),
        buildSpoilerField(),
        buildTextField(),

        const SizedBox(height: 16),
        PollForm(schema: poll, onChanged: (poll) => setState(() => this.poll = poll)),
        buildMedias(),
        Flexible(child: buildActions()),
      ],
    );
  }

  // Build the optional reply-to widget with the greyed out reply-to status.
  Widget buildReplyTo() {
    if (widget.replyTo == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(Colors.grey, BlendMode.modulate),
        child: StatusLite(schema: widget.replyTo!),
      ),
    );
  }

  // Build the optional spoiler text field for the status.
  Widget buildSpoilerField() {
    if (spoiler == null) {
      return const SizedBox.shrink();
    }

    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus) {
          setState(() => spoiler = spoilerController.text.isNotEmpty ? spoilerController.text : null);
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: TextFormField(
          controller: spoilerController,
          style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)?.txt_spoiler ?? "Spoiler",
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.6),
            ),
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainer,
          ),
        ),
      ),
    );
  }

  // Build the text form for the status content.
  Widget buildTextField() {
    final int maxLines = 6;

    return AutoCompleteForm(
      maxSuggestions: 7,
      controller: controller,
      builder: (context, textEditingController, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: textEditingController,
          focusNode: focusNode,
          enabled: !isEditSchedule,
          maxLines: maxLines,
          minLines: maxLines,
          maxLength: status?.server?.config.statuses.maxCharacters ?? 500,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
        );
      },
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
    return Padding(
      padding: const EdgeInsets.all(4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: url,
              width: medisWidth,
              height: medisWidth,
              fit: BoxFit.cover,
              placeholder: (context, url) => const ClockProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error, color: Theme.of(context).colorScheme.error),
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
      ),
    );
  }

  // Build the possible actions for the post status form.
  Widget buildActions() {
    final int maxMedias = status?.server?.config.statuses.maxAttachments ?? 4;
    final List<Widget> actions = [
        VisibilitySelector(
          type: vtype,
          size: tabSize,
          onChanged: (widget.editFrom == null && !isEditSchedule) ? (type) => setState(() => vtype = type ?? vtype) : null,
        ),

        // The media icon button to open the image picker and upload media files.
        IconButton(
          icon: Icon(
            Icons.perm_media_rounded,
            size: tabSize,
            color: medias.isEmpty ? null : Theme.of(context).colorScheme.primary,
          ),
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          onPressed: (poll == null && maxMedias > medias.length && isSignedIn && !isEditSchedule) ? onImagePicker : null,
        ),
        // The poll icon button to toggle the poll form.
        IconButton(
          icon: Icon(Icons.poll_outlined, size: tabSize, ),
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          onPressed: (medias.isEmpty && !isEditSchedule) ?
            () => setState(() => poll = poll == null ? NewPollSchema() : null) :
            null,
        ),
        // The spoiler icon button to toggle the spoiler text field.
        IconButton(
          icon: Icon(
            Icons.warning,
            size: tabSize,
            color: spoiler == null ? null : Theme.of(context).colorScheme.tertiary
          ),
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          onPressed: !isEditSchedule ? () => setState(() => spoiler = spoiler == null ? "" : null) : null,
        ),
        // The sensitive icon button to toggle the sensitive content of the status.
        IconButton(
          icon: Icon(
            isSensitive ? Icons.visibility_off_outlined : Icons.visibility,
            size: tabSize,
            color: isSensitive ? Theme.of(context).colorScheme.tertiary : null
          ),
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          onPressed: !isEditSchedule ? () => setState(() => isSensitive = !isSensitive) : null,
        ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;

        if (width < 400) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: actions,
              ),
              const SizedBox(height: 8),
              buildSubmitButton(fullWidth: true),
            ],
          );
        } else {
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ...actions,
              const Spacer(),
              buildSubmitButton(fullWidth: false),
            ],
          );
        }
      },
    );
  }

  // Build the submit button that can post the status or schedule the post.
  Widget buildSubmitButton({bool fullWidth = false}) {
    final IconData icon = (isScheduled || isEditSchedule) ? Icons.schedule : Icons.chat;
    final String text = widget.editFrom == null ?
        (isScheduled ?
          AppLocalizations.of(context)?.btn_status_scheduled ?? "Scheduled Toot" :
          AppLocalizations.of(context)?.btn_status_toot ?? "Toot") :
        AppLocalizations.of(context)?.btn_status_edit ?? "Edit Toot";

    switch (fullWidth) {
      case true:
        return SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            icon: Icon(icon, size: tabSize),
            label: Text(text),
            onPressed: (isScheduled || isEditSchedule) ? onSchedulePost : onPost,
            onLongPress: widget.editFrom == null ? () => setState(() => isScheduled = !isScheduled) : null,
          ),
        );
      case false:
        return FilledButton.icon(
          icon: Icon(icon, size: tabSize),
          label: Text(text),
          onPressed: (isScheduled || isEditSchedule) ? onSchedulePost : onPost,
          onLongPress: widget.editFrom == null ? () => setState(() => isScheduled = !isScheduled) : null,
        );
    }
  }

  // The atction to image picker and upload media files.
  void onImagePicker() async {
    final ImagePicker picker = ImagePicker();
    final XFile? media = await picker.pickMedia();

    if (media == null || status == null) {
      logger.d("No image selected, cannot upload media files.");
      return;
    }

    final String filepath = media.path;
    final AttachmentSchema attachment = await status!.uploadMedia(filepath);
    setState(() => medias.add(attachment));
  }

  // The callback when the user clicks the post button.
  void onPost({bool? edit}) async {
    if (!isReadyToPost) { return; }

    final PostStatusSchema schema = PostStatusSchema(
      status: controller.text,
      mediaIDs: medias.map((media) => media.id).toList(),
      poll: poll,
      spoiler: spoiler,
      visibility: vtype,
      sensitive: isSensitive,
      inReplyToID: widget.replyTo?.id,
      scheduledAt: scheduledAt,
    );

    final AccountSchema? account = status?.account;
    final StatusSchema? post = widget.editFrom == null ?
        await status?.createStatus(schema: schema, idempotentKey: idempotentKey, account: account!) :
        await status?.editStatus(id: widget.editFrom!.id, schema: schema, idempotentKey: idempotentKey, account: account!);

    if (mounted) {
      if (post != null) widget.onPost?.call(post);
      context.pop();
    }
  }

  // The callback when the user long presses the post button to schedule the post.
  void onSchedulePost() async {
    final Duration minDuration = const Duration(minutes: 5);
    final DateTime now = DateTime.now();
    final DateTime? datetime = await picker.DatePicker.showDateTimePicker(
      context,
      currentTime: now.add(minDuration),
      minTime: now.add(minDuration),
    );

    if (datetime == null) {
      logger.d("No date selected for scheduling the post.");
      return;
    }

    setState(() => scheduledAt = datetime.toUtc());
    onPost();
  }

  // auto detect the mentioned accounts in the status input field when reply the status.
  void onInitMentioned() {
    if (widget.replyTo == null) return;

    final ReplyTagType replyTag = pref?.replyTag ?? ReplyTagType.all;
    switch (replyTag) {
      case ReplyTagType.all:
        final List<String> accts = (widget.replyTo?.mentions ?? [])
            .where((mention) => mention.acct.isNotEmpty && mention.acct != status?.account?.acct)
            .map((mention) => '@${mention.acct}')
            .toList();

        final String mentions = {...accts, '@${widget.replyTo!.account.acct}'}
            .toList()
            .join(" ");
        logger.d("Auto-mentioning accounts: $mentions from ${widget.replyTo!.mentions.length} mentions.");
        controller.text = "$mentions ${controller.text}";
        break;
      case ReplyTagType.poster:
        controller.text = "@${widget.replyTo!.account.acct} ${controller.text}";
        break;
      case ReplyTagType.none:
        // Do nothing, no mention will be added.
        break;
    }
  }

  bool get isSignedIn => status?.domain?.isNotEmpty == true && status?.accessToken?.isNotEmpty == true;
  bool get isReadyToPost => controller.text.isNotEmpty || medias.isNotEmpty || (poll?.isValid ?? false);
  bool get isEditSchedule => widget.editFrom?.scheduledAt != null;
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
    final AccessStatusSchema? status = ref.read(accessStatusProvider);

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

        final SearchResultSchema? results = await status?.search(keyword: prefix, type: type);
        final List<String> token = (results?.hashtags ?? []).map((r) => r.name).toList();
        final List<String> suggestions = token.take(widget.maxSuggestions).toList();

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

// vim: set ts=2 sw=2 sts=2 et:
