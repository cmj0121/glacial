// The report dialog form to report an account.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

enum ReportStep {
  status,   // Select the statuses that are being reported.
  rules,    // Select the rules that are being violated.
  comment;  // Add a comment to the report.
}

class ReportDialog extends ConsumerStatefulWidget {
  final AccountSchema account;
  final StatusSchema status;

  const ReportDialog({
    super.key,
    required this.account,
    required this.status,
  });

  @override
  ConsumerState<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends ConsumerState<ReportDialog> {
  late final AccessStatusSchema? status = ref.read(accessStatusProvider);
  late final ScrollController controller = ScrollController();
  late final PageController pageController = PageController();

  late final List<ReportStep> steps;
  late final List<ReportCategoryType> categories;

  ReportCategoryType? category;
  ReportStep step = ReportStep.status;

  bool isLoading = false;
  bool isCompleted = false;

  late List<StatusSchema> statuses = [];
  late List<String> selectedStatusIDs = [widget.status.id];
  late List<String> selectedRuleIDs = [];
  late String comment = "";

  @override
  void initState() {
    super.initState();

    controller.addListener(onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => onLoad());

    steps = ReportStep.values.where((step) => hasRules || step != ReportStep.rules).toList();
    categories = ReportCategoryType.values.where((type) => hasRules || type != ReportCategoryType.violation).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (status == null) {
      logger.w("No server selected, but it's required to report an account.");
      return const SizedBox.shrink();
    }

    return Dialog(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(animation),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
           );
        },
        child: category == null ? buildCategorySelection() : buildReportForm(),
      ),
    );
  }

  // Build the landing page to select a category for the report.
  Widget buildCategorySelection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: categories.map((ReportCategoryType type) {
          final TextStyle? labelStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          );

          return ListTile(
            leading: Icon(type.icon, size: tabSize),
            title: Text(type.label(context)),
            subtitle: Text(type.tooltip(context), style: labelStyle),
            onTap: () => setState(() => category = type),
          );
        }).toList(),
      ),
    );
  }

  // Build the page like form to select a category and fill out the report details.
  Widget buildReportForm() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Expanded(child: buildReportPage()),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: buildPageIndicator(),
          ),
        ],
      ),
    );
  }

  // Build the form related on the page.
  Widget buildReportPage() {
    final Widget page = PageView(
      controller: pageController,
      onPageChanged: (int index) => setState(() => step = steps[index]),
      children: steps.map((step) {
        switch (step) {
          case ReportStep.status:
            return ListView.builder(
              controller: controller,
              itemCount: statuses.length,
              itemBuilder: (context, index) {
                final StatusSchema status = statuses[index];
                final bool checked = selectedStatusIDs.contains(status.id);

                return Card.outlined(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  color: checked ? Theme.of(context).colorScheme.tertiaryContainer : null,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: IgnorePointer(child: StatusLite(schema: status)),
                      onTap: () => setState(() => checked ?
                        selectedStatusIDs.remove(status.id) :
                        selectedStatusIDs.add(status.id)),
                    ),
                  ),
                );
              }
            );
          case ReportStep.rules:
            return ListView.builder(
              itemCount: status?.server?.rules.length ?? 0,
              itemBuilder: (context, index) {
                final RuleSchema rule = status!.server!.rules[index];
                final bool checked = selectedRuleIDs.contains(rule.id);

                return Card.outlined(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  color: checked ? Theme.of(context).colorScheme.tertiaryContainer : null,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(rule.text),
                      subtitle: Text(rule.hint),
                      selectedColor: checked ? Theme.of(context).colorScheme.primaryContainer : null,
                      onTap: () => setState(() => checked ? selectedRuleIDs.remove(rule.id) : selectedRuleIDs.add(rule.id)),
                    ),
                  ),
                );
              },
            );
          case ReportStep.comment:
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    AppLocalizations.of(context)?.desc_report_comment ?? "Add an optional comment",
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8.0),
                  TextField(
                    maxLines: 10,
                    decoration: InputDecoration(border: const OutlineInputBorder()),
                    onChanged: (String value) => setState(() => comment = value),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.send),
                    label: Text(AppLocalizations.of(context)?.btn_report_file ?? "File Report"),
                    onPressed: onFile,
                  ),
                ],
              ),
            );
        }
      }).toList(),
    );

    return Column(
      children: [
        Text(category!.label(context), style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8.0),
        Text(category!.tooltip(context), style: Theme.of(context).textTheme.bodySmall),
        const Divider(),
        Expanded(child: page),
      ],
    );
  }

  // Build the page indicator for the report form.
  Widget buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: ReportStep.values.map((step) {
        final bool isActive = this.step == step;
        final double size = isActive ? 18.0 : 12.0;
        final Widget child = InkWellDone(
          onTap: () => pageController.animateToPage(
            ReportStep.values.indexOf(step),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          ),
          child: const SizedBox.expand(),
        );

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
            borderRadius: BorderRadius.circular(size),
          ),
          child: child,
        );
      }).toList(),
    );
  }

  // On scroll to the bottom load more statuses for selection.
  void onScroll() async {
    final double loadingThreshold = 200.0;
    if (controller.position.pixels >= controller.position.maxScrollExtent - loadingThreshold) {
      await onLoad();
    }
  }

  // On load the user's statuses for selection.
  Future<void> onLoad() async {
    if (isLoading || isCompleted) {
      return;
    }

    setState(() => isLoading = true);

    final String? maxId = statuses.isEmpty ? null : statuses.last.id;
    final List<StatusSchema>? fetched = await status?.fetchTimeline(TimelineType.user, account: widget.account, maxId: maxId);

    setState(() {
      isLoading = false;
      isCompleted = (fetched?.isEmpty ?? true);
      statuses.addAll(fetched ?? []);
    });
  }

  // File the report to the server.
  Future<void> onFile() async {
    final ReportFileSchema schema = ReportFileSchema(
      accountID: widget.account.id,
      statusIDs: selectedStatusIDs,
      ruleIDs: selectedRuleIDs,
      category: category!,
      comment: comment,
    );

    await status?.report(schema);
    if (mounted) context.pop();
  }

  bool get hasRules => status?.server?.rules.isNotEmpty == true;
}

// vim: set ts=2 sw=2 sts=2 et:
