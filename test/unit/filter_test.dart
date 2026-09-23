import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/features/filters/domain/filter_state.dart';

void main() {
  group('FilterState', () {
    test('empty state is not active', () {
      const filter = FilterState.empty;
      expect(filter.isActive, isFalse);
      expect(filter.activeCount, 0);
    });

    test('single filter activates state and counts correctly', () {
      const filter = FilterState(categoryId: 'food');
      expect(filter.isActive, isTrue);
      expect(filter.activeCount, 1);
    });

    test('combining filters increments activeCount', () {
      final filter = FilterState(
        categoryId: 'food',
        searchQuery: 'Swiggy',
        minAmountPaise: 10000,
        startDate: DateTime(2026, 9, 1),
        endDate: DateTime(2026, 9, 15),
      );
      expect(filter.isActive, isTrue);
      expect(filter.activeCount, 4); // cat + search + amount + date
    });

    test('copyWith clear flags reset individual filters', () {
      const filter = FilterState(categoryId: 'food', searchQuery: 'Swiggy');

      final clearedCategory = filter.copyWith(clearCategory: true);
      expect(clearedCategory.categoryId, isNull);
      expect(clearedCategory.searchQuery, 'Swiggy');

      final clearedSearch = filter.copyWith(clearSearch: true);
      expect(clearedSearch.categoryId, 'food');
      expect(clearedSearch.searchQuery, isNull);
    });
  });
}
