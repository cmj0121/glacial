// The miscellaneous widget library of the app.
import 'dart:math';
import 'package:flutter/material.dart';

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

// The flipping card widget that shows a front and back side.
class Flipping extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const Flipping({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  State<Flipping> createState() => _FlippingState();
}

class _FlippingState extends State<Flipping> with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> animation;

  bool flipX = true;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: widget.duration)
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
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Matrix4 transform = Matrix4.identity();
    transform.setEntry(3, 2, 0.001);
    flipX ? transform.rotateY(animation.value) : transform.rotateX(animation.value);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform(
          transform: transform,
          alignment: Alignment.center,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
