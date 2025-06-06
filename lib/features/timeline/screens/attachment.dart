// The Attachment widget to show the media
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/timeline/models/core.dart';

// The pretty view of the media attachments.
class Attachments extends StatelessWidget {
  final List<AttachmentSchema> schemas;
  final double maxHeight;

  const Attachments({
    super.key,
    required this.schemas,
    this.maxHeight = 400,
  });

  @override
  Widget build(BuildContext context) {
    if (schemas.isEmpty) {
      return const SizedBox.shrink();
    }

    final Widget child = buildContent(context);
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: child,
    );
  }

  Widget buildContent(BuildContext context) {
    switch (schemas.length) {
      case 0:
        return const SizedBox.shrink();
      default:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: schemas.map((schema) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(1),
                  child: Attachment(schema: schema),
                ),
              );
            }).toList(),
        );
    }
  }
}

class Attachment extends StatelessWidget {
  final AttachmentSchema schema;

  const Attachment({
    super.key,
    required this.schema,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: OverflowBox(
        alignment: Alignment.center,
        maxWidth: double.infinity,
        maxHeight: double.infinity,
        child: MediaHero(child: buildContent(context)),
      ),
    );
  }

  Widget buildContent(BuildContext context) {
    switch (schema.type) {
      case MediaType.image:
        return CachedNetworkImage(
          imageUrl: schema.previewUrl ?? schema.url,
          fit: BoxFit.cover,
          errorWidget: (context, url, error) => const Icon(Icons.error),
        );
      case MediaType.gifv:
        return CachedNetworkImage(
          imageUrl: schema.previewUrl ?? schema.url,
          fit: BoxFit.cover,
          errorWidget: (context, url, error) => const Icon(Icons.error),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
