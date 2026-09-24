import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/money.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../state/overview_providers.dart';

/// Compact budget summary shown on the overview screen.
class BudgetSummaryCard extends ConsumerWidget {
  const BudgetSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsAsync = ref.watch(currentBudgetsProvider);
    final theme = Theme.of(context);

    return budgetsAsync.when(
      loading: () => const CardSkeleton(height: 80),
      error: (_, __) => const SizedBox.shrink(),
      data: (budgets) {
        if (budgets.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No budgets set for this month',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        }

        return SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: budgets.length,
            itemBuilder: (context, index) {
              final budget = budgets[index];
              final progress = budget.usageRatio.clamp(0.0, 1.5);
              final color = budget.isExceeded
                  ? theme.colorScheme.error
                  : budget.isWarning
                  ? Colors.amber
                  : theme.colorScheme.primary;

              return SizedBox(
                width: 160,
                child: Card(
                  margin: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => context.push('/budgets/${budget.category}'),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            budget.category,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          LinearProgressIndicator(
                            value: progress.clamp(0.0, 1.0),
                            color: color,
                            backgroundColor: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${Money.formatPaiseCompact(budget.spentPaise)} / ${Money.formatPaiseCompact(budget.limitPaise)}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
