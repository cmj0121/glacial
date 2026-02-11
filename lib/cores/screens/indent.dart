// The indent wrapper widget to show the indent of the content.
import 'package:flutter/material.dart';

class Indent extends StatelessWidget {
  final int indent;
  final Widget child;
  final double width;
  final EdgeInsetsGeometry padding;

  const Indent({
    super.key,
    required this.indent,
    required this.child,
    this.width = 4.0,
    this.padding = const EdgeInsets.only(left: 18.0),
  });

  @override
  Widget build(BuildContext context) {
    switch (indent) {
    case 0:
      return child;
    case 1:
      return buildContent(context);
    default:
      return Indent(indent: indent - 1, child: buildContent(context));
    }
  }

  Widget buildContent(BuildContext context) {
    return Padding(
      padding: padding,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: Theme.of(context).dividerColor,
              width: width,
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: width),
          child: child,
        ),
      ),
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
