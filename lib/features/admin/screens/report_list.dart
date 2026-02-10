// The paginated admin report list with filter (unresolved/all).
import 'package:flutter/material.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';

class AdminReportList extends StatefulWidget {
  final AccessStatusSchema status;

  const AdminReportList({
    super.key,
    required this.status,
  });

  @override
  State<AdminReportList> createState() => _AdminReportListState();
}

class _AdminReportListState extends State<AdminReportList> with PaginatedListMixin {
  List<AdminReportSchema> reports = [];
  bool showResolved = false;

  @override
  void initState() {
    super.initState();
    onLoad();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildFilterChips(),
          buildLoadingIndicator(),
          Flexible(child: buildContent()),
        ],
      ),
    );
  }

  Widget buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          FilterChip(
            label: Text(AppLocalizations.of(context)?.txt_admin_report_unresolved ?? 'Unresolved'),
            selected: !showResolved,
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  showResolved = false;
                  reports.clear();
                });
                resetPagination();
                onLoad();
              }
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: Text(AppLocalizations.of(context)?.txt_admin_report_resolved ?? 'Resolved'),
            selected: showResolved,
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  showResolved = true;
                  reports.clear();
                });
                resetPagination();
                onLoad();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget buildContent() {
    if (reports.isEmpty && !isLoading) {
      return NoResult(
        message: AppLocalizations.of(context)?.txt_admin_no_reports ?? "No reports",
      );
    }

    return ListView.builder(
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final AdminReportSchema report = reports[index];
        return _buildReportTile(report);
      },
    );
  }

  Widget _buildReportTile(AdminReportSchema report) {
    final String reportedBy = AppLocalizations.of(context)?.txt_admin_report_by ?? "Reported by";

    return AdaptiveGlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      onTap: () => context.push(RoutePath.adminReport.path, extra: report),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(report.category.icon, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    report.category.label(context),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                if (report.actionTaken)
                  Chip(
                    label: Text(
                      AppLocalizations.of(context)?.txt_admin_report_resolved ?? 'Resolved',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '@${report.targetAccount.acct}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (report.comment.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  report.comment,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              '$reportedBy @${report.account.acct}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> onLoad() async {
    if (shouldSkipLoad) return;

    setLoading(true);

    final List<AdminReportSchema> newReports = await widget.status.fetchAdminReports(
      resolved: showResolved,
    );

    if (mounted) {
      setState(() => reports.addAll(newReports));
      markLoadComplete(isEmpty: newReports.isEmpty);
    }
  }
}

// vim: set ts=2 sw=2 sts=2 et:
