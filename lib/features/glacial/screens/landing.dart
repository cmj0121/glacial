// The Landing page to show the app icon and flip it.
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:glacial/core.dart';

// The landing page that shows the icon of the app and flips intermittently.
class LandingPage extends StatefulWidget {
  final Duration duration;

  const LandingPage({
    super.key,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with SingleTickerProviderStateMixin {
  final Duration waitToPreload = const Duration(milliseconds: 1800);
  final int engineerModeClickThreshold = 5;

  late final AnimationController controller;
  late final Animation<double> animation;

  bool flipX = true;
  int clickCount = 0;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(duration: widget.duration, vsync: this)
      ..repeat(reverse: true);

    animation = Tween<double>(begin: 0, end: 2 * pi).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    ))
      ..addListener(() => setState(() {}))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          flipX = !flipX;
          controller.reset();
          controller.forward();
        }
      });

    controller.forward();
    preload();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildContent(),
    );
  }

  Widget buildContent() {
    return SafeArea(
      child: Center(
        child: InkWellDone(
          onTap: () => setState(() => clickCount++),
          child: buildIcon(),
        ),
      ),
    );
  }

  // Build the animation icon
  Widget buildIcon() {
    final Widget image = Image.asset('assets/images/icon.png');
    final Matrix4 transform = Matrix4.identity();
    transform.setEntry(3, 2, 0.001);
    flipX ? transform.rotateY(animation.value) : transform.rotateX(animation.value);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform(
          transform: transform,
          alignment: Alignment.center,
          child: image,
        );
      },
    );
  }

  // preload the necessary resources and navigate to the home page
  // if completed
  void preload() async {
    await Future.delayed(waitToPreload);
    logger.i('completed preloading, navigating to home page');

    if (mounted) {
      if (clickCount >= engineerModeClickThreshold) {
        logger.i("entering engineer mode ...");
        context.go(RoutePath.engineer.path);
        return;
      }

      final RoutePath route = RoutePath.explorer;
      logger.i("navigating to ${route.path} ...");
      context.go(route.path);
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
