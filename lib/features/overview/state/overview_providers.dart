import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../transactions/data/transaction_repository.dart';
import '../../transactions/domain/month_summary.dart';
import '../../transactions/domain/transaction.dart';
import '../../budgets/data/budget_repository.dart';
import '../../budgets/domain/budget.dart';
import '../../../core/utils/date_format.dart';

/// The currently selected month.
final monthProvider = StateProvider<DateTime>((ref) => DateTime.now());

/// Summary data for the selected month.
final summaryProvider = FutureProvider.family<MonthSummary, String>((
  ref,
  month,
) async {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.getSummary(month);
});

/// Summary for the current selected month (convenience).
final currentSummaryProvider = FutureProvider<MonthSummary>((ref) async {
  final month = ref.watch(monthProvider);
  final monthKey = AppDateFormat.monthKey(month);
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.getSummary(monthKey);
});

/// Previous month summary for comparison.
final previousSummaryProvider = FutureProvider<MonthSummary>((ref) async {
  final month = ref.watch(monthProvider);
  final prevMonth = AppDateFormat.previousMonth(month);
  final monthKey = AppDateFormat.monthKey(prevMonth);
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.getSummary(monthKey);
});

/// Recent transactions (first page of current month).
final recentTransactionsProvider = FutureProvider<List<Transaction>>((
  ref,
) async {
  final month = ref.watch(monthProvider);
  final monthKey = AppDateFormat.monthKey(month);
  final repo = ref.watch(transactionRepositoryProvider);
  final page = await repo.getTransactions(month: monthKey, limit: 5);
  return page.items;
});

/// Budgets for the current month.
final currentBudgetsProvider = FutureProvider<List<Budget>>((ref) async {
  final month = ref.watch(monthProvider);
  final monthKey = AppDateFormat.monthKey(month);
  final repo = ref.watch(budgetRepositoryProvider);
  return repo.getBudgets(monthKey);
});
