// The admin report detail with moderation actions.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';
import 'package:glacial/features/screens.dart';

class AdminReportDetail extends ConsumerStatefulWidget {
  final AdminReportSchema schema;

  const AdminReportDetail({
    super.key,
    required this.schema,
  });

  @override
  ConsumerState<AdminReportDetail> createState() => _AdminReportDetailState();
}

class _AdminReportDetailState extends ConsumerState<AdminReportDetail> {
  late final AccessStatusSchema? status = ref.read(accessStatusProvider);
  late AdminReportSchema report = widget.schema;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const Divider(),
          _buildTargetAccount(),
          const Divider(),
          if (report.comment.isNotEmpty) ...[
            _buildComment(),
            const Divider(),
          ],
          if (report.statuses.isNotEmpty) ...[
            _buildStatuses(),
            const Divider(),
          ],
          if (report.rules.isNotEmpty) ...[
            _buildRules(),
            const Divider(),
          ],
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final String reportedBy = AppLocalizations.of(context)?.txt_admin_report_by ?? "Reported by";
    final String assignedTo = AppLocalizations.of(context)?.txt_admin_assigned_to ?? "Assigned to";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(report.category.icon, size: 24),
            const SizedBox(width: 8),
            Text(report.category.label(context), style: Theme.of(context).textTheme.headlineSmall),
            const Spacer(),
            if (report.actionTaken)
              Chip(
                label: Text(AppLocalizations.of(context)?.txt_admin_report_resolved ?? 'Resolved'),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text('$reportedBy @${report.account.acct}', style: Theme.of(context).textTheme.bodyMedium),
        if (report.assignedAccount != null)
          Text('$assignedTo @${report.assignedAccount!.acct}', style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildTargetAccount() {
    return InkWellDone(
      onTap: () => context.push(RoutePath.profile.path, extra: report.targetAccount),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Account(schema: report.targetAccount),
      ),
    );
  }

  Widget _buildComment() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(report.comment, style: Theme.of(context).textTheme.bodyMedium),
    );
  }

  Widget _buildStatuses() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: report.statuses.map((status) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: StatusLite(schema: status),
        );
      }).toList(),
    );
  }

  Widget _buildRules() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: report.rules.map((rule) {
        return ListTile(
          leading: const Icon(Icons.rule, size: 20),
          title: Text(rule.text),
          subtitle: Text(rule.hint),
        );
      }).toList(),
    );
  }

  Widget _buildActions() {
    final List<AdminActionType> actions = report.actionTaken
        ? [AdminActionType.reopen]
        : [
            if (report.assignedAccount == null) AdminActionType.assignToSelf,
            if (report.assignedAccount != null) AdminActionType.unassign,
            AdminActionType.resolve,
          ];

    return Wrap(
      spacing: 8.0,
      children: actions.map((action) {
        return ElevatedButton.icon(
          icon: Icon(action.icon),
          label: Text(action.label(context)),
          style: action.isDangerous
              ? ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
                  foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
                )
              : null,
          onPressed: () => _onAction(action),
        );
      }).toList(),
    );
  }

  Future<void> _onAction(AdminActionType action) async {
    if (status == null) return;

    late AdminReportSchema updated;

    switch (action) {
      case AdminActionType.assignToSelf:
        updated = await status!.assignReportToSelf(report.id);
        break;
      case AdminActionType.unassign:
        updated = await status!.unassignReport(report.id);
        break;
      case AdminActionType.resolve:
        updated = await status!.resolveReport(report.id);
        break;
      case AdminActionType.reopen:
        updated = await status!.reopenReport(report.id);
        break;
      default:
        return;
    }

    if (mounted) {
      setState(() => report = updated);
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
