// The new status button to create a new status.
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

// The form of the new status that user can fill in to create a new status.
class PostStatusForm extends ConsumerStatefulWidget {
  final StatusSchema? replyTo;
  final StatusSchema? quoteTo;
  final StatusSchema? editFrom;
  final DraftSchema? draftFrom;
  final ValueChanged<StatusSchema>? onPost;

  const PostStatusForm({
    super.key,
    this.replyTo,
    this.quoteTo,
    this.editFrom,
    this.draftFrom,
    this.onPost,
  });

  @override
  ConsumerState<PostStatusForm> createState() => _StatusFormState();
}

class _StatusFormState extends ConsumerState<PostStatusForm> {
  final FocusNode focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();
  final double mediaWidth = 100;
  final String idempotentKey = const Uuid().v4();

  late final TextEditingController controller = TextEditingController(
    text: widget.draftFrom?.content ?? widget.editFrom?.plainText ?? "",
  );
  late final TextEditingController spoilerController = TextEditingController(
    text: widget.draftFrom?.spoiler ?? widget.editFrom?.spoiler ?? "",
  );
  late final AccessStatusSchema? status = ref.read(accessStatusProvider);
  late final SystemPreferenceSchema? pref = ref.read(preferenceProvider);

  late final String _draftId = widget.draftFrom?.id ?? const Uuid().v4();
  bool isScheduled = false;
  late NewPollSchema? poll = widget.draftFrom?.poll;
  late bool isSensitive = widget.draftFrom?.sensitive ?? widget.editFrom?.sensitive ?? false;
  late String? spoiler = widget.draftFrom?.spoiler ?? (widget.editFrom?.spoiler.isNotEmpty == true ? widget.editFrom?.spoiler : null);
  late List<AttachmentSchema> medias = widget.editFrom?.attachments ?? [];
  late VisibilityType vtype = widget.draftFrom?.visibility ?? widget.replyTo?.visibility ?? pref?.visibility ?? VisibilityType.public;
  late QuotePolicyType qtype = widget.draftFrom?.quotePolicy ?? widget.editFrom?.quoteApproval?.toUser ?? pref?.quotePolicy ?? QuotePolicyType.public;
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
      child: AccessibleDismissible(
        dismissKey: UniqueKey(),
        direction: DismissDirection.startToEnd,
        dismissLabel: AppLocalizations.of(context)?.lbl_swipe_back,
        confirmDismiss: (_) async {
          _autoSaveDraft();
          context.pop();
          return false;
        },
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
        buildSubmitButton(fullWidth: true),
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
        buildQuoteTo(),

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

  // Build the optional quote-to widget with the greyed out quote-to status.
  Widget buildQuoteTo() {
    final StatusSchema? quote = widget.quoteTo ?? widget.editFrom?.quote?.quotedStatus;

    if (quote == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(Colors.grey, BlendMode.modulate),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: StatusLite(schema: quote),
          ),
        ),
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
              width: mediaWidth,
              height: mediaWidth,
              fit: BoxFit.cover,
              placeholder: (context, url) => BlurhashPlaceholder(blurhash: media.blurhash),
              errorWidget: (context, url, error) => Icon(Icons.error, color: Theme.of(context).colorScheme.error),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: Icon(Icons.remove_circle, color: Theme.of(context).colorScheme.tertiary),
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
    final List<Widget> selector = [
      VisibilitySelector(
        type: vtype,
        size: tabSize,
        onChanged: (widget.editFrom == null && !isEditSchedule) ? (type) => setState(() => vtype = type ?? vtype) : null,
      ),
      QuotePolicyTypeSelector(
        policy: qtype,
        size: tabSize,
        onChanged: (value) => setState(() => qtype = value ?? qtype),
      ),
    ];
    final List<Widget> actions = [
      // The media icon button to open the image picker and upload media files.
      IconButton(
        icon: Icon(
          Icons.perm_media_rounded,
          size: tabSize,
          color: medias.isEmpty ? null : Theme.of(context).colorScheme.primary,
        ),
        onPressed: (poll == null && maxMedias > medias.length && isSignedIn && !isEditSchedule) ? onImagePicker : null,
      ),
      // The poll icon button to toggle the poll form.
      IconButton(
        icon: Icon(Icons.poll_outlined, size: tabSize, ),
        onPressed: (medias.isEmpty && !isEditSchedule) ?
          () => setState(() => poll = poll == null ? NewPollSchema() : null) :
          null,
      ),
      // The spoiler icon button to toggle the spoiler text field.
      IconButton(
        icon: Icon(
          Icons.warning,
          size: tabSize,
          color: spoiler == null ? null : Theme.of(context).colorScheme.tertiary,
        ),
        onPressed: !isEditSchedule ? () => setState(() => spoiler = spoiler == null ? "" : null) : null,
      ),
      // The sensitive icon button to toggle the sensitive content of the status.
      IconButton(
        icon: Icon(
          isSensitive ? Icons.visibility_off_outlined : Icons.visibility,
          size: tabSize,
          color: isSensitive ? Theme.of(context).colorScheme.tertiary : null
        ),
        onPressed: !isEditSchedule ? () => setState(() => isSensitive = !isSensitive) : null,
      ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: selector,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: actions,
        ),
      ],
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
  Future<void> onImagePicker() async {
    final ImagePicker picker = ImagePicker();
    final XFile? media = await picker.pickMedia();

    if (media == null || status == null) {
      logger.d("No image selected, cannot upload media files.");
      return;
    }

    final String filepath = media.path;
    final AttachmentSchema attachment = await status!.uploadMedia(filepath);
    if (mounted) setState(() => medias.add(attachment));
  }

  // The callback when the user clicks the post button.
  Future<void> onPost({bool? edit}) async {
    if (!isReadyToPost) { return; }

    final PostStatusSchema schema = PostStatusSchema(
      status: controller.text,
      mediaIDs: medias.map((media) => media.id).toList(),
      poll: poll,
      spoiler: spoiler,
      visibility: vtype,
      sensitive: isSensitive,
      inReplyToID: widget.replyTo?.id,
      quotedStatusID: widget.quoteTo?.id,
      scheduledAt: scheduledAt,
      quoteApprovalPolicy: qtype,
    );

    final AccountSchema? account = status?.account;
    final StatusSchema? post = widget.editFrom == null ?
        await status?.createStatus(schema: schema, idempotentKey: idempotentKey, account: account!) :
        await status?.editStatus(id: widget.editFrom!.id, schema: schema, idempotentKey: idempotentKey, account: account!);

    if (mounted && post != null) {
      widget.onPost?.call(post);
      await _removeDraftOnPost();
    }
    if (mounted) {
      context.pop();
    }
  }

  // The callback when the user long presses the post button to schedule the post.
  Future<void> onSchedulePost() async {
    final Duration minDuration = const Duration(minutes: 5);
    final DateTime now = DateTime.now();
    final DateTime minDateTime = now.add(minDuration);

    // Show date picker first
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: minDateTime,
      firstDate: minDateTime,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (date == null || !mounted) {
      logger.d("No date selected for scheduling the post.");
      return;
    }

    // Then show time picker
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(minDateTime),
    );

    if (time == null || !mounted) {
      logger.d("No time selected for scheduling the post.");
      return;
    }

    final DateTime datetime = DateTime(date.year, date.month, date.day, time.hour, time.minute);

    // Validate that selected datetime is at least 5 minutes in the future
    if (datetime.isBefore(DateTime.now().add(minDuration))) {
      logger.d("Selected time is too soon, must be at least 5 minutes in the future.");
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

  // Build a DraftSchema from the current form state.
  DraftSchema _buildDraftFromForm() {
    return DraftSchema(
      id: _draftId,
      content: controller.text,
      spoiler: spoiler,
      sensitive: isSensitive,
      visibility: vtype,
      quotePolicy: qtype,
      inReplyToId: widget.replyTo?.id ?? widget.draftFrom?.inReplyToId,
      quoteToId: widget.quoteTo?.id ?? widget.draftFrom?.quoteToId,
      poll: poll,
      updatedAt: DateTime.now(),
    );
  }

  // Auto-save the current compose state as a draft when navigating away.
  Future<void> _autoSaveDraft() async {
    if (widget.editFrom != null) return;

    final String? key = status?.compositeKey;
    if (key == null) return;

    final bool hasContent = controller.text.isNotEmpty || (poll?.isValid ?? false);
    if (!hasContent) return;

    await Storage().saveDraft(key, _buildDraftFromForm());
    if (mounted) {
      final String message = AppLocalizations.of(context)?.msg_draft_saved ?? 'Draft saved';
      showSnackbar(context, message);
    }
  }

  // Remove the draft after a successful post.
  Future<void> _removeDraftOnPost() async {
    final String? key = status?.compositeKey;
    if (key == null) return;
    await Storage().removeDraft(key, _draftId);
  }

  bool get isSignedIn => status?.domain?.isNotEmpty == true && status?.accessToken?.isNotEmpty == true;
  bool get isReadyToPost => controller.text.isNotEmpty || medias.isNotEmpty || (poll?.isValid ?? false);
  bool get isEditSchedule => widget.editFrom?.scheduledAt != null;
}

// vim: set ts=2 sw=2 sts=2 et:
