// The Application info that post the status
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:glacial/features/models.dart';

class Application extends StatelessWidget {
  final ApplicationSchema? schema;
  final double size;

  const Application({
    super.key,
    required this.schema,
    this.size = 10,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle style = Theme.of(context).textTheme.bodySmall!.copyWith(
      color: Colors.grey,
      fontSize: size,
    );

    if (schema == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Align(
        alignment: Alignment.centerRight,
        child: InkWell(
          onTap: schema!.website == null ? null : () async {
            final Uri url = Uri.parse(schema!.website!);
            await launchUrl(url);
          },
          child: Text(schema!.name, style: style),
        ),
      ),
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
