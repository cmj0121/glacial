// Blurhash placeholder widget for media loading states.
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';

import 'package:glacial/cores/screens/animations.dart';

/// Renders a blurhash-decoded image placeholder while media loads.
///
/// Falls back to [ClockProgressIndicator] when blurhash is null or invalid.
class BlurhashPlaceholder extends StatelessWidget {
  final String? blurhash;
  final BoxFit fit;

  const BlurhashPlaceholder({
    super.key,
    this.blurhash,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final String? hash = blurhash;
    if (hash == null || hash.length < 6) {
      return const Center(child: ClockProgressIndicator());
    }

    // BlurHash requires bounded constraints. Fall back to ClockProgressIndicator
    // when rendered in an unconstrained context (e.g., inside FittedBox).
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedWidth || !constraints.hasBoundedHeight) {
          return const Center(child: ClockProgressIndicator());
        }
        return BlurHash(hash: hash, imageFit: fit);
      },
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
