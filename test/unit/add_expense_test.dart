import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/features/transactions/data/transaction_repository.dart';
import 'package:spendwise/features/transactions/domain/transaction.dart';
import 'package:spendwise/features/budgets/data/budget_repository.dart';
import 'package:spendwise/features/budgets/domain/budget.dart';
import 'package:spendwise/core/notifications/budget_alert_service.dart';
import 'package:spendwise/core/utils/date_format.dart';

void main() {
  group('Add Expense & Budget Tracking Flow', () {
    late TransactionRepository transactionRepo;
    late BudgetRepository budgetRepo;
    late BudgetAlertService alertService;

    setUp(() {
      final dio = Dio();
      transactionRepo = TransactionRepository(dio: dio);
      budgetRepo = BudgetRepository(dio: dio);
      alertService = BudgetAlertService();
    });

    test('addTransaction inserts new expense and makes it queryable', () async {
      final now = DateTime.now();
      final monthKey = AppDateFormat.monthKey(now);

      const category = Category(
        id: 'food',
        name: 'Food',
        icon: 'restaurant',
        color: '#FF7043',
      );

      final newExpense = Transaction(
        id: 'test_expense_101',
        merchantRaw: 'NEW CAFE*101',
        merchantName: 'New Cafe',
        category: category,
        amountPaise: 45000, // ₹450.00
        at: now,
        mode: 'UPI',
        description: 'Coffee and snacks',
      );

      final saved = await transactionRepo.addTransaction(newExpense);
      expect(saved.id, equals('test_expense_101'));
      expect(saved.amountPaise, equals(45000));
      expect(saved.merchantName, equals('New Cafe'));

      // Verify it appears in getTransactions
      final page = await transactionRepo.getTransactions(
        month: monthKey,
        limit: 100,
      );
      expect(page.items.any((t) => t.id == 'test_expense_101'), isTrue);
    });

    test('recordExpense increments spentPaise and triggers alert if threshold exceeded', () async {
      final now = DateTime.now();
      final monthKey = AppDateFormat.monthKey(now);

      // Set a test budget of ₹1,000 (100,000 paise) with ₹750 spent (75,000 paise)
      final initialBudget = Budget(
        category: 'test_category',
        month: monthKey,
        limitPaise: 100000,
        spentPaise: 75000,
      );
      await budgetRepo.setBudget(initialBudget);

      // Record an expense of ₹100 (10,000 paise) -> pushes spending to ₹850 (85%)
      final updated = await budgetRepo.recordExpense(
        category: 'test_category',
        month: monthKey,
        amountPaise: 10000,
      );

      expect(updated, isNotNull);
      expect(updated!.spentPaise, equals(85000));
      expect(updated.isWarning, isTrue); // 85% >= 80%

      // Check alert service
      final alert = alertService.checkBudgetAlert(updated);
      expect(alert, isNotNull);
      expect(alert, contains('80%'));
    });
  });
}
