/// Represents a monthly budget for a category.
/// All money values are in integer paise.
class Budget {
  final String category;
  final String month; // 'yyyy-MM' format
  final int limitPaise;
  final int spentPaise;

  const Budget({
    required this.category,
    required this.month,
    required this.limitPaise,
    required this.spentPaise,
  });

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      category: json['category'] as String,
      month: json['month'] as String,
      limitPaise: json['limitPaise'] as int,
      spentPaise: json['spentPaise'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'category': category,
    'month': month,
    'limitPaise': limitPaise,
    'spentPaise': spentPaise,
  };

  Budget copyWith({
    String? category,
    String? month,
    int? limitPaise,
    int? spentPaise,
  }) {
    return Budget(
      category: category ?? this.category,
      month: month ?? this.month,
      limitPaise: limitPaise ?? this.limitPaise,
      spentPaise: spentPaise ?? this.spentPaise,
    );
  }

  /// Remaining budget in paise. Can be negative if exceeded.
  int get remainingPaise => limitPaise - spentPaise;

  /// Usage percentage (0.0 to 1.0+). Can exceed 1.0 if over budget.
  double get usageRatio {
    if (limitPaise == 0) return 0;
    return spentPaise / limitPaise;
  }

  /// Whether spending has reached 80% of the budget (amber warning).
  bool get isWarning => usageRatio >= 0.8 && usageRatio < 1.0;

  /// Whether spending has exceeded the budget (red).
  bool get isExceeded => usageRatio >= 1.0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Budget &&
          runtimeType == other.runtimeType &&
          category == other.category &&
          month == other.month;

  @override
  int get hashCode => Object.hash(category, month);
}
