// The Attachment widget to show the media
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

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
        child: MediaHero(child: buildContent()),
      ),
    );
  }

  Widget buildContent() {
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
      case MediaType.video:
        final Uri url = Uri.parse(schema.url);
        return MediaPlayer(url: url);
      default:
        logger.w("unsupported media type: ${schema.type}");
        return const SizedBox.shrink();
    }
  }
}

class MediaPlayer extends StatefulWidget {
  final Uri url;

  const MediaPlayer({
    super.key,
    required this.url,
  });

  @override
  State<MediaPlayer> createState() => _MediaPlayerState();
}

class _MediaPlayerState extends State<MediaPlayer> {
  late final VideoPlayerController controller;
  late Future<void> playerFuture;

  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.networkUrl(widget.url)
      ..setVolume(0.0) // Mute the video by default
      ..setLooping(true);

    playerFuture = controller.initialize().then((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: playerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        return buildPlayer();
      },
    );
  }

  // Build the video player with a progress indicator and controls.
  Widget buildPlayer() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: min(constraints.maxHeight, 600.0),
            maxWidth: min(constraints.maxWidth, 800.0),
          ),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: VideoPlayer(controller),
              ),
              buildControls(),
              VideoProgressIndicator(controller, allowScrubbing: true),
            ],
          ),
        );
      },
    );
  }

  // Build the controls for the video player.
  Widget buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(
          icon: Icon(controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
          onPressed: () {
            setState(() {
              controller.value.isPlaying ? controller.pause() : controller.play();
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.restart_alt),
          onPressed: () {
            setState(() {
              controller.seekTo(Duration.zero);
              controller.pause();
            });
          },
        ),
        IconButton(
          icon: Icon(controller.value.volume == 0.0 ? Icons.volume_off : Icons.volume_up),
          onPressed: () {
            setState(() {
              controller.setVolume(controller.value.volume == 0.0 ? 0.2 : 0.0);
            });
          },
        ),
      ],
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
