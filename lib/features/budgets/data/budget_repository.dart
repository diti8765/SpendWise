import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/bank_error.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/network/api_client.dart';
import '../domain/budget.dart';

/// Provides the [BudgetRepository].
final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository(dio: ref.watch(apiClientProvider));
});

/// Repository for budget-related API operations.
class BudgetRepository {
  final Dio _dio;
  final ErrorMapper _errorMapper = const ErrorMapper();
  static const bool _useMock = true;

  BudgetRepository({required Dio dio})
    : _dio = dio; // ignore: prefer_initializing_formals

  /// Fetches all budgets for the given month.
  Future<List<Budget>> getBudgets(String month) async {
    if (_useMock) return _mockGetBudgets(month);

    try {
      final response = await _dio.get(
        '/budgets',
        queryParameters: {'month': month},
      );
      final items = response.data as List;
      return items
          .map((e) => Budget.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _errorMapper.mapDioException(e);
    }
  }

  /// Creates or updates a budget for a category in the given month.
  Future<Budget> setBudget(Budget budget) async {
    if (_useMock) return _mockSetBudget(budget);

    try {
      final response = await _dio.put(
        '/budgets',
        queryParameters: {'month': budget.month},
        data: budget.toJson(),
      );
      return Budget.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _errorMapper.mapDioException(e);
    }
  }

  /// Deletes a budget.
  Future<void> deleteBudget({
    required String category,
    required String month,
  }) async {
    if (_useMock) {
      _mockBudgets.removeWhere(
        (b) => b.category == category && b.month == month,
      );
      return;
    }

    try {
      await _dio.delete(
        '/budgets/$category',
        queryParameters: {'month': month},
      );
    } on DioException catch (e) {
      throw _errorMapper.mapDioException(e);
    }
  }

  /// Records an expense against a budget in the given month, updating spentPaise.
  Future<Budget?> recordExpense({
    required String category,
    required String month,
    required int amountPaise,
  }) async {
    if (_useMock) {
      final index = _mockBudgets.indexWhere(
        (b) => b.category == category && b.month == month,
      );
      if (index >= 0) {
        final current = _mockBudgets[index];
        final updated = current.copyWith(
          spentPaise: current.spentPaise + amountPaise,
        );
        _mockBudgets[index] = updated;
        return updated;
      }
      return null;
    }

    try {
      final budgets = await getBudgets(month);
      for (final b in budgets) {
        if (b.category == category) {
          final updated = b.copyWith(spentPaise: b.spentPaise + amountPaise);
          return await setBudget(updated);
        }
      }
      return null;
    } on DioException catch (e) {
      throw _errorMapper.mapDioException(e);
    }
  }

  // ─── Mock implementation ──────────────────────────────────────

  static final List<Budget> _mockBudgets = _generateMockBudgets();

  Future<List<Budget>> _mockGetBudgets(String month) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _mockBudgets.where((b) => b.month == month).toList();
  }

  Future<Budget> _mockSetBudget(Budget budget) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    if (budget.limitPaise <= 0) {
      throw const ValidationError(
        message: 'Budget amount must be greater than zero.',
      );
    }

    final index = _mockBudgets.indexWhere(
      (b) => b.category == budget.category && b.month == budget.month,
    );

    if (index >= 0) {
      _mockBudgets[index] = budget;
    } else {
      _mockBudgets.add(budget);
    }

    return budget;
  }
}

List<Budget> _generateMockBudgets() {
  final now = DateTime.now();
  final month = '${now.year}-${now.month.toString().padLeft(2, '0')}';

  return [
    Budget(
      category: 'food',
      month: month,
      limitPaise: 1500000,
      spentPaise: 1200000,
    ),
    Budget(
      category: 'shopping',
      month: month,
      limitPaise: 2000000,
      spentPaise: 1800000,
    ),
    Budget(
      category: 'travel',
      month: month,
      limitPaise: 500000,
      spentPaise: 200000,
    ),
    Budget(
      category: 'entertainment',
      month: month,
      limitPaise: 300000,
      spentPaise: 310000,
    ),
    Budget(
      category: 'bills',
      month: month,
      limitPaise: 1000000,
      spentPaise: 850000,
    ),
  ];
}
