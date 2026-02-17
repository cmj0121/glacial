// The animations widget library for the app.
import 'dart:math';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
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
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final double progress = controller.value.clamp(0.0, 1.0);
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
    with TickerProviderStateMixin {
  late final AnimationController _rotationController;
  late final AnimationController _sweepController;
  late final CurvedAnimation _sweepAnimation;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();

    _sweepController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.duration.inMilliseconds ~/ 2),
    )..repeat(reverse: true);

    _sweepAnimation = CurvedAnimation(
      parent: _sweepController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _sweepAnimation.dispose();
    _rotationController.dispose();
    _sweepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color color = widget.color ?? Theme.of(context).colorScheme.secondary;

    return Center(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: Listenable.merge([_rotationController, _sweepAnimation]),
          builder: (context, child) {
            return CustomPaint(
              painter: _ArcSpinnerPainter(
                rotation: _rotationController.value,
                sweep: _sweepAnimation.value,
                color: color,
                strokeWidth: widget.strokeWidth,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ArcSpinnerPainter extends CustomPainter {
  final double rotation;
  final double sweep;
  final Color color;
  final double strokeWidth;

  _ArcSpinnerPainter({
    required this.rotation,
    required this.sweep,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Rect arcRect = (Offset.zero & size).deflate(strokeWidth / 2);
    final double startAngle = rotation * 2 * pi;
    final double sweepAngle = 0.5 + sweep * 2.0;

    canvas.drawArc(arcRect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(_ArcSpinnerPainter oldDelegate) {
    return rotation != oldDelegate.rotation ||
        sweep != oldDelegate.sweep ||
        color != oldDelegate.color ||
        strokeWidth != oldDelegate.strokeWidth;
  }
}

// vim: set ts=2 sw=2 sts=2 et:
