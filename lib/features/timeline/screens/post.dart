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
class StatusForm extends ConsumerStatefulWidget {
  final double maxWidth;
  final StatusSchema? replyTo;

  const StatusForm({
    super.key,
    this.maxWidth = 600,
    this.replyTo,
  });

  @override
  ConsumerState<StatusForm> createState() => _StatusFormState();
}

class _StatusFormState extends ConsumerState<StatusForm> {
  late final TextEditingController controller;
  final formKey = GlobalKey<FormState>();
  final double medisWidth = 100;
  final String ikey = Uuid().v4();

  VisibilityType vtype = VisibilityType.public;
  List<AttachmentSchema> medias = [];

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
    return ClipRRect(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: widget.maxWidth,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: buildContent(),
        ),
      ),
    );
  }

  Widget buildContent() {
    final int maxLines = 6;
    final ServerSchema? schema = ref.read(serverProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          minLines: maxLines,
          maxLength: schema?.config.statuses.maxCharacters ?? 500,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        buildMedias(),
        Flexible(child: buildActions()),
      ],
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
            placeholder: (context, url) => const CircularProgressIndicator(),
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
          icon: Icon(Icons.perm_media_rounded),
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          onPressed: maxMedias > medias.length ? onImagePicker : null,
        ),
        const Spacer(),
        TextButton.icon(
          icon: Icon(Icons.chat),
          label: Text(AppLocalizations.of(context)?.btn_post ?? "Post"),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.primary,
          ),
          onPressed: onPost,
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
      pollIDs: [],
      visibility: vtype,
      inReplyToID: widget.replyTo?.id,
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
}

// vim: set ts=2 sw=2 sts=2 et:
