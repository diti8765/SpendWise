import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/transaction_repository.dart';
import '../domain/transaction.dart';
import '../../filters/domain/filter_state.dart';

/// All available categories.
final categoriesProvider = Provider<List<Category>>((ref) {
  return const [
    Category(id: 'food', name: 'Food', icon: 'restaurant', color: '#FF7043'),
    Category(
      id: 'shopping',
      name: 'Shopping',
      icon: 'shopping_bag',
      color: '#42A5F5',
    ),
    Category(
      id: 'travel',
      name: 'Travel',
      icon: 'directions_car',
      color: '#66BB6A',
    ),
    Category(
      id: 'entertainment',
      name: 'Entertainment',
      icon: 'movie',
      color: '#AB47BC',
    ),
    Category(id: 'bills', name: 'Bills', icon: 'receipt', color: '#EF5350'),
    Category(
      id: 'health',
      name: 'Health',
      icon: 'local_hospital',
      color: '#26C6DA',
    ),
    Category(
      id: 'education',
      name: 'Education',
      icon: 'school',
      color: '#FFCA28',
    ),
    Category(id: 'other', name: 'Other', icon: 'more_horiz', color: '#78909C'),
  ];
});

/// Filter state shared between Feed and other screens.
final filterStateProvider =
    StateNotifierProvider<FilterStateNotifier, FilterState>((ref) {
      return FilterStateNotifier();
    });

class FilterStateNotifier extends StateNotifier<FilterState> {
  FilterStateNotifier() : super(const FilterState());

  void setCategory(String? categoryId) {
    state = state.copyWith(
      categoryId: categoryId,
      clearCategory: categoryId == null,
    );
  }

  void setSearchQuery(String? query) {
    state = state.copyWith(
      searchQuery: query,
      clearSearch: query == null || query.isEmpty,
    );
  }

  void setAmountRange({int? min, int? max}) {
    state = state.copyWith(
      minAmountPaise: min,
      maxAmountPaise: max,
      clearAmount: min == null && max == null,
    );
  }

  void setDateRange({DateTime? start, DateTime? end}) {
    state = state.copyWith(
      startDate: start,
      endDate: end,
      clearDate: start == null && end == null,
    );
  }

  void clearAll() {
    state = const FilterState();
  }
}

/// Feed key combining month + filters for proper family invalidation.
class FeedKey {
  final String month;
  final FilterState filter;
  final String? cursor;

  const FeedKey({required this.month, required this.filter, this.cursor});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeedKey &&
          runtimeType == other.runtimeType &&
          month == other.month &&
          filter == other.filter &&
          cursor == other.cursor;

  @override
  int get hashCode => Object.hash(month, filter, cursor);
}

/// Transaction feed provider — fetches a page of transactions.
final feedProvider = FutureProvider.family<TransactionPage, FeedKey>((
  ref,
  key,
) async {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.getTransactions(
    month: key.month,
    cursor: key.cursor,
    categoryId: key.filter.categoryId,
    searchQuery: key.filter.searchQuery,
    minAmountPaise: key.filter.minAmountPaise,
    maxAmountPaise: key.filter.maxAmountPaise,
    startDate: key.filter.startDate,
    endDate: key.filter.endDate,
  );
});

/// Single transaction detail.
final transactionDetailProvider = FutureProvider.family<Transaction, String>((
  ref,
  id,
) async {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.getTransaction(id);
});
