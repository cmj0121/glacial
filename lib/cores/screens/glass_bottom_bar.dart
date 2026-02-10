// Adaptive bottom bar with glassmorphism support.
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:glacial/cores/platform.dart';
import 'package:glacial/cores/screens/glass_style.dart';

/// Adaptive bottom bar that uses glassmorphism on Apple platforms
/// and a Material BottomAppBar on Android/other platforms.
class AdaptiveGlassBottomBar extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const AdaptiveGlassBottomBar({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (useLiquidGlass) {
      return ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: GlassStyle.blurSigma,
            sigmaY: GlassStyle.blurSigma,
          ),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface
                  .withValues(alpha: GlassStyle.opacity),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: GlassStyle.borderOpacity),
                  width: 0.5,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: child,
            ),
          ),
        ),
      );
    }

    return BottomAppBar(
      padding: padding,
      child: child,
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
