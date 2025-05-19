// The possible interactions of the timeline' status
import 'package:flutter/material.dart';

import 'package:glacial/features/timeline/models/core.dart';

class InteractionBar extends StatelessWidget {
  final StatusSchema schema;

  const InteractionBar({
    super.key,
    required this.schema,
  });

  @override
  Widget build(BuildContext context) {
    final List<StatusInteraction> actions = StatusInteraction.values;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.map((action) => Interaction(schema: schema, action: action)).toList(),
    );
  }
}

class Interaction extends StatefulWidget {
  final StatusSchema schema;
  final StatusInteraction action;

  const Interaction({
    super.key,
    required this.schema,
    required this.action,
  });

  @override
  State<Interaction> createState() => _InteractionState();
}

class _InteractionState extends State<Interaction> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(widget.action.icon),
      onPressed: widget.action.supportAnonymous ? () {} : null,
    );
  }
}


// vim: set ts=2 sw=2 sts=2 et:
