// The hero media widget for full-screen image viewing.
import 'package:flutter/material.dart';

import 'package:glacial/cores/screens/media_gallery.dart';
import 'package:glacial/cores/screens/media_viewer.dart';
import 'package:glacial/cores/screens/misc.dart';
import 'package:glacial/features/models.dart';

// The hero media that show the media and show to full-screen when tap on it.
class MediaHero extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final List<AttachmentSchema>? schemas;
  final int initialIndex;

  const MediaHero({
    super.key,
    required this.child,
    this.onTap,
    this.schemas,
    this.initialIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return InkWellDone(
      onTap: onTap ?? () => onHero(context),
      child: child,
    );
  }

  void onHero(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          // If schemas are provided, use the gallery viewer for swipe navigation
          if (schemas != null && schemas!.isNotEmpty) {
            return MediaGallery(
              schemas: schemas!,
              initialIndex: initialIndex,
            );
          }
          // Fallback to single media viewer
          return Center(
            child: Hero(
              tag: 'media-hero',
              child: MediaViewer(child: child),
            ),
          );
        },
      ),
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
