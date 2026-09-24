/// Summary of spending for a single month.
/// Used by the Overview screen for charts and totals.
class MonthSummary {
  /// Month key in 'yyyy-MM' format.
  final String month;

  /// Total spending in paise.
  final int totalPaise;

  /// Spending breakdown by category ID → paise.
  final Map<String, int> byCategory;

  /// Daily spending: index 0 = day 1 of the month.
  /// Each value is total paise spent on that day.
  final List<int> byDay;

  const MonthSummary({
    required this.month,
    required this.totalPaise,
    required this.byCategory,
    required this.byDay,
  });

  factory MonthSummary.fromJson(Map<String, dynamic> json) {
    return MonthSummary(
      month: json['month'] as String,
      totalPaise: json['totalPaise'] as int,
      byCategory: (json['byCategory'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, v as int),
      ),
      byDay: (json['byDay'] as List<dynamic>).cast<int>(),
    );
  }

  Map<String, dynamic> toJson() => {
    'month': month,
    'totalPaise': totalPaise,
    'byCategory': byCategory,
    'byDay': byDay,
  };

  /// Returns an empty summary for the given month.
  factory MonthSummary.empty(String month) {
    return MonthSummary(
      month: month,
      totalPaise: 0,
      byCategory: const {},
      byDay: const [],
    );
  }
}
