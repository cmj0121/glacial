// Adaptive tab bar with glassmorphism support.
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:glacial/cores/platform.dart';
import 'package:glacial/cores/screens/glass_style.dart';

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

// vim: set ts=2 sw=2 sts=2 et:
