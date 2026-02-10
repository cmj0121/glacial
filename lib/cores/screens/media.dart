// The media widget library for hero, gallery, and viewer.
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'package:glacial/cores/screens/animations.dart';
import 'package:glacial/cores/screens/misc.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/timeline/models/core.dart';
import 'package:glacial/l10n/app_localizations.dart';

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
        return MediaViewer(
          onDismiss: () => Navigator.of(context).maybePop(),
          onZoomChanged: onZoomChanged,
          onDragUpdate: onDragUpdate,
          onDragEnd: onDragEnd,
          child: buildMediaContent(schema),
        );
      },
    );
  }

  Widget buildMediaContent(AttachmentSchema schema) {
    switch (schema.type) {
      case MediaType.image:
      case MediaType.gifv:
        return CachedNetworkImage(
          imageUrl: schema.url,
          fit: BoxFit.contain,
          placeholder: (context, url) => const Center(
            child: ClockProgressIndicator(),
          ),
          errorWidget: (context, url, error) => const Icon(
            Icons.error,
            color: Colors.white,
          ),
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
              const Center(child: ClockProgressIndicator())
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

// The media viewer that can be used to show the media content in the app.
class MediaViewer extends StatefulWidget {
  final Widget child;
  final VoidCallback? onDismiss;
  final ValueChanged<bool>? onZoomChanged;
  final ValueChanged<double>? onDragUpdate;
  final VoidCallback? onDragEnd;

  const MediaViewer({
    super.key,
    required this.child,
    this.onDismiss,
    this.onZoomChanged,
    this.onDragUpdate,
    this.onDragEnd,
  });

  @override
  State<MediaViewer> createState() => _MediaViewerState();
}

class _MediaViewerState extends State<MediaViewer> with SingleTickerProviderStateMixin {
  final TransformationController controller = TransformationController();

  late AnimationController animationController;
  late Animation<Offset> offsetAnimation;

  Offset offset = Offset.zero;
  bool isDismissed = false;

  // Dismiss thresholds
  static const double distanceThreshold = 0.18; // 18% of screen height
  static const double velocityThreshold = 800.0; // pixels per second

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller for the dismiss animation.
    final Duration duration = const Duration(milliseconds: 300);
    animationController = AnimationController(vsync: this, duration: duration);

    offsetAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeInOut)
    )
        ..addListener(() => setState(() {}));

    animationController.addStatusListener((state) {
      if (state == AnimationStatus.completed) {
        // When the animation is completed, pop the media viewer.
        offset = Offset.zero;
      }
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ValueListenableBuilder(
        valueListenable: controller,
        builder: (context, Matrix4 value, child) {
          // Notify parent about zoom state changes
          final bool currentZoomed = value != Matrix4.identity();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onZoomChanged?.call(currentZoomed);
          });
          return buildContent();
        },
      ),
    );
  }

  // Build the interactive content of the media viewer and control the zoom and pan.
  Widget buildContent() {
    final bool isZoomed = controller.value != Matrix4.identity();

    return GestureDetector(
      onVerticalDragUpdate: isZoomed ? null : (details) {
        setState(() => offset += Offset(0, details.delta.dy));
        widget.onDragUpdate?.call(offset.dy);
      },
      onVerticalDragEnd: isZoomed ? null : (details) {
        final screenHeight = MediaQuery.of(context).size.height;
        final velocity = details.velocity.pixelsPerSecond.dy;

        // Dismiss if dragged past threshold OR velocity exceeds threshold
        final bool shouldDismiss =
            offset.dy.abs() > distanceThreshold * screenHeight ||
            velocity.abs() > velocityThreshold;

        if (shouldDismiss) {
          onDismiss();
          return;
        }

        widget.onDragEnd?.call();

        offsetAnimation = Tween<Offset>(begin: offset, end: Offset.zero).animate(
          CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
        );

        animationController.reset();
        animationController.forward();
      },
      onDoubleTap: () => controller.value = Matrix4.identity(),
      child: buildLayout(),
    );
  }

  // Build the core layout of the media viewer that show the media content and the close button.
  Widget buildLayout() {
    // When used in gallery mode, the gallery handles the close button
    final bool showCloseButton = widget.onDismiss == null;

    return Stack(
      alignment: Alignment.topCenter,
      fit: StackFit.expand,
      children: [
        Transform.translate(
          offset: offset,
          child: buildMedia(),
        ),
        if (showCloseButton)
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: Icon(Icons.close, color: Theme.of(context).colorScheme.error),
              onPressed: onDismiss,
            ),
          ),
      ],
    );
  }

  // Build the interactive media content that can be zoomed and panned.
  Widget buildMedia() {
    return InteractiveViewer(
      transformationController: controller,
      panEnabled: true,
      scaleEnabled: true,
      child: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.contain,
          child: isZoomed ? widget.child : ClipRRect(
            borderRadius: BorderRadius.circular(18.0),
            child: widget.child,
          ),
        ),
      ),
    );
  }

  // The callback function to handle the dismiss action of the media viewer.
  void onDismiss() {
    if (widget.onDismiss != null) {
      widget.onDismiss!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  bool get isZoomed => controller.value != Matrix4.identity();
}

// vim: set ts=2 sw=2 sts=2 et:
