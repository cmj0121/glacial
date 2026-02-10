// Adaptive card with glassmorphism support.
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:glacial/cores/platform.dart';
import 'package:glacial/cores/screens/glass_style.dart';

/// Adaptive card that uses glassmorphism on Apple platforms
/// and a Material Card on Android/other platforms.
class AdaptiveGlassCard extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  const AdaptiveGlassCard({
    super.key,
    this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = borderRadius ?? BorderRadius.circular(12);

    if (useLiquidGlass) {
      return Container(
        margin: margin,
        child: ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: GlassStyle.blurSigma,
              sigmaY: GlassStyle.blurSigma,
            ),
            child: Material(
              color: Theme.of(context).colorScheme.surface
                  .withValues(alpha: GlassStyle.opacity),
              borderRadius: radius,
              child: InkWell(
                onTap: onTap,
                borderRadius: radius,
                child: Container(
                  padding: padding,
                  decoration: BoxDecoration(
                    borderRadius: radius,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: GlassStyle.borderOpacity),
                      width: 1,
                    ),
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      margin: margin?.resolve(TextDirection.ltr),
      shape: RoundedRectangleBorder(borderRadius: radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      ),
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
