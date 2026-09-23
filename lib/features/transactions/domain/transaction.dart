class Category {
  final String id;
  final String name;
  final String icon;
  final String color;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
    );
  }
}

class Transaction {
  final String id;
  final String merchantRaw;
  final String merchantName;
  final Category category;
  final int amountPaise;
  final DateTime at;
  final String mode;

  Transaction({
    required this.id,
    required this.merchantRaw,
    required this.merchantName,
    required this.category,
    required this.amountPaise,
    required this.at,
    required this.mode,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      merchantRaw: json['merchantRaw'] as String,
      merchantName: json['merchantName'] as String,
      category: Category.fromJson(json['category'] as Map<String, dynamic>),
      amountPaise: json['amountPaise'] as int,
      at: DateTime.parse(json['at'] as String).toLocal(),
      mode: json['mode'] as String,
    );
  }
}