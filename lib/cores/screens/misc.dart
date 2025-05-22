// The miscellaneous widget library of the app.
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/timeline/models/core.dart';


// The InkWell wrapper that is no any animation and color.
class InkWellDone extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;

  const InkWellDone({
    super.key,
    required this.child,
    this.onTap,
    this.onDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      child: child,
    );
  }
}

// The indent wrapper widget to show the indent of the content.
class Indent extends StatelessWidget {
  final int indent;
  final Widget child;
  final double size;

  const Indent({
    super.key,
    required this.indent,
    required this.child,
    this.size = 10,
  });

  @override
  Widget build(BuildContext context) {
    switch (indent) {
    case 0:
      return child;
    case 1:
      return buildContent(context);
    default:
      return Indent(indent: indent - 1, child: buildContent(context));
    }
  }

  Widget buildContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: size),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 2,
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: size),
          child: child,
        ),
      ),
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
        showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: buildHero(context),
            );
          },
        );
      },
      child: child,
    );
  }

  // The hero-like media with full-screen and blur the background.
  Widget buildHero(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: InkWellDone(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.transparent,
              ),
            ),
          ),
          Center(
            child: InteractiveViewer(
              child: child,
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
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
    final Storage storage = Storage();

    return Html(
      data: storage.replaceEmojiToHTML(html, emojis: emojis),
      style: {
        'a': Style(
          color: Theme.of(context).colorScheme.secondary,
          textDecoration: TextDecoration.underline,
        ),
      },
      onLinkTap: onLinkTap,
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
