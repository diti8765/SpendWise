import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/budgets/domain/budget.dart';

/// Provides the [BudgetAlertService] singleton.
final budgetAlertServiceProvider = Provider<BudgetAlertService>((ref) {
  return BudgetAlertService();
});

/// Manages budget threshold alerts.
/// Tracks which alerts have already fired this month to ensure:
/// "At most one alert per category per threshold per month" (spec F5).
class BudgetAlertService {
  // Key format: 'month_category_threshold' e.g. '2026-09_food_80'
  final Set<String> _sentAlerts = {};

  /// Checks a budget and returns an alert message if a threshold was crossed.
  /// Returns null if no alert is needed or if already sent.
  String? checkBudgetAlert(Budget budget) {
    final month = budget.month;
    final category = budget.category;

    // Check 100% threshold first (exceeded)
    if (budget.isExceeded) {
      final key = '${month}_${category}_100';
      if (!_sentAlerts.contains(key)) {
        _sentAlerts.add(key);
        return 'Budget Exceeded: You have exceeded your $category budget!';
      }
      return null;
    }

    // Check 80% threshold (warning)
    if (budget.isWarning) {
      final key = '${month}_${category}_80';
      if (!_sentAlerts.contains(key)) {
        _sentAlerts.add(key);
        return 'Budget Warning: You have reached 80% of your $category budget.';
      }
      return null;
    }

    return null;
  }

  /// Resets sent alerts (for testing or new month).
  void reset() => _sentAlerts.clear();

  /// Checks if an alert was already sent.
  bool wasAlertSent(String month, String category, int threshold) {
    return _sentAlerts.contains('${month}_${category}_$threshold');
  }
}
