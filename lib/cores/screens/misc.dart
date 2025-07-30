// The miscellaneous widget library of the app.
import 'package:flutter/material.dart';

// The placeholder for the app's Work-In-Progress screen
class WIP extends StatelessWidget {
  final String? title;

  const WIP({
    super.key,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle? titleStyle = Theme.of(context).textTheme.headlineLarge;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Text(title ?? "Work in Progress", style: titleStyle),
        ),
      ),
    );
  }
}

// The InkWell wrapper that is no any animation and color.
class InkWellDone extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;

  const InkWellDone({
    super.key,
    required this.child,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      child: child,
    );
  }
}

// The widget to show the search result is empty, and show the
// message to the user.
class NoResult extends StatelessWidget {
  final String message;
  final double size;
  final IconData icon;

  const NoResult({
    super.key,
    this.message = "",
    this.size = 64,
    this.icon = Icons.sentiment_dissatisfied_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: buildContent(context),
      ),
    );
  }

  Widget buildContent(BuildContext context) {
    final Color color = Theme.of(context).colorScheme.secondary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: size, color: color),
        const SizedBox(height: 8),
        Text(message, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
