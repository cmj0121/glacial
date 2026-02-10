// The content widget library for HTML rendering and pop-up text fields.
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:glacial/cores/screens/misc.dart';
import 'package:glacial/features/models.dart';

// The customize HTML render
class HtmlDone extends StatelessWidget {
  final String html;
  final List<EmojiSchema> emojis;
  final OnTap? onLinkTap;

  const HtmlDone({
    super.key,
    required this.html,
    this.emojis = const [],
    this.onLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    return Html(
      data: EmojiSchema.replaceEmojiToHTML(html, emojis: emojis),
      style: {
        'a': Style(
          color: Theme.of(context).colorScheme.secondary,
          textDecoration: TextDecoration.underline,
        ),
        'blockquote': Style(
          color: Theme.of(context).colorScheme.secondary,
          padding: HtmlPaddings(left: HtmlPadding(8)),
          textAlign: TextAlign.justify,
          border: Border(
            left: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 2,
            ),
          ),
        ),
        'p': Style(
          whiteSpace: WhiteSpace.pre,
        ),
      },
      onLinkTap: onLinkTap,
    );
  }
}

// The pop-up TextField for the RWD and show the dialog with the TextField if screen is small.
class PopUpTextField extends StatefulWidget {
  final bool isHTML;
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final TextStyle? style;
  final InputDecoration decoration;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const PopUpTextField({
    super.key,
    this.isHTML = false,
    this.focusNode,
    this.controller,
    this.style,
    this.decoration = const InputDecoration(),
    this.onChanged,
    this.onSubmitted,
  });

  @override
  State<PopUpTextField> createState() => _PopUpTextFieldState();
}

class _PopUpTextFieldState extends State<PopUpTextField> {
  late String text = widget.controller?.text ?? "";

  @override
  Widget build(BuildContext context) {
    return InkWellDone(
      onTap: () => onPopUp(),
      child: Align(
        alignment: Alignment.centerLeft,
        child: widget.isHTML ?
          HtmlDone(html: text) :
          Text(
            text,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface).merge(widget.style),
          ),
      ),
    );
  }

  Widget buildPopUpTextField() {
    return Focus(
      autofocus: true,
      onFocusChange: (hasFocus) {
        if (!hasFocus) {
          setState(() => text = widget.controller?.text ?? "");
          widget.onSubmitted?.call(widget.controller?.text ?? "");
        }
      },
      child: TextField(
        minLines: 10,
        maxLines: 20,
        focusNode: widget.focusNode,
        controller: widget.controller,
        decoration: const InputDecoration(border: OutlineInputBorder()),
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
      ),
    );
  }

  void onPopUp() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: buildPopUpTextField(),
        ),
      ),
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
