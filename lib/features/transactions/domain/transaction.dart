/// Represents a spending category.
class Category {
  final String id;
  final String name;
  final String icon;
  final String color;

  const Category({
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'icon': icon,
    'color': color,
  };

  Category copyWith({String? id, String? name, String? icon, String? color}) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Category($id: $name)';
}

/// Represents a single financial transaction.
/// All money values are in integer paise.
class Transaction {
  final String id;
  final String merchantRaw;
  final String merchantName;
  final Category category;
  final int amountPaise;
  final DateTime at;
  final String mode;
  final String? description;

  const Transaction({
    required this.id,
    required this.merchantRaw,
    required this.merchantName,
    required this.category,
    required this.amountPaise,
    required this.at,
    required this.mode,
    this.description,
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
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'merchantRaw': merchantRaw,
    'merchantName': merchantName,
    'category': category.toJson(),
    'amountPaise': amountPaise,
    'at': at.toUtc().toIso8601String(),
    'mode': mode,
    'description': description,
  };

  Transaction copyWith({
    String? id,
    String? merchantRaw,
    String? merchantName,
    Category? category,
    int? amountPaise,
    DateTime? at,
    String? mode,
    String? description,
  }) {
    return Transaction(
      id: id ?? this.id,
      merchantRaw: merchantRaw ?? this.merchantRaw,
      merchantName: merchantName ?? this.merchantName,
      category: category ?? this.category,
      amountPaise: amountPaise ?? this.amountPaise,
      at: at ?? this.at,
      mode: mode ?? this.mode,
      description: description ?? this.description,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transaction &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
