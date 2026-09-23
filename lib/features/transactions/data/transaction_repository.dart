import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/bank_error.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/network/api_client.dart';
import '../domain/transaction.dart';
import '../domain/month_summary.dart';

/// Provides the [TransactionRepository].
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository(dio: ref.watch(apiClientProvider));
});

/// Response from a paginated transaction feed.
class TransactionPage {
  final List<Transaction> items;
  final String? nextCursor;

  const TransactionPage({required this.items, this.nextCursor});
}

/// Repository for transaction-related API operations.
/// In development, uses in-memory mock data.
class TransactionRepository {
  final Dio _dio;
  final ErrorMapper _errorMapper = const ErrorMapper();
  static const bool _useMock = true;

  TransactionRepository({required Dio dio})
    : _dio = dio; // ignore: prefer_initializing_formals

  /// Fetches a page of transactions.
  Future<TransactionPage> getTransactions({
    required String month,
    String? cursor,
    int limit = 20,
    String? categoryId,
    String? searchQuery,
    int? minAmountPaise,
    int? maxAmountPaise,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (_useMock) {
      return _mockGetTransactions(
        month: month,
        cursor: cursor,
        limit: limit,
        categoryId: categoryId,
        searchQuery: searchQuery,
        minAmountPaise: minAmountPaise,
        maxAmountPaise: maxAmountPaise,
        startDate: startDate,
        endDate: endDate,
      );
    }

    try {
      final response = await _dio.get(
        '/transactions',
        queryParameters: {
          'month': month,
          if (cursor != null) 'cursor': cursor,
          'limit': limit,
          if (categoryId != null) 'category': categoryId,
          if (searchQuery != null && searchQuery.isNotEmpty) 'q': searchQuery,
          if (minAmountPaise != null) 'minAmount': minAmountPaise,
          if (maxAmountPaise != null) 'maxAmount': maxAmountPaise,
          if (startDate != null)
            'startDate': startDate.toUtc().toIso8601String(),
          if (endDate != null) 'endDate': endDate.toUtc().toIso8601String(),
        },
      );

      final data = response.data as Map<String, dynamic>;
      final items = (data['items'] as List)
          .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
          .toList();

      return TransactionPage(
        items: items,
        nextCursor: data['nextCursor'] as String?,
      );
    } on DioException catch (e) {
      throw _errorMapper.mapDioException(e);
    }
  }

  /// Fetches a single transaction by ID.
  Future<Transaction> getTransaction(String id) async {
    if (_useMock) return _mockGetTransaction(id);

    try {
      final response = await _dio.get('/transactions/$id');
      return Transaction.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _errorMapper.mapDioException(e);
    }
  }

  /// Changes the category of a transaction.
  /// If [applyToMerchant] is true, creates a merchant rule.
  Future<Transaction> recategorise({
    required String transactionId,
    required String newCategoryId,
    bool applyToMerchant = false,
  }) async {
    if (_useMock) {
      return _mockRecategorise(
        transactionId: transactionId,
        newCategoryId: newCategoryId,
        applyToMerchant: applyToMerchant,
      );
    }

    try {
      final response = await _dio.patch(
        '/transactions/$transactionId',
        data: {'categoryId': newCategoryId, 'applyToMerchant': applyToMerchant},
      );
      return Transaction.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _errorMapper.mapDioException(e);
    }
  }

  /// Fetches the monthly summary.
  Future<MonthSummary> getSummary(String month) async {
    if (_useMock) return _mockGetSummary(month);

    try {
      final response = await _dio.get(
        '/summary',
        queryParameters: {'month': month},
      );
      return MonthSummary.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _errorMapper.mapDioException(e);
    }
  }

  // ─── Mock implementations ────────────────────────────────────────

  static final List<Transaction> _mockTransactions =
      _generateMockTransactions();

  Future<TransactionPage> _mockGetTransactions({
    required String month,
    String? cursor,
    int limit = 20,
    String? categoryId,
    String? searchQuery,
    int? minAmountPaise,
    int? maxAmountPaise,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    var filtered = _mockTransactions.where((t) {
      final txMonth = '${t.at.year}-${t.at.month.toString().padLeft(2, '0')}';
      if (txMonth != month) return false;
      if (categoryId != null && t.category.id != categoryId) return false;
      if (searchQuery != null &&
          searchQuery.isNotEmpty &&
          !t.merchantName.toLowerCase().contains(searchQuery.toLowerCase())) {
        return false;
      }
      if (minAmountPaise != null && t.amountPaise < minAmountPaise) {
        return false;
      }
      if (maxAmountPaise != null && t.amountPaise > maxAmountPaise) {
        return false;
      }
      if (startDate != null && t.at.isBefore(startDate)) return false;
      if (endDate != null && t.at.isAfter(endDate)) return false;
      return true;
    }).toList();

    // Sort by date descending
    filtered.sort((a, b) => b.at.compareTo(a.at));

    final startIndex = cursor != null ? int.tryParse(cursor) ?? 0 : 0;
    final endIndex = (startIndex + limit).clamp(0, filtered.length);
    final page = filtered.sublist(startIndex, endIndex);
    final hasMore = endIndex < filtered.length;

    return TransactionPage(
      items: page,
      nextCursor: hasMore ? endIndex.toString() : null,
    );
  }

  Future<Transaction> _mockGetTransaction(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _mockTransactions.firstWhere(
      (t) => t.id == id,
      orElse: () =>
          throw const NotFoundError(message: 'Transaction not found.'),
    );
  }

  Future<Transaction> _mockRecategorise({
    required String transactionId,
    required String newCategoryId,
    bool applyToMerchant = false,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final index = _mockTransactions.indexWhere((t) => t.id == transactionId);
    if (index == -1) {
      throw const NotFoundError(message: 'Transaction not found.');
    }

    final newCategory = _mockCategories.firstWhere(
      (c) => c.id == newCategoryId,
      orElse: () => throw const ValidationError(message: 'Invalid category.'),
    );

    final updated = _mockTransactions[index].copyWith(category: newCategory);
    _mockTransactions[index] = updated;

    if (applyToMerchant) {
      // Apply to all transactions from the same merchant.
      final merchantKey = updated.merchantName.toLowerCase().trim();
      for (int i = 0; i < _mockTransactions.length; i++) {
        if (_mockTransactions[i].merchantName.toLowerCase().trim() ==
            merchantKey) {
          _mockTransactions[i] = _mockTransactions[i].copyWith(
            category: newCategory,
          );
        }
      }
    }

    return updated;
  }

  Future<MonthSummary> _mockGetSummary(String month) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final transactions = _mockTransactions.where((t) {
      final txMonth = '${t.at.year}-${t.at.month.toString().padLeft(2, '0')}';
      return txMonth == month;
    }).toList();

    // Calculate totals
    int totalPaise = 0;
    final Map<String, int> byCategory = {};
    final Map<int, int> dayTotals = {};

    for (final t in transactions) {
      totalPaise += t.amountPaise;
      byCategory[t.category.id] =
          (byCategory[t.category.id] ?? 0) + t.amountPaise;
      dayTotals[t.at.day] = (dayTotals[t.at.day] ?? 0) + t.amountPaise;
    }

    // Parse month to get number of days
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
}

// ─── Mock data generation ───────────────────────────────────────

const List<Category> _mockCategories = [
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

const List<String> _mockMerchants = [
  'Swiggy',
  'Zomato',
  'Amazon',
  'Flipkart',
  'Uber',
  'Ola',
  'Netflix',
  'Spotify',
  'BigBasket',
  'DMart',
  'Apollo Pharmacy',
  'BookMyShow',
  'Jio',
  'Airtel',
  'PhonePe',
  'Croma',
  'Myntra',
  'IRCTC',
  'Starbucks',
  'McDonald\'s',
];

const Map<String, String> _merchantCategoryMap = {
  'Swiggy': 'food',
  'Zomato': 'food',
  'Starbucks': 'food',
  'McDonald\'s': 'food',
  'Amazon': 'shopping',
  'Flipkart': 'shopping',
  'Myntra': 'shopping',
  'DMart': 'shopping',
  'Croma': 'shopping',
  'BigBasket': 'shopping',
  'Uber': 'travel',
  'Ola': 'travel',
  'IRCTC': 'travel',
  'Netflix': 'entertainment',
  'Spotify': 'entertainment',
  'BookMyShow': 'entertainment',
  'Jio': 'bills',
  'Airtel': 'bills',
  'Apollo Pharmacy': 'health',
  'PhonePe': 'other',
};

List<Transaction> _generateMockTransactions() {
  final List<Transaction> transactions = [];
  final now = DateTime.now();

  // Generate transactions for the current month and previous month.
  for (int monthOffset = 0; monthOffset < 3; monthOffset++) {
    final month = DateTime(now.year, now.month - monthOffset);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    for (int day = 1; day <= daysInMonth; day++) {
      // 2-4 transactions per day
      final txCount = 2 + (day % 3);
      for (int t = 0; t < txCount; t++) {
        final merchantIndex =
            (day * 3 + t + monthOffset * 7) % _mockMerchants.length;
        final merchant = _mockMerchants[merchantIndex];
        final categoryId = _merchantCategoryMap[merchant] ?? 'other';
        final category = _mockCategories.firstWhere((c) => c.id == categoryId);

        // Amount between 50 and 5000 rupees (in paise)
        final amount =
            ((day * 137 + t * 431 + monthOffset * 29) % 495000) + 5000;

        transactions.add(
          Transaction(
            id: 'txn_${month.year}${month.month.toString().padLeft(2, '0')}_${day}_$t',
            merchantRaw: '${merchant.toUpperCase()}*${1000 + day}',
            merchantName: merchant,
            category: category,
            amountPaise: amount,
            at: DateTime(
              month.year,
              month.month,
              day,
              9 + t * 3,
              (t * 17) % 60,
            ),
            mode: t % 2 == 0 ? 'UPI' : 'Card',
            description: 'Payment to $merchant',
          ),
        );
      }
    }
  }

  // Sort descending by date
  transactions.sort((a, b) => b.at.compareTo(a.at));
  return transactions;
}
