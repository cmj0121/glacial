// Link preview card widget for status content.
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/models.dart';

/// Displays a link preview card with image, title, and description.
class PreviewCard extends StatelessWidget {
  final PreviewCardSchema schema;

  const PreviewCard({
    super.key,
    required this.schema,
  });

  @override
  Widget build(BuildContext context) {
    if (schema.image?.isEmpty ?? true) {
      return const SizedBox.shrink();
    }

    return InkWellDone(
      onTap: () => context.push(RoutePath.webview.path, extra: Uri.parse(schema.url)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: buildContent(context),
        ),
      )
    );
  }

  Widget buildContent(BuildContext context) {
    return AdaptiveGlassCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth / 3;
          final TextStyle? descStyle = Theme.of(context).textTheme.labelMedium;

          if (schema.width < width) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildImage(),
                const SizedBox(width: 12),

                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        schema.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        schema.description,
                        style: descStyle,
                        maxLines: 5,
                        textAlign: TextAlign.justify,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return SizedBox(
            width: schema.width.toDouble(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildImage(),
                const SizedBox(height: 12),

                Text(
                  schema.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  schema.description,
                  style: descStyle,
                  maxLines: 5,
                  textAlign: TextAlign.justify,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildImage() {
    if (schema.image?.isEmpty ?? true) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: schema.width.toDouble(),
      height: schema.height.toDouble(),
      child: CachedNetworkImage(
        imageUrl: schema.image!,
        placeholder: (context, url) => ShimmerEffect(child: ColoredBox(color: Theme.of(context).colorScheme.surfaceContainerHighest)),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      ),
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
