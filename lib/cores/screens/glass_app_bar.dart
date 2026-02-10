// Adaptive app bar with glassmorphism support.
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:glacial/cores/platform.dart';
import 'package:glacial/cores/screens/glass_button.dart';
import 'package:glacial/cores/screens/glass_style.dart';

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

// vim: set ts=2 sw=2 sts=2 et:
