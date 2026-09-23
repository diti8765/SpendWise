import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/utils/money.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/widgets/async_error_view.dart';
import '../../../core/widgets/skeleton.dart';
import '../state/overview_providers.dart';
import '../../../features/auth/state/auth_provider.dart';
import 'widgets/spending_donut_chart.dart';
import 'widgets/daily_trend_chart.dart';
import 'widgets/budget_summary_card.dart';
import 'widgets/recent_transactions_list.dart';
import '../../transactions/presentation/widgets/add_expense_sheet.dart';

/// Main dashboard showing monthly spending overview.
class OverviewScreen extends ConsumerWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(monthProvider);
    final summaryAsync = ref.watch(currentSummaryProvider);
    final prevSummaryAsync = ref.watch(previousSummaryProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SpendWise'),
        actions: [
          IconButton(
            tooltip: 'Add Expense',
            icon: const Icon(Icons.add),
            onPressed: () {
              showModalBottomSheet<bool>(
                context: context,
                isScrollControlled: true,
                builder: (_) => const AddExpenseSheet(),
              );
            },
          ),
          IconButton(
            tooltip: 'Log out',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) context.go(AppRoutes.login);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(currentSummaryProvider);
          ref.invalidate(previousSummaryProvider);
          ref.invalidate(recentTransactionsProvider);
          ref.invalidate(currentBudgetsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            // Month switcher
            _MonthSwitcher(month: month, ref: ref),

            // Total spending card
            summaryAsync.when(
              loading: () => const CardSkeleton(height: 100),
              error: (e, _) => AsyncErrorView(
                error: e,
                onRetry: () => ref.invalidate(currentSummaryProvider),
              ),
              data: (summary) {
                final prevTotal = prevSummaryAsync.valueOrNull?.totalPaise;
                return _TotalSpendingCard(
                  totalPaise: summary.totalPaise,
                  previousTotalPaise: prevTotal,
                );
              },
            ),

            const SizedBox(height: 16),

            // Category donut chart
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('By Category', style: theme.textTheme.titleMedium),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 220,
              child: summaryAsync.when(
                loading: () => const CardSkeleton(height: 200),
                error: (e, _) => AsyncErrorView(
                  error: e,
                  onRetry: () => ref.invalidate(currentSummaryProvider),
                ),
                data: (summary) => SpendingDonutChart(
                  byCategory: summary.byCategory,
                  totalPaise: summary.totalPaise,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Daily trend line chart
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Daily Spending', style: theme.textTheme.titleMedium),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 180,
              child: summaryAsync.when(
                loading: () => const CardSkeleton(height: 160),
                error: (e, _) => const SizedBox.shrink(),
                data: (summary) => DailyTrendChart(byDay: summary.byDay),
              ),
            ),

            const SizedBox(height: 16),

            // Budget summary
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Budgets', style: theme.textTheme.titleMedium),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.budgets),
                    child: const Text('View All'),
                  ),
                ],
              ),
            ),
            const BudgetSummaryCard(),

            const SizedBox(height: 16),

            // Recent transactions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Transactions',
                    style: theme.textTheme.titleMedium,
                  ),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.transactions),
                    child: const Text('View All'),
                  ),
                ],
              ),
            ),
            const RecentTransactionsList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'overview_add_expense_fab',
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
        onPressed: () {
          showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            builder: (_) => const AddExpenseSheet(),
          );
        },
      ),
    );
  }
}

class _MonthSwitcher extends StatelessWidget {
  final DateTime month;
  final WidgetRef ref;

  const _MonthSwitcher({required this.month, required this.ref});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            tooltip: 'Previous month',
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              ref.read(monthProvider.notifier).state =
                  AppDateFormat.previousMonth(month);
            },
          ),
          Text(
            AppDateFormat.monthYear(month),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            tooltip: 'Next month',
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              final nextMonth = AppDateFormat.nextMonth(month);
              if (nextMonth.isBefore(DateTime.now()) ||
                  nextMonth.month == DateTime.now().month) {
                ref.read(monthProvider.notifier).state = nextMonth;
              }
            },
          ),
        ],
      ),
    );
  }
}

class _TotalSpendingCard extends StatelessWidget {
  final int totalPaise;
  final int? previousTotalPaise;

  const _TotalSpendingCard({required this.totalPaise, this.previousTotalPaise});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String? changeText;
    Color? changeColor;

    if (previousTotalPaise != null && previousTotalPaise! > 0) {
      final change =
          ((totalPaise - previousTotalPaise!) / previousTotalPaise!) * 100;
      final isUp = change > 0;
      changeText =
          '${isUp ? '+' : ''}${change.toStringAsFixed(1)}% vs last month';
      changeColor = isUp ? theme.colorScheme.error : Colors.green;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Spending',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              Money.formatPaise(totalPaise),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (changeText != null) ...[
              const SizedBox(height: 4),
              Text(
                changeText,
                style: theme.textTheme.bodySmall?.copyWith(color: changeColor),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
