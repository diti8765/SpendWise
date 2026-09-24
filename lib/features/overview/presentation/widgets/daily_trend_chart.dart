import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Line chart showing daily spending for the month.
class DailyTrendChart extends StatelessWidget {
  final List<int> byDay;

  const DailyTrendChart({super.key, required this.byDay});

  @override
  Widget build(BuildContext context) {
    if (byDay.isEmpty) {
      return const Center(child: Text('No data'));
    }

    final theme = Theme.of(context);
    final maxY = byDay.reduce((a, b) => a > b ? a : b).toDouble();

    final spots = List.generate(byDay.length, (i) {
      return FlSpot(i.toDouble(), byDay[i].toDouble());
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 5,
                getTitlesWidget: (value, meta) {
                  final day = value.toInt() + 1;
                  return Text(
                    '$day',
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minY: 0,
          maxY: maxY > 0 ? maxY * 1.1 : 100.0,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.3,
              color: theme.colorScheme.primary,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
