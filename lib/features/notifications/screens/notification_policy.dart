// Bottom sheet for configuring notification filtering policy.
import 'package:flutter/material.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';

// Bottom sheet for configuring notification filtering policy.
class NotificationPolicySheet extends StatefulWidget {
  final AccessStatusSchema? status;

  const NotificationPolicySheet({super.key, required this.status});

  @override
  State<NotificationPolicySheet> createState() => _NotificationPolicySheetState();
}

class _NotificationPolicySheetState extends State<NotificationPolicySheet> {
  NotificationPolicySchema? policy;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => onLoad());
  }

  @override
  Widget build(BuildContext context) {
    final String title = AppLocalizations.of(context)?.txt_notification_policy ?? "Notification Policy";

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          if (policy == null)
            const Center(child: Padding(padding: EdgeInsets.all(32), child: ClockProgressIndicator()))
          else ...[
          buildRow(
            label: AppLocalizations.of(context)?.txt_notification_policy_not_following ?? "People you don't follow",
            value: policy!.forNotFollowing,
            onChanged: (v) => onUpdate(policy!.copyWith(forNotFollowing: v)),
          ),
          buildRow(
            label: AppLocalizations.of(context)?.txt_notification_policy_not_followers ?? "People not following you",
            value: policy!.forNotFollowers,
            onChanged: (v) => onUpdate(policy!.copyWith(forNotFollowers: v)),
          ),
          buildRow(
            label: AppLocalizations.of(context)?.txt_notification_policy_new_accounts ?? "New accounts",
            value: policy!.forNewAccounts,
            onChanged: (v) => onUpdate(policy!.copyWith(forNewAccounts: v)),
          ),
          buildRow(
            label: AppLocalizations.of(context)?.txt_notification_policy_private_mentions ?? "Private mentions",
            value: policy!.forPrivateMentions,
            onChanged: (v) => onUpdate(policy!.copyWith(forPrivateMentions: v)),
          ),
          buildRow(
            label: AppLocalizations.of(context)?.txt_notification_policy_limited_accounts ?? "Moderated accounts",
            value: policy!.forLimitedAccounts,
            onChanged: (v) => onUpdate(policy!.copyWith(forLimitedAccounts: v)),
          ),
          ],
        ],
      ),
    );
  }

  Widget buildRow({
    required String label,
    required NotificationPolicyValue value,
    required void Function(NotificationPolicyValue) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
          const SizedBox(width: 8),
          SegmentedButton<NotificationPolicyValue>(
            segments: NotificationPolicyValue.values.map((v) => ButtonSegment(
              value: v,
              icon: Icon(v.icon, size: 16),
              tooltip: v.tooltip(context),
            )).toList(),
            selected: {value},
            onSelectionChanged: (s) => onChanged(s.first),
            showSelectedIcon: false,
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> onLoad() async {
    final NotificationPolicySchema? result = await widget.status?.getNotificationPolicy();
    if (mounted) setState(() => policy = result);
  }

  Future<void> onUpdate(NotificationPolicySchema updated) async {
    setState(() => policy = updated);
    await widget.status?.updateNotificationPolicy(updated);
  }
}

// vim: set ts=2 sw=2 sts=2 et:
