// The Quote widget to show the quoted status
import 'package:flutter/material.dart';

import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

class Quote extends StatelessWidget {
  final QuoteSchema? schema;

  const Quote({super.key, required this.schema});

  @override
  Widget build(BuildContext context) {
    if (schema == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: buildContent(context),
    );
  }

  Widget buildContent(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StatusLite(schema: schema!.quotedStatus!),
      ),
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
