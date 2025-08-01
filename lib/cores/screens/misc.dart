// The miscellaneous widget library of the app.
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:glacial/core.dart';

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
  final OnTap? onLinkTap;

  const HtmlDone({
    super.key,
    required this.html,
    this.onLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: Html(
        data: html,
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
      ),
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
class MediaViewer extends StatelessWidget {
  final Widget child;

  const MediaViewer({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: const Key('media-viewer'),
      direction: DismissDirection.vertical,
      child: Stack(
        alignment: Alignment.topRight,
        fit: StackFit.expand,
        children: [
           InteractiveViewer(
            panEnabled: true,
            scaleEnabled: true,
            child: SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.contain,
                child: child,
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface),
              onPressed: () => context.pop()
            ),
          ),
        ],
      ),
      onDismissed: (direction) => context.pop(),
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
