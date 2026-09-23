/// Aggregated analytics for a single merchant.
class MerchantInsight {
  final String merchantName;
  final String merchantKey;
  final String categoryId;
  final int totalPaise;
  final int transactionCount;

  const MerchantInsight({
    required this.merchantName,
    required this.merchantKey,
    required this.categoryId,
    required this.totalPaise,
    required this.transactionCount,
  });

  /// Average transaction amount in paise.
  int get averagePaise {
    if (transactionCount == 0) return 0;
    return totalPaise ~/ transactionCount;
  }

  factory MerchantInsight.fromJson(Map<String, dynamic> json) {
    return MerchantInsight(
      merchantName: json['merchantName'] as String,
      merchantKey: json['merchantKey'] as String,
      categoryId: json['categoryId'] as String,
      totalPaise: json['totalPaise'] as int,
      transactionCount: json['transactionCount'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'merchantName': merchantName,
    'merchantKey': merchantKey,
    'categoryId': categoryId,
    'totalPaise': totalPaise,
    'transactionCount': transactionCount,
  };
}
