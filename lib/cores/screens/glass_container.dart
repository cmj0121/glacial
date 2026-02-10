// Adaptive container with glassmorphism support.
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:glacial/cores/platform.dart';
import 'package:glacial/cores/screens/glass_style.dart';

/// Adaptive container that uses glassmorphism on Apple platforms
/// and a styled Container on Android/other platforms.
class AdaptiveGlassContainer extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? color;

  const AdaptiveGlassContainer({
    super.key,
    this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = borderRadius ?? BorderRadius.circular(GlassStyle.borderRadius);

    if (useLiquidGlass) {
      return Container(
        width: width,
        height: height,
        margin: margin,
        child: ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: GlassStyle.blurSigma,
              sigmaY: GlassStyle.blurSigma,
            ),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: (color ?? Theme.of(context).colorScheme.surface)
                    .withValues(alpha: GlassStyle.opacity),
                borderRadius: radius,
                border: Border.all(
                  color: Colors.white.withValues(alpha: GlassStyle.borderOpacity),
                  width: 1.5,
                ),
              ),
              child: child,
            ),
          ),
        ),
      );
    }

    return Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: radius,
      ),
      child: child,
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
