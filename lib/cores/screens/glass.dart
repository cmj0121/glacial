// Adaptive Liquid Glass widgets for iOS 26+ support.
//
// These widgets automatically switch between Liquid Glass design on Apple
// platforms (iOS/macOS) and Material Design on Android/other platforms.
//
// Uses Flutter's BackdropFilter for stable glassmorphism effects.
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:glacial/cores/platform.dart';

/// Glass effect configuration for consistent styling.
class GlassStyle {
  static const double blurSigma = 20.0;
  static const double opacity = 0.7;
  static const double borderOpacity = 0.2;
  static const double borderRadius = 16.0;
}

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
      margin: margin as EdgeInsets?,
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

/// Adaptive app bar that uses glassmorphism on Apple platforms
/// and a Material AppBar on Android/other platforms.
class AdaptiveGlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leading;
  final Widget? title;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;

  const AdaptiveGlassAppBar({
    super.key,
    this.leading,
    this.title,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

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
            decoration: BoxDecoration(
              color: (backgroundColor ?? Theme.of(context).colorScheme.surface)
                  .withValues(alpha: GlassStyle.opacity),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: GlassStyle.borderOpacity),
                  width: 0.5,
                ),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: kToolbarHeight,
                child: NavigationToolbar(
                  leading: leading ?? (automaticallyImplyLeading && Navigator.of(context).canPop()
                      ? AdaptiveGlassIconButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          onPressed: () => Navigator.of(context).pop(),
                        )
                      : null),
                  middle: title,
                  trailing: actions != null
                      ? Row(mainAxisSize: MainAxisSize.min, children: actions!)
                      : null,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return AppBar(
      leading: leading,
      title: title,
      actions: actions,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: backgroundColor,
    );
  }
}

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

/// Adaptive tab bar that uses glassmorphism on Apple platforms
/// and a styled container on Android/other platforms.
class AdaptiveGlassTabBar extends StatelessWidget {
  final List<Widget> tabs;
  final int selectedIndex;
  final ValueChanged<int>? onTabSelected;

  const AdaptiveGlassTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (useLiquidGlass) {
      return ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface
                  .withValues(alpha: GlassStyle.opacity),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: GlassStyle.borderOpacity),
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: List.generate(tabs.length, (index) {
                final bool isSelected = index == selectedIndex;
                return Expanded(
                  child: InkWell(
                    onTap: () => onTabSelected?.call(index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          child: tabs[index],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      );
    }

    // Material fallback
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final bool isSelected = index == selectedIndex;
          return Expanded(
            child: InkWell(
              onTap: () => onTabSelected?.call(index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Center(child: tabs[index]),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Shows an adaptive modal bottom sheet with glassmorphism on Apple
/// platforms and a Material bottom sheet on Android/other platforms.
Future<T?> showAdaptiveGlassSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isDismissible = true,
  bool enableDrag = true,
  bool isScrollControlled = false,
}) {
  if (useLiquidGlass) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: GlassStyle.blurSigma,
            sigmaY: GlassStyle.blurSigma,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface
                  .withValues(alpha: GlassStyle.opacity),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              border: Border.all(
                color: Colors.white.withValues(alpha: GlassStyle.borderOpacity),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Flexible(child: builder(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  return showModalBottomSheet<T>(
    context: context,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    isScrollControlled: isScrollControlled,
    builder: builder,
  );
}

/// Shows an adaptive dialog with glassmorphism on Apple platforms
/// and a Material AlertDialog on Android/other platforms.
Future<T?> showAdaptiveGlassDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  String? title,
  List<Widget>? actions,
  bool barrierDismissible = true,
}) {
  if (useLiquidGlass) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: GlassStyle.blurSigma,
              sigmaY: GlassStyle.blurSigma,
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface
                    .withValues(alpha: GlassStyle.opacity),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: GlassStyle.borderOpacity),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null) ...[
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                  ],
                  builder(context),
                  if (actions != null) ...[
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: actions,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) => AlertDialog(
      title: title != null ? Text(title) : null,
      content: builder(context),
      actions: actions,
    ),
  );
}

// vim: set ts=2 sw=2 sts=2 et:
