// The media viewer widget with zoom, pan, and dismiss support.
import 'package:flutter/material.dart';

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
