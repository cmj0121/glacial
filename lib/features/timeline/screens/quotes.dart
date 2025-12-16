// The Quote widget to show the quoted status
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

class Quote extends ConsumerWidget {
  final QuoteSchema? schema;

  const Quote({super.key, required this.schema});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (schema == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: buildContent(context, ref),
    );
  }

  Widget buildContent(BuildContext context, WidgetRef ref) {
    if (schema?.quotedStatus == null) {
      return loadStatus(context, ref);
    }

    final Widget quote = StatusLite(schema: schema!.quotedStatus!, isNestedQuote: true);
    return buildQuote(context, quote);
  }

  Widget loadStatus(BuildContext context, WidgetRef ref) {
    final String? quotedStatusID = schema?.quotedStatusID;
    final AccessStatusSchema? status = ref.read(accessStatusProvider);

    if (quotedStatusID == null) {
      return buildNotFound(context);
    }

    return FutureBuilder(
      future: status?.getStatus(quotedStatusID),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        } else if (snapshot.hasError || snapshot.data == null) {
          return buildNotFound(context);
        } else {
          final StatusSchema? status = snapshot.data;
          final Widget? quote = status == null ? null : StatusLite(schema: status, isNestedQuote: true);
          return status == null ? buildNotFound(context) : buildQuote(context, quote!);
        }
      },
    );
  }

  Widget buildNotFound(BuildContext context) {
    // Mark the quote as unavailable.
    final String text = AppLocalizations.of(context)?.desc_quote_removed ?? "The Quote Status is Unavailable";
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: ListTile(
        leading: Icon(Icons.delete_outline, size: tabSize),
        title: Text(text, style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }

  Widget buildQuote(BuildContext context, Widget quote) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: quote,
      ),
    );
  }
}

class QuotePolicy extends StatelessWidget {
  final QuotePolicyType policy;

  const QuotePolicy({super.key, required this.policy});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 120,
        maxHeight: 48,
      ),
      child: Tooltip(
        message: policy.description(context),
        child: ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          leading: Icon(policy.icon),
          title: Text(policy.title(context)),
        ),
      ),
    );
  }
}

class QuotePolicyTypeSelector extends StatefulWidget {
  final double size;
  final QuotePolicyType? policy;
  final ValueChanged<QuotePolicyType?>? onChanged;

  const QuotePolicyTypeSelector({
    super.key,
    this.size = 32,
    this.policy,
    this.onChanged,
  });

  @override
  State<QuotePolicyTypeSelector> createState() => _QuotePolicyTypeSelectorState();
}

class _QuotePolicyTypeSelectorState extends State<QuotePolicyTypeSelector> {
  late QuotePolicyType policy;

  @override
  void initState() {
    super.initState();
    policy = widget.policy ?? QuotePolicyType.public;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: buildContent(),
    );
  }

  Widget buildContent() {
    return DropdownButtonHideUnderline(
      child: DropdownButton<QuotePolicyType>(
        value: policy,
        padding: const EdgeInsets.all(0),
        borderRadius: BorderRadius.circular(8),
        focusColor: Colors.transparent,
        icon: const SizedBox.shrink(),
        items: QuotePolicyType.values.map((QuotePolicyType value) {
          return DropdownMenuItem<QuotePolicyType>(
            value: value,
            child: QuotePolicy(policy: value),
          );
        }).toList(),
        onChanged: widget.onChanged == null ?
          null :
          (v) {
            setState(() => policy = v ?? policy);
            widget.onChanged?.call(v);
          },
      ),
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
