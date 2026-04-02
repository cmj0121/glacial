// The gallery viewer for swiping between multiple media attachments.
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'package:glacial/cores/screens/animations.dart';
import 'package:glacial/cores/screens/blurhash_placeholder.dart';
import 'package:glacial/cores/screens/media_viewer.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/timeline/models/core.dart';
import 'package:glacial/features/timeline/screens/attachment.dart';
import 'package:glacial/l10n/app_localizations.dart';

// The gallery viewer for swiping between multiple media attachments.
// Supports swipe left/right navigation, zoom, double-tap reset, and dismiss.
class MediaGallery extends StatefulWidget {
  final List<AttachmentSchema> schemas;
  final int initialIndex;

  const MediaGallery({
    super.key,
    required this.schemas,
    this.initialIndex = 0,
  });

  @override
  State<MediaGallery> createState() => _MediaGalleryState();
}

class _MediaGalleryState extends State<MediaGallery> {
  late PageController pageController;
  late int currentIndex;
  bool isZoomed = false;
  double backgroundOpacity = 1.0;
  bool showInfo = false;
  Map<String, IfdTag>? exifData;
  bool isLoadingExif = false;

  AttachmentSchema get currentSchema => widget.schemas[currentIndex];

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void onZoomChanged(bool zoomed) {
    if (isZoomed != zoomed) {
      setState(() => isZoomed = zoomed);
    }
  }

  void onDragUpdate(double dragDistance) {
    final screenHeight = MediaQuery.of(context).size.height;
    final opacity = 1.0 - (dragDistance.abs() / screenHeight).clamp(0.0, 0.5);
    setState(() => backgroundOpacity = opacity);
  }

  void onDragEnd() {
    setState(() => backgroundOpacity = 1.0);
  }

  Future<void> onToggleInfo() async {
    if (!showInfo && exifData == null && !isLoadingExif) {
      await loadExifData();
    }
    setState(() => showInfo = !showInfo);
  }

  Future<void> loadExifData() async {
    setState(() => isLoadingExif = true);
    try {
      final file = await DefaultCacheManager().getSingleFile(currentSchema.url);
      final Uint8List bytes = await file.readAsBytes();
      final data = await readExifFromBytes(bytes);
      if (mounted) {
        setState(() {
          exifData = data;
          isLoadingExif = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoadingExif = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: backgroundOpacity),
      body: SafeArea(
        child: Stack(
          children: [
            buildPageView(),
            buildTopBar(),
            buildBottomBar(),
            if (showInfo) buildInfoPanel(),
          ],
        ),
      ),
    );
  }

  Widget buildPageView() {
    return PageView.builder(
      controller: pageController,
      itemCount: widget.schemas.length,
      // Disable swiping when zoomed to allow panning the image
      physics: isZoomed ? const NeverScrollableScrollPhysics() : null,
      onPageChanged: (index) {
        setState(() {
          currentIndex = index;
          exifData = null;
          showInfo = false;
        });
      },
      itemBuilder: (context, index) {
        final schema = widget.schemas[index];
        if (schema.type == MediaType.image) {
          return MediaViewer(
            onDismiss: () => Navigator.of(context).maybePop(),
            onZoomChanged: onZoomChanged,
            onDragUpdate: onDragUpdate,
            onDragEnd: onDragEnd,
            child: buildMediaContent(schema),
          );
        }
        return buildMediaContent(schema);
      },
    );
  }

  Widget buildMediaContent(AttachmentSchema schema) {
    switch (schema.type) {
      case MediaType.image:
        return CachedNetworkImage(
          imageUrl: schema.url,
          fit: BoxFit.contain,
          placeholder: (context, url) => BlurhashPlaceholder(
            blurhash: schema.blurhash,
            fit: BoxFit.contain,
          ),
          errorWidget: (context, url, error) => const Icon(
            Icons.error,
            color: Colors.white,
          ),
        );
      case MediaType.gifv:
        return MediaPlayer(
          url: Uri.parse(schema.url),
          previewUrl: schema.previewUrl,
          blurhash: schema.blurhash,
          autoPlay: true,
          showControls: false,
        );
      case MediaType.video:
        return MediaPlayer(
          url: Uri.parse(schema.url),
          previewUrl: schema.previewUrl,
          blurhash: schema.blurhash,
          showControls: true,
        );
      case MediaType.audio:
        return MediaPlayer(
          url: Uri.parse(schema.url),
          cover: const Icon(Icons.music_note_rounded, size: 64, color: Colors.white),
        );
      default:
        return const Icon(Icons.image_not_supported, color: Colors.white);
    }
  }

  Widget buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black54, Colors.transparent],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            if (widget.schemas.length > 1)
              Text(
                '${currentIndex + 1} / ${widget.schemas.length}',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            if (currentSchema.type == MediaType.image)
              IconButton(
                icon: Icon(
                  showInfo ? Icons.info : Icons.info_outline,
                  color: Colors.white,
                ),
                onPressed: onToggleInfo,
              ),
          ],
        ),
      ),
    );
  }

  Widget buildBottomBar() {
    if (widget.schemas.length <= 1) return const SizedBox.shrink();

    return Positioned(
      bottom: 16,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(widget.schemas.length, (index) {
          final bool isActive = index == currentIndex;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 10 : 8,
            height: isActive ? 10 : 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.5),
            ),
          );
        }),
      ),
    );
  }

  Widget buildInfoPanel() {
    return Positioned(
      bottom: 60,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (currentSchema.description != null &&
                currentSchema.description!.isNotEmpty) ...[
              Text(
                AppLocalizations.of(context)?.txt_media_alt_text ?? 'Alt Text',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                currentSchema.description!,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 12),
            ],
            Text(
              AppLocalizations.of(context)?.txt_media_image_info ?? 'Image Info',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            if (isLoadingExif)
              const Center(child: ClockProgressIndicator.small())
            else
              buildExifInfo(),
          ],
        ),
      ),
    );
  }

  Widget buildExifInfo() {
    final List<Widget> items = [];

    if (exifData != null && exifData!.isNotEmpty) {
      final make = exifData!['Image Make']?.printable;
      final model = exifData!['Image Model']?.printable;
      if (make != null || model != null) {
        items.add(_buildInfoRow(Icons.camera_alt, '${make ?? ''} ${model ?? ''}'.trim()));
      }

      final dateTime = exifData!['EXIF DateTimeOriginal']?.printable ??
          exifData!['Image DateTime']?.printable;
      if (dateTime != null) {
        items.add(_buildInfoRow(Icons.calendar_today, dateTime));
      }

      final width = exifData!['EXIF ExifImageWidth']?.printable ??
          exifData!['Image ImageWidth']?.printable;
      final height = exifData!['EXIF ExifImageLength']?.printable ??
          exifData!['Image ImageLength']?.printable;
      if (width != null && height != null) {
        items.add(_buildInfoRow(Icons.aspect_ratio, '$width × $height'));
      }

      final exposure = exifData!['EXIF ExposureTime']?.printable;
      final fNumber = exifData!['EXIF FNumber']?.printable;
      final iso = exifData!['EXIF ISOSpeedRatings']?.printable;
      if (exposure != null || fNumber != null || iso != null) {
        final settings = [
          if (exposure != null) exposure,
          if (fNumber != null) 'f/$fNumber',
          if (iso != null) 'ISO $iso',
        ].join('  ');
        items.add(_buildInfoRow(Icons.settings, settings));
      }
    }

    if (items.isEmpty) {
      return Text(
        AppLocalizations.of(context)?.txt_media_no_exif ?? 'No EXIF data available',
        style: const TextStyle(color: Colors.white54, fontSize: 14),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items,
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
