// The announcement bottom sheet for server announcements.
import 'package:flutter/material.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';

// The bottom sheet that displays server announcements.
class AnnouncementSheet extends StatefulWidget {
  final AccessStatusSchema? status;

  const AnnouncementSheet({super.key, required this.status});

  @override
  State<AnnouncementSheet> createState() => _AnnouncementSheetState();
}

class _AnnouncementSheetState extends State<AnnouncementSheet> {
  List<AnnouncementSchema>? announcements;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => onLoad());
  }

  @override
  Widget build(BuildContext context) {
    if (announcements == null) return const ClockProgressIndicator();

    final String title = AppLocalizations.of(context)?.btn_drawer_announcement ?? "Announcements";

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          if (announcements!.isEmpty)
            NoResult(
              message: AppLocalizations.of(context)?.txt_no_announcements ?? "No announcements",
              icon: Icons.campaign_outlined,
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: announcements!.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) => buildAnnouncement(announcements![index]),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildAnnouncement(AnnouncementSchema announcement) {
    final Color? dimColor = announcement.read ? Theme.of(context).colorScheme.outline : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HtmlDone(html: announcement.content),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              announcement.publishedAt.split('T').first,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: dimColor),
            ),
            const Spacer(),
            if (!announcement.read)
              TextButton.icon(
                icon: const Icon(Icons.check, size: 16),
                label: Text(AppLocalizations.of(context)?.btn_dismiss ?? "Dismiss"),
                onPressed: () => onDismiss(announcement.id),
              ),
          ],
        ),
        if (announcement.reactions.isNotEmpty)
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: announcement.reactions.map((r) => buildReaction(announcement.id, r)).toList(),
          ),
      ],
    );
  }

  Widget buildReaction(String announcementId, ReactionSchema reaction) {
    return ActionChip(
      avatar: reaction.url != null
          ? Image.network(reaction.url!, width: 16, height: 16)
          : Text(reaction.name),
      label: Text('${reaction.count}'),
      backgroundColor: reaction.me ? Theme.of(context).colorScheme.primaryContainer : null,
      onPressed: () => onToggleReaction(announcementId, reaction),
    );
  }

  Future<void> onLoad() async {
    final List<AnnouncementSchema>? result = await widget.status?.fetchAnnouncements();
    if (mounted) setState(() => announcements = result ?? []);
  }

  Future<void> onDismiss(String id) async {
    await widget.status?.dismissAnnouncement(id);
    await onLoad();
  }

  Future<void> onToggleReaction(String announcementId, ReactionSchema reaction) async {
    if (reaction.me) {
      await widget.status?.removeAnnouncementReaction(announcementId, reaction.name);
    } else {
      await widget.status?.addAnnouncementReaction(announcementId, reaction.name);
    }
    await onLoad();
  }
}

// vim: set ts=2 sw=2 sts=2 et:
