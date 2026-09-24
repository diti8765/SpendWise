import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/money.dart';
import '../../../core/widgets/async_error_view.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../app/theme.dart';
import '../state/budget_providers.dart';
import '../domain/budget.dart';
import 'widgets/budget_progress_bar.dart';

/// Budget list screen with progress indicators.
class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsAsync = ref.watch(budgetsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets'),
        actions: [
          IconButton(
            tooltip: 'Add budget',
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/budgets/new'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(budgetsProvider),
        child: budgetsAsync.when(
          loading: () => ListView.builder(
            itemCount: 5,
            itemBuilder: (_, __) => const CardSkeleton(height: 80),
          ),
          error: (e, _) => AsyncErrorView(
            error: e,
            onRetry: () => ref.invalidate(budgetsProvider),
          ),
          data: (budgets) {
            if (budgets.isEmpty) {
              return const EmptyState(
                icon: Icons.account_balance_wallet_outlined,
                title: 'No budgets set',
                subtitle: 'Tap + to create a budget for a category',
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: budgets.length,
              itemBuilder: (context, index) {
                final budget = budgets[index];
                return _BudgetCard(
                  budget: budget,
                  onTap: () => context.push('/budgets/${budget.category}'),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  final Budget budget;
  final VoidCallback? onTap;

  const _BudgetCard({required this.budget, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor =
        AppTheme.categoryColors[budget.category] ??
        AppTheme.categoryColors['other']!;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: categoryColor.withValues(alpha: 0.15),
                    radius: 18,
                    child: Icon(Icons.category, color: categoryColor, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      budget.category[0].toUpperCase() +
                          budget.category.substring(1),
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        Money.formatPaise(budget.spentPaise),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'of ${Money.formatPaise(budget.limitPaise)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              BudgetProgressBar(
                ratio: budget.usageRatio,
                isWarning: budget.isWarning,
                isExceeded: budget.isExceeded,
              ),
              const SizedBox(height: 4),
              Text(
                budget.isExceeded
                    ? 'Over budget by ${Money.formatPaise(-budget.remainingPaise)}'
                    : '${Money.formatPaise(budget.remainingPaise)} remaining',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: budget.isExceeded
                      ? theme.colorScheme.error
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
