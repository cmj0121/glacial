// The Trends link that have been shared more than others.
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/trends/models/core.dart';

// The Trends link that have been shared more than others.
class TrendsLink extends StatelessWidget {
  final LinkSchema schema;
  final double maxHeight;
  final double imageSize;

  const TrendsLink({
    super.key,
    required this.schema,
    this.maxHeight = 220,
    this.imageSize = 180,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: maxHeight,
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        child: InkWellDone(
          onTap: () => launchUrl(Uri.parse(schema.url)),
          child: buildContent(context),
        ),
      ),
    );
  }

  Widget buildContent(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: buildText(context)),
        const SizedBox(width: 16),
        buildImage(),
      ],
    );
  }

  Widget buildText(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildAuthor(context),
        const SizedBox(height: 6),
        Text(
          schema.title,
          style: Theme.of(context).textTheme.bodyLarge,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),

        Text(
          schema.desc,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget buildImage() {
    return Center(
      child: SizedBox(
        width: imageSize,
        height: imageSize,
        child: MediaHero(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: schema.image,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildAuthor(BuildContext context) {
    final Uri? uri = Uri.tryParse(schema.authUrl);
    final Widget author = Text(schema.authName, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey));

    if (uri == null || schema.authUrl.isEmpty) {
      return author;
    }

    return InkWell(
      onTap: () => launchUrl(uri),
      child: author,
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
