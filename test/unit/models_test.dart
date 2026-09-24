import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/features/transactions/domain/transaction.dart';
import 'package:spendwise/features/transactions/domain/month_summary.dart';
import 'package:spendwise/features/budgets/domain/budget.dart';
import 'package:spendwise/features/merchants/domain/merchant_rule.dart';
import 'package:spendwise/features/merchants/domain/merchant_insight.dart';

void main() {
  group('Model Serialization', () {
    test('Category fromJson and toJson round-trip', () {
      final json = {
        'id': 'food',
        'name': 'Food & Dining',
        'icon': 'restaurant',
        'color': '#FF7043',
      };
      final cat = Category.fromJson(json);
      expect(cat.id, 'food');
      expect(cat.name, 'Food & Dining');
      expect(cat.toJson(), json);
    });

    test('Transaction fromJson converts UTC to local and stores paise', () {
      final json = {
        'id': 'txn_001',
        'merchantRaw': 'SWIGGY*BANGALORE',
        'merchantName': 'Swiggy',
        'category': {
          'id': 'food',
          'name': 'Food',
          'icon': 'restaurant',
          'color': '#FF7043',
        },
        'amountPaise': 45000,
        'at': '2026-09-23T10:30:00.000Z',
        'mode': 'UPI',
        'description': 'Lunch order',
      };

      final txn = Transaction.fromJson(json);
      expect(txn.id, 'txn_001');
      expect(txn.amountPaise, 45000); // Integer paise maintained
      expect(txn.merchantName, 'Swiggy');
      expect(txn.category.id, 'food');
      expect(txn.description, 'Lunch order');

      // toJson output should have ISO string
      final outputJson = txn.toJson();
      expect(outputJson['amountPaise'], 45000);
      expect(outputJson['at'], isNotEmpty);
    });

    test('Budget fromJson and toJson round-trip', () {
      final json = {
        'category': 'food',
        'month': '2026-09',
        'limitPaise': 1500000,
        'spentPaise': 1200000,
      };
      final budget = Budget.fromJson(json);
      expect(budget.category, 'food');
      expect(budget.limitPaise, 1500000);
      expect(budget.spentPaise, 1200000);
      expect(budget.toJson(), json);
    });

    test('MonthSummary fromJson and toJson round-trip', () {
      final json = {
        'month': '2026-09',
        'totalPaise': 500000,
        'byCategory': {'food': 300000, 'shopping': 200000},
        'byDay': [10000, 20000, 30000],
      };
      final summary = MonthSummary.fromJson(json);
      expect(summary.month, '2026-09');
      expect(summary.totalPaise, 500000);
      expect(summary.byCategory['food'], 300000);
      expect(summary.byDay.length, 3);
      expect(summary.toJson(), json);
    });

    test('MerchantRule fromJson and toJson round-trip', () {
      final json = {'merchantKey': 'swiggy', 'category': 'food'};
      final rule = MerchantRule.fromJson(json);
      expect(rule.merchantKey, 'swiggy');
      expect(rule.category, 'food');
      expect(rule.toJson(), json);
    });

    test('MerchantInsight calculates average correctly', () {
      final json = {
        'merchantName': 'Swiggy',
        'merchantKey': 'swiggy',
        'categoryId': 'food',
        'totalPaise': 450000,
        'transactionCount': 10,
      };
      final insight = MerchantInsight.fromJson(json);
      expect(insight.averagePaise, 45000); // 450000 / 10
      expect(insight.toJson(), json);
    });
  });
}
