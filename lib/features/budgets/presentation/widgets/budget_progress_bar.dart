import 'package:flutter/material.dart';

/// Budget progress bar with green/amber/red colouring.
class BudgetProgressBar extends StatelessWidget {
  final double ratio;
  final bool isWarning;
  final bool isExceeded;

  const BudgetProgressBar({
    super.key,
    required this.ratio,
    required this.isWarning,
    required this.isExceeded,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isExceeded
        ? theme.colorScheme.error
        : isWarning
        ? Colors.amber.shade700
        : theme.colorScheme.primary;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio.clamp(0.0, 1.0),
            minHeight: 8,
            color: color,
            backgroundColor: color.withValues(alpha: 0.15),
          ),
        ),
        // Accessible text alternative for the chart
        Semantics(
          label: '${(ratio * 100).toStringAsFixed(0)}% of budget used',
          child: const SizedBox.shrink(),
        ),
      ],
    );
  }
}
