// Shimmer animation effect for skeleton loading placeholders.
import 'package:flutter/material.dart';

/// A shimmer effect widget that sweeps a translucent gradient over its child.
///
/// Used to indicate loading state on skeleton placeholder widgets.
class ShimmerEffect extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const ShimmerEffect({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect> with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: widget.duration)..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final double slide = controller.value * 2.0 - 0.5;
            return LinearGradient(
              begin: Alignment(slide - 0.5, 0),
              end: Alignment(slide + 0.5, 0),
              colors: [
                colors.surfaceContainerHighest,
                colors.surfaceContainerLow,
                colors.surfaceContainerHighest,
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
