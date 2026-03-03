// The Attachment widget to show the media
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    if (schemas.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: schemas.asMap().entries.map((entry) {
        final int index = entry.key;
        final AttachmentSchema schema = entry.value;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.all(1),
            child: Attachment(
              schema: schema,
              schemas: schemas,
              initialIndex: index,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class Attachment extends ConsumerWidget {
  final AttachmentSchema schema;
  final List<AttachmentSchema>? schemas;
  final int initialIndex;

  const Attachment({
    super.key,
    required this.schema,
    this.schemas,
    this.initialIndex = 0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ClipRRect(
      child: OverflowBox(
        alignment: Alignment.center,
        maxWidth: double.infinity,
        maxHeight: double.infinity,
        child: MediaHero(
          schemas: schemas ?? [schema],
          initialIndex: initialIndex,
          child: buildContent(ref),
        ),
      ),
    );
  }

  Widget buildContent(WidgetRef ref) {
    final bool autoPlayVideo = ref.read(preferenceProvider)?.autoPlayVideo ?? true;

    switch (schema.type) {
      case MediaType.image:
        return CachedNetworkImage(
          imageUrl: schema.previewUrl ?? schema.url,
          fit: BoxFit.cover,
          placeholder: (context, url) => BlurhashPlaceholder(blurhash: schema.blurhash),
          errorWidget: (context, url, error) => const ImageErrorPlaceholder(),
        );
      case MediaType.gifv:
        // GIFV on Mastodon are short looping MP4 videos — play them as video.
        final Uri url = Uri.parse(schema.url);
        return MediaPlayer(
          url: url,
          previewUrl: schema.previewUrl,
          blurhash: schema.blurhash,
          autoPlay: autoPlayVideo,
          showControls: false,
        );
      case MediaType.video:
        final Uri url = Uri.parse(schema.url);
        return MediaPlayer(
          url: url,
          previewUrl: schema.previewUrl,
          blurhash: schema.blurhash,
        );
      case MediaType.audio:
        final Uri url = Uri.parse(schema.url);
        final Widget cover = Icon(Icons.music_note_rounded, size: 64);
        return MediaPlayer(url: url, cover: cover);
      default:
        logger.w("unsupported media type: ${schema.type}");
        return const SizedBox.shrink();
    }
  }
}

class MediaPlayer extends StatefulWidget {
  final Uri url;
  final Widget? cover;
  final String? previewUrl;
  final String? blurhash;
  final bool autoPlay;
  final bool showControls;

  const MediaPlayer({
    super.key,
    required this.url,
    this.cover,
    this.previewUrl,
    this.blurhash,
    this.autoPlay = false,
    this.showControls = true,
  });

  @override
  State<MediaPlayer> createState() => _MediaPlayerState();
}

class _MediaPlayerState extends State<MediaPlayer> {
  VideoPlayerController? _controller;
  bool _hasError = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    _controller?.dispose();
    _hasError = false;
    _isInitialized = false;

    final controller = VideoPlayerController.networkUrl(widget.url);
    _controller = controller;

    controller.initialize().then((_) {
      if (!mounted) return;
      controller.setVolume(0.0);
      controller.setLooping(true);
      setState(() => _isInitialized = true);
      if (widget.autoPlay) controller.play();
    }).catchError((Object error) {
      logger.e("Failed to initialize video: $error");
      if (!mounted) return;
      setState(() => _hasError = true);
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) return _buildError(context);
    if (!_isInitialized) return _buildLoading(context);
    return _buildPlayer();
  }

  Widget _buildLoading(BuildContext context) {
    // Show preview image while loading if available, otherwise shimmer.
    if (widget.previewUrl != null) {
      return Stack(
        alignment: Alignment.center,
        children: [
          CachedNetworkImage(
            imageUrl: widget.previewUrl!,
            fit: BoxFit.cover,
            placeholder: (context, url) => BlurhashPlaceholder(blurhash: widget.blurhash),
            errorWidget: (context, url, error) => const ImageErrorPlaceholder(),
          ),
          const CircularProgressIndicator(),
        ],
      );
    }
    // Show cover widget (e.g. music note for audio) while loading.
    if (widget.cover != null) {
      return Center(child: widget.cover!);
    }
    return Center(
      child: SizedBox(
        width: 50,
        height: 50,
        child: ShimmerEffect(child: ColoredBox(color: Theme.of(context).colorScheme.surfaceContainerHighest)),
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)?.msg_video_error ?? 'Video failed to load',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            icon: const Icon(Icons.refresh, size: 18),
            label: Text(AppLocalizations.of(context)?.btn_retry ?? 'Retry'),
            onPressed: _initController,
          ),
        ],
      ),
    );
  }

  // Build the video player with a progress indicator and controls.
  Widget _buildPlayer() {
    final controller = _controller!;

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
              Center(child: widget.cover ?? const SizedBox.shrink()),
              AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: VideoPlayer(controller),
              ),
              if (widget.showControls) _buildControls(controller),
              if (widget.showControls) VideoProgressIndicator(controller, allowScrubbing: true),
            ],
          ),
        );
      },
    );
  }

  // Build the controls for the video player.
  Widget _buildControls(VideoPlayerController controller) {
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
