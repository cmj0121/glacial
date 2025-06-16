// The Trends link that have been shared more than others.
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:glacial/features/models.dart';

// Show the History widget as the line chart.
class HistoryLineChart extends StatelessWidget {
  final List<HistorySchema> schemas;
  final double maxHeight;
  final double maxWidth;

  const HistoryLineChart({
    super.key,
    required this.schemas,
    this.maxHeight = 30,
    this.maxWidth = 80,
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
