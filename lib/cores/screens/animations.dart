// The animations widget library for the app.
import 'dart:math';
import 'package:flutter/material.dart';

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

// The clock-like progress indicator which shows the progress of the task.
class ClockProgressIndicator extends StatefulWidget {
  final double size;
  final double barHeight;
  final double barWidth;
  final Duration duration;
  final Color? color;

  const ClockProgressIndicator({
    super.key,
    this.size = 40.0,
    this.barHeight = 10.0,
    this.barWidth = 3.75,
    this.duration = const Duration(milliseconds: 650),
    this.color,
  });

  @override
  State<ClockProgressIndicator> createState() => _ClockProgressIndicatorState();
}

class _ClockProgressIndicatorState extends State<ClockProgressIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();

    animation = Tween<double>(begin: 0, end: 1).animate(controller);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 18.0),
        child: buildContent(),
      ),
    );
  }

  Widget buildContent() {
    return SizedBox(
      width: widget.size * 2,
      height: widget.size * 2,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) => buildClockBar(),
      ),
    );
  }

  Widget buildClockBar() {
    final Color color = widget.color ?? Theme.of(context).colorScheme.secondary;

    return Stack(
      children: List.generate(12, (index) {
        final double angle = (2 * pi / 12) * index;
        final double radius = widget.size / 2;

        final double x = radius + radius * 0.8 * cos(angle);
        final double y = radius + radius * 0.8 * sin(angle);
        final double progress = ((animation.value * 12) - index) % 12 / 12;
        final Color barColor = color.withValues(alpha: progress);

        return Positioned(
          left: x - 2,
          top: y - 2,
          child: Transform.rotate(
            angle: angle + pi / 2,
            child: Container(
              width: widget.barWidth,
              height: widget.barHeight,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(widget.barWidth / 2),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
