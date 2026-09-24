import 'package:flutter/foundation.dart';

/// Immutable filter state shared across screens.
/// Filters are combinable and survive navigation.
@immutable
class FilterState {
  final String? categoryId;
  final String? searchQuery;
  final int? minAmountPaise;
  final int? maxAmountPaise;
  final DateTime? startDate;
  final DateTime? endDate;

  const FilterState({
    this.categoryId,
    this.searchQuery,
    this.minAmountPaise,
    this.maxAmountPaise,
    this.startDate,
    this.endDate,
  });

  /// Whether any filter is active.
  bool get isActive =>
      categoryId != null ||
      (searchQuery != null && searchQuery!.isNotEmpty) ||
      minAmountPaise != null ||
      maxAmountPaise != null ||
      startDate != null ||
      endDate != null;

  /// Number of active filters (for badge count).
  int get activeCount {
    int count = 0;
    if (categoryId != null) count++;
    if (searchQuery != null && searchQuery!.isNotEmpty) count++;
    if (minAmountPaise != null || maxAmountPaise != null) count++;
    if (startDate != null || endDate != null) count++;
    return count;
  }

  FilterState copyWith({
    String? categoryId,
    String? searchQuery,
    int? minAmountPaise,
    int? maxAmountPaise,
    DateTime? startDate,
    DateTime? endDate,
    bool clearCategory = false,
    bool clearSearch = false,
    bool clearAmount = false,
    bool clearDate = false,
  }) {
    return FilterState(
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
      minAmountPaise: clearAmount
          ? null
          : (minAmountPaise ?? this.minAmountPaise),
      maxAmountPaise: clearAmount
          ? null
          : (maxAmountPaise ?? this.maxAmountPaise),
      startDate: clearDate ? null : (startDate ?? this.startDate),
      endDate: clearDate ? null : (endDate ?? this.endDate),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilterState &&
          runtimeType == other.runtimeType &&
          categoryId == other.categoryId &&
          searchQuery == other.searchQuery &&
          minAmountPaise == other.minAmountPaise &&
          maxAmountPaise == other.maxAmountPaise &&
          startDate == other.startDate &&
          endDate == other.endDate;

  @override
  int get hashCode => Object.hash(
    categoryId,
    searchQuery,
    minAmountPaise,
    maxAmountPaise,
    startDate,
    endDate,
  );

  /// Returns a cleared filter state.
  static const FilterState empty = FilterState();
}
