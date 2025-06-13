// The Status widget to show the toots from user.
import 'package:flutter/material.dart';

import 'package:glacial/features/timeline/models/core.dart';

// The icon of the status' visibility type.
class StatusVisibility extends StatelessWidget {
  final VisibilityType type;
  final double size;
  final bool isCompact;

  const StatusVisibility({
    super.key,
    required this.type,
    this.size = 16,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = Theme.of(context).colorScheme.onSurfaceVariant;

    if (isCompact) {
      return Tooltip(
        message: type.tooltip(context),
        child: Icon(type.icon(), size: size, color: color),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(type.icon(), size: size, color: color),
        const SizedBox(width: 8),
        Text(type.tooltip(context), style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontSize: size,
          fontWeight: FontWeight.bold,
        )),
      ],
    );
  }
}

// The dropdown button to select the status' visibility type.
class VisibilitySelector extends StatefulWidget {
  final double height;
  final double width;
  final VisibilityType? type;
  final ValueChanged<VisibilityType>? onChanged;

  const VisibilitySelector({
    super.key,
    this.height = 32,
    this.width = 120,
    this.type,
    this.onChanged,
  });

  @override
  State<VisibilitySelector> createState() => _VisibilitySelectorState();
}

class _VisibilitySelectorState extends State<VisibilitySelector> {
  late VisibilityType type;

  @override
  void initState() {
    super.initState();
    type = widget.type ?? VisibilityType.public;
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: widget.height,
        maxWidth: widget.width,
      ),
      child: buildContent(),
    );
  }

  Widget buildContent() {
    return DropdownButtonHideUnderline(
      child: DropdownButton<VisibilityType>(
        value: type,
        padding: const EdgeInsets.all(0),
        borderRadius: BorderRadius.circular(8),
        focusColor: Colors.transparent,
        icon: const SizedBox.shrink(),
        items: VisibilityType.values.map((VisibilityType value) {
          return DropdownMenuItem<VisibilityType>(
            value: value,
            child: StatusVisibility(type: value),
          );
        }).toList(),
        onChanged: (VisibilityType? newValue) {
          if (newValue != null) {
            setState(() {
              type = newValue;
            });
            widget.onChanged?.call(newValue);
          }
        },
      ),
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
