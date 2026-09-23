import '../domain/transaction.dart';
import '../domain/month_summary.dart';
import '../../merchants/domain/merchant_insight.dart';

/// Pure Dart aggregator for expensive calculations.
/// Designed to run on an isolate for large datasets (5000+ transactions).
///
/// This class has NO Flutter dependencies, making it unit-testable
/// and safe for `compute()` / `Isolate.run()`.
class Aggregator {
  const Aggregator();

  /// Computes a month summary from a list of transactions.
  MonthSummary computeSummary({
    required String month,
    required List<Transaction> transactions,
  }) {
    int totalPaise = 0;
    final Map<String, int> byCategory = {};
    final Map<int, int> dayTotals = {};

    for (final t in transactions) {
      totalPaise += t.amountPaise;
      byCategory[t.category.id] =
          (byCategory[t.category.id] ?? 0) + t.amountPaise;
      dayTotals[t.at.day] = (dayTotals[t.at.day] ?? 0) + t.amountPaise;
    }

    // Parse month to get days count
    final parts = month.split('-');
    final year = int.parse(parts[0]);
    final monthNum = int.parse(parts[1]);
    final daysInMonth = DateTime(year, monthNum + 1, 0).day;

    final byDay = List.generate(daysInMonth, (i) => dayTotals[i + 1] ?? 0);

    return MonthSummary(
      month: month,
      totalPaise: totalPaise,
      byCategory: byCategory,
      byDay: byDay,
    );
  }

  /// Computes merchant insights from a list of transactions.
  List<MerchantInsight> computeMerchantInsights(
    List<Transaction> transactions,
  ) {
    final Map<String, _MerchantAccum> accum = {};

    for (final t in transactions) {
      final key = t.merchantName.toLowerCase().trim();
      final entry = accum.putIfAbsent(
        key,
        () => _MerchantAccum(
          merchantName: t.merchantName,
          merchantKey: key,
          categoryId: t.category.id,
        ),
      );
      entry.totalPaise += t.amountPaise;
      entry.count++;
    }

    final insights = accum.values
        .map(
          (a) => MerchantInsight(
            merchantName: a.merchantName,
            merchantKey: a.merchantKey,
            categoryId: a.categoryId,
            totalPaise: a.totalPaise,
            transactionCount: a.count,
          ),
        )
        .toList();

    // Sort by total spent, descending (spec says "sorted by total by default").
    insights.sort((a, b) => b.totalPaise.compareTo(a.totalPaise));
    return insights;
  }

  /// Computes the percentage change between two months.
  /// Returns null if the previous month had zero spending.
  double? computeMonthOverMonthChange({
    required int currentTotalPaise,
    required int previousTotalPaise,
  }) {
    if (previousTotalPaise == 0) return null;
    return ((currentTotalPaise - previousTotalPaise) / previousTotalPaise) *
        100;
  }
}

/// Internal accumulator for merchant aggregation.
class _MerchantAccum {
  final String merchantName;
  final String merchantKey;
  final String categoryId;
  int totalPaise = 0;
  int count = 0;

  _MerchantAccum({
    required this.merchantName,
    required this.merchantKey,
    required this.categoryId,
  });
}
