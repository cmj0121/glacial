// The miscellaneous widget library of the app.
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:glacial/features/models.dart';

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

  const MediaHero({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return InkWellDone(
      onTap: () {
        // Pop-up the media as full-screen and blur the background.
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) {
              return Center(
                child: Hero(
                  tag: 'media-hero',
                  child: MediaViewer(child: child),
                ),
              );
            },
          ),
        );
      },
      child: child,
    );
  }
}

// The media viewer that can be used to show the media content in the app.
class MediaViewer extends StatefulWidget {
  final Widget child;

  const MediaViewer({
    super.key,
    required this.child,
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
        builder: (context, Matrix4 value, child) => buildContent(),
      ),
    );
  }

  // Build the interactive content of the media viewer and control the zoom and pan.
  Widget buildContent() {
    final bool isZoomed = controller.value != Matrix4.identity();

    return GestureDetector(
      onVerticalDragUpdate: isZoomed ? null : (details) {
        setState(() => offset += Offset(0, details.delta.dy));
      },
      onVerticalDragEnd: isZoomed ? null : (details) {
        final screenHeight = MediaQuery.of(context).size.height;

        if (offset.dy.abs() > threshold * screenHeight) {
          onDismiss();
        }

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
    return Stack(
      alignment: Alignment.topCenter,
      fit: StackFit.expand,
      children: [
        Transform.translate(
          offset: offset,
          child: buildMedia(),
        ),
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
            borderRadius: BorderRadius.circular(8.0),
            child: widget.child,
          ),
        ),
      ),
    );
  }

  // The callback function to handle the dismiss action of the media viewer.
  void onDismiss() {
    // Reset the transformation controller when dismissing the media viewer.
    Navigator.of(context).maybePop();
  }

  bool get isZoomed => controller.value != Matrix4.identity();
}

// vim: set ts=2 sw=2 sts=2 et:
