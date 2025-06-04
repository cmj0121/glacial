// The miscellaneous widget library of the app.
import 'dart:math';

import 'package:flutter/material.dart';


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
