// The miscellaneous widget library of the app.
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:glacial/cores/screens/animations.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/timeline/models/core.dart';

// The placeholder for the app's Work-In-Progress screen
class WIP extends StatelessWidget {
  final String? title;

  const WIP({
    super.key,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle? titleStyle = Theme.of(context).textTheme.headlineLarge;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Text(title ?? "Work in Progress", style: titleStyle),
        ),
      ),
    );
  }
}

// The InkWell wrapper that is no any animation and color.
class InkWellDone extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;

  const InkWellDone({
    super.key,
    required this.child,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      child: child,
    );
  }
}

// The customize HTML render
class HtmlDone extends StatelessWidget {
  final String html;
  final List<EmojiSchema> emojis;
  final OnTap? onLinkTap;

  const HtmlDone({
    super.key,
    required this.html,
    this.emojis = const [],
    this.onLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    return Html(
      data: EmojiSchema.replaceEmojiToHTML(html, emojis: emojis),
      style: {
        'a': Style(
          color: Theme.of(context).colorScheme.secondary,
          textDecoration: TextDecoration.underline,
        ),
        'blockquote': Style(
          color: Theme.of(context).colorScheme.secondary,
          padding: HtmlPaddings(left: HtmlPadding(8)),
          textAlign: TextAlign.justify,
          border: Border(
            left: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 2,
            ),
          ),
        ),
        'p': Style(
          whiteSpace: WhiteSpace.pre,
        ),
      },
      onLinkTap: onLinkTap,
    );
  }
}

// The widget to show the search result is empty, and show the
// message to the user.
class NoResult extends StatelessWidget {
  final String message;
  final double size;
  final IconData icon;

  const NoResult({
    super.key,
    this.message = "",
    this.size = 64,
    this.icon = Icons.sentiment_dissatisfied_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: buildContent(context),
      ),
    );
  }

  Widget buildContent(BuildContext context) {
    final Color color = Theme.of(context).colorScheme.secondary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: size, color: color),
        const SizedBox(height: 8),
        Text(message, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: backgroundOpacity),
      body: SafeArea(
        child: Stack(
          children: [
            buildPageView(),
            buildCloseButton(),
            if (widget.schemas.length > 1) buildPageIndicator(),
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
      onPageChanged: (index) => setState(() => currentIndex = index),
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

  Widget buildCloseButton() {
    return Positioned(
      top: 8,
      right: 8,
      child: IconButton(
        icon: const Icon(Icons.close, color: Colors.white),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
    );
  }

  Widget buildPageIndicator() {
    return Positioned(
      bottom: 24,
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
  double threshold = 0.18; // 20% of the screen height

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

        if (offset.dy.abs() > threshold * screenHeight) {
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

// The pop-up TextField for the RWD and show the dialog with the TextField if screen is small.
class PopUpTextField extends StatefulWidget {
  final bool isHTML;
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final TextStyle? style;
  final InputDecoration decoration;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const PopUpTextField({
    super.key,
    this.isHTML = false,
    this.focusNode,
    this.controller,
    this.style,
    this.decoration = const InputDecoration(),
    this.onChanged,
    this.onSubmitted,
  });

  @override
  State<PopUpTextField> createState() => _PopUpTextFieldState();
}

class _PopUpTextFieldState extends State<PopUpTextField> {
  late String text = widget.controller?.text ?? "";

  @override
  Widget build(BuildContext context) {
    return InkWellDone(
      onTap: () => onPopUp(),
      child: Align(
        alignment: Alignment.centerLeft,
        child: widget.isHTML ?
          HtmlDone(html: text) :
          Text(
            text,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface).merge(widget.style),
          ),
      ),
    );
  }

  Widget buildPopUpTextField() {
    return Focus(
      autofocus: true,
      onFocusChange: (hasFocus) {
        if (!hasFocus) {
          setState(() => text = widget.controller?.text ?? "");
          widget.onSubmitted?.call(widget.controller?.text ?? "");
        }
      },
      child: TextField(
        minLines: 10,
        maxLines: 20,
        focusNode: widget.focusNode,
        controller: widget.controller,
        decoration: const InputDecoration(border: OutlineInputBorder()),
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
      ),
    );
  }

  void onPopUp() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: buildPopUpTextField(),
        ),
      ),
    );
  }
}

/// Mixin for paginated list state management.
///
/// Provides common state variables and helper methods for screens that display
/// paginated lists with loading, refresh, and completion states.
///
/// Example usage:
/// ```dart
/// class _MyListState extends State<MyList> with PaginatedListMixin {
///   List<MyItem> items = [];
///
///   Future<void> onLoad() async {
///     if (shouldSkipLoad) return;
///     setLoading(true);
///
///     final newItems = await api.fetchItems(offset: items.length);
///     if (mounted) {
///       setState(() => items.addAll(newItems));
///       markLoadComplete(isEmpty: newItems.isEmpty);
///     }
///   }
///
///   Future<void> onRefresh() => refreshList(onLoad);
/// }
/// ```
mixin PaginatedListMixin<T extends StatefulWidget> on State<T> {
  bool _isRefresh = false;
  bool _isLoading = false;
  bool _isCompleted = false;

  /// Whether the list is currently being refreshed (pull-to-refresh).
  bool get isRefresh => _isRefresh;

  /// Whether the list is currently loading more items.
  bool get isLoading => _isLoading;

  /// Whether all items have been loaded (no more pages).
  bool get isCompleted => _isCompleted;

  /// Returns true if loading should be skipped (already loading or completed).
  bool get shouldSkipLoad => _isLoading || _isCompleted;

  /// Sets the loading state. Call this at the start of a load operation.
  void setLoading(bool value) {
    if (mounted) setState(() => _isLoading = value);
  }

  /// Marks the load operation as complete.
  /// [isEmpty] should be true if no new items were loaded, indicating end of list.
  void markLoadComplete({required bool isEmpty}) {
    if (mounted) {
      setState(() {
        _isRefresh = false;
        _isLoading = false;
        _isCompleted = isEmpty;
      });
    }
  }

  /// Resets state for a refresh operation and calls the provided load function.
  /// Use this for pull-to-refresh functionality.
  Future<void> refreshList(Future<void> Function() loadFunction) async {
    setState(() {
      _isRefresh = true;
      _isLoading = false;
      _isCompleted = false;
    });

    await loadFunction();
  }

  /// Resets all pagination state. Call this when the list needs to be cleared.
  void resetPagination() {
    _isRefresh = false;
    _isLoading = false;
    _isCompleted = false;
  }

  /// Builds the loading indicator widget.
  /// Shows ClockProgressIndicator when loading (but not during pull-to-refresh).
  Widget buildLoadingIndicator() {
    return (_isLoading && !_isRefresh)
        ? const ClockProgressIndicator()
        : const SizedBox.shrink();
  }
}

// vim: set ts=2 sw=2 sts=2 et:
