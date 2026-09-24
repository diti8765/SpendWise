import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_format.dart';
import '../data/budget_repository.dart';
import '../domain/budget.dart';
import '../../overview/state/overview_providers.dart';

/// Budgets for the currently selected month.
final budgetsProvider = FutureProvider<List<Budget>>((ref) async {
  final month = ref.watch(monthProvider);
  final monthKey = AppDateFormat.monthKey(month);
  final repo = ref.watch(budgetRepositoryProvider);
  return repo.getBudgets(monthKey);
});
