// The animations widget library for the app.
import 'dart:math';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

// The arc-style progress indicator for indeterminate loading states.
class ClockProgressIndicator extends StatefulWidget {
  final double size;
  final Duration duration;
  final Color? color;
  final double strokeWidth;

  const ClockProgressIndicator({
    super.key,
    this.size = 32.0,
    this.duration = const Duration(milliseconds: 1200),
    this.color,
    this.strokeWidth = 3.0,
  });

  const ClockProgressIndicator.small({
    super.key,
    this.color,
    this.duration = const Duration(milliseconds: 1200),
  }) : size = 20.0,
       strokeWidth = 2.0;

  const ClockProgressIndicator.medium({
    super.key,
    this.color,
    this.duration = const Duration(milliseconds: 1200),
  }) : size = 32.0,
       strokeWidth = 3.0;

  const ClockProgressIndicator.large({
    super.key,
    this.color,
    this.duration = const Duration(milliseconds: 1200),
  }) : size = 48.0,
       strokeWidth = 3.5;

  // Pull-to-refresh indicator builder for [CustomMaterialIndicator].
  // Fades in and scales up with pull progress, then spins at full size while loading.
  static Widget refreshBuilder(BuildContext context, IndicatorController controller) {
    bool didTriggerHaptic = false;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final double progress = controller.value.clamp(0.0, 1.0);

        if (progress >= 1.0 && !didTriggerHaptic) {
          didTriggerHaptic = true;
          HapticFeedback.mediumImpact();
        } else if (progress < 1.0) {
          didTriggerHaptic = false;
        }

        return Opacity(
          opacity: progress,
          child: Transform.scale(
            scale: 0.5 + progress * 0.5,
            child: child,
          ),
        );
      },
      child: ClockProgressIndicator(
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  @override
  State<ClockProgressIndicator> createState() => _ClockProgressIndicatorState();
}

class _ClockProgressIndicatorState extends State<ClockProgressIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color color = widget.color ?? Theme.of(context).colorScheme.primary;

    return Center(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _ClockSpinnerPainter(
            animation: _controller,
            color: color,
            strokeWidth: widget.strokeWidth,
          ),
        ),
      ),
    );
  }
}

/// Clock-style spinner — a thin circle face with a single hand that
/// rotates clockwise like a second hand. Calm and minimal.
///
/// Uses [repaint: animation] so it repaints every frame without
/// rebuilding the widget tree.
class _ClockSpinnerPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;
  final double strokeWidth;

  _ClockSpinnerPainter({
    required this.animation,
    required this.color,
    required this.strokeWidth,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double radius = (size.width - strokeWidth) / 2;
    final double angle = animation.value * 2 * pi - pi / 2; // start at 12 o'clock

    // Clock face — thin circle.
    final Paint facePaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(cx, cy), radius, facePaint);

    // Hour markers — 4 small dots at 12, 3, 6, 9.
    final Paint dotPaint = Paint()..color = color.withValues(alpha: 0.25);
    final double dotRadius = strokeWidth * 0.6;
    for (int i = 0; i < 4; i++) {
      final double a = i * pi / 2 - pi / 2;
      canvas.drawCircle(
        Offset(cx + radius * cos(a), cy + radius * sin(a)),
        dotRadius,
        dotPaint,
      );
    }

    // Center dot.
    canvas.drawCircle(
      Offset(cx, cy),
      strokeWidth * 0.8,
      Paint()..color = color,
    );

    // Hand — line from center to ~80% of radius.
    final double handLength = radius * 0.78;
    final Paint handPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx + handLength * cos(angle), cy + handLength * sin(angle)),
      handPaint,
    );
  }

  @override
  bool shouldRepaint(_ClockSpinnerPainter oldDelegate) =>
      color != oldDelegate.color || strokeWidth != oldDelegate.strokeWidth;
}

// vim: set ts=2 sw=2 sts=2 et:
