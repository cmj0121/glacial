// The new status button to create a new status.
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
  late final AccessStatusSchema? status = ref.read(accessStatusProvider);
  late final SystemPreferenceSchema? pref = ref.read(preferenceProvider);

  bool isScheduled = false;
  NewPollSchema? poll;
  late bool isSensitive = widget.editFrom?.sensitive ?? false;
  late String? spoiler = widget.editFrom?.spoiler.isNotEmpty == true ? widget.editFrom?.spoiler : null;
  late List<AttachmentSchema> medias = widget.editFrom?.attachments ?? [];
  late VisibilityType vtype = widget.editFrom?.visibility ?? pref?.visibility ?? VisibilityType.public;
  late DateTime? scheduledAt = widget.editFrom?.scheduledAt;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
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
      ),
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
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
        onChanged: (value) => setState(() => spoiler = value),
      ),
    );
  }

  // Build the text form for the status content.
  Widget buildTextField() {
    final int maxLines = 6;

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      maxLines: maxLines,
      minLines: maxLines,
      maxLength: status?.server?.config.statuses.maxCharacters ?? 500,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
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
          onChanged: widget.editFrom == null ? (type) => setState(() => vtype = type ?? vtype) : null,
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
          onPressed: (poll == null && maxMedias > medias.length && isSignedIn) ? onImagePicker : null,
        ),
        // The poll icon button to toggle the poll form.
        IconButton(
          icon: Icon(Icons.poll_outlined, size: tabSize, ),
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          onPressed: medias.isNotEmpty ? null : () => setState(() => poll = poll == null ? NewPollSchema() : null),
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
          onPressed: () => setState(() => spoiler = spoiler == null ? "" : null),
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
          onPressed: () => setState(() => isSensitive = !isSensitive),
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
    final IconData icon = widget.editFrom == null ? (isScheduled ? Icons.schedule : Icons.chat) : Icons.edit;
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
            onPressed: widget.editFrom == null ? (isScheduled ? onSchedulePost : onPost) : onPost,
            onLongPress: widget.editFrom == null ? () => setState(() => isScheduled = !isScheduled) : null,
          ),
        );
      case false:
        return FilledButton.icon(
          icon: Icon(icon, size: tabSize),
          label: Text(text),
          onPressed: widget.editFrom == null ? (isScheduled ? onSchedulePost : onPost) : onPost,
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

    final StatusSchema? post = widget.editFrom == null ?
        await status?.createStatus(schema: schema, idempotentKey: idempotentKey) :
        await status?.editStatus(id: widget.editFrom!.id, schema: schema, idempotentKey: idempotentKey);
    if (mounted) {
      if (post != null) widget.onPost?.call(post);
      context.pop();
    }
  }

  // The callback when the user long presses the post button to schedule the post.
  void onSchedulePost() async {
    final DateTime now = DateTime.now();
    final DateTime? datetime = await picker.DatePicker.showDateTimePicker(context, currentTime: now);

    if (datetime == null) {
      logger.d("No date selected for scheduling the post.");
      return;
    }

    setState(() => scheduledAt = datetime.toUtc());
    onPost();
  }

  bool get isSignedIn => status?.domain?.isNotEmpty == true && status?.accessToken?.isNotEmpty == true;
  bool get isReadyToPost => controller.text.isNotEmpty || medias.isNotEmpty || (poll?.isValid ?? false);
}

// vim: set ts=2 sw=2 sts=2 et:
