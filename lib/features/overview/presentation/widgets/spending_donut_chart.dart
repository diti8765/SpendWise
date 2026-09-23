import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/money.dart';

/// Donut chart showing spending by category.
class SpendingDonutChart extends StatelessWidget {
  final Map<String, int> byCategory;
  final int totalPaise;

  const SpendingDonutChart({
    super.key,
    required this.byCategory,
    required this.totalPaise,
  });

  @override
  Widget build(BuildContext context) {
    if (byCategory.isEmpty || totalPaise <= 0) {
      return const Center(child: Text('No spending data'));
    }

    final sections = byCategory.entries.map((entry) {
      final color =
          AppTheme.categoryColors[entry.key] ??
          AppTheme.categoryColors['other']!;
      final percentage = totalPaise > 0
          ? (entry.value / totalPaise * 100)
          : 0.0;

      return PieChartSectionData(
        value: entry.value.toDouble(),
        color: color,
        radius: 40,
        title: percentage >= 5 ? '${percentage.toStringAsFixed(0)}%' : '',
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 50,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Legend
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: byCategory.entries.map((entry) {
              final color =
                  AppTheme.categoryColors[entry.key] ??
                  AppTheme.categoryColors['other']!;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      entry.key,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      Money.formatPaiseCompact(entry.value),
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
