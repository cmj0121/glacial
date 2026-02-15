// Skeleton placeholder widgets for loading states.
import 'package:flutter/material.dart';

import 'package:glacial/cores/screens/shimmer.dart';

/// A skeleton placeholder card mirroring the StatusLite layout.
class SkeletonStatusCard extends StatelessWidget {
  final bool showMedia;

  const SkeletonStatusCard({
    super.key,
    this.showMedia = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = Theme.of(context).colorScheme.surfaceContainerHighest;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outline)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(color),
          const SizedBox(height: 12),
          _buildContentLines(color),
          if (showMedia) ...[
            const SizedBox(height: 12),
            _buildMediaPlaceholder(color),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(Color color) {
    return Row(
      children: [
        // Avatar placeholder (48px, borderRadius: 8)
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name line
              Container(width: 120, height: 14, color: color),
              const SizedBox(height: 6),
              // Handle line
              Container(width: 80, height: 12, color: color),
            ],
          ),
        ),
        // Timestamp placeholder
        Container(width: 40, height: 10, color: color),
      ],
    );
  }

  Widget _buildContentLines(Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: double.infinity, height: 12, color: color),
          const SizedBox(height: 8),
          Container(width: double.infinity, height: 12, color: color),
          const SizedBox(height: 8),
          Container(width: 160, height: 12, color: color),
        ],
      ),
    );
  }

  Widget _buildMediaPlaceholder(Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 60),
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

/// A list of skeleton cards wrapped in a shimmer effect.
class SkeletonTimeline extends StatelessWidget {
  final int count;

  const SkeletonTimeline({
    super.key,
    this.count = 4,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: List.generate(count, (index) {
            return SkeletonStatusCard(showMedia: index == 1);
          }),
        ),
      ),
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
