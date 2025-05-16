// The Glacial core application
import 'dart:math';
import 'package:flutter/material.dart';

import 'package:glacial/core.dart';
import 'package:glacial/routes.dart';

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
  late final AnimationController controller;
  late final Animation<double> animation;

  bool flipX = true;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(duration: widget.duration, vsync: this)
      ..repeat(reverse: true);

    animation = Tween<double>(begin: 0, end: pi).animate(CurvedAnimation(
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
      body: SafeArea(
        child: Center(
          child: buildContent(),
        ),
      ),
    );
  }

  Widget buildContent() {
    final Widget image = Image.asset('assets/images/logo.png');
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
    await Future.delayed(const Duration(milliseconds: 2000));

    if (mounted) {
      logger.i("completely preloaded ...");
      context.go(RoutePath.home.path);
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
