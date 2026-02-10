// Adaptive buttons with glassmorphism support.
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:glacial/cores/platform.dart';

/// Adaptive button that uses glassmorphism on Apple platforms
/// and a Material button on Android/other platforms.
class AdaptiveGlassButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool filled;
  final EdgeInsetsGeometry? padding;

  const AdaptiveGlassButton({
    super.key,
    required this.child,
    this.onPressed,
    this.filled = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (useLiquidGlass) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: filled
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.8)
                : Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: DefaultTextStyle(
                  style: TextStyle(
                    color: filled
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (filled) {
      return FilledButton(
        onPressed: onPressed,
        child: child,
      );
    }

    return TextButton(
      onPressed: onPressed,
      child: child,
    );
  }
}

/// Adaptive icon button that uses glassmorphism on Apple platforms
/// and a Material IconButton on Android/other platforms.
class AdaptiveGlassIconButton extends StatelessWidget {
  final IconData icon;
  final double? size;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color;

  const AdaptiveGlassIconButton({
    super.key,
    required this.icon,
    this.size,
    this.onPressed,
    this.tooltip,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final Widget button = useLiquidGlass
        ? ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Material(
                color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.4),
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: onPressed,
                  customBorder: const CircleBorder(),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      icon,
                      size: size,
                      color: color ?? Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),
          )
        : IconButton(
            icon: Icon(icon, size: size, color: color),
            onPressed: onPressed,
          );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }

    return button;
  }
}

// vim: set ts=2 sw=2 sts=2 et:
