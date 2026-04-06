// The customized tab bar with an animated indicator painted directly on
// canvas. Uses CustomPainter with repaint: animation so the indicator
// repaints without rebuilding the widget tree — no LayoutBuilder, no
// build-scope conflicts with concurrent page animations.
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:glacial/core.dart';

class SwipeTabBar extends StatefulWidget {
  final int itemCount;
  final IndexedWidgetBuilder tabBuilder;
  final TabController? controller;
  final bool Function(int)? onTabTappable;
  final VoidCallback? onDoubleTap;

  const SwipeTabBar({
    super.key,
    required this.itemCount,
    required this.tabBuilder,
    this.controller,
    this.onTabTappable,
    this.onDoubleTap,
  });

  @override
  State<SwipeTabBar> createState() => _SwipeTabBarState();
}

class _SwipeTabBarState extends State<SwipeTabBar> with TickerProviderStateMixin {
  late final AnimationController controller;

  late Animation<double> animation;
  late int selectedIndex;

  @override
  void initState() {
    super.initState();

    selectedIndex = widget.controller?.index ?? 0;
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    animation = Tween<double>(begin: selectedIndex.toDouble(), end: 0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );

    widget.controller?.addListener(_onExternalTabChange);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onExternalTabChange);
    controller.dispose();
    super.dispose();
  }

  void _onExternalTabChange() {
    final int newIndex = widget.controller!.index;
    if (newIndex == selectedIndex) {
      // Index didn't change (e.g. indexIsChanging became false after
      // animation completed). Rebuild for tab icon highlight update.
      if (!widget.controller!.indexIsChanging && mounted) setState(() {});
      return;
    }

    // Animate the indicator to the new position. CustomPainter repaints
    // via repaint: animation so no AnimatedBuilder needed.
    animation = Tween<double>(begin: animation.value, end: newIndex.toDouble()).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );
    selectedIndex = newIndex;
    controller.forward(from: 0);

    // Rebuild tab icons so isSelected highlight updates immediately.
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    final Widget content = CustomPaint(
      foregroundPainter: _IndicatorPainter(
        animation: animation,
        itemCount: widget.itemCount,
        color: scheme.primary,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildBar(),
          const SizedBox(height: 4),
        ],
      ),
    );

    if (useLiquidGlass) {
      return ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: ColoredBox(
            color: scheme.surface.withValues(alpha: GlassStyle.opacity),
            child: content,
          ),
        ),
      );
    }

    return ColoredBox(
      color: scheme.surface,
      child: content,
    );
  }

  Widget _buildBar() {
    return Row(
      children: List.generate(widget.itemCount, (index) {
        final bool isClickable = widget.onTabTappable?.call(index) ?? true;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: InkWellDone(
              onTap: isClickable ? () => _onTabTap(index) : null,
              onDoubleTap: isClickable ? widget.onDoubleTap : null,
              child: widget.tabBuilder(context, index),
            ),
          ),
        );
      }),
    );
  }

  void _onTabTap(int index) {
    if (index == selectedIndex) return;

    setState(() {
      animation = Tween<double>(begin: animation.value, end: index.toDouble()).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
      selectedIndex = index;
      controller.forward(from: 0);
    });
    widget.controller?.animateTo(index);
  }
}

/// Paints the tab indicator at the bottom. Listens to the animation via
/// [repaint] so it repaints on every tick without any widget rebuild.
class _IndicatorPainter extends CustomPainter {
  final Animation<double> animation;
  final int itemCount;
  final Color color;

  _IndicatorPainter({
    required this.animation,
    required this.itemCount,
    required this.color,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    if (itemCount <= 0) return;
    final double tabWidth = size.width / itemCount;
    final double left = tabWidth * animation.value;
    final RRect rect = RRect.fromLTRBR(
      left,
      size.height - 4,
      left + tabWidth,
      size.height,
      const Radius.circular(2),
    );
    canvas.drawRRect(rect, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_IndicatorPainter old) =>
      color != old.color || itemCount != old.itemCount;
}

// vim: set ts=2 sw=2 sts=2 et:
