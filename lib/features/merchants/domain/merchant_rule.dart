/// A rule that maps a merchant to a category.
/// When a user recategorises and chooses "apply to all from this merchant",
/// a MerchantRule is created/updated.
class MerchantRule {
  /// The normalised merchant key (lowercase, trimmed).
  final String merchantKey;

  /// The category ID to assign.
  final String category;

  const MerchantRule({required this.merchantKey, required this.category});

  factory MerchantRule.fromJson(Map<String, dynamic> json) {
    return MerchantRule(
      merchantKey: json['merchantKey'] as String,
      category: json['category'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'merchantKey': merchantKey,
    'category': category,
  };

  MerchantRule copyWith({String? merchantKey, String? category}) {
    return MerchantRule(
      merchantKey: merchantKey ?? this.merchantKey,
      category: category ?? this.category,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MerchantRule &&
          runtimeType == other.runtimeType &&
          merchantKey == other.merchantKey;

  @override
  int get hashCode => merchantKey.hashCode;
}
