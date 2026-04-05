// The list picker: create a list and open per-list timelines.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:glacial/core.dart';
import 'package:glacial/features/extensions.dart';
import 'package:glacial/features/models.dart';

class ListTimelineTab extends ConsumerStatefulWidget {
  const ListTimelineTab({super.key});

  @override
  ConsumerState<ListTimelineTab> createState() => _ListTimelineTabState();
}

class _ListTimelineTabState extends ConsumerState<ListTimelineTab> with TickerProviderStateMixin {
  static const double _maxWidth = 680;

  late final AccessStatusSchema? status = ref.read(accessStatusProvider);
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _loaded = false;
  bool _hasInput = false;
  List<ListSchema> _lists = [];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onInputChange);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onLoad());
  }

  @override
  void dispose() {
    _controller.removeListener(_onInputChange);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onInputChange() {
    final bool next = _controller.text.trim().isNotEmpty;
    if (next != _hasInput) setState(() => _hasInput = next);
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildComposer(),
            Flexible(child: _buildListing()),
          ],
        ),
      ),
    );
  }

  Widget _buildComposer() {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final String hint = AppLocalizations.of(context)?.desc_create_list ?? 'Create a new list';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: hint,
                isDense: true,
                prefixIcon: Icon(Icons.playlist_add_rounded, size: 22, color: scheme.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: scheme.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: scheme.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: scheme.primary, width: 1.5),
                ),
              ),
              onSubmitted: (_) => _onSubmit(),
            ),
          ),
          const SizedBox(width: 10),
          IconButton.filledTonal(
            icon: Icon(Icons.arrow_forward_rounded, size: 20, color: scheme.primary),
            tooltip: AppLocalizations.of(context)?.btn_save ?? 'Save',
            onPressed: _hasInput ? _onSubmit : null,
          ),
        ],
      ),
    );
  }

  Widget _buildListing() {
    if (_lists.isEmpty) {
      if (!_loaded) return const LoadingOverlay(isLoading: true, child: SizedBox.expand());
      final String message = AppLocalizations.of(context)?.txt_no_result ?? 'No results found';
      return NoResult(message: message, icon: Icons.coffee);
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: _lists.length,
      separatorBuilder: (_, _) => Divider(
        height: 1,
        thickness: 1,
        color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
      ),
      itemBuilder: (context, index) {
        final ListSchema schema = _lists[index];
        return AccessibleDismissible(
          dismissKey: ValueKey('list_${schema.id}'),
          direction: DismissDirection.endToStart,
          dismissLabel: AppLocalizations.of(context)?.lbl_swipe_remove,
          background: _buildDeleteBackground(context),
          secondaryBackground: _buildDeleteBackground(context),
          onDismissed: (_) => _onRemove(index),
          child: _ListRow(
            schema: schema,
            onTap: () => context.push(RoutePath.listItem.path, extra: schema),
          ),
        );
      },
    );
  }

  Widget _buildDeleteBackground(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: scheme.errorContainer,
      child: Icon(Icons.delete_forever_rounded, color: scheme.onErrorContainer, size: 24),
    );
  }

  Future<void> _onSubmit() async {
    final String name = _controller.text.trim();
    if (name.isEmpty) return;
    await status?.createList(title: name);
    _controller.clear();
    _focusNode.unfocus();
    _onLoad();
  }

  Future<void> _onLoad() async {
    final List<ListSchema> lists = await status?.getLists() ?? [];
    if (mounted) {
      setState(() {
        _lists = lists;
        _loaded = true;
      });
    }
  }

  Future<void> _onRemove(int index) async {
    if (index < 0 || index >= _lists.length) return;
    final String id = _lists[index].id;
    await status?.deleteList(id);
    if (mounted) setState(() => _lists.removeAt(index));
  }
}

class _ListRow extends StatelessWidget {
  final ListSchema schema;
  final VoidCallback onTap;

  const _ListRow({required this.schema, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final String exclusiveLabel = schema.exclusive
        ? AppLocalizations.of(context)?.txt_list_short_exclusive ?? 'Exclusive'
        : AppLocalizations.of(context)?.txt_list_short_inclusive ?? 'Inclusive';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.format_list_bulleted_rounded, size: 20, color: scheme.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    schema.title,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  DefaultTextStyle(
                    style: theme.textTheme.bodySmall!.copyWith(color: scheme.onSurfaceVariant),
                    child: Row(
                      children: [
                        _MetaBadge(icon: schema.replyPolicy.icon, label: schema.replyPolicy.label(context)),
                        const SizedBox(width: 12),
                        _MetaBadge(
                          icon: schema.exclusive ? Icons.remove_circle_outline : Icons.check_circle_outline,
                          label: exclusiveLabel,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, size: 20, color: scheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _MetaBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: scheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
