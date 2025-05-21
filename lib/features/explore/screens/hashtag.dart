// The Trends link that have been shared more than others.
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:glacial/core.dart';
import 'package:glacial/routes.dart';
import 'package:glacial/features/explore/models/hashtag.dart';

// The trends of the links that have been shared more than others.
class HashTag extends StatelessWidget {
  final HashTagSchema schema;

  const HashTag({
    super.key,
    required this.schema,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        child: InkWellDone(
          onTap: () => context.push(RoutePath.hashtagTimeline.path, extra: schema.name),
          child: buildContent(context),
        ),
      ),
    );
  }

  Widget buildContent(BuildContext context) {
    return Row(
    children: [
        Expanded(child: buildTag(context)),
        const Spacer(),
        HistoryLineChart(schemas: schema.history),
      ],
    );
  }

  Widget buildTag(BuildContext context) {
    final int uses = schema.history.map((s) => int.parse(s.uses)).reduce((a, b) => a + b);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '#${schema.name}',
          style: Theme.of(context).textTheme.labelMedium,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Text(
          AppLocalizations.of(context)?.txt_trends_uses(uses) ?? '$uses used in the past days',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ]
    );
  }
}

// Show the History widget as the line chart.
class HistoryLineChart extends StatelessWidget {
  final List<HistorySchema> schemas;
  final double maxHeight;
  final double maxWidth;


  const HistoryLineChart({
    super.key,
    required this.schemas,
    this.maxHeight = 30,
    this.maxWidth = 120,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = Theme.of(context).colorScheme.onSecondary;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight, maxWidth: maxWidth),
      child: buildContent(color),
    );
  }

  Widget buildContent(Color color) {
    final LineChartBarData spots = LineChartBarData(
      spots: schemas.map((schema) {
        return FlSpot(double.parse(schema.day), double.parse(schema.uses),
        );
      }).toList(),
      color: color,
      belowBarData: BarAreaData(show: true, color: color),
      dotData: FlDotData(show: false),
      curveSmoothness: 0,
      barWidth: 1,
    );

    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(show: false),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(enabled: false),
        lineBarsData: [spots],
      ),
    );
  }
}

// vim: set ts=2 sw=2 sts=2 et:
