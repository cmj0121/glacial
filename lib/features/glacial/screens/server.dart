// The search widget to search specified resource.
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/glacial/models/server.dart';

// fetch the server information from the specified domain.
Future<ServerSchema> fetch(String domain) async {
  logger.i('search the mastodon server: $domain');

  final Uri url = Uri.parse('https://$domain/api/v2/instance');
  final response = await get(url);

  if (response.statusCode != 200) {
    logger.w('failed to load the server: $domain: ${response.statusCode}');
    throw Exception('Failed to load the server: $domain');
  }

  return ServerSchema.fromString(response.body);
}

// The Mastodon server widget to show the information based on the widget type.
class MastodonServer extends StatelessWidget {
  final ServerSchema schema;
  final ValueChanged<ServerSchema>? onTap;

  const MastodonServer({
    super.key,
    required this.schema,
    this.onTap,
  });

  // The static method to create the server widget by the passed domain, with
  // the future builder to load the server information.
  static Widget builder({required String domain, ValueChanged<ServerSchema>? onTap}) {
    return FutureBuilder(
      future: fetch(domain),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LinearProgressIndicator();
        } else if (snapshot.hasError) {
          final String text = AppLocalizations.of(context)?.txt_invalid_instance ?? 'Invalid instance: $domain';
          return Text(text, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.red));
        }

        final ServerSchema schema = snapshot.data as ServerSchema;
        logger.i("successfully loaded the server: ${schema.domain}");
        return MastodonServer(schema: schema, onTap: onTap);
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWellDone(
      onTap: () => onTap?.call(schema),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: buildThumbnail()),
              const SizedBox(height: 16),
              Text(schema.title, style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 16),
              Flexible(
                child: Text(schema.desc, style: Theme.of(context).textTheme.bodyLarge),
              ),
              const SizedBox(height: 6),
              buildMetadata(),
            ],
          ),
        ),
      ),
    );
  }

  // Build the thumbnail image of the server.
  Widget buildThumbnail() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: OverflowBox(
        alignment: Alignment.center,
        maxWidth: double.infinity,
        maxHeight: double.infinity,
        child: CachedNetworkImage(
          imageUrl: schema.thumbnail,
          placeholder: (context, url) => const CircularProgressIndicator(),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      ),
    );
  }

  // Build the metadata of the server, including the server version and the
  // supported languages.
  Widget buildMetadata() {
    final List<String> tags = [
      'v${schema.version}',
      'mau: ${schema.usage.userActiveMonthly}',
      ...schema.languages,
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: tags.map((tag) {
        // Show the pill tag with the text.
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          margin: const EdgeInsets.only(left: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade400,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(tag, style: const TextStyle(fontSize: 10, color: Colors.black)),
        );
      }).toList(),
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
